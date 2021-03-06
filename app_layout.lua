PrivacyGame = {
  GAME_HEIGHT = 720,
  GAME_WIDTH = 1280,
  CARD_SIDE = 128,
  ARROW_SIDE = 128,
  TEXT_SIDE = 128,
  TARGETBOX_SIDE = 132,
  CARDS_OFFSET_Y = 540,
  CARDS_GAP = 5,
  CARDS_SCALE = 0.75,
  TARGETBOX_BORDER_SIZE = 4,
  TARGETBOX_FILL_COLOUR1 = {0.85, 0.48, 0.15},
  TARGETBOX_BORDER_COLOUR1 = {0, 0, 0}
}

local menuArea = {}
menuArea.xMin = display.safeScreenOriginX
menuArea.yMin = display.safeScreenOriginY
menuArea.width = (44/568) * display.safeActualContentWidth
menuArea.height = display.safeActualContentHeight
menuArea.xMax = menuArea.xMin + menuArea.width
menuArea.yMax = menuArea.yMin + menuArea.height

local mainArea = {}
mainArea.xMin = menuArea.xMax
mainArea.yMin = display.safeScreenOriginY
mainArea.width = display.safeActualContentWidth - menuArea.width
mainArea.height = display.safeActualContentHeight
mainArea.xMax = display.safeScreenOriginX + display.safeActualContentWidth
mainArea.yMax = display.safeScreenOriginY + display.safeActualContentHeight

local cardArea = {}
cardArea.ratio = 1 - (PrivacyGame.CARDS_OFFSET_Y/PrivacyGame.GAME_HEIGHT)
cardArea.width = mainArea.width * cardArea.ratio
cardArea.height = mainArea.height
cardArea.xMin = mainArea.xMax - cardArea.width
cardArea.yMin = mainArea.yMin
cardArea.xMax = mainArea.xMax
cardArea.yMax = mainArea.yMax

local descArea = {}
descArea.xMin = mainArea.xMin
descArea.yMin = mainArea.yMin
descArea.width = mainArea.width - cardArea.width
descArea.height = mainArea.height * cardArea.ratio
descArea.xMax = cardArea.xMin
descArea.yMax = descArea.yMin + descArea.height
descArea.titleHeight = descArea.height*0.3

local targetArea = {}
targetArea.xMin = mainArea.xMin
targetArea.yMin = descArea.yMax
targetArea.width = mainArea.width - cardArea.width
targetArea.height = mainArea.height - descArea.height
targetArea.xMax = cardArea.xMin
targetArea.yMax = mainArea.yMax
targetArea.offset = math.min(
    (targetArea.width*0.04),
    (targetArea.height*0.04)
)
targetArea.scaleFactor = math.min(
    (targetArea.width*0.9) / PrivacyGame.GAME_WIDTH,
    (targetArea.height*0.9) / PrivacyGame.CARDS_OFFSET_Y
)


return {
    menuArea = menuArea,
    mainArea = mainArea,
    cardArea = cardArea,
    descArea = descArea,
    targetArea = targetArea
}
