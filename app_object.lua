local M = {}

local app_io = require( "app_io" )
local app_layout = require( "app_layout" )
local widget = require( "widget" )
local screen = require( "screen" )
local dropdown = require( "dropdown" )

-- ----------------------------------------------------------------------------
-- OBJECTS
-- ----------------------------------------------------------------------------
Arrow = {}
TargetBox = {}
Card = {}

--Singletons
TargetPanel = {}
DescArea = {}
CardDeck = {}

local docsDir = system.DocumentsDirectory

-- ----------------------------------------------------------------------------
-- The default style for the app
-- ----------------------------------------------------------------------------
local style = {
  targetBox = {
    fillColour = PrivacyGame.TARGETBOX_FILL_COLOUR1,
    borderColour = PrivacyGame.TARGETBOX_BORDER_COLOUR1
  },
  arrow = {
    img = "resources/img/arrow2.png"
  }
}

-- ----------------------------------------------------------------------------
-- Game rules
-- ----------------------------------------------------------------------------
-- game score
local intialScore = 100
local score = 100 -- initial points
local scorePointsToAdd = 10
local txtScore
-- image win
local imgWin
local imgWinButton

local sounds = {}

-- sounds
function loadSounds()
  sounds["correct"] = audio.loadSound( "resources/sfx/correct.mp3", system.DocumentsDirectory )
  sounds["incorrect"] = audio.loadSound( "resources/sfx/incorrect.mp3", system.DocumentsDirectory )
  sounds["cheer"] = audio.loadSound( "resources/sfx/cheer.mp3", system.DocumentsDirectory )
  sounds["sad"] = audio.loadSound( "resources/sfx/sad.mp3", system.DocumentsDirectory )
end

function playSound(snd)
  audio.play( sounds[snd],{ loops=0 , channel=audio.findFreeChannel() } )
end

function hasGameEnded()
  for i = 1, TargetPanel.numTargets do
    local t = TargetPanel.targets[i]
    if not ( t.isComplete ) then
      return false
    end
  end

  return true
end

-- ----------------------------------------------------------------------------
-- TARGET BOX
-- ----------------------------------------------------------------------------

function TargetBox:new( targetDesc )
  local o = {
    isComplete = false,
    matchingCard = targetDesc.matchingCard
  }
  local targetArea = app_layout.targetArea

  local grp = display.newGroup()
  grp.x = targetDesc.x + (PrivacyGame.TARGETBOX_SIDE/2)
  grp.y = targetDesc.y + (PrivacyGame.TARGETBOX_SIDE/2)

  local side = PrivacyGame.TARGETBOX_SIDE - (PrivacyGame.TARGETBOX_BORDER_SIZE/2)
  local box = display.newRect( grp, 0, 0, side, side )
  box.strokeWidth = PrivacyGame.TARGETBOX_BORDER_SIZE
  box:setFillColor( unpack( style.targetBox.fillColour ) )
  box:setStrokeColor( unpack( style.targetBox.borderColour ) )

  local textOptions = {
    parent = grp,
    text = targetDesc.text,
    width = PrivacyGame.TEXT_SIDE,
    height = PrivacyGame.TEXT_SIDE,
    align = "center"
  }
  local text = display.newText( textOptions )

  function o:attachCard( card )
    self.ref:insert( card.ref, true )
  end

  function o:complete()
    self.isComplete = true
  end

  function o:containsPoint( x, y )
    local bounds = self.ref.contentBounds
    if ( x > bounds.xMin and x < bounds.xMax and y > bounds.yMin and y < bounds.yMax ) then
      return true
    end
    return false
  end

  o.ref = grp
  box.appObject = o

  return o
end

-- ----------------------------------------------------------------------------
-- ARROW
-- ----------------------------------------------------------------------------

function Arrow:new( arrowDesc, idx )
  local o = {}
  local targetArea = app_layout.targetArea

  local rect = display.newImageRect(
    style.arrow.img,
    system.DocumentsDirectory,
    PrivacyGame.ARROW_SIDE,
    PrivacyGame.ARROW_SIDE
  )

  rect.x = arrowDesc.x
  rect.y = arrowDesc.y
  rect:scale( arrowDesc.scaleX, arrowDesc.scaleY )
  rect:rotate( arrowDesc.angle )

  o.ref = rect

  return o
end

-- ----------------------------------------------------------------------------
-- CARD
-- ----------------------------------------------------------------------------

