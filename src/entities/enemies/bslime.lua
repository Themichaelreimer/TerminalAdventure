local GSlime = require("src.entities.enemies.gslime")
local BSlime = GSlime:extend("BSlime")

BSlime.colourName = 'blue'
BSlime.baseHP = 30
BSlime.randomWalkSpeed = 150
BSlime.dashSpeed = 400
BSlime.damage=6
BSlime.waterPenalty = 0.35

return BSlime
