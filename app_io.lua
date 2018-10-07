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

function M.openDatabase()

end

local function closeDatabase()
  if ( db and db:isopen() ) then
    db:close()
  end
end

M.closeDatabase = closeDatabase

--initImages() is called only if the pictures table is empty
local function initImages()

  local dstImagesPath
  if not ( lfs.chdir( docsPath ) ) then
    return nil
  else
    dstImagesPath = lfs.currentdir() .. "/images"
    if not ( lfs.chdir( dstImagesPath ) ) then
      --docsPath/images doesn't exist. Create it.
      if not ( lfs.mkdir( "images" ) ) then
        --Couldn't create docsPath/images.
        return nil
      end
    end
  end

  local srcImagesPath
  if not ( lfs.chdir( resourcePath ) ) then
    --There should be an images directory in the ResourceDirectory
    return nil
  else
    srcImagesPath = lfs.currentdir() .. "/images"
  end

  for filename in lfs.dir( srcImagesPath ) do
    local srcPath = system.pathForFile( filename, srcImagesPath )
    local dstPath = system.pathForFile( filename, dstImagesPath )

    local srcFile = io.open( srcPath, "rb" )
    if not ( srcFile ) then
      return nil
    end

    local dstFile = io.open( dstPath, "wb" )
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
      INSERT INTO pictures(picture_filename) VALUES(']] .. filename .. [[');
    ]]
    local res = db:exec( cmd )
    if not ( res == sqlite3.OK ) then
      return nil
    end
  end

end

function M.initDatabase()

  if ( db ) then
    local cmd = [[
      CREATE TABLE IF NOT EXISTS scenarios(
        scenario_id INTEGER PRIMARY KEY,
        scenario_name,
        scenario_difficulty INTEGER NOT NULL,
        scenario_text,
        scenario_credit,
        scenario_status
      );
      CREATE TABLE IF NOT EXISTS pictures(
        picture_id INTEGER PRIMARY KEY,
        picture_filename
      );
      CREATE TABLE IF NOT EXISTS cards(
        scenario_id INTEGER NOT NULL REFERENCES scenarios(scenario_id),
        card_number INTEGER NOT NULL,
        picture_id INTEGER NOT NULL REFERENCES pictures(picture_id),
        card_label,
        PRIMARY KEY(scenario_id, card_number)
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
        res = initImages()
        if not ( res ) then
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
