Explosion = require("src.entities.explosion")

local Bomb = class("Bomb")

Bomb.char = 'b'
Bomb.time = 2
Bomb.ld = 5

function Bomb:init(x, y, vx, vy)
  self.lifetime = self.time
  self.colour = colours.darkGray
  self.deleted = false
  self.physicsable = true

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(-5, 5, 22, 22)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)

  self.body:setLinearVelocity(3*vx, 3*vy)
  self.body:setLinearDamping(self.ld)
  self.body:setFixedRotation(true)

  self.fixture:setRestitution(0.1)
  self.fixture:setMask(collisionCategories.player)
  self.fixture:setUserData(self)
  table.insert(gameObjects, self)
end

function Bomb:destroy()
  -- Clean up resources to prevent leaks
  self.deleted = true
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
end

function Bomb:onExpire()
  ecsWorld:add(Explosion(self.body:getX(), self.body:getY(), 4))
  -- Note: The lifetime System removes this entity
end

function Bomb:update(dt)
  local theta = 2 * math.pi * self.lifetime
  local c = math.sin(-theta)

  -- Determine colour by a sine function of time
  if c > 0.5 then self.colour = colours.white
  elseif c > -0.5 then self.colour = colours.darkGray
  else self.colour = colours.red end
end

return Bomb
