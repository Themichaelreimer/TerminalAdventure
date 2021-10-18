local Heart = class("Heart")

Heart.char = '+'
Heart.colourName = 'red'
Heart.size = '12'
Heart.LIFETIME = 5
Heart.ignorePhysics = true

function Heart:init(x, y, healAmount)
  self.colour = colours[self.colourName]
  self.deleted = false
  self.lifetime = self.LIFETIME
  self.healAmount = healAmount

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(-5, 5, 22, 22)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setSensor(true)
  self.fixture:setUserData(self)
end

function Heart:destroy()
  self.deleted = true
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
end

function Heart:collect()
  player._HP = player._HP + self.healAmount
  if player._HP > player.maxHP then player._HP = player.maxHP end
  self:destroy()
end

function Heart:dealHit(other)
  if other.isPlayer then self:collect() end
end

return Heart
