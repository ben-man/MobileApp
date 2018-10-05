local M = {}

local json = require( "json" )
local sqlite3 = require( "sqlite3" )

local docsDir = system.DocumentsDirectory
local dbPath = system.pathForFile( "data.db", docsDir )

local db = sqlite3.open( dbPath )

function M.openDatabase()
  local cmd = [[
    CREATE TABLE IF NOT EXISTS scenarios ( scenario_id INTEGER PRIMARY KEY autoincrement, scenario_name, scenario_difficulty INTEGER NOT NULL, scenario_text, scenario_credit, scenario_status );
    CREATE TABLE IF NOT EXISTS pictures ( picture_id INTEGER PRIMARY KEY autoincrement, picture_filename );
    CREATE TABLE IF NOT EXISTS cards ( scenario_id INTEGER NOT NULL references scenarios(scenario_id), card_number INTEGER NOT NULL, picture_id INTEGER NOT NULL references pictures(picture_id), card_label, primary key (scenario_id, card_number) );
  ]]
  db:exec( cmd )
end

function M.closeDatabase()
  if ( db and db:isopen() ) then
    db:close()
  end
end

return M
