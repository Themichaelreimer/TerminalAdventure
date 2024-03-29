-- Import external libraries
class = require("lib.30log")
tiny = require("lib.tiny")
star = require("lib.lua-star")

screen = {}
levelCanvas = love.graphics.newCanvas()
level = {}
levelTable = {}
font = {}
world = {}  -- Physics world
camera = {}
player = {}
playerSaveData = {}
debugString = ""
title = {}
titleScreen = true

normalizeDiagonalSpeed = true
seed = love.math.random()*10000
playerName = ""
deathTime = 0

require("src.shaders")
require("src.constants")
require("src.colours")
require("src.music")
require("src.helpers")
require("src.sfx")
require("src.enemies")
require("src.ecs")
require("src.pathfinding")
require("src.gameMenu")

require("src.levelGen.levelManager")
require("controller")

Player = require("src.entities.player")
require("camera")
require("titles")

colours = japanesque

-- Basically an enum; at most 16 entries allowed
collisionCategories = {
  player= 16,
  enemies= 2,
  walls= 3,
}

blockingText = nil

WINDOW_TITLES = {
  { "A Game About Nothing", title1, "green" },
  { "He's a Close-Attacker", title2, "red" },
  { "Terminal Adventure", title3, "blue" },
  { "Wallet Quest", title4, "yellow" },
  { "What's the Deal with ASCII?", title5, "purple" },
}

CHARACTER_NAMES = {
  "Jerry the Destroyer",
  "George the Mariner",
  "Elaine the Graceful",
  "Cosmo the Magician"
}

debugRender = false -- Whether or not to draw bounding boxes
canDie = true  -- Whether or not the game ends
debug = false
useTiles = true
useMouse = false

gameState = {
  canGoUp = false,
  canGoDown = false
}

function love.load()
  loadShaders()

  -- Init physics and world
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact)

  local tilesWidth = 60
  local tilesHeight = 60

  -- Screen Settings
  screen.tileSize = 24
  halfTile = screen.tileSize/2

  -- Draw Scale
  local px, py = getBaseScreenDim()
  screen.width = px -- viewport width
  screen.height = py -- viewport height
  screen.sx = 1
  screen.sy = 1
  screen.settings = {
    resizable=true,
  }
  -- Pre-calculated useful values
  screen.uiSize = screen.height/5
  screen.halfWidth = screen.width/2

  planGame()
  loadLevel(nil, 1, true)
  local playerInitPos = level.map.upstairs

  camera = makeCamera(world, playerInitPos.x * screen.tileSize, playerInitPos.y* screen.tileSize)

  font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
  love.graphics.setFont(font)
  title = randomElement(WINDOW_TITLES)
  love.window.setTitle(title[1])
  playerName = randomElement(CHARACTER_NAMES)
  love.window.updateMode(screen.width, screen.height, screen.settings)

end

function love.update(dt)

  keyboardUpdate(dt)
  musicUpdate(dt)
  menuClosedThisFrame = false

  if titleScreen then return end

  if menuOpen then
    menuUpdate(dt)
  else
    if blockingText == nil then
      moveCamera(camera, dt)

      -- Update the Box2D physics world (as opposed to the ECS world)
      level:update(dt)
      world:update(dt)
    else
      if blockingText ~= nil then
        blockingText.time = blockingText.time - dt
        if blockingText.time < 0 then blockingText = nil end
      end
    end
  end
end

function love.draw()

  if titleScreen then displayTitleScreen() return end
  local dt = love.timer.getDelta()
  local sx = screen.sx
  local sy = screen.sy


  if deathTime < 4 then
    -- Draw level canvas
    if levelCanvas then
      love.graphics.setBackgroundColor(colours.black)
      love.graphics.setColor(1,1,1)

      -- Enter player coords
      love.graphics.scale(sx, sy)
      love.graphics.translate(-camera:getX() , -camera:getY())

      love.graphics.draw(levelCanvas)
    end

    if not blockingText and not menuOpen then
      ecsWorld:update(dt)
    end

    -- / CAMERA SPACE
    love.graphics.translate(camera:getX() , camera:getY())

    if player then drawUI() end

    if blockingText ~= nil then
      displayBlockingText()
    end

    if menuOpen then
      menuDraw()
    end
  end

  if player.HP <= 0 and not debug  then
    displayDeathScreen(dt, false)
  end

  if gameWon == true then
    displayDeathScreen(dt, true)
  end

end

function getBaseScreenDim()
  return screen.tileSize * 40, screen.tileSize * 30
end

function drawUI()
  local uiSize = screen.height/5
  local halfWidth = screen.width/2
  local margin = 12
  local lineHeight = 24
  local itemStr = ""

  love.graphics.setColor(colours.white)

  -- DRAW GUI
  -- FUTURE OPTIMIZATION - could draw this to canvas on updates instead of re-rendering every screen
  love.graphics.translate(0, 4*uiSize) -- Transform into UI screen space
  love.graphics.setColor(colours.black) 
  love.graphics.rectangle('fill', 0, 0, screen.width, uiSize)
  love.graphics.setColor(colours.white)

  love.graphics.print(playerName, margin, lineHeight)
  love.graphics.print("Dungeon: L"..level:getFloorNum(), margin + halfWidth, lineHeight)

  love.graphics.print("Health: " .. round(player.HP) .. "/"..player.maxHP, margin, 2*lineHeight)
  love.graphics.setColor(colours.green)
  love.graphics.print(getAsciiBar(player.HP, player.maxHP), 216, 2*lineHeight)
  love.graphics.setColor(colours.white)
  love.graphics.print("Magic: " .. round(player.magic) .. "/"..player.maxMagic, margin + halfWidth, 2*lineHeight)
  love.graphics.setColor(colours.blue)
  love.graphics.print(getAsciiBar(player.magic, player.maxMagic), 216 + halfWidth, 2*lineHeight)

  love.graphics.setColor(colours.white)

  if activeInventory.z then itemStr = activeInventory.z.name end
  love.graphics.print("Z:" .. itemStr, margin, 3*lineHeight)
  if activeInventory.x then itemStr = activeInventory.x.name else itemStr = "" end
  love.graphics.print("X:" .. itemStr, margin + halfWidth, 3*lineHeight)
  love.graphics.print(debugString, margin, 4*lineHeight)

  love.graphics.translate(0, -4*uiSize) -- Transform into UI screen space
