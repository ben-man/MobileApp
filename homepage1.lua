local composer = require ("composer")

local scene = composer.newScene()


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------



-------------------------------------------------
--Scene Events Functions
-------------------------------------------------


--create()
function scene:create ( event )
	
	local homeGroup = self.view
	--code here runs when the scene is first created but has not yet appeared on screen
	
	--creating homegroup
	local homeGroup = display.newGroup()

	--creating background image
	local centerX = display.contentCenterX

	local centerY = display.contentCenterY

	local background = display.newImage("Background.jpg", centerX, centerY, true)
	homeGroup:insert(background)
	--displaying title on main screen
	local title = display.newText("PrivacyGames", centerX, centerY - 125, "Arial", 35)
	title:setFillColor(0,0,1)
	homeGroup:insert(title)
	--Displaying Play area on main screen
	local play = display.newText("Play", centerX, centerY - 50, "Arial", 30)
	play:setFillColor(0,0,1)
	homeGroup:insert(play)
	--displaying Admin area on main screen
	local admin = display.newText("Admin", centerX, centerY - 10, "Arial", 30)
	admin:setFillColor(0,0,1)
	homeGroup:insert(admin)

end


--show()
function scene:show ( event )


end


--hide()
function scene:hide ( event )


end

--destroy()
function scene:destroy ( event )


end

-------------------------------------------------
--Scene event function listeners
-------------------------------------------------

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

-------------------------------------------------

return scene