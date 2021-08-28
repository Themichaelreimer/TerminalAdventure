Level = {
  className = "Level",
  traversedTiles = {}, -- Set of visited tiles, formatted as strings like "x;y". Maps to lightness level
  updateQueue = {}, -- List of cells that need to be updated, and the lightness level
  mustUpdateCanvas = true,
  items = {}
}

itemFactory = {
  coins = createCoinsObject,
  map = createMapObject,
  xray = createXRayGlassesObject,
}

-- Generates an entirely new level
function Level:new(o, world, genParams)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  self.genParams = genParams
  self.world = world
  self.map = Map:new()
  self.tileWidth = #self.map.map[0]
  self.tileHeight = #self.map.map
  self.pixelWidth = self.tileWidth * screen.tileSize
  self.pixelHeight = self.tileHeight * screen.tileSize

  self:makePhysicsBody()
  self:resetCanvas() -- Sets the initial value of self.canvas

  self:placeItemInLevel(world, "map")
  self:placeItemInLevel(world, "xray")
  self:placeItemInLevel(world, "coins")
  self:placeItemInLevel(world, "coins")
  self:placeItemInLevel(world, "coins")

  return o
end

--Restores a level by it's saved data
function Level:restore(o, world, map, objects)

end

function Level:destroy()

  -- Free items
  for i=1, #self.items do
    self.items[i]:destroy()
  end

  -- Free canvas
  self.canvas:destroy()

  -- Free physics objects
  --[[
  local bodies = self.world:getBodies()
  for i,body in ipairs(bodies) do
    local fixtures = body:getFixtures()
    for j, fixture in ipairs(fixtures) do
      local shape = fixture:getShape()
      fixture:destroy()
      shape:destroy()
    end
    body:destroy()
  end
  ]]--
  self.world:destroy()


end

function Level:placeItemInLevel(world, itemName, x, y)
  if not x or y then
    x, y = self.map:getRandomEmptyTile()
  end

  -- Convert x and y from tile coords to pixel coords; offset into middle of tile
  x = (x + 0.5)*screen.tileSize
  y = (y + 0.5)*screen.tileSize

  local item
  if itemName == "map" then
    item = createMapObject(world, x, y)
  elseif itemName == 'xray' then
    item = createXRayGlassesObject(world, x, y)
  elseif itemName == 'coins' then
    item = createCoinsObject(world, x, y)
  end
  -- Add 0.5 offset, to put the item in the middle of the cell
  self:addItemToLevel(item)
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
  love.graphics.setColor(1,1,1)
  love.graphics.draw(self.canvas)

  for iItem=1, #self.items do
    self.items[iItem]:draw()
  end

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

  if not hasMap then
    self:resetMapLightness()
    self:resetMapCanvas()
  end

  -- Idea: Cast out rays in equally spaced angles from (x, y)
  -- For each ray cast, and for each space each ray touches, if the lightMap at the sp is darker
  -- than the ray's lightness value for that space, then update the lightMap with the brighter value and redraw the space
  rays = self:rayTrace(x, y, 80)
  for iRay=0, #rays do
    if rays[iRay] ~= nil then
      for iRaySpace=0, #rays[iRay] do
        local data = rays[iRay][iRaySpace]
        if data ~= nil then
          -- If the player has a map, then the lightness is taken as the highest ever value for that space
          -- ie, the space can only get brighter, never darker
          if hasMap then
            if self.map.lightMap[data.y][data.x] < data.lightness then
              self.map.lightMap[data.y][data.x] = data.lightness
              self:redrawCell(data.x, data.y, data.lightness)
            end
          else
            self.map.lightMap[data.y][data.x] = data.lightness
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
  love.graphics.print(self.map.map[y][x].char, x*screen.tileSize, y*screen.tileSize)

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

    local tile = self.map.map[tileY][tileX]

    local result = {
      x = tileX,
      y = tileY,
      distance = i,
      lightness = (maxDistance - i) / maxDistance
    }
    table.insert(results, result)

    -- Terminate the ray if we hit something solid
    if tile.solid and not hasXRay then return results end
  end
  return results
end

function Level:renderEntireCanvas()
  local tileSize = screen.tileSize
  love.graphics.setColor(colours.lightGray) -- nord white
  love.graphics.setCanvas(self.canvas)

  for y=0, #self.map.map do
    for x=0, #self.map.map[y] do
      love.graphics.print(self.map.map[y][x].char, x*tileSize, y*tileSize)
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

function Level:resetMapCanvas()
  love.graphics.setColor(colours.black)
  love.graphics.rectangle("fill", 0, 0, self.pixelWidth, self.pixelHeight)
end

function Level:resetMapLightness()
  for y=0, #self.map.lightMap do
    for x=0, #self.map.lightMap[y] do
      self.map.lightMap[y][x] = 0.0
    end
  end
end

-- PHYSICS CONSTRUCTION

function Level:makePhysicsBody()
  self.body = love.physics.newBody(self.world, 0, 0, "static")
  local tSize = screen.tileSize
  for y=0, #self.map.map do
    for x=0, #self.map.map[y] do
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
  if not self.map.map[y][x].solid then
    return false
  end

  if y > 0 and not self.map.map[y-1][x].solid then
    return true
  elseif y < #self.map.map-1 and not self.map.map[y+1][x].solid then
    return true
  elseif x > 0 and not self.map.map[y][x-1].solid then
    return true
  elseif x < #self.map.map[y]-1 and not self.map.map[y][x+1].solid then
    return true
  end

  return false

end

function Level:addItemToLevel(itemPtr)
  table.insert(self.items, itemPtr)
  --self.items[#self.items] = itemPtr
end

function Level:removeItemFromLevel(itemPtr)
  for i=1, #self.items do
    if self.items[i] == itemPtr then
      table.remove(self.items, i)
    end
  end
end

function Level:getLightnessAtTile(x, y)
  return self.map.lightMap[y][x]
end

function Level:getTileAtCoordinates(x, y)
  -- TODO: Probably better if we can check if x,y are ints already. For now, it's fine to just assume float and round
  return self.map.map[math.floor(y)][math.floor(x)]
end