end

function getAsciiBar(val, max)
  local result = "["
  local numBars = round(10 * (val / max))
  for i=1, numBars do
    result = result .. "="
  end
  for i=numBars, 9 do
    result = result .. " "
  end
  result = result .."]"
  return result
end

function love.resize(width, height)
  local px, py = getBaseScreenDim() 
  screen.sx = width / px
  screen.sy = height / py
end

function displayBlockingText()

  -- Transparent background
  love.graphics.setColor(colours.black[1], colours.black[2], colours.black[3], 0.8)
  love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)

  -- Text
  love.graphics.setColor(colours.white)
  font = love.graphics.newFont("VeraMono.ttf", 4*screen.tileSize)
  love.graphics.printf(blockingText.text, 0, screen.height/2 - 2*screen.tileSize, screen.width, "center")
  font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
  love.graphics.printf(blockingText.subtext, 0, screen.height/2, screen.width, "center")

  if blockingText.time < 0 then blockingText = nil end
end

-- TODO: Split different 'screens' into different files, perhaps managed by files
function displayTitleScreen()
  -- Transparent background
  love.graphics.setColor(colours.black[1], colours.black[2], colours.black[3])
  love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)

  -- Text
  love.graphics.setColor(colours[title[3]])
  font = love.graphics.newFont("VeraMono.ttf", 4*screen.tileSize)
  love.graphics.printf(title[1], 0, screen.height/2 - 2*screen.tileSize, screen.width, "center")
  font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
  love.graphics.printf("Press x, z, or enter to continue", 0, screen.height/2, screen.width, "center")

  if keyboard.x or keyboard.z or keyboard['return'] then titleScreen = false end
end

function displayDeathScreen(dt, win)
  -- Transparent background
  if debug and not win then return end
  deathTime  = deathTime + dt
  local playerWon = win or false

  if deathTime < 2 then
    local alpha = deathTime/2
    love.graphics.setColor(colours.black[1], colours.black[2], colours.black[3], alpha)
    love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)

  else
    love.graphics.setColor(colours.black)
    love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)
    local alpha = (deathTime - 2) / 2

    -- Text
    if playerWon then
      love.graphics.setColor(colours.green[1], colours.green[2], colours.green[3], alpha)
      font = love.graphics.newFont("VeraMono.ttf", 4*screen.tileSize)
      love.graphics.printf("You escaped with your wallet!", 0, screen.height/2 - 2*screen.tileSize, screen.width, "center")
      font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
      love.graphics.printf("Press x, z, or enter to exit", 0, screen.height/2, screen.width, "center")
    else
      love.graphics.setColor(colours.red[1], colours.red[2], colours.red[3], alpha)
      font = love.graphics.newFont("VeraMono.ttf", 4*screen.tileSize)
      love.graphics.printf("You died...", 0, screen.height/2 - 2*screen.tileSize, screen.width, "center")
      font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
      love.graphics.printf("Press x, z, or enter to exit", 0, screen.height/2, screen.width, "center")
    end

  end

  if deathTime > 4 then
    if keyboard.x or keyboard.z or keyboard['return'] then love.event.quit() end
  end
end

function setBlockingText(text, subtext, time)
  blockingText = {
    text=text,
    subtext=subtext,
    time=time
  }
end

-- These functions are most likely deprecated, for an ECS system that handles the kinds of collisions
function findObjectOfClassInFixtures(obj1, obj2, className)
  -- ONLY WORKS IF BOTH ITEMS AREN'T THE SAME CLASS
  local result = nil
  if obj1.className == className then
    result = obj1
  elseif obj2.className == className then
    result = obj2
  end
  return result
end

function handlePossibleHit(giver, receiver)
  -- Note: receiver is the userData on a fixture
  -- By convention, I will only set this value on the
  -- fixtures of game objects. (Therefore, non-null implies ECS gameobject)
  if receiver == nil then return nil end
  if giver.dealHit then giver:dealHit(receiver) end
end

function beginContact(fixture1, fixture2, contact)
  local obj1 = fixture1:getUserData()
  local obj2 = fixture2:getUserData()

  if obj1 ~= nil and obj2 ~= nil then
    if obj1.dealHit then obj1:dealHit(obj2) end
    if obj2.dealHit then obj2:dealHit(obj1) end
  end

  if obj1 == nil or obj2 == nil then return nil end

  if obj1.onContactStart then
    obj1:onContactStart(obj2)
  end

  if obj2.onContactStart then
    obj2:onContactStart(obj1)
  end
end

function endContact(fixture1, fixture2, contact)
  debugString = ""
  local obj1 = fixture1:getUserData()
  local obj2 = fixture2:getUserData()

  if not (obj1 and obj2) then return end

  if obj1.onContactEnd then
    obj1:onContactEnd(obj2)
  end
  if obj2.onContactEnd then
    obj2:onContactEnd(obj1)
  end
end

function checkObjectWithNameExists(name)
  for i,go in ipairs(gameObjects) do
    if go.name == name then return true end
  end
  return false
end