-- totalCars used for layout
function Card:new( imgPath, idx )
  local o = {
    name = imgPath,
    idx = idx
  }
  local cardArea = app_layout.cardArea

  local image = display.newImageRect( 
    app_io.getImagePath( imgPath ), 
    system.DocumentsDirectory, 
    PrivacyGame.CARD_SIDE, 
    PrivacyGame.CARD_SIDE
  )

  function o:detach()
    self.attachedTo = nil
    local stage = display.getCurrentStage()
    stage:insert( self.ref, true )
    self.ref:scale( self.returnTo.scale, self.returnTo.scale )
  end

  -- [[ movement touch ]] --
  function o:touch( event )
    local card = event.target.appObject
    
    if ( event.phase == "began" ) then
      card.returnTo = {}
      card.returnTo.x, card.returnTo.y = card.ref:localToContent( 0, 0 )
      card.returnTo.scale = card.ref.xScale
      local stage = display.getCurrentStage()
      CardDeck:lock()
      stage:insert( card.ref )
      card.ref.x = card.returnTo.x
      card.ref.y = card.returnTo.y
      stage:setFocus( card.ref )
      card.ref.anchorY = 0.5
      transition.to( card.ref, { x=event.x, y=event.y, time=10} )
      return true

    elseif ( event.phase == "moved" ) then

      if ( card.attachedTo ) then
        local target = card.attachedTo
        if ( target:containsPoint( event.x, event.y ) ) then
          return true
        else
          card:detach()
          card.ref.x = event.x
          card.ref.y = event.y
    
          return true
        end
      end


      for i = 1, TargetPanel.numTargets do
        local target = TargetPanel.targets[i]
        if ( target:containsPoint( event.x, event.y ) ) then
          if ( target.isComplete ) then
            --This target already has a card attached; do nothing
            card.ref.x = event.x
            card.ref.y = event.y
            return true
          end

          card.returnTo.size = card.ref.contentWidth
          card.attachedTo = target
          target:attachCard( card )
          return true
        end
      end

      card.ref.x = event.x
      card.ref.y = event.y

      return true

    elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
      
      local isCorrect = false
      local badGuess = false

      if ( card.attachedTo ) then
        local target = card.attachedTo

        if( target.matchingCard == card.name ) then
          isCorrect = true
          target:complete()
        else
          card:detach()
          card.ref.x = event.x
          card.ref.y = event.y
          badGuess = true
        end
      end

      display.getCurrentStage():setFocus( nil )

      if not ( isCorrect ) then
        transition.to( 
          card.ref,
          {
            x=card.returnTo.x,
            y=card.returnTo.y,
            time=450,
            onComplete = function( cardRef )
              CardDeck:reinsertCard( cardRef.appObject )
            end
          }
        )

        if ( badGuess ) then
          score = score - scorePointsToAdd
          -- redraw score
          txtScore.text = "Points: " .. score
          -- onFoundCard
          playSound("incorrect")

          if ( score <= 0 ) then
            playSound("sad")
            imgLose.isVisible = true
            imgLoseButton.isVisible = true
          end

        end

      else
        CardDeck:removeCard( card )
        score = score + scorePointsToAdd
        -- redraw score
        txtScore.text = "Points: " .. score
        playSound("correct")

        if(hasGameEnded())then
          playSound("cheer")
          imgWin.isVisible = true
          imgWinButton.isVisible = true
        end
      end

      CardDeck:unlock()
      return true
    end

  end

  image:addEventListener( "touch", o )

  o.ref = image
  image.appObject = o

  return o
end

-- ----------------------------------------------------------------------------
-- CARD DECK - A set of cards
-- ----------------------------------------------------------------------------

function CardDeck:clear()
  if( self.ref ) then
    self.ref:removeSelf()
    self.ref = nil
  end
end

