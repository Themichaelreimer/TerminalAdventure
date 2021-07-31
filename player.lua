isSwinging = false
swordObject = {} 

function drawPlayer(player)
  local playerStep = 2*math.sin((player:getX() + player:getY())/4)
  local tSize = screen.tileSize
  local swordBody = swordObject.body
  love.graphics.setColor(colours.green) -- nord green
  love.graphics.print("@", player:getX()-tSize/2, player:getY()-tSize/2 + playerStep, player:getAngle())
  if isSwinging then
    love.graphics.print("t", swordBody:getX() - swordObject.width/2, swordBody:getY() - swordObject.height, swordBody:getAngle()+math.pi)
  end
  
    -- DEBUG 
  if debugRender then
    love.graphics.setColor(0.1, 0.1, 0.5, 0.5)
    love.graphics.polygon("fill", player:getWorldPoints(playerBox:getPoints()))
    if isSwinging then 
      love.graphics.polygon("fill", swordObject.body:getWorldPoints(swordObject.shape:getPoints()))
    end
    love.graphics.setColor(1, 1, 1, 1)
  end
end

function playerUpdate(dt, body)
  local tileSize = screen.tileSize
  local halfTile = tileSize/2
  local dx = 0
  local dy = 0
  
  local px = player:getX()
  local py = player:getY()
  
  if love.keyboard.isDown("down") and py < map.heightPixels - halfTile then
    dy = playerData.moveSpeed
  end
  
  if love.keyboard.isDown("up") and py > halfTile then
    dy = -playerData.moveSpeed
  end
  
  if love.keyboard.isDown("left") and px > 0 then
    dx = -playerData.moveSpeed
  end
  
  if love.keyboard.isDown("right") and px < map.widthPixels then
    dx = playerData.moveSpeed
  end
  
  if love.keyboard.isDown("x") and not isSwinging then
    swingSword()
  end
  
  player:setLinearVelocity(dx,dy)
end

function swingSword()
  isSwinging = true
  swordObject = {
      body = love.physics.newBody(world, player:getX(), player:getY(), "dynamic"),
      shape =  love.physics.newRectangleShape(8,36),
      width = 8,
      height = 24,
    }
  swordObject.fixture = love.physics.newFixture(swordObject.body, swordObject.shape, 10)
  swordObject.fixture:setMask(collisionCategories.player) -- Might not be necessary with the joint
  swordObject.joint = love.physics.newMotorJoint(player, swordObject.body)
  swordObject.joint:setAngularOffset(0)
  
  
end