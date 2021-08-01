isSwinging = false
swordObject = {} 

function drawPlayer(player)
  local px = player:getX()
  local py = player:getY()
  local playerStep = 2*math.sin((px + py)/4)
  local tSize = screen.tileSize
  local swordBody = swordObject.body
  
  love.graphics.setColor(colours.green) -- nord green
  love.graphics.print("@", px-tSize/2, py-tSize/2 + playerStep, player:getAngle())
  if isSwinging then
    local swordOriginX = swordBody:getX() - swordObject.width/2 
    local swordOriginY = swordBody:getY() - swordObject.height/2 + tSize/2
    love.graphics.print("t", swordOriginX, swordOriginY, swordBody:getAngle(), 1, 1, swordObject.width/2, swordObject.height/2)
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
  if isSwinging then
    swordObject.timer = swordObject.timer - dt
    if swordObject.timer < 0 then endSwingSword() end
  end
end

function swingSword()
  isSwinging = true
  swordObject = {
      body = love.physics.newBody(world, player:getX(), player:getY(), "dynamic"),
      shape =  love.physics.newRectangleShape(8,36),
      width = 8,
      height = 12,
      timer = 0.25,
    }
  swordObject.fixture = love.physics.newFixture(swordObject.body, swordObject.shape, 10)
  swordObject.fixture:setMask(collisionCategories.player) -- Might not be necessary with the joint
  swordObject.joint = love.physics.newRevoluteJoint(player, swordObject.body, player:getX(), player:getY(), false)
  swordObject.joint:setMotorSpeed(20)
  swordObject.joint:setMaxMotorTorque(1000000)
  swordObject.joint:setMotorEnabled(true)
end

function endSwingSword()
  swordObject.joint:destroy()
  swordObject.fixture:destroy()
  --swordObject.shape:destroy()
  swordObject.body:destroy()
  swordObject = {}
  isSwinging = false
end