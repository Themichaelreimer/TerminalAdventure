screen = {}
map = {}
font = {}
world = {}
camera = {}
player = {}

debugRender = false

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

  player = Player:new(nil, world, initX, initY)
  camera = makeCamera(world, initX, initY)

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

  moveCamera(camera, dt)
  player:update(dt)
  world:update(dt)

end

function updateMapCanvas()
  love.graphics.setColor(colours.lightGray) -- nord white
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

  local uiSize = screen.height/5
  local halfWidth = screen.width/2
  local margin = 12
  local lineHeight = 24

  -- DRAW LEVEL
  love.graphics.setBackgroundColor(colours.black) -- nord black
  love.graphics.translate(-camera:getX(), -camera:getY()) -- Transform into camera space
  love.graphics.draw(levelCanvas)
  player:draw()
  love.graphics.setColor(colours.white) -- nord white

  love.graphics.translate(camera:getX(), camera:getY()) -- Transform back to screen space

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
  love.graphics.print("Z:", margin, 4*lineHeight)

end

function love.resize(width, height)
  screen.width = width
  screen.height = height
  levelCanvas = love.graphics.newCanvas(map.widthPixels, map.heightPixels)
  updateMapCanvas()
end
