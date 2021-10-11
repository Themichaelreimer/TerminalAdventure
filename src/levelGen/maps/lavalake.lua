local Map = require('src.levelGen.map')

local LavaLake = Map:extend("LavaLake")

function LavaLake:makeTileMap()
  local params = self:generateParams()
  return self:makeLavaLake(params)  -- Lightmap isn't really a function of map, but it's faster this way
end

function LavaLake:generateParams()
  -- This function generates the parameters used to generate a map
  -- This includes things like width, height, and the proportion of walls to open space
  local result = {
    width = math.random(60,80),
    height = math.random(60,80),
    wallThreshold = 0.93,
    smoothness = math.random(8,20),

    lavaProbability = (0.2 * love.math.random()) + 0.2,
    lavaSmoothness = math.random(6,15),
  }
  return result
end

function LavaLake:makeLavaLake(genParams)
  local lightMap = {}
  local map = {}
  for y=0, genParams.height do
    map[y] = {}
    lightMap[y] = {}
    for x=0, genParams.width do
      map[y][x] = self:determineTile(x, y, genParams)
      lightMap[y][x] = 0.0
    end
  end
  return map, lightMap
end

function LavaLake:determineTile(x, y, genParams)
  local simp = love.math.noise( (x + seed) / genParams.smoothness, (y + seed) / genParams.smoothness)
  if simp > genParams.wallThreshold then
      return tiles.wall
  end
  local lavaSimplex = love.math.noise( (x + 2*seed) / genParams.lavaSmoothness, (y + 2*seed) / genParams.lavaSmoothness)
  if lavaSimplex > genParams.lavaProbability then
    return tiles.floor
  else
    return tiles.lava
  end
end

return LavaLake
