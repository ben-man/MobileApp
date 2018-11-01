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
	local playMenuGroup = display.newGroup()
	
	
	--playmenu Page
	print("::PlayMenuArea::")
	--creating background image
	local centerX = display.contentCenterX
	local centerY = display.contentCenterY
	
	local bgImage = display.newImage("Background.jpg", centerX, centerY, false)
	--insert into the homeGroup
	playMenuGroup:insert(bgImage)
	
	--display title on main screen
	local title = display.newText("PrivacyGames", centerX, centerY - 125, "Arial", 35)
	title:setFillColor(0,0,1)
	--insert into the homeGroup
	playMenuGroup:insert(title)
	
	--displaying play button
	nameText = display.newText("Enter Name To Play Game:",200, 75, "Arial", 20)
	nameText:setFillColor(0,0,1)
	playMenuGroup:insert(nameText)
	
	--Getting Name of User and Going to Play
	
	local nameField 
	
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
	nameField = native.newTextField(150,110,180,40)
	nameField:addEventListener("userInput", textListener)
	
	--function to handle play button event
	--going to play page
	local function beginPlayButtonEvent(event)
		
		if ("ended" == event.phase ) then
			composer.gotoScene("play", "fade", 400)
		end
	
	end
	
	local beginPlayButton = widget.newButton(
		{
			shape = "roundedRect",
			width = 200,
			height = 40,
			cornerRadius = 2,
			fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 4,
			left = 75,
			top = 130,
			id = "beginplaybtn",
			label = "Play Game",
			onEvent = beginPlayButtonEvent
		}
	)
	
	
	--insert play buton in homeGroup
	playMenuGroup:insert(beginPlayButton)
	
	
		
	--displaying scenario creation button
	
	--function to handle scenario button event
	local function helpButtonEvent(event)
		
		if ("ended" == event.phase ) then
			print("go to help page")
		end
	
	end
	
	local helpButton = widget.newButton(
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
			id = "helpbtn",
			label = "Help",
			onEvent = helpButtonEvent
		}
	)
	
	
	--insert scenario buton in homeGroup
	playMenuGroup:insert(helpButton)
	
	
	

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

