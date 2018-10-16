local M = {}

local app_io = require( "app_io" )

local function onSystemEvent( event )
    if ( event.type == "applicationExit" ) then
      app_io.closeDatabase()
    end
end

Runtime:addEventListener( "system", onSystemEvent )

return M
