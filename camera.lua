function makeCamera(world, xPixel, yPixel)

  -- Idea: Camera is just an invisible body, who's
  -- position in the world determines the transformation matrix
  -- and who's position is constrained by the map

  return love.physics.newBody(world, xPixel, yPixel, "dynamic")

end

function moveCamera(camera, dt)
  local uiSize = screen.height/5
  local halfWidth = screen.width/2
  local halfHeight = (screen.height + uiSize)/2
  local halfTile = screen.tileSize/2

  local tx = math.max(player.body:getX(), halfWidth - halfTile)
  tx = math.min(tx, level.pixelWidth - halfWidth + screen.tileSize)
  local dx = tx - camera:getX() - halfWidth

  local ty = math.max(player.body:getY(), halfHeight - halfTile)
  ty = math.min(ty, level.pixelHeight - screen.height/5 + screen.tileSize )
  local dy = ty - camera:getY() - halfHeight

  local dist2 = dx*dx + dy*dy

  if dist2 > 0.1 then
    camera:setLinearVelocity(dx * dist2 * dt / 16, dy * dist2 * dt / 16)
  else
    camera:setLinearVelocity(0, 0)
  end

end
