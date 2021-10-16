local Snake = require("src.entities.enemies.snake")
local GSlime = Snake:extend("GSlime")

GSlime.char = "o"
GSlime.colourName = "green"
GSlime.damage = 3
GSlime.randomWalkSpeed = 100
GSlime.dashSpeed = 200
GSlime.force = 100
GSlime.ld = 2
GSlime.baseHP = 20
GSlime.stunTime = 0.5
GSlime.IDLE_TIME = 1.0
GSlime.MOVE_TIME = 0.01
GSlime.dashChance = 1.0
GSlime.range = 30
GSlime.waterPenalty = 0.5

function GSlime:update()
  if self.lifetime then
    self.alpha = 0.5 * (1 - math.cos(self.lifetime * self.lifetime * 4 * math.pi))
  end
  self.xScale = 1 + math.sin(math.pi * self.idleTimer/4)
  self.yScale = 1 + math.sin(math.pi * self.idleTimer/2)
end

return GSlime
