local lightingSystem = tiny.processingSystem(class "lightingSystem")

lightingSystem.filter = tiny.requireAll("lightDistance", "body")
lightingSystem.NUM_RAYS = 80
lightingSystem.previousLevel = nil
lightingSystem.updateTiles = {}
lightingSystem.mustRefreshCanvas = false
lightingSystem.usingShaderThisFrame = false

-- The entities in this system represent light sources
function lightingSystem:process(entity, dt)

  local firstFrameOnFloor = false
  love.graphics.setCanvas(levelCanvas)
  love.graphics.translate(camera:getX(), camera:getY())
  love.graphics.scale(1/screen.sx, 1/screen.sy)
  

  -- Check if the level has changed over the last frame
  if not self.previousLevel == level then
    self:resetCanvas()
    love.graphics.setCanvas(levelCanvas)
  end
  self.previousLevel = level

  if level and player then
    if not hasMap then
      self:resetMapLightness()
      self:resetMapCanvas()
    end
    local x, y = player:getMapCoordinates()

    if useTiles then
      -- Shader should be used atomically - wrt to a frame
      self.usingShaderThisFrame = true
      love.graphics.setShader(shaders.lighting)
      if firstFrameOnFloor or self.mustRefreshCanvas then
        self:resetMapCanvas()
        self:renderEntireCanvas()
        self.mustRefreshCanvas = false
      end
      self:updateCanvasLighting(x, y, entity.lightDistance, self.NUM_RAYS)
      love.graphics.setShader()
    else
      if firstFrameOnFloor or self.mustRefreshCanvas then
        self:resetMapCanvas()
        self:renderEntireCanvas()
        self.mustRefreshCanvas = false
      end
      self:updateCanvasLighting(x, y, entity.lightDistance, self.NUM_RAYS)

    end
    self.usingShaderThisFrame = false
  end

  -- DEBUG REGION
  if debugRender then
    love.graphics.setColor(0.5, 0.1, 0.1,0.5)
    for k,v in pairs(level.colliders) do
      love.graphics.polygon("fill", v:getBody():getWorldPoints(v:getShape():getPoints()))
    end
    love.graphics.setColor(1, 1, 1, 1)
  end
  -- / DEBUG REGION

  love.graphics.setCanvas()
  love.graphics.scale(screen.sx, screen.sy)
  love.graphics.translate(-camera:getX(), -camera:getY())
end

function lightingSystem:updateCanvasLighting(x, y, dist, numRays)

  local tileSize = screen.tileSize

  -- Ensures the player's current cell is seen, which is otherwise not guarenteed
  if level:tileInLevel(x,y) then
    level.map.lightMap[y][x] = 1
    self:redrawCell(x, y, 1)
  end

  -- Update tiles modified by external entities/systems
  -- updateTiles is populated by self.queueRedrawCell
  for _, v in ipairs(self.updateTiles) do
    self:redrawCell(v.x, v.y)
  end
  self.updateTiles = {}

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

function lightingSystem:queueRedrawCell(x, y)
  local cell = {x = x, y = y}
  table.insert(self.updateTiles, cell)
end

function lightingSystem:redrawCell(x, y, alpha)

  local tileSize = screen.tileSize
  local colour = colours[level.map.map[y][x].colour]
  alpha = alpha or level.map.lightMap[y][x]

  --Blank out cell. Looks more weird if we don't do this
  --love.graphics.setColor(colours.black)
  if self.usingShaderThisFrame then
    shaders.lighting:send("tl", 0.0)
    shaders.lighting:send("tr", 0.0)
    shaders.lighting:send("bl", 0.0)
    shaders.lighting:send("br", 0.0)
  else
    love.graphics.setColor(colours.black)
  end
  love.graphics.rectangle("fill", x*tileSize, y*tileSize, tileSize, tileSize)

  --Draw
  if self.usingShaderThisFrame then
    local tl, tr, bl, br = self:getShaderLightingCoords(x, y)
    shaders.lighting:send("tl", tl)
    shaders.lighting:send("tr", tr)
    shaders.lighting:send("bl", bl)
    shaders.lighting:send("br", br)

    local pw = level.map.map[y][x].img:getWidth()
    local ph = level.map.map[y][x].img:getHeight()

    love.graphics.draw(level.map.map[y][x].img, (x-0.11)*screen.tileSize, (y+0.11)*screen.tileSize, 0, screen.tileSize/pw, screen.tileSize/ph)

  else
    love.graphics.setColor(colour[1], colour[2], colour[3], alpha)
    love.graphics.print(level.map.map[y][x].char, x*screen.tileSize, y*screen.tileSize )
  end
