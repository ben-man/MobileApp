local M = {}

local app_io = require( "app_io" )

local docsDir = system.DocumentsDirectory
local img = {
  targetBox = "resources/img/TargetBox.png",
  arrow = "resources/img/arrow2.png"
}

TargetBox = {}

function TargetBox:new( targetDesc )
  local o = {}
  o.matchingCard = targetDesc.matchingCard

  local group = display.newGroup()
  group.x = targetDesc.x
  group.y = targetDesc.y
  local rect = display.newImageRect( group, img.targetBox, 132, 132 )
  rect.anchorX = 0
  rect.anchorY = 0
  local textOptions = {
    parent = group,
    text = targetDesc.text,
    width = 128,
    height = 128,
    align = "center"
  }
  local text = display.newText( textOptions )
  text.anchorX = 0
  text.anchorY = 0

  o.displayRef = group

  return o
end

Arrow = {}

function Arrow:new( arrowDesc )
  local o = {}

  local rect = display.newImageRect( img.arrow, 128, 128 )
  rect.x = arrowDesc.x
  rect.y = arrowDesc.y
  rect:scale( arrowDesc.scaleX, arrowDesc.scaleY )
  rect:rotate( arrowDesc.angle )

  o.displayRef = rect

  return o
end

return M
