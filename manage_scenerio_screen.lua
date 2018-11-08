---------------------------------------------------------------------------------
--
-- scene1.lua
--
---------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- INCLUDE REQUIRED LIBRARIES
-- ----------------------------------------------------------------------------  

local composer = require( "composer" )
local scene = composer.newScene() 
local widget = require("widget") -- for status label
local app_io = require( "app_io" )
 

-- ----------------------------------------------------------------------------
-- INITIALIZE VALUES
-- ----------------------------------------------------------------------------
local font = "HelveticaNeue" or system.nativeFont
local userid = nil
local password = nil 
local _W = display.contentWidth
local _H = display.contentHeight

local image, text1, text2, text3, memTimer

local background = display.newRect(0, 0, 0, 0)

local labelUsername,labelPassword,frmUsername,frmPassword,eventButton,tableView

 

-- ----------------------------------------------------------------------------
-- HANDLE BUTTON PRESS
-- ----------------------------------------------------------------------------
-- Button event listener function
 
 



local function onRowRender( event )
  local row        = event.row
  local rowHeight  = row.contentHeight
  local rowWidth   = row.contentWidth
  local name      = row.params.name
  local leftIcon   = row.params.leftIcon or nil
  local rightIcon  = row.params.rightIcon or nil
  local titleColor = row.params.titleColor or {0,0,0}


  local options = {
      parent   = row,
      text     = name,    
      x        = 20,
      y        = rowHeight * .5,
      width    = rowWidth,
      font     = native.systemFont,   
      fontSize = 10,
      align    = 'left'
  }
 
 
	local myImage = display.newText( options)
  myImage.anchorX = 0
  myImage:setFillColor( titleColor )
  row:insert(myImage)
  
local function buttonEvent( event )

        local options = {
         effect = "fade",
         time = 20,
         params = { id = row.params.id }
       }
        
        composer.gotoScene( "play_screen", options ) 
     
    
    return true
  end

  local function buttonEvent2( event )
      
      app_io.deleteImage(row.params.id)

      tableView:deleteRows( { row.id } )
     
    
    return true
  end
 

    local eventButton = widget.newButton(
  {
    label = 'Delete', 
    shape = "rectangle",
    x = 365,
    y = rowHeight * .5,
    width = 60,
    height = 25,
    font = appFont,
    fontSize = 12,
    fillColor = { default={ 0.1,0.3,0.6,1 }, over={ 0.1,0.3,0.6,1 } },
    labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
    onRelease = buttonEvent,
  })
    row:insert(  eventButton )

end


local function onRowTouch(event)
  local row   = event.target
  local phase = event.phase

  if phase == 'release' then
    --row.params._group:hide(0.001)
    --row.params.action()
  end

  return true
end


local function createTable( options, width, height, group )
  
  local tableView = widget.newTableView{
      x = 50,
      y = 50,
      width  = width,
      height = height,
      hideBackground = false,
      rowTouchDelay = 0,
      onRowRender = onRowRender,
      onRowTouch = onRowTouch
  }

  for i=1, #options  do 
      local option = options[i]
      option._group = group
      tableView:insertRow{
        rowHeight  = 54,
        isCategory = false,
        params = option
      }
  end

  return tableView
end


-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view

	image = display.newRect(0, 0, 0, 0) 
	image.x = display.contentCenterX
	image.y = display.contentCenterY
	

	sceneGroup:insert( image ) 
 
	local s = app_io.loadScenarios() 
 

   tableView = createTable( s, 400, 280, sceneGroup )
   tableView.anchorY = 0
   tableView.anchorX = 0
   sceneGroup:insert( tableView )


	 
	text1 = display.newText( "Manage Images", 0, 0, font, 18 )
	text1:setFillColor( 255 )
	text1.x, text1.y = display.contentWidth * 0.5, 20
	sceneGroup:insert( text1 )
	
	 
  
    
	
	print( "\n1: create event")
end

function scene:show( event )
	
	local phase = event.phase
	 
	if "did" == phase then 
		composer.removeScene( "play_screen" )
	end 
	 
	
end

function scene:hide( event )
	
	local phase = event.phase
	  
end

function scene:destroy( event )
	print( "((destroying scene 1's view))" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
