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
    
	--creating homegroup
	local homeGroup = display.newGroup()
	
	--homepage 
	print("::HomePageArea::")
	
	--creating background image
	local centerX = display.contentCenterX
	local centerY = display.contentCenterY
	
	local WIDTH = display.contentWidth
	local HEIGHT = display.contentHeight
	
	local SIZE = (math.min(HEIGHT, WIDTH))*0.9
	local LOCATION = { x = (WIDTH - SIZE)/2, y = (HEIGHT - SIZE)/2 }
	
	local bgImage = display.newImage("Background.jpg", centerX, centerY, false)
	--insert into the homeGroup
	homeGroup:insert(bgImage)
	
	--display title on main screen
	local title = display.newText("PrivacyGames", centerX, centerY - 125, "Arial", 35)
	title:setFillColor(0,0,1)
	--insert into the homeGroup
	homeGroup:insert(title)
	
	--displaying play button
	
	--function to handle play button event
	--going to playmenu page
	local function playbtnEvent(event)
		
		if ("ended" == event.phase ) then
			composer.gotoScene("playMenu", "fade", 400)
		end
	
	end
	
	local playButton = widget.newButton(
		{
			shape = "roundedRect",
			width = 200,
			height = 40,
			cornerRadius = 2,
			fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 4,
			left = 75,
			top = 80,
			id = "playbtn",
			label = "PlayGame",
			onEvent = playbtnEvent
		}
	)
	
	
	--insert play buton in homeGroup
	homeGroup:insert(playButton)
	
	
		
	--displaying scenario creation button
	
	--function to handle scenario button event
	local function scenariobtnEvent(event)
		
		if ("ended" == event.phase ) then
			print("go to scenario creation")
		end
	
	end
	
	local scenarioButton = widget.newButton(
		{
			shape = "roundedRect",
			width = 200,
			height = 40,
			cornerRadius = 2,
			fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 4,
			left = 75,
			top = 140,
			id = "scenariobtn",
			label = "Scenario Creation",
			onEvent = scenariobtnEvent
		}
	)
	
	
	--insert scenario buton in homeGroup
	homeGroup:insert(scenarioButton)
	
	
	--displaying FAQ button
	--function to handle FAQ button event
	local function faqbtnEvent(event)
		
		if ("ended" == event.phase ) then
			print("gotoscene faq")
		end
	
	end
	
	local faqButton = widget.newButton(
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
			id = "faqbtn",
			label = "FAQ",
			onEvent = faqbtnEvent
		}
	)
	
	--insert play buton in homeGroup
	homeGroup:insert(faqButton)
	
	--displaying admin button
	--function to handle admin button event
	local function adminbtnEvent(event)
		
		if ("ended" == event.phase ) then
			print("gotoscene admin")
			composer.gotoScene("admin", "fade", 400)
		end
	
	end
	
	local adminButton = widget.newButton(
		{
			shape = "roundedRect",
			width = 200,
			height = 40,
			cornerRadius = 2,
			fillColor = { default={1,0,0,1}, over={1,0.1,0.7,0.4} },
			strokeColor = { default={1,0.4,0,1}, over={0.8,0.8,1,1} },
			strokeWidth = 4,
			left = 75,
			top = 260,
			id = "adminbtn",
			label = "Admin",
			onEvent = adminbtnEvent
		}
	)
	
	--insert play buton in homeGroup
	homeGroup:insert(adminButton)


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

