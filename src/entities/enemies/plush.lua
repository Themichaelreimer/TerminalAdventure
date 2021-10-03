local Snake = require("src.entities.enemies.snake")

local Plush = Snake:extend("Plush")

Plush.char = 'a'
Plush.colourName = 'pink'
Plush.speed = 8
Plush.dashSpeed = 10
Plush.damage=3

Plush.IDLE_TIME = 0.01
Plush.MOVE_TIME = 1.0
Plush.dashChance = 0.1
Plush.baseHP = 8
Jackal.waterPenalty = 16

return Plush
