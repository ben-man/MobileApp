local M = {}

local app_io = require( "app_io" )
local app_object = require( "app_object")
local app_layout = require( "app_layout" )



local function makeDeck( cards )
  local deck = CardDeck:new()

  for i = 1, #cards do
    deck:add( cards[i] )
  end

  deck:scale( PrivacyGame.CARDS_SCALE )

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

local function makeStatusPanel()
  return StatusPanel:new()
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

  local targetPanel = makeTargetPanel( s.targets, s.arrows )
  local deck = makeDeck( s.cards )
  local statusPanel = makeStatusPanel()
end

function onScrollDeck( deckEvent )
  local deck = deckEvent.deck
  local pos = deckEvent.pos
  local cardArea = app_layout.cardArea
  local bounds = deck.getCardBounds()

  deck:scroll( pos.yOffset )

  return true
end

function onStopScroll()
  return true
end

function onMoveCard( cardEvent )
  local c = cardEvent.card
  local pos = cardEvent.pos
  c:move( pos.xOffset, pos.yOffset )
  return true
end

function onDropCard()
  return true
end

return M
