tiles={
  floor = {char='.', solid=false, color='white'},
  wall = {char='#', solid=true, color='white'},
  water = {char='~', solid=true, color='blue'}
}

caveGenParams={
  seed= love.math.random()*10000,
  smoothness = 10,  -- Somewhere in the 8-20 range is probably good
  wallThreshold = 0.6,
  waterThreshold= 0.0 -- Setting water this way looks a little too "normal"
}

Level = {
  className = "Level"
}

function Level:new(o, world, genParams)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  self.genParams = genParams
  self.tileWidth = 60
  self.tileHeight = 60
  self.pixelWidth = self.tileWidth * screen.tileSize
  self.pixelHeight = self.tileHeight * screen.tileSize
  self.world = world

  self:makeSimplexCave(self.tileWidth, self.tileHeight)
  self:makePhysicsBody()
  self:resetCanvas() -- Sets the initial value of self.canvas
  self:renderEntireCanvas()

  return o
end

function Level:update(dt)

end

function Level:draw(dt)
  love.graphics.setBackgroundColor(colours.black) -- nord black
  love.graphics.draw(self.canvas)
end

function Level:resetCanvas()
  self.canvas = love.graphics.newCanvas(self.pixelWidth, self.pixelHeight)
end

function Level:renderEntireCanvas()
  local tileSize = screen.tileSize
  love.graphics.setColor(colours.lightGray) -- nord white
  love.graphics.setCanvas(self.canvas)

  for y=0, #self.map do
    for x=0, #self.map[y] do
      love.graphics.print(self.map[y][x].char, x*tileSize, y*tileSize)
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

-- PHYSICS CONSTRUCTION

function Level:makePhysicsBody()
  self.body = love.physics.newBody(self.world, 0, 0, "static")
  local tSize = screen.tileSize
  for y=0, #self.map do
    for x=0, #self.map[y] do
      if self:spaceNeedsCollider(x, y) then
        local tarX = (x + 0.3) * tSize
        local tarY= (y + 0.6) * tSize
        local shape = love.physics.newRectangleShape(tarX, tarY, tSize, tSize)
        local fixture = love.physics.newFixture(self.body, shape)
      end
    end
  end
end

function Level:spaceNeedsCollider(x, y)
  -- Determines whether this space needs a collider
  -- Decided via being a solid space, adjacent to a not-solid space
  if not self.map[y][x].solid then
    return false
  end

  if y > 0 and not self.map[y-1][x].solid then
    return true
  elseif y < #self.map-1 and not self.map[y+1][x].solid then
    return true
  elseif x > 0 and not self.map[y][x-1].solid then
    return true
  elseif x < #self.map[y]-1 and not self.map[y][x+1].solid then
    return true
  end

  return false

end

-- LOGICAL LEVEL GENERATION

function Level:makeSimplexCave(width, height)
  self.map = {}
  for y=0, height do
    self.map[y] = {}
    for x=0, width do
      self.map[y][x] = self:determineTile(x, y)
    end
  end
end

function Level:determineTile(x, y)
  local simp = love.math.noise( (x + self.genParams.seed) / self.genParams.smoothness, (y + self.genParams.seed) / self.genParams.smoothness)
  if simp > self.genParams.wallThreshold then
      return tiles.wall
  end
  if simp < self.genParams.waterThreshold then
    return tiles.water
  end
  return tiles.floor
end
