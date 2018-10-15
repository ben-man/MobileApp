local M = {}

local json = require( "json" )
local sqlite3 = require( "sqlite3" )
local lfs = require( "lfs" )
local MultipartFormData = require("multipartForm")

local settings = {currentScenario = ""}
local docsDir = system.DocumentsDirectory
local resourceDir = system.ResourceDirectory
local dbPath = system.pathForFile( "data.db", docsDir )
local docsPath = system.pathForFile( nil, docsDir )
local resourcePath = system.pathForFile( nil, resourceDir )

local db = sqlite3.open( dbPath )

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
  if ( db and db:isopen() ) then
    db:close()
  end
end

M.closeDatabase = closeDatabase

--initImages() is called only if the pictures table is empty
local function initImages()

  local dstImagesPath = docsPath .. "/images"
  local srcImagesPath = resourcePath .. "/images"

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

function M.init()

  local t = json_loadTable( system.pathForFile( "settings.json", docsDir ) )
  if ( t ) then
    settings = t
  end

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

  local scenarios = json_loadTable( system.pathForFile( "scenarios.json", resourceDir ) )
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
