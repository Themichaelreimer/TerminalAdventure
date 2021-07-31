function makeCamera(world, xPixel, yPixel)
  
  -- Idea: Camera is just an invisible body, who's 
  -- position in the world determines the transformation matrix
  -- and who's position is constrained by the map
  
  return love.physics.newBody(world, xPixel, yPixel, "dynamic")
  
end

function moveCamera(camera, player, dt)
  local tx = math.max(player:getX(), screen.width/2 - screen.tileSize/2)
  --local tx = player:getX()
  local dx = tx - camera:getX() -screen.width/2
  
  local ty = math.max(player:getY(), screen.height/2 -screen.tileSize/2)
  --local ty = player:getY()
  local dy = ty - camera:getY() - screen.height/2
  
  local dist2 = dx*dx + dy*dy
  
  if dist2 > 0.1 then
    camera:setLinearVelocity(dx * dist2 * dt / 16, dy * dist2 * dt / 16)
  else
    camera:setLinearVelocity(0, 0)
  end
  
end
