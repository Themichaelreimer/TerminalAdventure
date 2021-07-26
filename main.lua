player = {} -- player body
playerBox = {}
playerData = {}
screen = {}
map = {}
font = {}
world = {}

debugRender = false

require("levelgen")
require("player")

function love.load()
  -- Init physics and world
  world = love.physics.newWorld(0, 0, true)

  player = love.physics.newBody(world, 400, 300, "dynamic")
  player:setFixedRotation(true)
  playerData.size = 22  -- 16 x 16
  playerData.moveSpeed = 100  -- 1 to 5 is good, with 5 being max upgraded
  playerBox = love.physics.newRectangleShape(-5, 5, playerData.size, playerData.size)
  love.physics.newFixture(player, playerBox)
  
  -- Screen Settings
  screen.tileSize = 24
  screen.width = screen.tileSize * 40
  screen.height = screen.tileSize * 30
  screen.settings = {
    resizable=true,
  }
  
  font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
  love.graphics.setFont(font)
  love.window.updateMode(screen.width, screen.height, screen.settings)
  
  -- Generate Level
  map = makeSimplexCave(100, 100, caveGenParams)
  makePhysicsBody(map, world)
  levelCanvas = love.graphics.newCanvas(screen.width, screen.height)
  updateMapCanvas()

end

function love.update(dt)
  
  playerUpdate(dt,player)
  world:update(dt)

end

function updateMapCanvas()
  love.graphics.setCanvas(levelCanvas)
  local tileSize = screen.tileSize
  for y=0, #map do
    for x=0, #map[y] do
      love.graphics.print(map[y][x].char, x*tileSize, y*tileSize)
    end
  end
  
  -- DEBUG REGION
  -- Draw bounding boxes for physics; can be deleted once physics works
  if debugRender then 
    love.graphics.setColor(0.5, 0.1, 0.1,0.5)
    bodies = world:getBodies()
    body = bodies[1]
    for k,v in pairs(body:getFixtures()) do
      love.graphics.polygon("fill", body:getWorldPoints(v:getShape():getPoints()))
    end
    love.graphics.setColor(1, 1, 1, 1)
  end
  
  love.graphics.setCanvas()
end

function love.draw(dt)
  love.graphics.draw(levelCanvas)
  local playerStep = 2*math.sin((player:getX() + player:getY())/4)
  local tSize = screen.tileSize
  love.graphics.print("@", player:getX()-tSize/2, player:getY()-tSize/2 + playerStep, player:getAngle())
  
  -- DEBUG 
  if debugRender then
    love.graphics.setColor(0.1, 0.1, 0.5, 0.5)
    love.graphics.polygon("fill", player:getWorldPoints(playerBox:getPoints()))
    love.graphics.setColor(1, 1, 1, 1)
  end
  
end

function love.resize(width, height)
  screen.width = width
  screen.height = height
  levelCanvas = love.graphics.newCanvas(screen.width, screen.height)
  updateMapCanvas()
end