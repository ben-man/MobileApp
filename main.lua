-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
 
display.setStatusBar( display.HiddenStatusBar )
 
local composer = require "composer"

local widget = require "widget"

isAdmin = 0

-- load first scene
composer.gotoScene( "play_screen", "fade", 100 ) 

