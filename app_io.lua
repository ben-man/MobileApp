local M = {}

local json = require( "json" )
local sqlite3 = require( "sqlite3" )
local lfs = require( "lfs" )

local settings = {initComplete = false}
local statusFlags = {
  CORE = 0,
  USER = 1
}
local docsDir = system.DocumentsDirectory
local resourceDir = system.ResourceDirectory
local dbPath = system.pathForFile( "data.db", docsDir )
local docsPath = system.pathForFile( nil, docsDir )
local resourcePath = system.pathForFile( nil, resourceDir )
local db
local currentScenario

local function copyFile( srcPath, dstPath )
    -- io.open opens a file at path; returns nil if no file found
    local srcFile, srcError = io.open( srcPath, "rb" )
    assert( srcFile, srcError )

    local dstFile, dstError = io.open( dstPath, "wb" )
    assert( dstFile, dstError )

    local data = assert( srcFile:read( "*a" ), "copyFile: read failed" )
    assert( dstFile:write( data ), "copyFile: write failed" )

    io.close( srcFile )
    io.close( dstFile )
    return true
end

--save table t in json format as path
local function json_saveTable( t, path )

    local file, errorString = io.open( path, "w" )

    if not ( file ) then
        print( "json_saveTable: File error: " .. errorString )
        return nil
    else
        file:write( json.encode( t ) )
        io.close( file )
        return true
    end
end

--load table from json format file at path
local function json_loadTable( path )

    local file = io.open( path, "r" )

    if not file then
        return nil
    else
        local contents = file:read( "*a" )
        local t = json.decode( contents )
        io.close( file )
        return t
    end
end

local function closeDatabase()
  print( "Closing database...")
  if ( db and db:isopen() ) then
    db:close()
  end
end

M.closeDatabase = closeDatabase

function M.getSettings()
  return settings
end

local function saveSettings()
  json_saveTable( settings, system.pathForFile( "settings.json", docsDir ) )
end

M.saveSettings = saveSettings

local function setField( key, value )
  settings[key] = value
  saveSettings()
end

local function getField( key )
  return settings[key]
end

local function initDirectories()

  assert( lfs.chdir( docsPath ), "chdir failed" )

  local path = docsPath .. "/resources"
  if not ( lfs.chdir( path ) ) then
    --docsPath/resources doesn't exist
    assert( lfs.mkdir( "resources" ), "Couldn't create 'resources' directory in docsPath" )
    assert( lfs.chdir( path ), "chdir failed" )
  end

  path = path .. "/img"
  if not ( lfs.chdir( path ) ) then
    --docsPath/resources/img doesn't exist
    assert( lfs.mkdir( "img" ), "Couldn't create 'img' directory in docsPath/resources" )
    assert( lfs.chdir( path ), "chdir failed" )
  end

  path = path .. "/cards"
  if not ( lfs.chdir( path ) ) then
    --docsPath/resources/img/cards doesn't exist
    assert( lfs.mkdir( "cards" ), "Couldn't create 'cards' directory in docsPath/resources/img" )
  end

  local dstImagesPath = docsPath .. "/resources/img/cards"
  local srcImagesPath = resourcePath .. "/resources/img/cards"

  local imageList = io.open( resourcePath .. "/images.txt", "r" )
  assert( imageList, "Could not open images.txt" )

  for filename in imageList:lines() do
    local srcPath = srcImagesPath .. "/" .. filename
    local dstPath = dstImagesPath .. "/" .. filename

    copyFile( srcPath, dstPath )
  end

  io.close( imageList )

  return true
end

function M.getImagePath( imageName )
  local path = "resources/img/cards/" .. imageName
  return path
end

function M.getScenarios( difficulty )

  local cmd = [[
    SELECT id, name, difficulty, status FROM scenarios
  ]]
--[[
  if ( difficulty ) then
    cmd = cmd .. " WHERE difficulty = " .. difficulty
  end

  cmd = cmd .. " ORDER BY name"
]]
  local i = 0
  local scenarios = {}
  for row in db:nrows( cmd ) do
    i = i + 1
    scenarios[i] = row
  end

  if ( i > 0 ) then
    return scenarios
  else
    print( "getScenarios: no scenarios found" )
    return nil
  end
end

