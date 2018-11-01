local composer = require( "composer" )

local scene = composer.newScene()

local widget = require ("widget")
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    -- Code here runs when the scene is first created but has not yet appeared on screen

    -- Assign "self.view" to local variable "sceneGroup" for easy reference
    
	--creating playMenugroup
	local adminGroup = display.newGroup()

--Admin Page
print("::AdminArea::")

--Creating UserName and Password Fields and button to get login Details

--username field
usernameText = display.newText("UserName:", 440,10,"Arial",14)
	usernameText:setFillColor(0,0,1)
	--insert into the adminGroup
	adminGroup:insert(usernameText)

local usernameField 
	
	local function textListener(event)
	
		if (event.phase == "began") then
			--user begins editing "nameField"
		
		elseif (event.phase == "ended" or event.phase == "submitted") then
			--output resulting text from "nameField"
			print(event.target.text)
		
		elseif (event.phase == "editing") then
			print(event.newCharacters)
			print(event.oldText)
			print(event.startPosition)
			print(event.text)
		end
	end
--creating text field
usernameField = native.newTextField(150,110,180,40)
usernameField:addEventListener("userInput", textListener)

--password field
passwordText = display.newText("Password:", 440,10,"Arial",14)
	passwordText:setFillColor(0,0,1)
	--insert into the adminGroup
	adminGroup:insert(passwordText)

--password
local passwordField 
	
	local function textListener(event)
	
		if (event.phase == "began") then
			--user begins editing "nameField"
		
		elseif (event.phase == "ended" or event.phase == "submitted") then
			--output resulting text from "nameField"
			print(event.target.text)
		
		elseif (event.phase == "editing") then
			print(event.newCharacters)
			print(event.oldText)
			print(event.startPosition)
			print(event.text)
		end
	end
--creating text field
passwordField = native.newTextField(150,150,180,40)
passwordField:addEventListener("userInput", textListener)

--Button for Login
--function to handle button event
	local function loginButtonEvent(event)
		
		if ("ended" == event.phase ) then
			--
		end
	
	end
	
	local loginButton = widget.newButton(
		{
			shape = "roundedRect",
			width = 200,
			height = 40,
			cornerRadius = 2,
			fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 4,
			left = 75,
			top = 200,
			id = "loginbtn",
			label = "Login",
			onEvent = loginButtonEvent
		}
	)
	
	
	--insert scenario buton in homeGroup
	adminGroup:insert(loginButton)

	
--Button for Reset
--function to handle button event
	local function resetButtonEvent(event)
		
		if ("ended" == event.phase ) then
			print("goto Reset Link or send reset password")
		end
	
	end
	
	local resetButton = widget.newButton(
		{
			shape = "roundedRect",
			width = 200,
			height = 40,
			cornerRadius = 2,
			fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 4,
			left = 75,
			top = 200,
			id = "resetbtn",
			label = "Reset",
			onEvent = resetButtonEvent
		}
	)
	
	
	--insert scenario buton in homeGroup
	adminGroup:insert(resetButton)


end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene

