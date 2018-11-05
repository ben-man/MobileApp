local M = {}

local app_io = require( "app_io" )
local app_layout = require( "app_layout" )
local widget = require( "widget" )

-- physics engine
local physics = require "physics"
physics.start()
physics.setGravity( 0, 0 )

local docsDir = system.DocumentsDirectory
local img = {
  targetBox = "resources/img/TargetBox.png",
  sourceBox = "resources/img/SourceBox.png",
  arrow = "resources/img/arrow2.png"
}

-- game rules
local foundedCard = false
-- last rect found when playing
local foundObj = {}
-- if a img were already founded true or false
local foundedObjets = {}
-- game score
local intialScore = 0
local score = 0 -- initial points
local scorePointsToAdd = 10
local txtScore
-- image win
local imgWin
local imgWinButton
local imgLose
local imgLoseButton

local sounds = {}


-- sounds ---
function loadSounds()
  sounds["correct"] = audio.loadSound( "resources/sfx/correct.mp3" )
  sounds["incorrect"] = audio.loadSound( "resources/sfx/incorrect.mp3" )
  sounds["sad"] = audio.loadSound( "resources/sfx/sad.mp3" )
  sounds["cheer"] = audio.loadSound( "resources/sfx/cheer.mp3" )
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

TargetBox = {}
rects = {}
textRects = {}


group_a = display.newGroup()
group_b = display.newGroup()
group_c = display.newGroup()

function TargetBox:new( targetDesc , ID)
  --local o = {}
  local targetArea = app_layout.targetArea
  --o.matchingCard = targetDesc.matchingCard

  --group.x = targetDesc.x
  --group.y = targetDesc.y
  if rects[ID] ~= nil then rects[ID] = nil end
  rects[ID] = display.newImageRect( group_a, "resources/img/TargetBox.png", 132, 132 )
  if( rects[ID] ~= nil ) then
    rects[ID].anchorX = 0
    rects[ID].anchorY = 0
    rects[ID].name = targetDesc.matchingCard
    foundedObjets[ID] = false
    --rects[ID].x = targetDesc.x
    --rects[ID].y = targetDesc.y

    local textOptions = {
      parent = group_a,
      text = targetDesc.text,
      width = 128,
      height = 128,
      align = "center"
    }
    local text = display.newText( textOptions )
    text.anchorX = 0
    text.anchorY = 0
    text.x = targetDesc.x
    text.y = targetDesc.y
    textRects[ID] = text

    --o.displayRef = group
    physics.addBody(rects[ID],"dynamic",{isSensor=true,radius=25})
    rects[ID]:addEventListener("collision",function(e) self:onCollision(rects[ID], e) end)
  end
  --return o
end

-- [[ colision system ]] --
-- when player drops image on rect inside main panel
function TargetBox:onCollision(self, event)
     if ( event.phase == "began" ) then
        if(self.name == event.other.name)then
          foundedCard = true
          img = getImgRectByName(self.name)

          if(img ~= nil)then
             foundObj.x = self.x
             foundObj.y = self.y
             foundObj.width = self.width
             foundObj.height = self.height
          end
        end
     elseif ( event.phase == "ended" ) then
          foundedCard = false
     end
end

function getImgRectByName(name)
  for i=1,#images,1 do

     --print(name, images[i].name, name ==  images[i].name)
    if name == images[i].name then
      return images[i]
    end
  end
  return nil
end

Arrow = {}
arrows = {}

function Arrow:new( arrowDesc, idx )
  local o = {}
  local targetArea = app_layout.targetArea

  local rect = display.newImageRect(
    group_a,
    "resources/img/arrow2.png",
    PrivacyGame.ARROW_WIDTH,
    PrivacyGame.ARROW_HEIGHT
  )
  if rect ~= nil then
  rect.x = arrowDesc.x
  rect.y = arrowDesc.y
  rect:scale( arrowDesc.scaleX, arrowDesc.scaleY )

  if((idx % (#rects/2)) ~= 0) then
    rect:rotate( arrowDesc.angle + 180 )
  else
     rect:rotate( arrowDesc.angle )
  end
  arrows[idx] = rect

  end
  --o.displayRef = group

  return o
end

images = {}
Card = {}
CardsLocation = {}

-- totalCars used for layout
function Card:new( imgPath, idx, totalCards, cardName)
  local o = {}
  local cardArea = app_layout.cardArea

  local imgBorder = 2
  local ySpace = (display.contentHeight / totalCards) -  imgBorder
  local offset = imgBorder/2


  --local border = display.newImageRect( group, img.sourceBox, 134, ySpace )
  --border.anchorX = 0
  --border.anchorY = 0
  images[idx] = display.newImageRect( group_a, imgPath, 128, ySpace)
  images[idx].anchorX = 0
  images[idx].anchorY = 0
  images[idx].name = cardName

  -- used to replace cards to original locations
  local Coords = {x=0,y=0}
  Coords.x = cardArea.xMin + (display.contentWidth - cardArea.xMin)/2.5
  Coords.y = cardArea.yMin + (offset + (idx-1)*ySpace + (idx-1) * imgBorder)
  CardsLocation[idx] = Coords
  -- used to translate with touch event
  images[idx].x = cardArea.xMin + (display.contentWidth - cardArea.xMin)/2.5
  images[idx].y = cardArea.yMin + (offset + (idx-1)*ySpace + (idx-1) * imgBorder)
  images[idx]:scale(0.4,1)
  -- add lister touch
  images[idx]:addEventListener("touch",function(e) self:touch(e, idx) end)
  -- add lister colision
  physics.addBody(images[idx],"dynamic",{isSensor=true,radius=25})
  images[idx]:addEventListener("collision",function(e) self:onCollision(e, idx) end)
   --group.x = cardArea.xMin
  --group.y = cardArea.yMin + (offset + idx*ySpace + idx * imgBorder)
  --o.displayRef = group

  return o
end

-- [[ movement touch ]] --
function Card:touch( event , idx)
  local xScaleFactor = 0.4
  --print("x:"..event.x, "y:"..event.y, self.images[idx].isFocus )
  if ( event.phase == "began" ) then
    -- we only work if new images
    if(foundedObjets[idx] == false) then
      local stage = display.getCurrentStage()
      stage:setFocus( images[idx] )
      images[idx].isFocus = true
      transition.to( images[idx], { x=event.x - (images[idx].width*xScaleFactor)/2,y=event.y - images[idx].height/2, time=10} )
    end
  elseif ( images[idx].isFocus ) then
    if ( event.phase == "moved" ) then
        images[idx].x = event.x --- (images[idx].width*xScaleFactor)/2
        images[idx].y = event.y --- images[idx].height/2

         images[idx].x = event.x
        images[idx].y = event.y

    elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
      local stage = display.getCurrentStage()
      stage:setFocus(nil)
      images[idx].isFocus = nil
      if not foundedCard then
        transition.to( images[idx], { x= CardsLocation[idx].x, y=CardsLocation[idx].y, time=450} )
        score = score - scorePointsToAdd
        -- redraw score
        txtScore.text = "Score: " .. score
      -- onFoundCard
        playSound("incorrect")
        if(score <= 0) then
          playSound("sad")
          score = 0
          txtScore.text = "Points: " .. score

          imgLose.isVisible = true
          imgLoseButton.isVisible = true
        end

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
end

-- [[ colision system ]] --
function Card:onCollision(event, idx)
    --print(event.phase)
     if ( event.phase == "began" ) then
        --local obj1 = event.object1
        --local obj2 = event.object2
        --print(obj1.name,obj2.name)
     end
end

CardDeck = {}


function CardDeck:new()
  local o = {cards = {}, numCards = 0}
  local group = display.newGroup()

  function o:add( cardDesc, totalCards, i )
    -- add name match for collision
    local c = Card:new( app_io.getImagePath( cardDesc.spriteSrc ), i, totalCards, cardDesc.name )
    self.cards[i] = c
    --group:insert( c.displayRef )
    self.numCards = i
  end

  o.displayRef = group

  return o
end

TargetPanel = {}

function cleanObjects()
  for k,v in pairs(rects) do
    print(rects[k].name)
    if(rects[k] ~= nil) then
      rects[k]:removeEventListener("collision",function(e) self:onCollision(rects[k], e) end)
      rects[k]:removeSelf()
      rects[k] = nil
    end
  end

  for k,v in pairs(textRects) do
    if(textRects[k] ~= nil) then
        textRects[k]:removeSelf()
        textRects[k] = nil
      end
  end

  for k,v in pairs(images) do
    if(images[k] ~= nil) then
      images[k]:removeEventListener("collision",function(e) self:onCollision(e, k) end)
      images[k]:removeSelf()
      images[k] = nil
    end
  end

  if txtScore ~= nil then
    txtScore:removeSelf()
    txtScore = nil
  end

  for k,v in pairs(foundedObjets) do
    if(foundedObjets[k] ~= nil) then
      foundedObjets[k] = nil
    end
  end

  for i=1, group_a.numChildren do
    group_a:remove(i)
  end
  group_a = display.newGroup()

  for i=1, group_b.numChildren do
    group_b:remove(i)
  end
  group_b = display.newGroup()

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

  score = intialScore


  rects = {}
  textRects = {}
  images = {}
  CardsLocation = {}
  arrows = {}
  foundedObjets = {}
end

function TargetPanel:new()
  local o = {}
  local contents = display.newGroup()
  local targetArea = app_layout.targetArea

  local rect = display.newRoundedRect(
    group_a,
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

  function o:addTarget( targetDesc, ID )
    TargetBox:new( targetDesc, ID )
    --self.contents:insert( t.displayRef )
  end

  function o:addArrow( arrowDesc , ID)
    local a = Arrow:new( arrowDesc , ID)
    --self.contents:insert( a.displayRef )
  end

  function o:createTextScore(size)
      local x =  rect.width/2
      local y =  targetArea.yMin/2
      txtScore = display.newText( "Points: " ..  score, x, y, "Consolas", size )
      txtScore:setFillColor(1,0.2,0.2, 1)
  end

  function o:createImgWin()
    imgWin = display.newImageRect( group_b, "resources/img/correct.png", 160, 160 )
    imgWin.isVisible = false
  end

  function o:createImgLose()
    imgLose = display.newImageRect( group_b, "resources/img/incorrect.png", 160, 160 )
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
    imgWinButtonS = graphics.newImageSheet( img, options )
    imgWinButton = widget.newButton(
    {
        sheet = imgWinButtonS,
        defaultFrame = 1,
        overFrame = 2,
        label = "",
        onEvent = function(e) resetGameEvent(e) end
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
    imgWinButtonL = graphics.newImageSheet( img, options )
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
    local ratio = math.min(
      (rect.width*0.9) / self.contents.width,
      (rect.height*0.9) / self.contents.height
    )

    group_c:insert(group_a)
    group_c:insert(group_b)

    imgWin.x = rect.width/2
    imgWin.y = rect.height


    imgLose.x = rect.width/2
    imgLose.y = rect.height

    local xScale = 0.35
    local yScale = 0.4
    local rectWidth = 0
    local rectHeight = 0
    local arrowWidth= 0
    local arrowHeight= 0
    if(rects[1] ~= nil ) then
      rectWidth = rects[1].width  * xScale
      rectHeight= rects[1].height  * yScale
    end
    if(arrows[1] ~= nil ) then
      arrowWidth = arrows[1].width * xScale
      arrowHeight = arrows[1].height * yScale
    end
    local xPadding = 0.05 * rect.width
    local yPadding = 0.15 * rect.height
    local xOffset = xPadding
    local yOffset = yPadding
    local totalCards = #rects
    local totalArrows = #arrows
    local textYpadding = 0.05 * rectWidth
    for i=1,#rects,1 do
      rects[i].x =  xOffset + targetArea.xMin --+ rects[i].contentWidth/2
      rects[i].y =  yOffset + targetArea.yMin --+ rects[i].contentHeight/2
      rects[i]:scale(xScale,yScale)

      textRects[i].x =  xOffset + targetArea.xMin --+ rects[i].contentWidth/2
      textRects[i].y =  textYpadding + yOffset + targetArea.yMin --+ rects[i].contentHeight/2
      textRects[i]:scale(xScale,yScale)

      xOffset = xOffset + (rect.width - (#rects/2 * rectWidth) + (math.floor(#arrows/2) * arrowWidth) + 2 * xPadding)/(#rects + 1) + rectWidth

      if i <= #arrows and (i % (#rects/2) ~= 0)then
        arrows[i].x = xOffset + targetArea.xMin --+ rects[i].contentWidth/2  -
        arrows[i].y = yOffset + targetArea.yMin + arrowHeight/2
        arrows[i]:scale(xScale,yScale)
        xOffset = xOffset + (rect.width - (#rects/2 * rectWidth) + (math.floor(#arrows/2) * arrowWidth) + 2 * xPadding)/(#rects + 1)
      elseif i <= #arrows and (i % (#rects/2) == 0)then
        xOffset = xOffset - (rect.width - (#rects/2 * rectWidth) + (math.floor(#arrows/2) * arrowWidth) + 2 * xPadding)/(#rects + 1)
                  - arrowWidth/2
        arrows[i].x = xOffset + targetArea.xMin --+ rects[i].contentWidth/2  -
        arrows[i].y = yOffset + targetArea.yMin + arrowHeight/2 + rectHeight * 1.1
        arrows[i]:scale(xScale,yScale)

      end
      -- 1/2 of rects
      if(i % (#rects/2) == 0)then
        yOffset = yOffset + rect.height/2
        xOffset = xPadding
      end
    end

    --  rects["other"]:scale( ratio, ratio )
  end

  --group_d:insert( contents )
  --o.displayRef = group
  o.contents = contents
  return o
end

DescArea = {}

function DescArea:new( name, desc )
  local o = {}
  local descArea = app_layout.descArea

  local rect = display.newRect( descArea.xMin, descArea.yMin, descArea.width, descArea.height )
  rect.anchorX = 0
  rect.anchorY = 0
  rect:setFillColor( 0, 0, 1, 0.3 )

  local titleOpts = {
    --parent = group_a,
    text = name,
    font = "skranji-bold.ttf",
    fontSize = descArea.height*0.2,
    x = descArea.xMin,
    y = descArea.yMin,
    width = descArea.width,
    height = descArea.height*0.3,
    align = "left"
  }
  local titleTxt = display.newText( titleOpts )
  titleTxt.anchorX = 0
  titleTxt.anchorY = 0

  local descOpts = {
    --parent = group_a,
    text = desc,
    font = native.systemFont,
    fontSize = descArea.height*0.7*0.2,
    x = descArea.xMin,
    y = descArea.yMin + titleOpts.height,
    width = descArea.width,
    height = descArea.height*0.7,
    align = "left"
  }
  local descTxt = display.newText( descOpts )
  descTxt.anchorX = 0
  descTxt.anchorY = 0

  return o
end

function resetGameEvent(event)
  if(event.phase == "began")then
    app_io.loadNextScenario()
    app_game.buildGame()
  end
end

return M
