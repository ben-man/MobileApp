local M = {}

local app_io = require( "app_io" )
local app_object = require( "app_object")

local widthScale = display.contentWidth/1280
local heightScale = display.contentHeight/720

local targetAreaX = 50
local targetAreaY = 100
local targetAreaHeight = display.contentHeight - targetAreaY - 10
local targetAreaWidth = display.contentWidth - (targetAreaX*2)

local function makeTargetArea()
  local rect = display.newRoundedRect( targetAreaX, targetAreaY, targetAreaWidth, targetAreaHeight, 12 )
  rect.strokeWidth = 3
  rect:setStrokeColor( 1, 0, 0 )
  rect.anchorX = 0
  rect.anchorY = 0
  display.setDefault( "textureWrapX", "repeat" )
  display.setDefault( "textureWrapY", "mirroredRepeat" )

  rect.fill = { type="image", filename="resources/img/cork-wallet.png" }
end

local function makeTargetBox( targetDesc, parent )
  local t =  TargetBox:new( targetDesc )
  if ( parent ) then
    parent:insert( t.displayRef )
  end
end

local function makeArrow( arrowDesc, parent )
  local a = Arrow:new( arrowDesc )
  if ( parent ) then
    parent:insert( a.displayRef )
  end
end

function M.buildGame()
  print( "content width: " .. display.contentWidth)
  print( "content height " .. display.contentHeight)

  local s = assert( app_io.getCurrentScenario(), "Current scenario is nil")

  makeTargetArea()

  local targets = display.newGroup()

  for i = 1, #s.targets do
    makeTargetBox( s.targets[i], targets )
  end

  for i = 1, #s.arrows do
    makeArrow( s.arrows[i], targets )
  end

  targets.x = targetAreaX + (targetAreaWidth/2)
  targets.y = targetAreaY + (targetAreaHeight/2)
  targets.anchorChildren = true

  local ratio = math.min((targetAreaWidth*0.9) / targets.width, (targetAreaHeight*0.9) / targets.height);
  targets:scale( ratio, ratio )

end

return M
