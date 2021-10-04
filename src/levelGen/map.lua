local Map = class("Map")

function Map:init(data, mapData)
  if data then
    self:restore(data)
  else
    self.map, self.lightMap = self:makeTileMap()

    self.width = #self.map[0]
    self.height = #self.map

    local stairs = self:placeStairs()
    self.upstairs = stairs.up
    self.downstairs = stairs.down
    -- Generates nil error somehow
    self.map[self.upstairs.y][self.upstairs.x] = tiles.upstairs
    self.map[self.downstairs.y][self.downstairs.x] = tiles.downstairs
  end
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
  }
end

function Map:placeStairs()

  local up = nil
  local down = nil

  local x, y = self:getRandomEmptyTile()

  up = {
    x = x,
    y = y
  }

  x,y = self:getRandomEmptyTile()

  down = {
    x = x,
    y = y
  }

  return {
    up = up,
    down = down
  }
end

function Map:getRandomEmptyTile()
  local x = math.random(0, self.width)
  local y = math.random(0, self.height)
  while self.map[y][x].solid or self.map[y][x].aiAvoid do
    x = math.random(0, self.width)
    y = math.random(0, self.height)
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
    width = math.random(60,80),
    height = math.random(60,80),
    wallThreshold = (0.4 * math.random()) + 0.3,
    smoothness = math.random(8,20),
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
