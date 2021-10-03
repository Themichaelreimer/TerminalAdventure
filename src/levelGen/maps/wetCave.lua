local Map = require('src.levelGen.map')

local WetCave = Map:extend("WetCave")

function WetCave:makeTileMap()
  local params = self:generateParams()
  return self:makeWetCave(params)  -- Lightmap isn't really a function of map, but it's faster this way
end

function WetCave:generateParams()
  -- This function generates the parameters used to generate a map
  -- This includes things like width, height, and the proportion of walls to open space
  local result = {
    width = math.random(60,80),
    height = math.random(60,80),
    wallThreshold = (0.3 * math.random()) + 0.6,
    smoothness = math.random(8,20),

    waterProbability = (0.4 * love.math.random()) + 0.2,
    waterSmoothness = math.random(10,25),
  }
  return result
end

function WetCave:makeWetCave(genParams)
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

function WetCave:determineTile(x, y, genParams)
  local simp = love.math.noise( (x + seed) / genParams.smoothness, (y + seed) / genParams.smoothness)
  if simp > genParams.wallThreshold then
      return tiles.wall
  end
  local waterSimplex = love.math.noise( (x + 2*seed) / genParams.waterSmoothness, (y + 2*seed) / genParams.waterSmoothness)
  if waterSimplex > genParams.waterProbability then
    return tiles.floor
  else
    return tiles.water
  end
end

return WetCave