local function loadScenario( id )

  local s

  for row in db:nrows( "SELECT * FROM scenarios WHERE id = " .. id ) do
    s = row
  end

  if not ( s ) then
    print( "loadScenario: no scenario selected")
    return nil
  end

  if ( s.descriptionBox ) then
    s.descriptionBox = json.decode( s.descriptionBox )
  end
  s.cards = json.decode( s.cards )
  s.targets = json.decode( s.targets )
  s.arrows = json.decode( s.arrows )

--[=[
  s.pictures = {}
  local count = #s.cards
  local slots = {}

  for i = 1, count do
    slots[i] = i
  end

  local n = count
  for i = 1, count do
    local c = s.cards[i]
    local r = math.random( n )
    s.pictures[slots[r]] = {
      path = system.pathForFile( "images/" .. c.picture , docsDir ),
      cardIndex = i
    }
    table.remove( slots, r )
    n = n - 1
  end
]=]
  currentScenario = s
  setField( "scenarioId", s.id )
  return s
end

M.loadScenario = loadScenario

 
function M.loadImages()

  local s = {}

  for row in db:nrows( "SELECT * FROM pictures"  ) do
    --s = row 
    s[#s+1] =
    {
        id = row.id,
        filename = row.filename
    }
  end

  
  return s

end


function M.deleteImage( param )

   print (param)
   local cmd = "DELETE from pictures WHERE id = " .. param  
   local res = db:exec( cmd ) 

end


function M.loadScenarios()

  local s = {}

  for row in db:nrows( "SELECT * FROM scenarios " ) do
    s[#s+1] =
    {
        id = row.id,
        difficulty = row.difficulty,
        name = row.name
    }
  end
 
  return s

end


function M.deleteScenario ( param )

   print (param)
   local cmd = "DELETE from scenarios WHERE id = " .. param  
   local res = db:exec( cmd ) 

end


local function loadNextScenario()

  if not ( currentScenario ) then

    --Restore the current scenario
    local id = getField( "scenarioId" )

    if ( id ) then
      return loadScenario( id )
    end

    --Otherwise, load the first scenario
    local cmd = "SELECT id FROM scenarios ORDER BY id"

    for row in db:nrows( cmd ) do
      --currentScenario = row
      return loadScenario( row.id )
    end

    --We shouldn't reach this point
    error( "No scenario found" )
  else
    --load the next scenario
    local cmd = "SELECT id FROM scenarios WHERE id > " .. currentScenario.id .. " ORDER BY id"

    for row in db:nrows( cmd ) do
      return loadScenario( row.id )
    end

    --No scenarios left; you win
    currentScenario = nil
    return nil
  end
end

M.loadNextScenario = loadNextScenario

function M.getCurrentScenario()
  return currentScenario
end

local function insertScenario( s, flag )

  if ( s.difficulty <= -6 ) then
    s.difficulty = 0
  elseif ( s.difficulty <= -4 ) then
    s.difficulty = 1
  elseif ( s.difficulty <= -3 ) then
    s.difficulty = 2
  else
    s.difficulty = 3
  end

  local function checkString( str )
    if not ( str ) then
      return ""
    end

    if ( string.find( str, "\'" ) ) then
      return string.gsub( str, "\'", "\'\'" )
    end

    return str
  end

  local cmd = [[
    INSERT INTO scenarios(name, difficulty, description, credits, descriptionBox, cards, targets, arrows, status) VALUES(
      ']] .. checkString( s.name ) .. [[',
      ]] .. s.difficulty .. [[,
      ']] .. checkString( s.description ) .. [[',
      ']] .. checkString( s.credits ) .. [[',
      ']] .. checkString( json.encode( s.descriptionBox ) ) .. [[',
      ']] .. checkString( json.encode( s.cards ) ) .. [[',
      ']] .. checkString( json.encode( s.targets ) ) .. [[',
      ']] .. checkString( json.encode( s.arrows ) ) .. [[',
      ]] .. flag .. [[
    );
  ]]

  local res = db:exec( cmd )
  if not ( res == sqlite3.OK) then
    print( cmd )
    error( "exec failed...(" .. res .. ")" )
  end

  return true
end

function M.scanScenarios()

  local scenarios = json_loadTable( system.pathForFile( "scenarios.json", resourceDir ) )
  assert( scenarios, "scanScenarios: Could not load scenarios.json" )

  local xMin = scenarios[1].targets[1].x
  local yMin = scenarios[1].targets[1].y
  local xMax = 0
  local yMax = 0

  local count = #scenarios
  for scenarioIndex = 1, count do
     local s = scenarios[scenarioIndex]
     
     for targetIndex = 1, #s.targets do
        local t = s.targets[targetIndex]
        if ( t.x < xMin ) then
          xMin = t.x
        end
        if ( t.x > xMax ) then
          xMax = t.x
        end
        if ( t.y < yMin ) then
          yMin = t.y
        end
        if ( t.y > yMax ) then
          yMax = t.y
        end
      end

    for cardIndex = 1, #s.cards do
      local c = s.cards[cardIndex]
      if ( c.name ~= c.spriteSrc ) then
        print( "scenario: " .. scenarioIndex .. " card: " .. cardIndex .. " name: " .. c.name .. " spriteSrc: " .. c.spriteSrc)
      end
    end

  end

  print( "xMin: " .. xMin )
  print( "xMax: " .. xMax )
  print( "yMin: " .. yMin )
  print( "yMax: " .. yMax )
end

local function initScenariosTable()

  local scenarios = json_loadTable( system.pathForFile( "scenarios.json", resourceDir ) )
  assert( scenarios, "initScenariosTable: Could not load scenarios.json" )

  local count = #scenarios
  for i = 1, count do
	   insertScenario( scenarios[i], statusFlags.CORE )
  end

  return true
end

local function initPicturesTable( count )

  local dstImagesPath = docsPath .. "/resources/img/cards"
  local srcImagesPath = resourcePath .. "/resources/img/cards"

  local imageList = io.open( resourcePath .. "/images.txt", "r" )
  assert( imageList, "Could not open images.txt" )

  for filename in imageList:lines() do
    local srcPath = srcImagesPath .. "/" .. filename
    local dstPath = dstImagesPath .. "/" .. filename

    copyFile( srcPath, dstPath )

    local cmd = [[
      INSERT INTO pictures(filename, status) VALUES(
        ']] .. filename .. [[',
        ]] .. statusFlags.CORE .. [[
      );
    ]]
    local res = db:exec( cmd )
    assert ( res == sqlite3.OK, "initImages: failed to insert row for" .. filename )
  end

  io.close( imageList )
  return true
end

function M.buildDatabase()

  if ( settings.initComplete ) then
    return nil
  end

  local dbHandle = io.open( dbPath, "r" )
  if( dbHandle ) then
    print("Deleting existing database...")
    io.close( dbHandle )
    os.remove( dbPath )
  end

  print("Building database...")
  db = assert( sqlite3.open( dbPath ), "Failed to open database..." )

  local cmd = [[
    CREATE TABLE scenarios(
      id INTEGER PRIMARY KEY,
      name,
      difficulty INTEGER,
      description,
      credits,
      descriptionBox,
      cards,
      targets,
      arrows,
      status
    );
    CREATE TABLE pictures(
      id INTEGER PRIMARY KEY,
      filename,
      status
    );
  ]]
  local res = db:exec( cmd )
  if not ( res == sqlite3.OK ) then
    error( "buildDatabase: exec failed...(" .. res .. ")" )
  end

  initPicturesTable()
  initScenariosTable()

  print( "Finished building database...")
  return true
end

function M.printScenario( s )
  print( "id: " .. s.id )
  print( "name: " .. s.name )
  print( "difficulty: " .. s.difficulty )
  print( "description: " .. s.description )
  print( "credits: " .. s.credits )
  print( "descriptionBox: " .. json.encode( s.descriptionBox ) )
  print( "cards: " .. json.encode( s.cards ) )
  print( "targets: " .. json.encode( s.targets ) )
  print( "arrows: " .. json.encode( s.arrows ) )
  print( "status: " .. s.status )
end

--function M.init()
  local t = json_loadTable( system.pathForFile( "settings.json", docsDir ) )
  if ( t and type(t) == "table" ) then
    settings = t
  end

  if not ( settings.initComplete ) then
    initDirectories()
    copyFile( system.pathForFile( "data.db", resourceDir ), dbPath )
    settings.initComplete = true
    saveSettings()
  end

  db = assert( sqlite3.open( dbPath ), "Failed to open database..." )
  loadNextScenario()
--end

return M
