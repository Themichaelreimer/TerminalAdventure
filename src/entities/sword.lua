local Sword = class("Sword")

Sword.char = 'l'
Sword.expireTime = 0.25
Sword.arcAngle = 7 * math.pi / 8
Sword.damage = 10
Sword.width = 8
Sword.height = 24

function Sword:init(parentEntity)
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(self.width, self.height)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setSensor(true)
  self.colour = colours.gray

  self.parent = parentEntity
  self.parent.isSwinging = true
  self.lifetime = self.expireTime  -- lifetime System manages this
  self.deleted = false

  self.angularVelocity = self.arcAngle / self.expireTime
  local facing = parentEntity.facing or SOUTH
  self.angle = angleFromDirection(facing) - self.arcAngle / 2

  table.insert(gameObjects, self)
end

function Sword:update(dt)

  -- Update Angle
  self.angle = self.angle + self.angularVelocity * dt
  self.body:setAngle(self.angle + math.pi/2)

  -- Update Position
  local pBody = self.parent.body
  local r = self.height
  self.body:setPosition(pBody:getX() - r * math.cos(self.angle), pBody:getY() -  r * math.sin(self.angle))
end

function Sword:draw()
  love.graphics.setColor(self.colour)
  love.graphics.print(self.char, self.body:getX(), self.body:getY(), self.angle+math.pi/2, 1, 1, self.width/2, self.height/2)
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

return Sword
