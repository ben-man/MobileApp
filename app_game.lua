local M = {}

local app_io = require( "app_io" )
local app_object = require( "app_object")

local function makeDescArea( name, desc )
  return DescArea:new( name, desc )
end

local function makeDeck( cards )
  local deck = CardDeck:new()

  for i = 1, #cards do
    -- #cards used to adjust images layout
    deck:add( cards[i], #cards, i)
  end

  return deck
end

local function makeTargetPanel( targets, arrows )
  local panel = TargetPanel:new()

  for i=1, #targets do
    -- ID target
    panel:addTarget( targets[i], i )
  end

  for i = 1, #arrows do
    panel:addArrow( arrows[i], i )
  end

  panel:createTextScore(14)
  panel:createImgWin()
  panel:createImgLose()
  panel:createWinImgButton(0,40,768/3,64,"resources/img/button_continue_spritesheet.png")
  panel:createLoseImgButton(0,40,768/3,64,"resources/img/button_retry_spritesheet.png")

  panel:fitContentsToPanel()

  loadSounds()

  return panel
end

function M.buildGame()

  local s = assert( app_io.getCurrentScenario(), "Current scenario is nil")

  -- the order is importante -> deck above panel

  cleanObjects()
  local txt = makeDescArea( s.name, s.description )
  local panel = makeTargetPanel( s.targets, s.arrows )
  local deck = makeDeck( s.cards )

end


return M
