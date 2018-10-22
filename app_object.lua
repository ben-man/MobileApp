local M = {}

local app_io = require( "app_io" )
local app_layout = require( "app_layout" )

local docsDir = system.DocumentsDirectory
local img = {
  targetBox = "resources/img/TargetBox.png",
  sourceBox = "resources/img/SourceBox.png",
  arrow = "resources/img/arrow2.png"
}

TargetBox = {}

function TargetBox:new( targetDesc )
  local o = {}
  local targetArea = app_layout.targetArea
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
  local group = display.newGroup()
  local targetArea = app_layout.targetArea

  local rect = display.newImageRect(
    group,
    img.arrow,
    PrivacyGame.ARROW_WIDTH,
    PrivacyGame.ARROW_HEIGHT
  )
  rect.x = arrowDesc.x
  rect.y = arrowDesc.y
  rect:scale( arrowDesc.scaleX, arrowDesc.scaleY )
  rect:rotate( arrowDesc.angle )

  o.displayRef = group

  return o
end

Card = {}

function Card:new( imgPath, idx )
  local o = {}
  local group = display.newGroup()
  local cardArea = app_layout.cardArea

  local border = display.newImageRect( group, img.sourceBox, 134, 134 )
  border.anchorX = 0
  border.anchorY = 0
  local image = display.newImageRect( group, imgPath, 128, 128 )
  image.anchorX = 0
  image.anchorY = 0

  group.x = cardArea.xMin
  group.y = cardArea.yMin + (idx*(134 + 10))

  o.displayRef = group

  return o
end

CardDeck = {}

function CardDeck:new()
  local o = {cards = {}, numCards = 0}
  local group = display.newGroup()

  function o:add( cardDesc )
    local idx = self.numCards + 1
    local c = Card:new( app_io.getImagePath( cardDesc.spriteSrc ), idx - 1 )
    self.cards[idx] = c
    group:insert( c.displayRef )
    self.numCards = idx
  end

  o.displayRef = group

  return o
end

TargetPanel = {}

function TargetPanel:new()
  local o = {}
  local group = display.newGroup()
  local contents = display.newGroup()
  local targetArea = app_layout.targetArea

  local rect = display.newRoundedRect(
    group,
    targetArea.xMin, 
    targetArea.yMin,
    targetArea.width - targetArea.offset,
    targetArea.height - targetArea.offset,
    12
  )
  rect.strokeWidth = 3
  rect:setStrokeColor( 1, 0, 0 )
  rect.anchorX = 0
  rect.anchorY = 0
  display.setDefault( "textureWrapX", "repeat" )
  display.setDefault( "textureWrapY", "mirroredRepeat" )

  rect.fill = { type="image", filename="resources/img/cork-wallet.png" }

  function o:addTarget( targetDesc )
    local t = TargetBox:new( targetDesc )
    self.contents:insert( t.displayRef )
  end

  function o:addArrow( arrowDesc )
    local a = Arrow:new( arrowDesc )
    self.contents:insert( a.displayRef )
  end

  function o:fitContentsToPanel()
    self.contents.x = targetArea.xMin + (rect.width/2)
    self.contents.y = targetArea.yMin + (rect.height/2)
    self.contents.anchorChildren = true
    local ratio = math.min(
      (rect.width*0.9) / self.contents.width, 
      (rect.height*0.9) / self.contents.height
    )
    self.contents:scale( ratio, ratio )
  end

  group:insert( contents )
  o.displayRef = group
  o.contents = contents
  return o
end

return M
