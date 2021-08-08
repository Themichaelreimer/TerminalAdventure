screen = {}
level = {}
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
  local initX = 24 * 40
  local initY = 24 * 30

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

  level = Level:new(nil, world, caveGenParams)

end

function love.update(dt)

  moveCamera(camera, dt)
  player:update(dt)
  level:update(dt)
  world:update(dt)

end


function love.draw(dt)

  local uiSize = screen.height/5
  local halfWidth = screen.width/2
  local margin = 12
  local lineHeight = 24

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
  love.graphics.print("Z:", margin, 4*lineHeight)

end

function love.resize(width, height)
  screen.width = width
  screen.height = height
end
