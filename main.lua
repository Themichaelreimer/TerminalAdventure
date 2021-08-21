screen = {}
level = {}
font = {}
world = {}
camera = {}
player = {}
debugString = ""

debugRender = false
normalizeDiagonalSpeed = true
seed = love.math.random()*10000,

require("map")
require("level")
require("player")
require("camera")
require("colours")
require("items")

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

function love.load()
  -- Init physics and world
  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact)

  -- TODO: Determine start point in the world instead of this hardcoded spot

  local tilesWidth = 60
  local tilesHeight = 60


  -- Screen Settings
  screen.tileSize = 24
  screen.width = screen.tileSize * 40 -- viewport width
  screen.height = screen.tileSize * 30 -- viewport height
  screen.settings = {
    resizable=true,
  }

  level = Level:new(nil, world)
  local playerInitPos = level.map.upstairs
  player = Player:new(nil, world, playerInitPos.x * screen.tileSize, playerInitPos.y * screen.tileSize)
  camera = makeCamera(world, playerInitPos.x* screen.tileSize, playerInitPos.y* screen.tileSize)

  font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
  love.graphics.setFont(font)
  love.window.updateMode(screen.width, screen.height, screen.settings)



end

function love.update(dt)

  if blockingText == nil then
    moveCamera(camera, dt)
    player:update(dt)
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

  local uiSize = screen.height/5
  local halfWidth = screen.width/2
  local margin = 12
  local lineHeight = 24

  level:updateLevelCanvas()

  -- CAMERA SPACE
  love.graphics.translate(-camera:getX(), -camera:getY())

  level:draw()
  player:draw()
  love.graphics.setColor(colours.white) -- nord white

  -- SCREEN SPACE
  love.graphics.translate(camera:getX(), camera:getY())

  -- DRAW GUI
  love.graphics.translate(0, 4*uiSize) -- Transform into UI screen space
  love.graphics.setColor(colours.black)
  love.graphics.rectangle('fill', 0, 0, screen.width, uiSize)
  love.graphics.setColor(colours.white)

  love.graphics.print("Jerry the Destroyer", margin, lineHeight)
  love.graphics.print("Dungeon: L1", margin + halfWidth, lineHeight)

  love.graphics.print("Health: 24/24", margin, 2*lineHeight)
  love.graphics.setColor(colours.green)
  love.graphics.print("[==========]", 216, 2*lineHeight)
  love.graphics.setColor(colours.white)
  love.graphics.print("Magic: 10/10", margin + halfWidth, 2*lineHeight)
  love.graphics.setColor(colours.blue)
  love.graphics.print("[==========]", 216 + halfWidth, 2*lineHeight)

  love.graphics.setColor(colours.white)
  love.graphics.print("X: Sword", margin, 3*lineHeight)
  love.graphics.print("Z:", margin + halfWidth, 3*lineHeight)
  love.graphics.print(debugString, margin, 4*lineHeight)

  love.graphics.translate(0, -4*uiSize) -- Transform into UI screen space

  if blockingText ~= nil then
    displayBlockingText()
  end

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
