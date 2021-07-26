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

-- PHYSICS CONSTRUCTION

function makePhysicsBody(map, world)
  -- idea: scanlines maybe?
  local body = love.physics.newBody(world, 0, 0, "static")
  local tSize = screen.tileSize
  for y=0, #map do
    for x=0, #map[y] do
      if spaceNeedsCollider(map, x, y) then
        local tarX = (x+0.3) * tSize
        local tarY= (y+0.6) * tSize
        local shape = love.physics.newRectangleShape(tarX, tarY, tSize, tSize)
        local fixture = love.physics.newFixture(body, shape)
      end
    end
  end
  return body
end

function spaceNeedsCollider(map, x, y)
  -- Determines whether this space needs a collider
  if not map[y][x].solid then
    return false
  end
  
  if y > 0 and not map[y-1][x].solid then
    return true
  elseif y < #map-1 and not map[y+1][x].solid then
    return true
  elseif x > 0 and not map[y][x-1].solid then
    return true
  elseif x < #map[y]-1 and not map[y][x+1].solid then
    return true
  end
  
  return false
  
end

-- LOGICAL LEVEL GENERATION

function makeSimplexCave(width, height, params)
  local map = {}
  for y=0, height do
    map[y] = {}
    for x=0, width do
      map[y][x] = determineTile(x,y,params)
    end
  end
  return map
end

function determineTile(x,y,genParams)
  local simp = love.math.noise( (x + genParams.seed)/genParams.smoothness, (y + genParams.seed)/genParams.smoothness)
  if simp > genParams.wallThreshold then
      return tiles.wall
  end
  if simp < genParams.waterThreshold then
    return tiles.water
  end
  return tiles.floor
end