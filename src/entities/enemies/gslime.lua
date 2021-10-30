local Snake = require("src.entities.enemies.snake")
local GSlime = Snake:extend("GSlime")

GSlime.char = "o"
GSlime.colourName = "green"
GSlime.damage = 3
GSlime.randomWalkSpeed = 100
GSlime.dashSpeed = 200
GSlime.force = 100
GSlime.ld = 3
GSlime.baseHP = 20
GSlime.stunTime = 0.5
GSlime.IDLE_TIME = 1.0
GSlime.MOVE_TIME = 0.01
GSlime.dashChance = 1.0
GSlime.range = 30
GSlime.waterPenalty = 0.5
GSlime.canSwim = true
GSlime.size = 20

function GSlime:update()
  if self.lifetime then
    self.alpha = 0.5 * (1 - math.cos(self.lifetime * self.lifetime * 4 * math.pi))
  end
  self.xScale = 1 + math.sin(math.pi * self.idleTimer/self.IDLE_TIME)/2
  self.yScale = 1 + math.sin(math.pi * self.idleTimer/self.IDLE_TIME)/2

  local myTile = level:getTileAtCoordinates(self.body:getX()/screen.tileSize, self.body:getY()/screen.tileSize)
  if myTile == tiles.water then
    self.dashChance = 0
  else
    self.dashChance = 1
  end

end


return GSlime
