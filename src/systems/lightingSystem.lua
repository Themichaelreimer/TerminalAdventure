local lightingSystem = tiny.processingSystem(class "lightingSystem")

lightingSystem.filter = tiny.requireAll("lightDistance", "body")
lightingSystem.NUM_RAYS = 80
lightingSystem.previousLevel = nil

-- The entities in this system represent light sources
function lightingSystem:process(entity, dt)

  if not self.previousLevel == level then
    self:resetCanvas()
  end
  self.previousLevel = level

  love.graphics.setCanvas(levelCanvas)

  if level and player then
    if not hasMap then
      self:resetMapLightness()
      self:resetMapCanvas()
    end
    local x, y = player:getMapCoordinates()
    self:updateCanvasLighting(x, y, entity.lightDistance, self.NUM_RAYS)
  end

  love.graphics.setCanvas()
end

function lightingSystem:updateCanvasLighting(x, y, dist, numRays)
  local tileSize = screen.tileSize

  -- Idea: Cast out rays in equally spaced angles from (x, y)
  -- For each ray cast, and for each space each ray touches, if the lightMap at the space is darker
  -- than the ray's lightness value for that space, then update the lightMap with the brighter value and redraw the space
  rays = self:rayTrace(x, y, dist, numRays)
  for iRay=0, #rays do
    if rays[iRay] ~= nil then
      for iRaySpace=0, #rays[iRay] do
        local data = rays[iRay][iRaySpace]
        if data ~= nil then
          -- If the player has a map, then the lightness is taken as the highest ever value for that space
          -- ie, the space can only get brighter, never darker
          if hasMap then
            if level.map.lightMap[data.y][data.x] < data.lightness then
              level.map.lightMap[data.y][data.x] = data.lightness
              self:redrawCell(data.x, data.y, data.lightness)
            end
          else
            level.map.lightMap[data.y][data.x] = data.lightness
            self:redrawCell(data.x, data.y, data.lightness)
          end
        end
      end
    end
  end
end

function lightingSystem:redrawCell(x, y, alpha)

  local tileSize = screen.tileSize
  local colour = colours.lightGray
  alpha = alpha or self.map.lightMap[y][x]

  --Blank out cell. Looks more weird if we don't do this
  love.graphics.setColor(colours.black)
  love.graphics.rectangle("fill", x*tileSize, y*tileSize, tileSize, tileSize)

  --Draw
  love.graphics.setColor(colour[1], colour[2], colour[3], alpha)
  love.graphics.print(level.map.map[y][x].char, x*screen.tileSize, y*screen.tileSize)
end

function lightingSystem:rayTrace(x, y, dist, numRays)
  local results = {}
  for iAngle=0, numRays do
    local rads = 2 * math.pi * iAngle / numRays
    table.insert(results, self:traceRay(x, y, rads, dist))
  end
  return results
end

function lightingSystem:traceRay(x, y, angle, maxDistance)
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
    if tileY < 0 or tileY > level.tileHeight or not tileY then return results end
    if tileX < 0 or tileX > level.tileWidth or not tileX then return results end

    local tile = level.map.map[tileY][tileX]

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

function lightingSystem:resetCanvas()
  levelCanvas = love.graphics.newCanvas(level.pixelWidth, level.pixelHeight)
end

function lightingSystem:resetMapCanvas()
  love.graphics.setColor(colours.black)
  if level then
    love.graphics.rectangle("fill", 0, 0, level.pixelWidth, level.pixelHeight)
  else
    love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)
  end
end

function lightingSystem:resetMapLightness()
  for y=0, #level.map.lightMap do
    for x=0, #level.map.lightMap[y] do
      level.map.lightMap[y][x] = 0.0
    end
  end
end

return lightingSystem
