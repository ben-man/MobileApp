local M = {}

local app_io = require( "app_io" )
local app_layout = require( "app_layout" )
local widget = require( "widget" )
local screen = require( "screen" )
local dropdown = require( "dropdown" )

-- ----------------------------------------------------------------------------
-- OBJECTS
-- ----------------------------------------------------------------------------
Menu = {}
TargetPanel = {}
DescArea = {}
CardDeck = {}

Arrow = {}
TargetBox = {}
Card = {}
-- ----------------------------------------------------------------------------
-- Physics engine
-- ----------------------------------------------------------------------------
local physics = require "physics"
physics.start()
physics.setGravity( 0, 0 )

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
end

function playSound(snd)
  audio.play( sounds[snd],{ loops=0 , channel=audio.findFreeChannel() } )
end

function hasGameEnded()
  for i=1,#foundedObjets,1 do
    if foundedObjets[i] == false then
      return false
    end
  end
  return true
end

-- ----------------------------------------------------------------------------
-- MENU
-- ----------------------------------------------------------------------------
local menuArea = app_layout.menuArea

function Menu:hide()
  if( self.ref ) then
    self.ref.isVisible = false
  end
end

function Menu:new()
  local o = {}

  if( self.ref ) then
    self.ref.isVisible = true
    return o
  end

  local myDropdown

  local button = widget.newButton{
    width       = 32,
    height      = 32,
    defaultFile = 'resources/img/menu_white.png',
    overFile    = 'resources/img/menu_white.png',
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
  button.anchorY = 0
  
  myDropdown     = Dropdown.new{
    x            = menuArea.xMin + (menuArea.width/2),
    y            = menuArea.yMin,
    toggleButton = button,
  
    width        = 140,
    marginTop    = 12,
    padding      = 10,
    options      = dropdownOptions
  }

  self.ref = button
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

  physics.addBody( box, "dynamic", {isSensor=true, radius=25} )

  function o:attachCard( card )
    --card.displayRef.x = 0
    --card.displayRef.y = 0
    --grp:insert( card.displayRef )
  end

  function o:detachCard()

  end

  o.displayRef = grp
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

  o.displayRef = rect

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
    imgPath, 
    system.DocumentsDirectory, 
    PrivacyGame.CARD_SIDE, 
    PrivacyGame.CARD_SIDE
  )

  -- [[ movement touch ]] --
  function o:touch( event )
    local card = event.target
    
    if ( event.phase == "began" ) then

        display.getCurrentStage():setFocus( card )
        --images[idx].isFocus = true
        transition.to( card, { x=event.x, y=event.y, time=10} )

    elseif ( event.phase == "moved" ) then

          card.x = event.x
          card.y = event.y

    elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
      
      if( target.matchingCard == card.name ) then

      end

      display.getCurrentStage():setFocus( nil )
      --images[idx].isFocus = nil
      if not foundedCard then
        transition.to( images[idx], { x= CardsLocation[idx].x, y=CardsLocation[idx].y, time=450} )
        score = score - scorePointsToAdd
        -- redraw score
        txtScore.text = "Points: " .. score
      -- onFoundCard
        playSound("incorrect")

      else
        foundedObjets[idx] = true
        foundedCard = false
        images[idx].x = foundObj.x
        images[idx].y = foundObj.y
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

    end

  end

    -- [[ colision system ]] --
  -- when player drops image on rect inside main panel
  function o:collision( event )

    local card = event.target.appObject
    local target = event.other.appObject

    if ( target.isComplete ) then
      --This target already has a card attached; do nothing
      return true
    end

    if ( event.phase == "began" ) then
        card.isAttached = true
        target.attachCard( card )
    elseif ( event.phase == "ended" ) then
        card.isAttached = false
        target.detachCard()
    end
  end 

  --addback:
  --physics.addBody( image,"dynamic",{isSensor=true,radius=25} )
  --image:addEventListener( "collision", o )
  --image:addEventListener( "touch", o )

  o.displayRef = image
  image.appObject = o

  return o
end

-- ----------------------------------------------------------------------------
-- CARD DECK - A set of cards
-- ----------------------------------------------------------------------------

function CardDeck:new()
  local o = {
    cards = {},
    numCards = 0,
    scaleFactor = PrivacyGame.CARDS_SCALE,
  }

  local grp = display.newGroup()
  local cardArea = app_layout.cardArea

  local scrollView = widget.newScrollView{
    x = cardArea.xMin,
    y = cardArea.yMin,
    width = cardArea.width,
    height = cardArea.height,
    hideBackground = true,
    hideScrollBar = true,
    horizontalScrollDisabled = true
  }
  scrollView.anchorX = 0
  scrollView.anchorY = 0
  grp:insert( scrollView )

  function o:setScale( scaleFactor )
    self.scaleFactor = scaleFactor
  end

  function o:add( cardDesc )
    local idx = self.numCards + 1
    local c = Card:new( app_io.getImagePath( cardDesc.spriteSrc ), idx )
    self.cards[idx] = c
    self.numCards = idx
    c.displayRef:scale( self.scaleFactor, self.scaleFactor )
    scrollView:insert( c.displayRef )
  end

  o.displayRef = grp

  return o
end

-- ----------------------------------------------------------------------------
-- TARGET PANEL - The main play area
-- ----------------------------------------------------------------------------

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

  DescArea:clear()

  score = intialScore
end

function TargetPanel:new()
  local o = {}

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

  function o:addTarget( targetDesc )
    local t = TargetBox:new( targetDesc )
    self.contents:insert( t.displayRef )
  end

  function o:addArrow( arrowDesc )
    local a = Arrow:new( arrowDesc )
    self.contents:insert( a.displayRef )
  end

  function o:createTextScore(size)
      local x =  rect.width/2
      local y =  targetArea.yMin
      txtScore = display.newText( "Points: " ..  score, x, y, "Consolas", size )
      txtScore:setFillColor(1,0.2,0.2, 1)
  end

  function o:createImgWin()
    imgWin = display.newImageRect( "resources/img/correct.png", system.DocumentsDirectory, 160, 160 )
    imgWin.isVisible = false
  end

  function o:createImgLose()
    imgLose = display.newImageRect( "resources/img/incorrect.png", system.DocumentsDirectory, 160, 160 )
    imgLose.isVisible = false
  end

  function o:createWinImgButton( x, y, w, h, img)
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
    imgWinButton.x = txtScore.x
    imgWinButton.y = txtScore.y + 22
    imgWinButton.isVisible = false
  end

  function o:createLoseImgButton( x, y, w, h, img)
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
    imgLoseButton.x = txtScore.x
    imgLoseButton.y = txtScore.y + 22
    imgLoseButton.isVisible = false
  end

  function o:fitContentsToPanel()
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

  grp:insert( contents )
  o.displayRef = grp
  o.contents = contents
  return o
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
  local o = {}
  local descArea = app_layout.descArea

  if ( self.ref ) then
    self:clear()
  end

  local group = display.newGroup()

  local topPart = descArea.height*0.3
  local bottomPart = descArea.height - topPart

  local rect = display.newRect( group, descArea.xMin, descArea.yMin + topPart, descArea.width, descArea.height - topPart )
  rect.anchorX = 0
  rect.anchorY = 0
  rect:setFillColor( 0, 0, 1, 0.3 )

  local titleOpts = {
    parent = group,
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
  group:insert( scrollView )

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

  self.ref = group

  return o
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
