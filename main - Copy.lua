-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local app_io = require( "app_io" )
local app_event = require( "app_event" )

--[[
app_io.initDatabase()
local scenarios = app_io.getScenarios( 0 )
if ( #scenarios > 0 ) then
  local s = app_io.loadScenario( scenarios[1].id )
end
]]

app_io.printScenario( app_io.getCurrentScenario() )

local composer = require ("composer")
composer.gotoScene("homepage", "fade", 500)


