tiles={
  floor = {char='.', solid=false, color='white'},
  wall = {char='#', solid=true, color='white'},
  water = {char='~', solid=true, color='blue'},
  stairsUp = {char='<', solid=false, color='white'},
  stairsDown = {char='>', solid=false, color='white'},
}

Map = {
  className = "Map"
  -- Lightmap
  -- tileMap
}

MapManager = {
  maps = {}
}

function Map:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  -- TODO: Use RNG to determine which algorithm to use
  -- Also TODO: Implement more than one algorithm

  local params = generateSimplexGenParams()
  self.width = params.width
  self.height = params.height
  self.map, self.lightMap = makeSimplexCave(params)
  return o
end

function generateSimplexGenParams()
  -- This function generates the parameters used to generate a map
  -- This includes things like width, height, and the proportion of walls to open space
  local result = {
    width = math.random(100,400),
    height = math.random(100,400),
    wallThreshold = 0.4 * math.random() + 0.3,
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