end

function lightingSystem:getShaderLightingCoords(x, y)
  --if true then return 1,1,1,1 end

  if not level:tileInLevel(x, y) or level.map.lightMap[y][x] == 0 then return 0,0,0,0 end
  local l,r,b,t
  if level:tileInLevel(x-1,y) then l = level.map.lightMap[y][x-1] else l = 0 end
  if level:tileInLevel(x+1,y) then r = level.map.lightMap[y][x+1] else r = 0 end
  if level:tileInLevel(x,y+1) then b = level.map.lightMap[y+1][x] else b = 0 end
  if level:tileInLevel(x,y-1) then t = level.map.lightMap[y-1][x] else t = 0 end
  return l,r,b,t
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
  local dx = 0.5 -- Stores the change in x/y from the movement of the ray
  local dy = 0.5
  for i=0, maxDistance do
    dx = dx + angleX
    dy = dy + angleY

    -- The use of math.floor is arbitrary, since we need a round, but the round
    -- doesn't have to be exact. As long as we're consistently off by the
    -- same amount for each ray, it should be fine
    local tileX = math.floor(x + dx)
    local tileY = math.floor(y + dy)

    -- Stop the raycast if we go off the map. Return previous results
    --if tileY < 0 or tileY > level.tileHeight or not tileY then return results end
    --if tileX < 0 or tileX > level.tileWidth or not tileX then return results end

    if not level:tileInLevel(tileX, tileY) then return results end
    local tile = level.map.map[tileY][tileX]

    local result = {
      x = tileX,
      y = tileY,
      distance = i,
      lightness = (maxDistance - i) / maxDistance
    }
    table.insert(results, result)

    -- Terminate the ray if we hit something solid
    if tile == tiles.wall and not hasXRay then return results end
  end
  return results
end

function lightingSystem:resetCanvas()
  levelCanvas = love.graphics.newCanvas(level.pixelWidth, level.pixelHeight)
end

function lightingSystem:resetMapCanvas()
  if self.usingShaderThisFrame then
    shaders.lighting:send("tl", 0.0)
    shaders.lighting:send("tr", 0.0)
    shaders.lighting:send("bl", 0.0)
    shaders.lighting:send("br", 0.0)
  else
    love.graphics.setColor(colours.black)
  end
  
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

function lightingSystem:renderEntireCanvas()
  local tileSize = screen.tileSize
  love.graphics.setColor(colours.lightGray) -- nord white

  for y=0, #level.map.map do
    for x=0, #level.map.map[y] do
      self:redrawCell(x, y, level.map.lightMap[y][x])
    end
  end

  -- DEBUG REGION
  if debugRender then
    love.graphics.setColor(0.5, 0.1, 0.1,0.5)
    --bodies = world:getBodies()
    --body = bodies[1]
    --for k,v in pairs(body:getFixtures()) do
    for k,v in pairs(level.colliders) do
      love.graphics.polygon("fill", v:getBody():getWorldPoints(v:getShape():getPoints()))
    end
    love.graphics.setColor(1, 1, 1, 1)
  end
  -- / DEBUG REGION
end

return lightingSystem
