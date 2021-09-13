-- Import external libraries
class = require("lib.30log")
tiny = require("lib.tiny")

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

NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

debugRender = false
normalizeDiagonalSpeed = true
seed = love.math.random()*10000,

require("helpers")
require("controller")
require("map")
require("level")
--require("player")
Player = require("src.entities.player")
require("camera")
require("colours")
require("items")  -- This will be deletable soon
require("weapons") -- This will be deletable soon

require("src.ecs")

colours = japanesque

-- Basically an enum; at most 16 entries allowed
collisionCategories = {
  player= 16,
  enemies= 2,
  walls= 3,
}

blockingText = nil

-- TODO - Put upgrades and equipment into a table
hasMap = false
hasXRay = false
hasBombs = true

WINDOW_TITLES = {
  "It's a Game About Nothing",
  "He's a Close-Attacker",
  "The Caves of Nothing",
  "Wallet Quest",
  "What's the Deal with ASCII?",
}

function love.load()
  -- Init physics and world
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact)

  local tilesWidth = 60
  local tilesHeight = 60

  -- Screen Settings
  screen.tileSize = 24
  halfTile = screen.tileSize/2
  screen.width = screen.tileSize * 40 -- viewport width
  screen.height = screen.tileSize * 30 -- viewport height
  screen.settings = {
    resizable=true,
  }

  level = Level:new(nil, world, 1)
  local playerInitPos = level.map.upstairs

  --player = Player:new(nil, world, playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile)
  player = Player(playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile)
  ecsWorld:add(player)
  assert(player ~= nil)

  camera = makeCamera(world, playerInitPos.x * screen.tileSize, playerInitPos.y* screen.tileSize)

  font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
  love.graphics.setFont(font)
  love.window.setTitle(randomElement(WINDOW_TITLES))
  love.window.updateMode(screen.width, screen.height, screen.settings)

end

function saveLevel()
  local lvlNum = level.floorNum
  levelTable[lvlNum] = level:getLevelSaveData()
  playerSaveData = player:getSaveData()
  player:destroy()
  player=nil
end

function nextLevel()

  local lvlNum = level.floorNum
  local dstNum = level.floorNum+1
  saveLevel()

  level:destroy()

  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact)

  if levelTable[dstNum] == nil then
    level = Level:new(nil, world, dstNum)
    table.insert(levelTable, level)
    --levelTable[dstNum] = level
  else
    level = Level:restore(nil, world, levelTable[dstNum])
  end

  local playerInitPos = level.map.upstairs
  --player = Player:new(nil, world, playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile)
  player = Player(playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile, playerSaveData)
  ecsWorld:add(player)
  camera = makeCamera(world, playerInitPos.x* screen.tileSize, playerInitPos.y* screen.tileSize)

end

function prevLevel()
  local lvlNum = level.floorNum
  local dstNum = level.floorNum-1
  saveLevel()

  if lvlNum > 1 then
    levelTable[lvlNum] = level:getLevelSaveData()

    level:destroy()

    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact)

    level = Level:restore(nil, world, levelTable[dstNum])
    local playerInitPos = level.map.downstairs
    --player = Player:new(nil, world, playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile)
    player = Player(playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile, playerSaveData)
    ecsWorld:add(player)
    camera = makeCamera(world, playerInitPos.x* screen.tileSize, playerInitPos.y* screen.tileSize)
  end
end

function love.update(dt)

  keyboardUpdate(dt)

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

function love.draw()



  -- Draw level canvas
  if levelCanvas then
    love.graphics.setBackgroundColor(colours.black)
    love.graphics.setColor(1,1,1)
    love.graphics.draw(levelCanvas)
  end

  -- CAMERA SPACE
  love.graphics.translate(-camera:getX(), -camera:getY())

  -- Updates the ECS world. This happens here because
  -- ECS contains a drawing system that can only draw inside of love.draw
  local dt = love.timer.getDelta()
  ecsWorld:update(dt)

  -- / CAMERA SPACE
  love.graphics.translate(camera:getX(), camera:getY())

  if player then drawUI() end

  if blockingText ~= nil then
    displayBlockingText()
  end

end

function drawUI()
  local uiSize = screen.height/5
  local halfWidth = screen.width/2
  local margin = 12
  local lineHeight = 24

  love.graphics.setColor(colours.white)

  -- DRAW GUI
  -- FUTURE OPTIMIZATION - could draw this to canvas on updates instead of re-rendering every screen
  love.graphics.translate(0, 4*uiSize) -- Transform into UI screen space
  love.graphics.setColor(colours.black)
  love.graphics.rectangle('fill', 0, 0, screen.width, uiSize)
  love.graphics.setColor(colours.white)

  love.graphics.print("Jerry the Destroyer", margin, lineHeight)
  love.graphics.print("Dungeon: L"..level:getFloorNum(), margin + halfWidth, lineHeight)

  love.graphics.print("Health: " .. player.HP .. "/"..player.maxHP, margin, 2*lineHeight)
  love.graphics.setColor(colours.green)
  love.graphics.print(getAsciiBar(player.HP, player.maxHP), 216, 2*lineHeight)
  love.graphics.setColor(colours.white)
  love.graphics.print("Magic: 10/10", margin + halfWidth, 2*lineHeight)
  love.graphics.setColor(colours.blue)
  love.graphics.print("[==========]", 216 + halfWidth, 2*lineHeight)

  love.graphics.setColor(colours.white)
  love.graphics.print("X: Sword", margin, 3*lineHeight)
  love.graphics.print("Z: Bombs", margin + halfWidth, 3*lineHeight)
  love.graphics.print(debugString, margin, 4*lineHeight)

  love.graphics.translate(0, -4*uiSize) -- Transform into UI screen space
end

function getAsciiBar(val, max)
  local result = "["
  local numBars = 10 * (val / max)
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
  screen.width = width
  screen.height = height
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

function setBlockingText(text, subtext, time)
  blockingText = {
    text=text,
    subtext=subtext,
    time=time
  }
end

-- ONLY WORKS IF BOTH ITEMS AREN'T THE SAME CLASS
function findObjectOfClassInFixtures(obj1, obj2, className)
  local result = nil
  if obj1.className == className then
    result = obj1
  elseif obj2.className == className then
    result = obj2
  end
  return result
end

function beginContact(fixture1, fixture2, contact)
  local obj1 = fixture1:getUserData()
  local obj2 = fixture2:getUserData()

  -- The only interactions we have to care about in this callback
  -- are ones involving custom classes. If userData isn't set,
  -- then one or more objects isn't from a custom class
  if obj1 == nil or obj2 == nil then return nil end

  local playerObj = findObjectOfClassInFixtures(obj1, obj2, "Player")
  local itemObj = findObjectOfClassInFixtures(obj1, obj2, "Item")

  if playerObj ~=nil and itemObj ~=nil then
    if itemObj.itemName ~= "Coins" then
      itemObj:collect()
    else
      debugString = "5 gold. Too bad you don't have your wallet!"
    end
  end

end

function endContact(fixture1, fixture2, contact)
  debugString = ""
end
