local M = {}

local json = require( "json" )
local sqlite3 = require( "sqlite3" )
local lfs = require( "lfs" )

local docsDir = system.DocumentsDirectory
local resourceDir = system.ResourceDirectory
local dbPath = system.pathForFile( "data.db", docsDir )
local docsPath = system.pathForFile( nil, docsDir )
local resourcePath = system.pathForFile( nil, resourceDir )

local db = sqlite3.open( dbPath )

local function loadTable( filename )

    local path = system.pathForFile( filename, resourceDir )
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
  if ( db and db:isopen() ) then
    db:close()
  end
end

M.closeDatabase = closeDatabase

local dstImagesPath = docsPath .. "/images"
local srcImagesPath = resourcePath .. "/images"

--initImages() is called only if the pictures table is empty
local function initImages()

  if not ( lfs.chdir( dstImagesPath ) ) then
    --docsPath/images doesn't exist. Create it.
    if not ( lfs.chdir( docsPath ) ) then
      return nil
    end

    if not ( lfs.mkdir( "images" ) ) then
      --Couldn't create docsPath/images.
      return nil
    end
  end

  local imageList = io.open( resourcePath .. "/images.txt", "r" )
  if not ( imageList ) then
    return nil
  end

  for filename in imageList:lines() do
    local srcFile = io.open( srcImagesPath .. "/" .. filename, "rb" )
    if not ( srcFile ) then
      return nil
    end

    local dstFile = io.open( dstImagesPath .. "/" .. filename, "wb" )
    if not ( dstFile ) then
      return nil
    end

    local data = srcFile:read( "*a" )
    if not ( data ) then
      return nil
    else
      if not ( dstFile:write( data ) ) then
        return nil
      end
    end

    srcFile:close()
    dstFile:close()

    local cmd = [[
      INSERT INTO pictures(filename) VALUES(']] .. filename .. [[');
    ]]
    local res = db:exec( cmd )
    if not ( res == sqlite3.OK ) then
      return nil
    end
  end

  io.close( imageList )

  return true
end

function M.getScenarios( difficulty )

  local cmd = [[
    SELECT id, name, difficulty, text, credit, status FROM scenarios
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

local function saveScenario( s )

  local cmd = [[
    INSERT INTO scenarios(name, difficulty, text, credit, status, cards) VALUES(
      ']] .. s.name .. [[',
      ]] .. s.difficulty .. [[,
      ']] .. s.text .. [[',
      ']] .. s.credit .. [[',
      ]] .. s.status .. [[,
      ']] .. json.encode( s.cards ) .. [['
    );
  ]]

  local res = db:exec( cmd )
  if not ( res == sqlite3.OK ) then
    print( "cmd: " .. cmd )
    print( "Failed to insert scenario (error code: " .. res .. ")")
    return nil
  end

  local id = db:last_insert_rowid()
  s.id = id
  return id
end

--initScenarios() is called only if the scenarios table is empty
local function initScenarios()

  local scenarios = loadTable( "scenarios.json" )
  if not ( scenarios ) then
    return nil
  end

  local count = #scenarios
  for i = 1, count do
	   saveScenario( scenarios[i] )
  end

  return true
end

function M.initDatabase()

  if ( db ) then
    local cmd = [[
      CREATE TABLE IF NOT EXISTS scenarios(
        id INTEGER PRIMARY KEY,
        name,
        difficulty INTEGER NOT NULL,
        text,
        credit,
        status,
        cards
      );
      CREATE TABLE IF NOT EXISTS pictures(
        id INTEGER PRIMARY KEY,
        filename
      );
    ]]
    local res = db:exec( cmd )
    if not ( res == sqlite3.OK ) then
      --exec failed
      closeDatabase()
      return nil
    end

    local col = "count(*)"
    for row in db:nrows( "SELECT " .. col .. " FROM pictures" ) do
      if ( row[col] == 0 ) then

        if not ( initImages() ) then
          closeDatabase()
          return nil
        end
      end
    end

    for row in db:nrows( "SELECT " .. col .. " FROM scenarios" ) do
      if ( row[col] == 0 ) then
        if not ( initScenarios() ) then
          closeDatabase()
          return nil
        end
      end
    end

  else
    --could not open database
    return nil
  end
end

return M
