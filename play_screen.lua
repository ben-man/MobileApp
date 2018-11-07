---------------------------------------------------------------------------------
--
-- scene2.lua
--
---------------------------------------------------------------------------------


local composer = require( "composer" )
local scene = composer.newScene()
local widget = require('widget')  


local app_io = require( "app_io" )
local app_event = require( "app_event" )
app_game = require( "app_game" ) 
local dropdown = require('dropdown')
local app_layout = require( "app_layout" )
--local screen = require('screen') 


local myDropdown,dropdownOptions,button,dropdownOptions
local menuArea = app_layout.menuArea

local image, text1, text2, text3, memTimer



function createMenu()
	
	    print("admin"..isAdmin)
	 	if isAdmin == 0 then
		dropdownOptions = {
			{
			title     = 'Play',
			action    = function() 
				composer.gotoScene( "play_screen", "fade", 20 ) 
			end
			},
			{
			title     = 'Editor',
			action    = function()

			end
			},
			{
			title     = 'Login',
			action    = function() 
				composer.gotoScene( "login_screen", "fade", 20 )    
			end
			},
			{
			title     = 'Help',
			action    = function()
			  native.showAlert('Help', 'What is it\nThe Privacy Game is a fun way to help you understand and protect your privacy online.\n\nHow does it work?\nOn the screen you will see squares with text representing different things related to your privacy online. The goal is to match the correct images to the different squares. You will begin working with an easy scenario, and the difficulty will increase as you progress through the levels. There is a scoring system, where if you happen to answer incorrectly, points will be deducted from your overall score.\n\nHow does this benefit you?\nBy matching pictures to the different labels, it is reinforcing the different scenarios you may be faced with online. It helps you identify what these potential harms may be, and then how to deal with them in an easy and understandable way. As the difficulty increases, you will learn to deal with more complex scenarios, applicable to real and tangible harms in everyday life. You will learn about the legislation and other legal instruments that are designed to protect you when using the internet.', {'Ok'})
			end
			},
			{
			title     = 'About',
			action    = function()
			  native.showAlert('About Us', 'Coming Soon.', {'Ok'})
			end
			},
			{
			title     = 'Contact Us',
			action    = function()
			  native.showAlert('Contact Us', 'Email', {'Ok'}) 
			end
			},
		}
	else
		dropdownOptions = {
			{
			title     = 'Play',
			action    = function() 
				composer.gotoScene( "play_screen", "fade", 20 ) 
			end

			},
			{
			title     = 'Editor',
			action    = function()

			end
			},
			{
			title     = 'Logout',
			action    = function()  
				isAdmin = 0 
				createMenu()
			end
			},
			{
			title     = 'Manage Images',
			action    = function() 
				composer.gotoScene( "manage_image_screen", "fade", 20 )    
			end
			},
			{
			title     = 'Manage Scenarios',
			action    = function()
				composer.gotoScene( "manage_scenerio_screen", "fade", 20 )  
			end
			},
			{
			title     = 'Contact Us',
			action    = function()
			  native.showAlert('Contact Us', 'Email', {'Ok'})
			end
			},
		}
	
	end	


	button = widget.newButton{
		width       = 32,
		height      = 32,
		--x           = menuArea.xMin + (menuArea.width/2),
		--y           = menuArea.yMin,
		baseDir = system.DocumentsDirectory,
		defaultFile = 'resources/img/menu_white.png',
		overFile    = 'resources/img/menu_white.png',
		--label = "Menu",
		--labelColor = { default={ 102, 255, 0, 255 }, over={ 164, 198, 57} },
		onEvent     = function( event )
			local target = event.target
			local phase  = event.phase
			if phase == 'began' then
			  target.alpha = .2
			else
			  target.alpha = 1
			  if phase ==  'ended' then
			    myDropdown:toggle()
			  end
			end
			end
		}
		--button.alpha = .5
		button.anchorY = 0

		myDropdown     = dropdown.new{
		  x            = menuArea.xMin + (menuArea.width/2),
		  y            = menuArea.yMin,
		  toggleButton = button,

		  width        = 140,
		  marginTop    = 12,
		  padding      = 10,
		  options      = dropdownOptions
	} 

---[[ Skip through scenarios - for testing only.
	local fastForwardButton = display.newImageRect( "resources/img/arrow2.png", system.DocumentsDirectory, 24, 24 )
	fastForwardButton.x = menuArea.xMin + (menuArea.width/2)
	fastForwardButton.y = button.contentBounds.yMax + (button.contentHeight/2)

	local function tapListener( event )
		app_io.loadNextScenario()
		app_game.buildGame()
		return true
	end
	fastForwardButton:addEventListener( "tap", tapListener )
--]]	
end


function scene:create( event )
	local sceneGroup = self.view
	
	image = display.newRect(0, 0, 0, 0) 
	image.x = display.contentCenterX
	image.y = display.contentCenterY
	
	sceneGroup:insert( image )
	
	image.touch = onSceneTouch
	
	--text1 = display.newText( "Scene 2", 0, 0, native.systemFontBold, 24 )
	--text1:setFillColor( 255 )
	--text1.x, text1.y = display.contentWidth * 0.5, 50
	--sceneGroup:insert( text1 )
	


    createMenu()

 
    sceneGroup:insert( button )

	 

end

function scene:show( event )
	print("showS")

    createMenu() 

	local sceneGroup = self.view
	
	local phase = event.phase 
	
	if "did" == phase then 
		composer.removeScene( "login_screen" )
		composer.removeScene( "manage_image_screen" )
	end
   
	app_game.buildGame() 
	   
	
end

function scene:hide( event )
	
	local phase = event.phase 
	app_game.removeGame()
end

function scene:destroy( event ) 
	print( "((destroying scene 2's view))" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
