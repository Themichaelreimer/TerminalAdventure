local aiSystem = tiny.processingSystem(class "aiSystem")

-- Enemy component just has to exist, doesn't have useful data. Just marks an entity as needing AI
aiSystem.filter = tiny.requireAll("behaviour", "body")
aiSystem.maxRange = 30  -- 30 tiles

function aiSystem:process(e, dt)

  if not e.deleted then
    local map = level.map
    if not map then return end

    local distance = getDistanceBetweenBodies(player.body, e.body)
    if distance < (self.maxRange * screen.tileSize) then
      local start = pixelsToTiles(e.body:getX(), e.body:getY())
      local goal = pixelsToTiles(player.body:getX(), player.body:getY())
      local path
      if distance > (2 * screen.tileSize) then
        path = star:find(map.width, map.height, start, goal, positionIsOpen, true, false, self.maxRange * screen.tileSize )
      else
        path = {start, goal}
      end

      if path then
        moveToTarget(e, path[2])
      end
    end

  end
end

function moveToTarget(e, pathCell)
  local tx = (pathCell.x * screen.tileSize) - e.body:getX() + 0.5*screen.tileSize
  local ty = (pathCell.y * screen.tileSize) - e.body:getY() + 0.5*screen.tileSize
  e.body:setLinearVelocity(e.speed*tx, e.speed*ty)
end

function positionIsOpen(x,y)
  return not level.map.map[y][x].solid
end

return aiSystem
