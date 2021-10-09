local Snake = require("src.entities.enemies.snake")

local Jackal = Snake:extend("Jackal")

Jackal.char = 'd'
Jackal.colourName = 'brown'
Jackal.speed = 5
Jackal.stunTime = 0.2
Jackal.IDLE_TIME = 0.5
Jackal.MOVE_TIME = 1.0
Jackal.dashChance = 0
Jackal.baseHP = 15
Jackal.bouncyStep = true -- Enables bouncy step in asciiDrawSystem
Jackal.waterPenalty = 4

return Jackal
