Sword = require("src.entities.sword")

local HeroSword = Sword:extend("HeroSword")

HeroSword.char = 'I'
HeroSword.expireTime = 0.20
HeroSword.force=200
HeroSword.damage=20
HeroSword.width=12
HeroSword.height=32
HeroSword.xScale=0.08
HeroSword.yScale=0.05
HeroSword.colourName = 'white'

return HeroSword
