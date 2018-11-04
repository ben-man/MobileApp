local M = {}

local app_io = require( "app_io" )
local app_layout = require( "app_layout" )

local docsDir = system.DocumentsDirectory
local img = {
  targetBox = "resources/img/TargetBox.png",
  sourceBox = "resources/img/SourceBox2.png",
  arrow = "resources/img/arrow2.png"
}

Position = {}

function Position:new( xOffset, yOffset )
  local o = {
    xOffset = xOffset,
    yOffset = yOffset
  }

  return o
end

CardEvent = {}

function CardEvent:new( card, pos )
  local o = {
    card = card,
    pos = pos
  }

  return o
end

DeckEvent = {}

function DeckEvent:new( deck, pos )
  local o = {
    deck = deck,
    pos = pos
  }

  return o
end

StatusPanel = {}

function StatusPanel:new( deck, pos )
  local o = {}
  local cardArea = app_layout.cardArea
  local rect = display.newRect( display.safeScreenOriginX, 0, display.safeActualContentWidth, display.safeScreenOriginY )
  rect.anchorX = 0
  rect.anchorY = 0
  rect:setFillColor( 1, 0, 0 )
  rect:toFront()
  return o
end

TargetBox = {}

function TargetBox:new( targetDesc )
  local o = {}
  local targetArea = app_layout.targetArea
  o.matchingCard = targetDesc.matchingCard

  local group = display.newGroup()
  group.x = targetDesc.x
  group.y = targetDesc.y
  local rect = display.newImageRect( group, img.targetBox, PrivacyGame.TARGETBOX_WIDTH, PrivacyGame.TARGETBOX_HEIGHT )
  rect.anchorX = 0
  rect.anchorY = 0
  local textOptions = {
    parent = group,
    text = targetDesc.text,
    width = PrivacyGame.TEXT_WIDTH,
    height = PrivacyGame.TEXT_HEIGHT,
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

function Card:new( imgPath )
  local o = {selected = false}
  local group = display.newGroup()

  local border = display.newImageRect( group, img.sourceBox, PrivacyGame.SOURCEBOX_WIDTH, PrivacyGame.SOURCEBOX_HEIGHT )
  local image = display.newImageRect( group, imgPath, PrivacyGame.CARD_WIDTH, PrivacyGame.CARD_HEIGHT )

  function o:move( xOffset, yOffset )
    image:translate( xOffset, yOffset )
  end

  function o:touch( event )
    if ( event.phase == "began" ) then
      -- Code executed when the button is touched
      -- "event.target" is the touched object
      return true
    elseif ( event.phase == "moved" ) then
      -- Code executed when the touch is moved over the object
      local x, y
      if not ( self.selected ) then
        x = event.x - event.xStart
        y = event.y - event.yStart
        self.selected = true
        self.displayRef:toFront()
        display.getCurrentStage():setFocus( event.target )
      else
        x = event.x - self.touchX
        y = event.y - self.touchY
      end

      self.touchX = event.x
      self.touchY = event.y

      return onMoveCard( CardEvent:new( self, Position:new( x, y ) ) )
    elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
      -- Code executed when the touch lifts off the object
      self.selected = false
      display.getCurrentStage():setFocus( nil )

      return onDropCard()
    end
  end

  image:addEventListener( "touch", o )

  o.displayRef = group
  return o
end

local function printBounds( obj )
  local bounds = obj.contentBounds
  print( "xMin: ".. bounds.xMin )
  print( "yMin: ".. bounds.yMin )
  print( "xMax: ".. bounds.xMax )
  print( "yMax: ".. bounds.yMax )
end


CardDeck = {}

function CardDeck:new()
  local o = {
    cards = {},
    numCards = 0,
    gapSize = PrivacyGame.CARDS_GAP,
    scrolling = false
  }
  local group = display.newGroup()
  local contents = display.newGroup()

  function o:setGapSize( sz )
    self.gapSize = sz
  end

  function o:add( cardDesc )
    local idx = self.numCards + 1
    local c = Card:new( app_io.getImagePath( cardDesc.spriteSrc ) )
    self.cards[idx] = c
    self.contents:insert( c.displayRef )
    self.numCards = idx
    local ref = c.displayRef
    local cardArea = app_layout.cardArea
    ref.x = cardArea.xMin + (cardArea.width/2)
    ref.y = cardArea.yMin + (PrivacyGame.SOURCEBOX_HEIGHT/2) + ((idx-1)*(PrivacyGame.SOURCEBOX_HEIGHT + self.gapSize))
  end

  function o:scale( scaleFactor )
    for i = 1, self.numCards do
      local c = self.cards[i]
      local ref = c.displayRef
      local sz = PrivacyGame.SOURCEBOX_HEIGHT * scaleFactor
      ref.y = app_layout.cardArea.yMin + (sz/2) + ((i-1)*(sz + self.gapSize))
      ref:scale( scaleFactor, scaleFactor )
    end
    --printBounds( contents )
  end

  function o:getCardBounds()
    return contents.contentBounds
  end


  local cardArea = app_layout.cardArea
  local rect = display.newRect( cardArea.xMin, cardArea.yMin, cardArea.width, cardArea.height )
  rect:setFillColor( 1, 1, 1 )
  rect.isVisible = false
  rect.isHitTestable = true
  rect.anchorX = 0
  rect.anchorY = 0
  --rect.alpha = 0.1

  function o:scroll( yOffset )
    contents:translate( 0, yOffset )
  end

  function o:touch( event )
    if ( event.phase == "began" ) then
      -- Code executed when the button is touched
      -- "event.target" is the touched object
      return true
    elseif ( event.phase == "moved" ) then
      -- Code executed when the touch is moved over the object
      local x, y
      if not ( self.scrolling ) then
        x = event.x - event.xStart
        y = event.y - event.yStart
        if ( x == 0 ) then
          self.scrolling = true
          display.getCurrentStage():setFocus( event.target )
        else
          local a = math.atan( y/x )
          if ( a < 0 ) then
            a = a * -1
          end

          if ( a > (math.pi/4) ) then
            --we want to scroll the cards...
            self.scrolling = true
            display.getCurrentStage():setFocus( event.target )
          else
            return false
          end
        end
      else
        x = event.x - self.touchX
        y = event.y - self.touchY
      end

      self.touchX = event.x
      self.touchY = event.y
      return onScrollDeck( DeckEvent:new( self, Position:new( x, y ) ) )
    elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
      -- Code executed when the touch lifts off the object
      self.scrolling = false
      display.getCurrentStage():setFocus( nil )
      return onStopScroll()
    end
  end

  rect:addEventListener( "touch", o )

  group:insert( contents )
  group:insert( rect )
  o.displayRef = group
  o.contents = contents
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
