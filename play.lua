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
	local playGroup = display.newGroup()
	
	--play Page
	print("::PlayArea::")
	
	--creating background image
	print("playarea")
	
	local s = {}
	s.id = first
	print(s.id)

	
	--scene horizental and vertical arrays
	s.h = {}
	s.v = {}
	
	
	
	--creating background image
	local centerX = display.contentCenterX
	local centerY = display.contentCenterY
	
	local WIDTH = display.contentWidth
	local HEIGHT = display.contentHeight
	
	local SIZE = (math.min(HEIGHT, WIDTH))*0.9
	local LOCATION = { x = (WIDTH - SIZE)/2, y = (HEIGHT - SIZE)/2 }
	
	local bgImage = display.newImage("Background.jpg", centerX, centerY, false)
	--insert into the playGroup
	playGroup:insert(bgImage)
	
	--inserting source box
	local sourceImage = display.newImage("SourceBox.png", centerX, centerY, false)
	--insert into the playGroup
	playGroup:insert(sourceImage)
	
	--inserting target box
	local targetImage = display.newImage("TargetBox.png", centerX, centerY, false)
	--insert into the playGroup
	playGroup:insert(targetImage)
	
	--inserting cards
	local 
	
	--display score text
	scoreText = display.newText("Score:", 25, 10, "Arial", 14)
	scoreText:setFillColor(0,0,1)
	--insert into the playGroup
	playGroup:insert(scoreText)
	
	scoreNum = display.newText("0", 54, 10, "Arial", 14)
	scoreNum:setFillColor(0,0,1)
	--insert into the playGroup
	playGroup:insert(scoreNum)
	
	--display level text
	levelText = display.newText("Level:", 440,10,"Arial",14)
	levelText:setFillColor(0,0,1)
	--insert into the playGroup
	playGroup:insert(levelText)
	
	levelNum = display.newText("1", 470,10,"Arial",14)
	levelNum:setFillColor(0,0,1)
	--insert into the playGroup
	playGroup:insert(levelNum)
	
	
	
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

