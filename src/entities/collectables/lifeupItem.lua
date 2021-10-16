Item = require("src.entities.collectables.baseItem")
local LifeUpItem = Item:extend("LifeUpItem")

LifeUpItem.char = '+'
LifeUpItem.itemName = "Vitality Up" -- Display name
LifeUpItem.acquireString = "You are more resiliant"

function LifeUpItem:payload()
  local hpGained = round(player.maxHP * 0.25)
  player.maxHP = player.maxHP + hpGained
  player._HP = player._HP + hpGained
end

return LifeUpItem
