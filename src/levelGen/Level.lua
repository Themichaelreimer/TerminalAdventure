local Level = class("Level")

require('src.entities.items')
Map = require("src.levelGen.map")

-- Generates an entirely new level
function Level:init(floorNum, data)

  if data then
    self:restore(data)
  else
    self.map = Map()
    self.tileWidth = #self.map.map[0]
    self.tileHeight = #self.map.map
    self.pixelWidth = self.tileWidth * screen.tileSize
    self.pixelHeight = self.tileHeight * screen.tileSize
    self.items = {}
    self.traversedTiles = {} -- Set of visited tiles, formatted as strings like "x;y". Maps to lightness level
    self.mustUpdateCanvas = true
    self.floorNum = floorNum
    self.projectiles = {}
    self.colliders = {}
    levelCanvas = love.graphics.newCanvas(self.pixelWidth, self.pixelHeight)

    self:makePhysicsBody()
    self:makeLevelBoundaryCollider()

    self:placeItemInLevel("map")
    self:placeItemInLevel("xray")

    for i=0, 3 do
      self:placeEnemyInLevel("Snake")
    end

    for i=0, 3 do
      self:placeEnemyInLevel("Jackal")
    end

    for i=0, 3 do
      self:placeEnemyInLevel("Plush")
    end
  end
end

function Level:makeLevelBoundaryCollider()
  -- Makes 4 edges for the level boundary. Cleaned up when the world is deleted on floor transitions
  local half = screen.tileSize/2
  local body = love.physics.newBody(world, 0, 0, "static")
  local top = love.physics.newEdgeShape(0-half,0-half,self.pixelWidth+half*2,0-half)
  local right = love.physics.newEdgeShape(self.pixelWidth+half*2, 0-half*2, self.pixelWidth+half*2, self.pixelHeight+half*2)
  local bottom = love.physics.newEdgeShape(self.pixelWidth+half*2, self.pixelHeight+half*2, 0-half, self.pixelHeight+half*2)
  local left = love.physics.newEdgeShape(0-half, self.pixelHeight+half*2, 0-half, 0-half)
  love.physics.newFixture(body, top, 1)
  love.physics.newFixture(body, bottom, 1)
  love.physics.newFixture(body, left, 1)
  love.physics.newFixture(body, right, 1)
end

function Level:getFloorNum()
  return self.floorNum
end

function Level:getLevelSaveData()
  local result = {
    mapData = self.map:getSaveData(),
    floorNum = self.floorNum,
    items = {},
  }

  for i=1, #self.items do
    local saveItem = {
      x = self.items[i].x,
      y = self.items[i].y,
      itemName = self.items[i]:getInternalItemName()
    }
    table.insert(result.items, saveItem)
  end

  return result
end

--Restores a level by it's saved data
function Level:restore(data)
  self.map = Map(data.mapData)

  self.tileWidth = #self.map.map[0]
  self.tileHeight = #self.map.map
  self.pixelWidth = self.tileWidth * screen.tileSize
  self.pixelHeight = self.tileHeight * screen.tileSize
  levelCanvas = love.graphics.newCanvas(pixelWidth, pixelHeight)

  self.items = {}
  for i=1, #data.items do
    local itemObj = data.items[i]
    self:placeItemInLevel(itemObj.itemName, itemObj.x, itemObj.y )
  end

  self.projectiles = {}
  self.colliders = {}

  self.floorNum = data.floorNum
  self:makePhysicsBody()
end

function Level:destroy()

  -- Free items
  for i=1, #self.items do
    if self.items[i] ~= nil then
      self.items[i]:tearDown()
    end
    self.items = {}
  end

  world:destroy()

end

function Level:placeEnemyInLevel(name, x, y)
  if not x or not y then
    x, y = self.map:getRandomEmptyTile()
  end
  if name == "Snake" then
    makeSnake(x, y)
  elseif name == "Jackal" then
    makeJackal(x, y)
  elseif name == "Plush" then
    makePlush(x, y)
  end
end

function Level:placeItemInLevel(itemName, x, y)
  if not x or not y then
    x, y = self.map:getRandomEmptyTile()
  end
  x = (x+0.5)*screen.tileSize
  y = (y+0.5)*screen.tileSize

  local item
  if itemName == "map" then
    makeMap(x, y, true)
  elseif itemName == 'xray' then
    makeXRay(x, y, true)
  elseif itemName == 'coins' then
    -- Add coins if I ever put them back in
  end
end

function Level:update(dt)

end

function Level:draw(dt)

end

function getTileKey(x,y)
  return x .. ";" .. y
end

-- PHYSICS CONSTRUCTION

function Level:makeCollider(x, y)
  local tSize = screen.tileSize
  local tarX = (x + 0.3) * tSize
  local tarY = (y + 0.6) * tSize
  local body = love.physics.newBody(world, 0, 0, "static")
  local shape = love.physics.newRectangleShape(tarX, tarY, tSize, tSize)
  local fixture = love.physics.newFixture(body, shape)
  self.colliders[getTileKey(x,y)] = fixture
end

function Level:makePhysicsBody()
  for y=0, #self.map.map do
    for x=0, #self.map.map[y] do
      if self:spaceNeedsCollider(x, y) then
        self:makeCollider(x, y)
      end
    end
  end
end

function Level:recalculateWallColliders(startX, startY, endX, endY)
  for y=startY, endY do
    for x=startX, endX do
      if self:spaceNeedsCollider(x, y) and self.colliders[getTileKey(x,y)] == nil then
        self:makeCollider(x, y)
      elseif self.colliders[getTileKey(x,y)] ~= nil and not self:spaceNeedsCollider(x, y) then
        self:destroyCollider(x, y)
      end
    end
  end
end

function Level:destroyCollider(x, y)
  local fixture = self.colliders[getTileKey(x, y)]
  local shape = fixture:getShape()
  local body = fixture:getBody()
  fixture:destroy()
  shape:release()
  body:destroy()

  self.colliders[getTileKey(x, y)] = nil
end

function Level:spaceNeedsCollider(x, y)
  -- Determines whether this space needs a collider
  -- Decided via being a solid space, adjacent to a not-solid space
  if not self:tileInLevel(x, y) or not self.map.map[y][x].solid then
    return false
  end

  if y > 0 and not self.map.map[y-1][x].solid then
    return true
  elseif y < #self.map.map and not self.map.map[y+1][x].solid then
    return true
  elseif x > 0 and not self.map.map[y][x-1].solid then
    return true
  elseif x < #self.map.map[y] and not self.map.map[y][x+1].solid then
    return true
  end
  return false
end

function Level:tileInLevel(x, y)
  if (0 <= y and y <= #self.map.map) then
    return (0 <= x and x <= #self.map.map[0])
  end
  return false
end

function Level:getLightnessAtTile(x, y)
  if not self:tileInLevel(x, y) then return 0 end
  return self.map.lightMap[y][x]
end

function Level:getTileAtCoordinates(x, y)
  if not self:tileInLevel(x, y) then return nil end
  return self.map.map[math.floor(y)][math.floor(x)]
end

return Level
