-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local app_io = require( "app_io" )
local app_event = require( "app_event" )
local app_game = require( "app_game" )
local widget = require('widget')
local dropdown = require('dropdown')
local screen = require('screen')
--[[
app_io.initDatabase()
local scenarios = app_io.getScenarios( 0 )
if ( #scenarios > 0 ) then
  local s = app_io.loadScenario( scenarios[1].id )
end
]]

app_io.printScenario( app_io.getCurrentScenario() )
app_game.buildGame()

local myDropdown

local dropdownOptions = {
  {
    title     = 'Play',
    action    = function() 
  
    end 
  },
  {
    title     = 'Editor',
    action    = function() 
  
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

local button = widget.newButton{
  width       = 56,
  height      = 32,
  defaultFile = 'resources/img/menu.png',
  overFile    = 'resources/img/menu.png',
  label = "Menu",
  labelColor = { default={ 102, 255, 0, 255 }, over={ 164, 198, 57} },
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
button.alpha = .5

myDropdown     = dropdown.new{
  x            = screen.leftSide + 40,
  y            = screen.topSide + 50,
  toggleButton = button,

  width        = 280,
  marginTop    = 12,
  padding      = 10,
  options      = dropdownOptions
}

