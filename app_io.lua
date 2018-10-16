local M = {}

local json = require( "json" )
local sqlite3 = require( "sqlite3" )
local lfs = require( "lfs" )
local MultipartFormData = require("multipartForm")

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

local function copyFile( srcPath, dstPath )
    -- io.open opens a file at path; returns nil if no file found
    local srcFile, srcError = io.open( srcPath, "rb" )
    assert( srcFile, "copyFile: " .. srcError )

    local dstFile, dstError = io.open( dstPath, "wb" )
    assert( dstFile, "copyFile: " .. dstError )

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

local function initDirectories()

  if not ( lfs.chdir( docsPath ) ) then
    return nil
  end

  local path = docsPath .. "/resources"
  if not ( lfs.chdir( path ) ) then
    --docsPath/resources doesn't exist
    if not ( lfs.mkdir( "resources" ) ) then
      print( "Couldn't create 'resources' directory in docsPath" )
      return nil
    end
    if not ( lfs.chdir( path ) ) then
      return nil
    end
  end

  path = path .. "/img"
  if not ( lfs.chdir( path ) ) then
    --docsPath/resources/img doesn't exist
    if not ( lfs.mkdir( "img" ) ) then
      print( "Couldn't create 'img' directory in docsPath/resources" )
      return nil
    end
    if not ( lfs.chdir( path ) ) then
      return nil
    end
  end

  path = path .. "/cards"
  if not ( lfs.chdir( path ) ) then
    --docsPath/resources/img/cards doesn't exist
    if not ( lfs.mkdir( "cards" ) ) then
      print( "Couldn't create 'cards' directory in docsPath/resources/img" )
      return nil
    end
  end

  return true
end

function M.getScenarios( difficulty )

  local cmd = [[
    SELECT id, name, difficulty, description, credits, status FROM scenarios
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

function M.loadScenario( id )

  local s
  for row in db:nrows( "SELECT * FROM scenarios WHERE id = " .. id ) do
    s = row
  end

  if not ( s ) then
    print( "loadScenario: no scenario selected")
    return nil
  end

  s.cards = json.decode( s.cards )
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

  return s
end

function M.getContent()

  local i = 0
  local scenarios = {}

  local pics = {}

  local imageList = io.open( resourcePath .. "/images.txt", "r" )
  if not ( imageList ) then
    return nil
  end

  for filename in imageList:lines() do
    pics[filename] = true
  end

  io.close( imageList )

  local function downloadListener( event )
    if ( event.isError ) then
        print( "getContent: downloadListener: Network error - download failed: ", event.response )
    elseif ( event.phase == "ended" ) then
        print( "Downloaded: " .. event.response.filename )
    end
  end

  local function networkListener( event )

    if ( event.isError ) then
      print( "getContent: networkListener: Network error: ", event.response )
    else

      if ( event.response == "EOF" ) then
        --no scenarios left
        print( "getContent: networkListener: EOF" )
        json_saveTable( scenarios, system.pathForFile( "scenarios.json", docsDir ) )
        print( "getContent: done" )
      elseif ( event.response == "Failure!" ) then
        --failed to get next scenario
        print( "getContent: networkListener: Failure!" )
      else
        i = i + 1
        --print ( "RESPONSE[" .. i .. "]: " .. event.response )
        local s = json.decode( event.response )

        if not ( s ) then
          print( "getContent: json decode failed" )
          return
        end

        if not ( type( s ) == "table" ) then
          print( "getContent: response decoded to a " .. type( s ) )
          print( "RESPONSE: " .. event.response )
          json_saveTable( scenarios, system.pathForFile( "scenarios.json", docsDir ) )
          print( "getContent: done" )
          return
        end

        if ( s.name and type( s.name ) == "string" and s.cards and type( s.cards ) == "table") then
          scenarios[i] = s

          local count = #s.cards
          for i = 1, count do
            local c = s.cards[i]
            if not ( pics[c.spriteSrc] ) then
              local img = c.spriteSrc
              if ( string.find( img, " " ) ) then
                img = string.gsub( img, " ", "%%20" )
              end
              network.download(
                "http://www.privacygames.com/resources/img/cards/" .. img,
                "GET",
                downloadListener,
                {progress = false},
                "resources/img/cards/" .. c.spriteSrc,
                docsDir
              )
              pics[c.spriteSrc] = true
            end
          end

          local multipart = MultipartFormData.new()
          multipart:addField( "name", s.name )
          local params = {}
          params.body = multipart:getBody()
          params.headers = multipart:getHeaders()

          timer.performWithDelay( 5000, function()
            print( "body[" .. i .. "]: " .. params.body )
            network.request( "http://www.privacygames.com/getnextscenario.php", "POST", networkListener, params )
            end
          )
        end
      end
    end
  end

  local multipart = MultipartFormData.new()
  local params = {}
  params.body = multipart:getBody()
  params.headers = multipart:getHeaders()
  print( "body: " .. params.body )
  network.request( "http://www.privacygames.com/getnextscenario.php", "POST", networkListener, params )
end

local function insertScenario( s, flag )

  local cmd = [[
    INSERT INTO scenarios(name, difficulty, description, credits, descriptionBox, cards, targets, arrows, status) VALUES(
      ']] .. s.name .. [[',
      ]] .. s.difficulty .. [[,
      ']] .. s.description .. [[',
      ']] .. s.credits .. [[',
      ']] .. json.encode( s.descriptionBox ) .. [[',
      ']] .. json.encode( s.cards ) .. [[',
      ']] .. json.encode( s.targets ) .. [[',
      ']] .. json.encode( s.arrows ) .. [['
      ]] .. flag .. [[
    );
  ]]

  local res = db:exec( cmd )
  assert( res == sqlite3.OK, "insertScenario: bad exec (" .. cmd .. ")" )

  return true
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
  assert( imageList, "initImages: could not open images.txt" )

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

  print("Building database...")

  db = assert( sqlite3.open( dbPath ), "buildDatabase: Failed to open database..." )

  local cmd = [[
    CREATE TABLE scenarios(
      id INTEGER PRIMARY KEY,
      name,
      difficulty INTEGER NOT NULL,
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
  assert( res == sqlite3.OK, "buildDatabase: exec failed..." )

  initPicturesTable()
  initScenariosTable()

  print( "Finished building database...")
  return true
end

function M.init()
  local t = json_loadTable( system.pathForFile( "settings.json", docsDir ) )
  if ( t and type(t) == "table" ) then
    settings = t
  end

  if not ( settings.initComplete ) then
    assert( initDirectories(), "app_io: initDirectories failed..." )
    copyFile( system.pathForFile( "data.db", resourceDir ), dbPath )
    settings.initComplete = true
    saveSettings()
  end

  db = assert( sqlite3.open( dbPath ), "Failed to open database..." )
end

return M
