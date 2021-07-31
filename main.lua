player = {} -- player body
playerBox = {}
playerData = {}
screen = {}
map = {}
font = {}
world = {}
camera = {}

debugRender = true

require("levelgen")
require("player")
require("camera")
require("colours")

colours = japanesque

-- Basically an enum; at most 16 entries allowed
collisionCategories = {
  player= 16,
  enemies= 2,
  walls= 3,
}

function love.load()
  -- Init physics and world
  world = love.physics.newWorld(0, 0, true)
  
  -- TODO: Determine start point in the world instead of this hardcoded spot
  local tilesWidth = 60
  local tilesHeight = 60
  local initX = 400
  local initY = 300
  
  camera = makeCamera(world, initX, initY)

  player = love.physics.newBody(world, initX, initY, "dynamic")
  player:setFixedRotation(true)
  playerData.size = 22 
  playerData.moveSpeed = 100  
  playerBox = love.physics.newRectangleShape(-5, 5, playerData.size, playerData.size)
  love.physics.newFixture(player, playerBox)
  
  -- Screen Settings
  screen.tileSize = 24
  screen.width = screen.tileSize * 40 -- viewport width
  screen.height = screen.tileSize * 30 -- viewport height
  screen.settings = {
    resizable=true,
  }
  
  font = love.graphics.newFont("VeraMono.ttf", screen.tileSize)
  love.graphics.setFont(font)
  love.window.updateMode(screen.width, screen.height, screen.settings)
  
  -- Generate Level
  map = makeSimplexCave(tilesWidth, tilesHeight, caveGenParams)
  makePhysicsBody(map.map, world)
  levelCanvas = love.graphics.newCanvas(tilesWidth * screen.tileSize, tilesHeight * screen.tileSize)
  updateMapCanvas()

end

function love.update(dt)
  
  moveCamera(camera, player, dt)
  playerUpdate(dt,player)
  world:update(dt)

end

function updateMapCanvas()
  love.graphics.setColor(colours.white) -- nord white
  love.graphics.setCanvas(levelCanvas)
  local tileSize = screen.tileSize
  for y=0, #map.map do
    for x=0, #map.map[y] do
      love.graphics.print(map.map[y][x].char, x*tileSize, y*tileSize)
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
  love.graphics.setBackgroundColor(colours.black) -- nord black
  love.graphics.translate(-camera:getX(), -camera:getY())
  love.graphics.draw(levelCanvas)
  drawPlayer(player)
  love.graphics.setColor(colours.white) -- nord white
  
end

function love.resize(width, height)
  screen.width = width
  screen.height = height
  levelCanvas = love.graphics.newCanvas(map.widthPixels, map.heightPixels)
  updateMapCanvas()
end