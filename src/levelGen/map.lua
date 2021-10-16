local Map = class("Map")

function Map:init(data, mapData)
  if data then
    self:restore(data)
  else
    self.map, self.lightMap = self:makeTileMap()
    self.numHealthUpgradesPerLevel = 1

    self.width = #self.map[0]
    self.height = #self.map

    local easyStairs = mapData.floorNum < 4
    local stairs = self:placeStairs(easyStairs)
    self.ents = self:placeEntities(mapData.items, mapData.floorNum, stairs.up)

    self.upstairs = stairs.up
    self.downstairs = stairs.down
    -- Generates nil error somehow
    self.map[self.upstairs.y][self.upstairs.x] = tiles.upstairs
    self.map[self.downstairs.y][self.downstairs.x] = tiles.downstairs
  end
end

function Map:tileInLevel(x, y)
  if (0 <= y and y <= #self.map) then
    return (0 <= x and x <= #self.map[0])
  end
  return false
end

function Map:placeEntities(floorItems, floorNum, start)
  -- Place items
  result = {}
  local halfTile = screen.tileSize/2
  for k, v in pairs(floorItems) do
    local entry = {name = v.name}
    local easy = v.easyAccess

    if easy then
      local path = nil
      local spot = nil
      while not path do
        spotX, spotY = self:getRandomEmptyTile()
        path = findPathBetweenCells(self, start.x, start.y, spotX, spotY, 0, 5000)
      end
      entry.x = spotX*screen.tileSize + halfTile
      entry.y = spotY*screen.tileSize + halfTile
      table.insert(result, entry)

    else
      local spotX, spotY = self:getRandomEmptyTile()
      entry.x = spotX*screen.tileSize + halfTile
      entry.y = spotY*screen.tileSize + halfTile
      table.insert(result, entry)
    end

  end

  for i=1, self.numHealthUpgradesPerLevel do
    local spotX, spotY = self:getRandomEmptyTile()
    entry = {name="LifeUpItem"}
    entry.x = spotX*screen.tileSize + halfTile
    entry.y = spotY*screen.tileSize + halfTile
    table.insert(result, entry)
  end

  -- Select and place enemeis
  for k, name in pairs(floorEnemies) do
    local numToSpawn = floorEnemies[k][floorNum]
    for i=1,numToSpawn do
      local spotX, spotY = self:getRandomEmptyTile(10,start)
      local entry = {
        name = k,
        x = spotX*screen.tileSize + halfTile,
        y = spotY*screen.tileSize + halfTile
      }
      table.insert(result, entry)
    end
  end
  return result
end

function Map:makeTileMap()
  -- IMPLEMENT ME IN SUB CLASSES
end

function Map:restore(data)
  self.upstairs = data.upstairs
  self.downstairs = data.downstairs
  self.map = data.tileMap
  self.lightMap = data.lightMap
  self.width = #self.map[0]
  self.height = #self.map
end

function Map:getSaveData()
  return {
    tileMap = self.map,
    lightMap = self.lightMap,
    upstairs = self.upstairs,
    downstairs = self.downstairs,
    ents = self.ents  -- This is only used the first time a level is loaded, after that levelManager handles entities
  }
end

function Map:placeStairs(easy)

  local up
  local down
  local path
  while not path do
    local x1, y1 = self:getRandomEmptyTile()
    local x2, y2 = self:getRandomEmptyTile()
    path = findPathBetweenCells(self, x1, y1, x2, y2, 0, 50000)
    if easy == false then path = true end -- the actual path doesn't matter, only matters if it's defined
    up = {x = x1, y = y1}
    down = {x = x2, y = y2}
  end

  return {
    up = up,
    down = down
  }
end

function Map:getRandomEmptyTile(minDist, spot)
  local x = love.math.random(0, self.width)
  local y = love.math.random(0, self.height)
  minDist = minDist or 1
  spot = spot or {x=0,y=0}
  local dist = math.sqrt((x-spot.x)*(x-spot.x) + (y-spot.y)*(y-spot.y))
  while self.map[y][x].solid or self.map[y][x].aiAvoid or dist < minDist do
    x = love.math.random(0, self.width)
    y = love.math.random(0, self.height)
    dist = math.sqrt((x-spot.x)*(x-spot.x) + (y-spot.y)*(y-spot.y))
  end
  return x, y
end

-----------------------------------------------------------------------------------------------------------------------
-- Procedural procedural-generation functions. Ie, pure functions
-----------------------------------------------------------------------------------------------------------------------
function generateSimplexGenParams()
  -- This function generates the parameters used to generate a map
  -- This includes things like width, height, and the proportion of walls to open space
  local result = {
    width = love.math.random(60,80),
    height = love.math.random(60,80),
    wallThreshold = (0.4 * love.math.random()) + 0.3,
    smoothness = love.math.random(8,20),
  }
  return result
end

function makeSimplexCave(genParams)
  local lightMap = {}
  local map = {}
  for y=0, genParams.height do
    map[y] = {}
    lightMap[y] = {}
    for x=0, genParams.width do
      map[y][x] = determineTile(x, y, genParams)
      lightMap[y][x] = 0.0
    end
  end
  return map, lightMap
end

function determineTile(x, y, genParams)
  local simp = love.math.noise( (x + seed) / genParams.smoothness, (y + seed) / genParams.smoothness)
  if simp > genParams.wallThreshold then
      return tiles.wall
  end
  return tiles.floor
end

return Map
