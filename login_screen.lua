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

local labelUsername,labelPassword,frmUsername,frmPassword,eventButton


 

-- handle field events
function  userInput(event)
    if(event.phase == "began") then
        -- you could implement tweening of object to get out of the way of the keyboard here
        print("Began Password" .. ' ' .. event.target.text)
        --event.target.text = ''
    elseif(event.phase == "editing") then
        -- fired with each new character
        print("Editing Password" .. ' ' .. event.target.text)
    elseif(event.phase == "ended") then
        -- fired when the field looses focus as a result of some other object being interacted with
        print("Ended Password" .. ' ' .. event.target.text)
    elseif(event.phase == "submitted") then
        -- you could implement tweening of objects to their original postion here
        print("Submitted Password" .. ' ' .. event.target.text)        
    end
end 

 
-- ----------------------------------------------------------------------------
-- MAKE KEYBOARD GO AWAY ON BACKGROUND TAP
-- ----------------------------------------------------------------------------
function  tap(event)
    native.setKeyboardFocus(nil)
end


-- ----------------------------------------------------------------------------
-- HANDLE BUTTON PRESS
-- ----------------------------------------------------------------------------
-- Button event listener function
 
local function buttonEvent( event )

		local userid = frmUsername.text
	    local password = frmPassword.text 

	    print("u"..userid)
	    print("p"..password)
	    print("ad"..isAdmin)
 
	 	if(userid == 'admin' or password == 'admin') then 
	 		isAdmin = 1
			composer.gotoScene( "play_screen", "slideLeft", 300  ) 
		end  
		 
		return true
end
 
-- Called when the scene's view does not exist:
function scene:create( event )
	local sceneGroup = self.view

	image = display.newRect(0, 0, 0, 0) 
	image.x = display.contentCenterX
	image.y = display.contentCenterY
	
	sceneGroup:insert( image )
	
	 
	text1 = display.newText( "Admin Login", 0, 0, native.systemFontBold, 24 )
	text1:setFillColor( 255 )
	text1.x, text1.y = display.contentWidth * 0.5, 50
	sceneGroup:insert( text1 )
	
	
    labelUsername = display.newText(sceneGroup, "Username", 0, 0, font, 18)
	labelUsername.anchorY = 0
	labelUsername.anchorX = 0
	labelUsername:setTextColor(180, 180, 180)
	labelUsername.x = _W * 0.5 - ( _W * 0.4 )
	labelUsername.y = 95
	sceneGroup:insert(labelUsername)

	labelPassword = display.newText(sceneGroup, "Password", 0, 0, font, 18)
	labelPassword.anchorY = 0
	labelPassword.anchorX = 0
	labelPassword:setTextColor(180, 180, 180)
	labelPassword.x = _W * 0.5 - ( _W * 0.4 )
	labelPassword.y = 160
	sceneGroup:insert(labelPassword) 

    frmUsername = native.newTextField(0, 0, _W*0.8, 30)
    frmUsername.inputType = "default"
    frmUsername.font = native.newFont(font, 18)
    frmUsername.hasBackground = true
    frmUsername.isEditable = true
    frmUsername.align = "left"
    frmUsername.anchorY = 0
    frmUsername.x = _W * 0.5
    frmUsername.y = 115  
	sceneGroup:insert(frmUsername)

	frmPassword = native.newTextField(0, 0, _W * 0.8, 30)
    frmPassword.inputType = "default"
    frmPassword.font = native.newFont(font, 18)
    frmPassword.hasBackground = true
    frmPassword.isEditable = true
    frmPassword.isSecure = true
    frmPassword.align = "left"
    frmPassword.anchorY = 0
    frmPassword.x = _W * 0.5
    frmPassword.y = 180 
    sceneGroup:insert(frmPassword)



    eventButton = widget.newButton(
	{
		label = 'Login', 
		shape = "rectangle",
		x = display.contentCenterX,
		y = 260 - display.screenOriginY,
		width = 278,
		height = 32,
		font = appFont,
		fontSize = 15,
		fillColor = { default={ 0.1,0.3,0.6,1 }, over={ 0.1,0.3,0.6,1 } },
		labelColor = { default={ 1,1,1,1 }, over={ 1,1,1,0.8 } },
		onRelease = buttonEvent,
	})
    sceneGroup:insert(  eventButton )

 
    
	
	print( "\n1: create event")
end

function scene:show( event )
	
	local phase = event.phase
	 
	if "did" == phase then 
		composer.removeScene( "play_screen" )
	end
	frmPassword:addEventListener("userInput",frmPassword)
	background:addEventListener("tap",background)
	 
	
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
