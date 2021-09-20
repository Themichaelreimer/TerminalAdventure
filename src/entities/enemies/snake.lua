local Snake = class("Snake")

Snake.char = 's'
Snake.size = 14
Snake.damage = 6
Snake.speed = 30
Snake.force = 200
Snake.ld = 7
Snake.baseHP = 15
Snake.behaviour = "idle" -- Enables AI system

function Snake:init(x,y)
  self.deleted = false
  self.colour = colours.red

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(-5, 5, self.size, self.size)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData(self)

  self.body:setFixedRotation(true)
  self.body:setLinearDamping(self.ld)

  self.maxHP = self.baseHP
  self.HP = self.maxHP

  table.insert(gameObjects, self)
end

function Snake:destroy()
  -- Clean up resources to prevent leaks
  self.deleted = true
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
end

function Snake:dealHit(otherEntity)
  if otherEntity == self or not otherEntity.takeDamage then return nil end
  otherEntity:takeDamage(self.damage)

  local vx, vy = getDirectionVector(self.body, otherEntity.body, true)
  otherEntity.body:applyLinearImpulse(self.force * vx, self.force *  vy)
end

function Snake:takeDamage(damage)
  self.HP = self.HP - damage
  if self.HP < 1 then self:destroy() end
end

-- draw handled by asciiDrawSystem

return Snake