function CardDeck:new()

  if ( self.ref ) then
    self:clear()
  end

  self.cards = {}
  self.numCards = 0
  self.scaleFactor = PrivacyGame.CARDS_SCALE
  self.gap = PrivacyGame.CARDS_GAP

  local grp = display.newGroup()
  local cardArea = app_layout.cardArea
  local descArea = app_layout.descArea

  local scrollView = widget.newScrollView{
    x = cardArea.xMin,
    y = cardArea.yMin + descArea.titleHeight,
    width = cardArea.width,
    height = cardArea.height - descArea.titleHeight,
    hideBackground = true,
    hideScrollBar = true,
    horizontalScrollDisabled = true
  }
  scrollView.anchorX = 0
  scrollView.anchorY = 0
  grp:insert( scrollView )

  function self:setScale( scaleFactor )
    self.scaleFactor = scaleFactor
  end

  function self:reinsertCard( card )
    card.ref.anchorY = 0
    scrollView:insert( card.ref )
    card.ref.x = (scrollView.width/2)
    card.ref.y = ( (card.idx-1)*((PrivacyGame.CARD_SIDE*self.scaleFactor)+self.gap) )
  end

  function self:removeCard( card )
    table.remove( self.cards, card.idx )
    for i = 1, #self.cards do
      local c = self.cards[i]
      c.idx = i
      c.ref.y = ( (i-1)*((PrivacyGame.CARD_SIDE*self.scaleFactor)+self.gap) )
    end
    self.numCards = self.numCards - 1
    scrollView:setScrollHeight( self.numCards*((PrivacyGame.CARD_SIDE*self.scaleFactor)+self.gap) )
  end

  function self:add( cardDesc )
    local idx = self.numCards + 1
    local c = Card:new( cardDesc.spriteSrc, idx )
    self.cards[idx] = c
    self.numCards = idx
    c.ref.anchorY = 0
    c.ref:scale( self.scaleFactor, self.scaleFactor )
    scrollView:insert( c.ref )
    c.ref.x = (scrollView.width/2)
    c.ref.y = ( (idx-1)*((PrivacyGame.CARD_SIDE*self.scaleFactor)+self.gap) )
  end

  function self:lock()
    scrollView:setIsLocked( true )
  end

  function self:unlock()
    scrollView:setIsLocked( false )
  end

  function self:detachCard()

  end

  self.ref = grp

  return self
end

-- ----------------------------------------------------------------------------
-- TARGET PANEL - The main play area
-- ----------------------------------------------------------------------------

function TargetPanel:clear()
  if( self.ref ) then
    self.ref:removeSelf()
    self.ref = nil
  end
end

