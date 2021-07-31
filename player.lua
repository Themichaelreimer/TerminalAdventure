isSwinging = false

function playerUpdate(dt, body)
  local tileSize = screen.tileSize
  local dx = 0
  local dy = 0
  
  if love.keyboard.isDown("down") then --and player:getY() < screen.height-playerData.size then
    dy = playerData.moveSpeed
  end
  
  if love.keyboard.isDown("up") and player:getY() > 0 then
    dy = -playerData.moveSpeed
  end
  
  if love.keyboard.isDown("left") and player:getX() > 0 then
    dx = -playerData.moveSpeed
  end
  
  if love.keyboard.isDown("right") then --and player:getX() < screen.width-playerData.size then
    dx = playerData.moveSpeed
  end
  
  if love.keyboard.isDown("x") and isSwinging then
    swingSword()
  end
  
  player:setLinearVelocity(dx,dy)
end

function swingSword()
  
end