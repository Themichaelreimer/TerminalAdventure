-- This entity is an experiment with particle emitters
-- As of right now, I think they just don't look good with my art style
-- and it's unlikely to be used in the future

local SmokePuff = class("SmokePuff")

SmokePuff.char = '*'
SmokePuff.time = 1
SmokePuff.particleLifetime = 0.5
SmokePuff.maxParticles = 4

function SmokePuff:init(x, y, colour)

  self.lifetime = self.time
  self.texture = love.graphics.newCanvas(screen.tileSize, screen.tileSize)
  self.colour = colour
  self:initTexture()
  self.particleSystem = love.graphics.newParticleSystem(self.texture, self.maxParticles)
  --self.particleSystem:setEmissionRate(4*self.maxParticles)
  self.particleSystem:setParticleLifetime(self.particleLifetime)
  self.particleSystem:setPosition(x,y)
  --self.particleSystem:setLinearAcceleration(0,0)
  self.particleSystem:setRadialAcceleration(0,1)
  local c = self.colour
  self.particleSystem:setColors(c[1], c[2], c[3], 1, c[1], c[2], c[3], 0)
  self.particleSystem:setSizes(3)
  self.particleSystem:setEmissionArea("normal", 8, 8, 0, true)
  self.particleSystem:start()
  self.particleSystem:emit(self.maxParticles)

end

function SmokePuff:initTexture()
  love.graphics.setCanvas(self.texture)
  love.graphics.setColor(self.colour)
  love.graphics.print('*')
  love.graphics.setCanvas()
end

function SmokePuff:draw()
  love.graphics.draw(self.particleSystem)
end

function SmokePuff:update(dt)
  --self.particleSystem:setDirection(1000 * 2 * math.pi * self.lifetime)
  self.particleSystem:update(dt)
  debugString = "Particles: " .. self.particleSystem:getCount() .. "Lifetime: ".. self.lifetime
end

return SmokePuff
