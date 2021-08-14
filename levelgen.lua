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
  className = "Level",
  traversedTiles = {}, -- Set of visited tiles, formatted as strings like "x;y". Maps to lightness level
  updateQueue = {}, -- List of cells that need to be updated, and the lightness level
  mustUpdateCanvas = true
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

  self.tileUpdateQueue = {}

  return o
end

function Level:update(dt)
  local playerX, playerY = player:getMapCoordinates()
  local tileKey = getTileKey(playerX, playerY)
  --debugString = tileKey
  if self.traversedTiles[tileKey] == nil or true then
    self.traversedTiles[tileKey] = true
    self:updateCanvasLighting(playerX, playerY, 3)
    self.mustUpdateCanvas = true
  end
end

function Level:draw(dt)
  love.graphics.setBackgroundColor(colours.black) -- nord black
  love.graphics.draw(self.canvas)
end

function getTileKey(x,y)
  return x .. ";" .. y
end

function Level:updateLevelCanvas()
  -- MUST HAPPEN IN love.draw(), otherwise changes won't stick
  if self.mustUpdateCanvas then
    local playerX, playerY = player:getMapCoordinates()
    self:updateCanvasLighting(playerX, playerY, 10)
    self.mustUpdateCanvas = false
  end
end

function Level:resetCanvas()
  self.canvas = love.graphics.newCanvas(self.pixelWidth, self.pixelHeight)
end

function Level:updateCanvasLighting(x, y, dist)
  local tileSize = screen.tileSize
  love.graphics.setCanvas(self.canvas)

  --[[
  local yMin = math.max(0, y-dist)
  local yMax = math.min(y+dist, #self.map)
  local xMin = math.max(0, x-dist)
  local xMax = math.min(x+dist, #self.map[y])


  for ly=yMin, yMax do
    for lx=xMin, xMax do
      if self.lightMap[y][x] < 1.0 then
        local dx = lx-x
        local dy = ly-y
        local lightness = 50 / (2*((dx*dx) + (dy*dy)))
        --local lightness = 1.0
        lightness = math.min(lightness, 1.0)
        lightness = math.max(lightness, 0.0)

        self:redrawCell(lx, ly, lightness)
        --self.lightMap[ly][lx] = lightness
      end
    end
  end
  ]]--

  -- Idea: Cast out 45 rays in equally spaced angles from (x, y)
  -- For each ray cast, and for each space each ray touches, if the lightMap at the sp is darker
  -- than the ray's lightness value for that space, then update the lightMap with the brighter value and redraw the space
  rays = self:rayTrace(x, y, 45)
  for iRay=0, #rays do
    if rays[iRay] ~= nil then
      for iRaySpace=0, #rays[iRay] do
        local data = rays[iRay][iRaySpace]
        if data ~= nil then
          -- If the player has a map, then the lightness is taken as the highest ever value for that space
          -- ie, the space can only get brighter, never darker
          if hasMap then
            if self.lightMap[data.y][data.x] < data.lightness then
              self.lightMap[data.y][data.x] = data.lightness
              self:redrawCell(data.x, data.y, data.lightness)
              print("DRAW (" .. data.x .. ", ".. data.y .. ")")
            end
          else
            print("NO MAP")
            self:redrawCell(data.x, data.y, data.lightness)
          end
        end
      end
    end
  end

  love.graphics.setCanvas()
end

function Level:redrawCell(x, y, alpha)

  local tileSize = screen.tileSize
  local colour = colours.lightGray

  --Blank out cell. Looks more weird if we don't do this
  love.graphics.setColor(colours.black)
  love.graphics.rectangle("fill", x*tileSize, y*tileSize, tileSize, tileSize)

  --Draw
  love.graphics.setColor(colour[1], colour[2], colour[3], alpha)
  love.graphics.print(self.map[y][x].char, x*screen.tileSize, y*screen.tileSize)

end

function Level:rayTrace(x, y, numRays)
  local maxdist = 10
  local results = {}
  for iAngle=0, numRays do
    local rads = 2 * math.pi * iAngle / numRays
    table.insert(results, self:traceRay(x, y, rads, maxdist))
  end
  return results
end

function Level:traceRay(x, y, angle, maxDistance)
  local results = {}
  local angleX = math.cos(angle) -- Contribution of the angle to dx / dy
  local angleY = math.sin(angle)
  local dx = 0 -- Stores the change in x/y from the movement of the ray
  local dy = 0
  for i=0, maxDistance do
    dx = dx + angleX
    dy = dy + angleY

    -- The use of math.floor is arbitrary, since we need a round, but the round
    -- doesn't have to be exact. As long as we're consistently off by the
    -- same amount for each ray, it should be fine
    local tileX = math.floor(x + dx)
    local tileY = math.floor(y + dy)

    -- Stop the raycast if we go off the map. Return previous results
    if tileY < 0 or tileY > self.tileHeight then return results end
    if tileX < 0 or tileX > self.tileWidth then return results end

    local tile = self.map[tileY][tileX]

    local result = {
      x = tileX,
      y = tileY,
      distance = i,
      lightness = (maxDistance - i) / maxDistance
    }
    table.insert(results, result)

    -- Terminate the ray if we hit something solid
    if tile.solid then return results end
  end
  return results
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
  -- / DEBUG REGION
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
-- These methods initialize self.map, which controls theoretical level data, and self.lightMap, which stores
-- cell lightness levels

function Level:makeSimplexCave(width, height)
  self.lightMap = {}
  self.map = {}
  for y=0, height do
    self.map[y] = {}
    self.lightMap[y] = {}
    for x=0, width do
      self.map[y][x] = self:determineTile(x, y)
      self.lightMap[y][x] = 0.0
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
