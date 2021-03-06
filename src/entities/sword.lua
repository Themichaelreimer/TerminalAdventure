local Sword = class("Sword")

Sword.char = 'l'
Sword.expireTime = 0.2
Sword.arcAngle = 7 * math.pi / 8
Sword.force = 100
Sword.damage = 10
Sword.width = 8
Sword.height = 24
Sword.xScale = 0.2
Sword.yScale = 0.05
Sword.colourName = 'gray'

function Sword:init(parentEntity)
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(self.width, self.height)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setSensor(true)
  self.fixture:setUserData(self)

  self.colour = colours[self.colourName]

  self.parent = parentEntity
  self.parent.isSwinging = true
  self.lifetime = self.expireTime  -- lifetime System manages this
  self.deleted = false

  self.angularVelocity = self.arcAngle / self.expireTime

  if not useMouse then
    local facing = parentEntity.facing or SOUTH
    self.angle = angleFromDirection(facing) - self.arcAngle / 2
  else
    -- Calculate local position of player on screen
    local lx = player.body:getX() - camera:getX()
    local ly = player.body:getY() - camera:getY()
    self.angle = getMouseAngle(lx, ly) - (self.arcAngle/2)
  end

  table.insert(gameObjects, self)
end

function Sword:update(dt)

  -- Update Angle
  self.angle = self.angle + self.angularVelocity * dt
  self.body:setAngle(self.angle + math.pi/2)

  -- Update Position
  local pBody = self.parent.body
  local r = self.height + 8
  local x = pBody:getX() - r * math.cos(self.angle)
  local y = pBody:getY() -  r * math.sin(self.angle)
  self.body:setPosition(x, y)

end

function Sword:draw()
  love.graphics.setColor(self.colour)
  love.graphics.print(self.char, self.body:getX(), self.body:getY(), self.angle+math.pi/2, self.width*self.xScale, self.height*self.yScale, self.width/2, self.height/2)
  if debugRender then
    love.graphics.setColor(0,0,1,0.6)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    love.graphics.circle("fill", self.body:getX(), self.body:getY(), 4)
  end
end

function Sword:destroy()
  self.deleted = true
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
  self.parent.isSwinging = false
end

function Sword:dealHit(otherEntity)
  -- Can't hit self
  if otherEntity == self.parent then return nil end
  if otherEntity.takeDamage then otherEntity:takeDamage(self.damage) end
  if otherEntity.ignorePhysics and otherEntity.ignorePhysics == true then
  else
    self:applyForce(otherEntity.body)
  end
end

function Sword:applyForce(body)
  local vx, vy = getDirectionVector(self.parent.body, body, true)
  body:applyLinearImpulse(self.force * vx, self.force *  vy)
end

return Sword
