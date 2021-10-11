function findPathToEntity(startEntity, goalEntity, maxDist)
  local map = level.map
  if not map then return end

  local distance = getDistanceBetweenBodies(startEntity.body, goalEntity.body)
  if distance < (maxDist * screen.tileSize) then
    local start = pixelsToTiles(startEntity.body:getX(), startEntity.body:getY())
    local goal = pixelsToTiles(goalEntity.body:getX(), goalEntity.body:getY())
    local path
    if distance > (2 * screen.tileSize) then
      path = star:find(map.width, map.height, start, goal, positionIsOpen, true, false, maxDist * screen.tileSize )
    else
      path = {start, goal}
    end
    return path
  end
end

function findPathBetweenCells(map, x1, y1, x2, y2, minDistance, maxDistance)
  local start = {x = x1, y = y1}
  local goal = {x = x2, y = y2}
  local path = star:find(map.width, map.height, start, goal, positionIsOpenOnMap(map), true, true, maxDistance )
  return path

end

function positionIsOpen(x,y)
  -- TODO: Factor passable obstacles into this, and it can be used for
  -- Level generation
  return level:tileInLevel(x,y) and not level.map.map[y][x].aiAvoid
end

function positionIsOpenOnMap(map)
  -- Returns a function that indicates whether position x,y is open on a map
  local map = map
  return function(x, y)
    return map:tileInLevel(x, y) and not map.map[y][x].aiAvoid
  end
end

function moveToTarget(e, pathCell)
  local tx = (pathCell.x * screen.tileSize) - e.body:getX() + 0.5*screen.tileSize
  local ty = (pathCell.y * screen.tileSize) - e.body:getY() + 0.5*screen.tileSize
  e.body:setLinearVelocity(e.speed*tx, e.speed*ty)
end
