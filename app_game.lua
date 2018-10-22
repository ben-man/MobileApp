local M = {}

local app_io = require( "app_io" )
local app_object = require( "app_object")

local function makeDeck( cards )
  local deck = CardDeck:new()

  for i = 1, #cards do
    deck:add( cards[i] )
  end

  return deck
end

local function makeTargetPanel( targets, arrows )
  local panel = TargetPanel:new()

  for i = 1, #targets do
    panel:addTarget( targets[i] )
  end

  for i = 1, #arrows do
    panel:addArrow( arrows[i] )
  end

  panel:fitContentsToPanel()

  return panel
end

function M.buildGame()

  --[[
  print( "content width: " .. display.contentWidth)
  print( "content height " .. display.contentHeight)
  print( "safescreenoriginx" .. display.safeScreenOriginX )
  print( "safescreenoriginy" .. display.safeScreenOriginY )
  print( "safeActualContentWidth: " .. display.safeActualContentWidth )
  print( "safeActualContentHeight: " .. display.safeActualContentHeight )
  --]]

  local s = assert( app_io.getCurrentScenario(), "Current scenario is nil")

  local deck = makeDeck( s.cards )
  local panel = makeTargetPanel( s.targets, s.arrows )

end

return M
