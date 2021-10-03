local Map = require('src.levelGen.map')

local SimplexCave = Map:extend("SimplexCave")

function SimplexCave:makeTileMap()
  local params = self:generateSimplexGenParams()
  return self:makeSimplexCave(params)  -- Lightmap isn't really a function of map, but it's faster this way
end

function SimplexCave:generateSimplexGenParams()
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

function SimplexCave:makeSimplexCave(genParams)
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

function SimplexCave:determineTile(x, y, genParams)
  local simp = love.math.noise( (x + seed) / genParams.smoothness, (y + seed) / genParams.smoothness)
  if simp > genParams.wallThreshold then
      return tiles.wall
  end
  return tiles.floor
end

return SimplexCave