function TargetPanel:new()

  if ( self.ref ) then
    self:clear()
  end

  self.targets = {}
  self.numTargets = 0
  local grp = display.newGroup()
  local contents = display.newGroup()
  local targetArea = app_layout.targetArea

  local rect = display.newRoundedRect(
    grp,
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

  rect.fill = { 
    type="image",
    filename="resources/img/cork-wallet.png",
    baseDir = system.DocumentsDirectory
  }

  function self:addTarget( targetDesc )
    local idx = self.numTargets + 1
    local t = TargetBox:new( targetDesc )
    self.targets[idx] = t
    self.numTargets = idx
    self.contents:insert( t.ref )
  end

  function self:addArrow( arrowDesc )
    local a = Arrow:new( arrowDesc )
    self.contents:insert( a.ref )
  end

  function self:createTextScore( size )
--[[
      local x =  (targetArea.width - targetArea.offset)/2
      local y =  targetArea.yMin
      txtScore = display.newText( "Points: " ..  score, x, y, "Consolas", size )
      txtScore:setFillColor(1,0.2,0.2, 1)
]]
      local descArea = app_layout.descArea
      local cardArea = app_layout.cardArea
      local scoreOpts = {
        parent = grp,
        text = "Points: " ..  score,
        font = "skranji-bold.ttf",
        fontSize = descArea.titleHeight*(2/3),
        x = descArea.xMax + (cardArea.width/2),
        y = descArea.yMin,
        --width = descArea.width,
        --height = topPart,
        align = "left"
      }
      txtScore = display.newText( scoreOpts )
      txtScore.anchorY = 0
      txtScore:setFillColor( 1, 0.2, 0.2 )
    
      if ( txtScore.contentWidth > cardArea.width ) then
        local scale = cardArea.width/txtScore.contentWidth
        txtScore:scale( scale, scale )
      end
  end

  function self:createImgWin()
    imgWin = display.newImageRect( "resources/img/correct.png", system.DocumentsDirectory, 160, 160 )
    imgWin.isVisible = false
  end

  function self:createImgLose()
    imgLose = display.newImageRect( "resources/img/incorrect.png", system.DocumentsDirectory, 160, 160 )
    imgLose.isVisible = false
  end

  function self:createWinImgButton( x, y, w, h, img )
     local options = {
      width = w,
      height = h,
      numFrames = 3,
      sheetContentWidth = 768,
      sheetContentHeight = 64
    }
    imgWinButtonS = graphics.newImageSheet( img, system.DocumentsDirectory, options )
    imgWinButton = widget.newButton(
    {
        sheet = imgWinButtonS,
        defaultFrame = 1,
        overFrame = 2,
        label = "",
        onEvent = function(e) continueGameEvent(e) end
    })
    imgWinButton:scale(0.5,0.4)
    imgWinButton.x = (app_layout.targetArea.width - app_layout.targetArea.offset)/2
    imgWinButton.y = app_layout.targetArea.yMin + 22
    imgWinButton.isVisible = false
  end

  function self:createLoseImgButton( x, y, w, h, img )
     local options = {
      width = w,
      height = h,
      numFrames = 3,
      sheetContentWidth = 768,
      sheetContentHeight = 64
    }
    imgWinButtonL = graphics.newImageSheet( img, system.DocumentsDirectory, options )
    imgLoseButton = widget.newButton(
    {
        sheet = imgWinButtonL,
        defaultFrame = 1,
        overFrame = 2,
        label = "",
        onEvent = function(e) resetGameEvent(e) end
    })
    imgLoseButton:scale(0.5,0.4)
    imgLoseButton.x = (app_layout.targetArea.width - app_layout.targetArea.offset)/2
    imgLoseButton.y = app_layout.targetArea.yMin + 22
    imgLoseButton.isVisible = false
  end

  function self:fitContentsToPanel()
    self.contents.x = targetArea.xMin + (rect.width/2)
    self.contents.y = targetArea.yMin + (rect.height/2)
    self.contents.anchorChildren = true

    local gap = math.min(
      (rect.width*0.1),
      (rect.height*0.1)
    )

    local ratio = math.min(
      (rect.width-gap) / self.contents.width,
      (rect.height-gap) / self.contents.height
    )

    imgWin.x = rect.width/2
    imgWin.y = rect.height

    imgLose.x = rect.width/2
    imgLose.y = rect.height

    self.contents:scale( ratio, ratio )

--[[
    local rect1 = display.newRect( self.contents.x, self.contents.y, (rect.width-gap), (rect.height-gap) )
    rect1:setFillColor( 1, 0, 0 )

    local rect2 = display.newRect( self.contents.x, self.contents.y, self.contents.contentWidth, self.contents.contentHeight )
    rect2:setFillColor( 0, 0, 1 )
--]]
  end

  self.contents = contents
  grp:insert( contents )
  self.ref = grp

  return self
end

-- ----------------------------------------------------------------------------
-- DESC AREA - The title and description text
-- ----------------------------------------------------------------------------

function DescArea:clear()
  if( self.ref ) then
    self.ref:removeSelf()
    self.ref = nil
  end
end

function DescArea:new( name, desc )

  if ( self.ref ) then
    self:clear()
  end

  local descArea = app_layout.descArea

  local grp = display.newGroup()

  local topPart = descArea.titleHeight
  local bottomPart = descArea.height - topPart

  local rect = display.newRect( grp, descArea.xMin, descArea.yMin + topPart, descArea.width, descArea.height - topPart )
  rect.anchorX = 0
  rect.anchorY = 0
  rect:setFillColor( 0, 0, 1, 0.3 )

  local titleOpts = {
    parent = grp,
    text = name,
    font = "skranji-bold.ttf",
    fontSize = topPart*(2/3),
    x = descArea.xMin,
    y = descArea.yMin,
    --width = descArea.width,
    --height = topPart,
    align = "left"
  }
  local titleTxt = display.newText( titleOpts )
  titleTxt.anchorX = 0
  titleTxt.anchorY = 0

  if ( titleTxt.contentWidth > descArea.width ) then
    local scale = descArea.width/titleTxt.contentWidth
    titleTxt:scale( scale, scale )
  end

  local scrollView = widget.newScrollView{
    x = descArea.xMin + (descArea.width/2),
    y = descArea.yMin + topPart + (bottomPart/2),
    width = descArea.width,
    height = bottomPart*0.9,
    hideBackground = true,
    hideScrollBar = true,
    horizontalScrollDisabled = true
  }
  --scrollView.anchorX = 0
  --scrollView.anchorY = 0
  grp:insert( scrollView )

  local descOpts = {
    --parent = group,
    text = desc,
    font = native.systemFont,
    fontSize = descArea.height*0.7*0.2,
    x = 0,
    y = 0,
    width = descArea.width,
    height = 0,
    align = "left"
  }
  local descTxt = display.newText( descOpts )
  descTxt.anchorX = 0
  descTxt.anchorY = 0

  scrollView:insert( descTxt )

  self.ref = grp

  return self
end

function cleanObjects()

  if(imgLose)then
    imgLose.isVisible = false
  end
  if(imgWin)then
    imgWin.isVisible = false
  end
  if(imgWinButton)then
    imgWinButton.isVisible = false
  end
  if(imgLoseButton)then
    imgLoseButton.isVisible = false
  end

  TargetPanel:clear()
  CardDeck:clear()
  DescArea:clear()

  score = intialScore
end

function continueGameEvent(event)
  if(event.phase == "began")then
    app_io.loadNextScenario()
    app_game.buildGame()
  end
end

function resetGameEvent(event)
  if(event.phase == "began")then
    app_game.buildGame()
  end
end

return M
