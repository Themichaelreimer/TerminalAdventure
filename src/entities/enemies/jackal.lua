local Snake = require("src.entities.enemies.snake")

local Jackal = Snake:extend("Jackal")

Jackal.char = 'd'
Jackal.colourName = 'brown'
Jackal.speed = 5
Jackal.IDLE_TIME = 0.5
Jackal.MOVE_TIME = 1.0
Jackal.dashChance = 0
Jackal.baseHP = 15

return Jackal
