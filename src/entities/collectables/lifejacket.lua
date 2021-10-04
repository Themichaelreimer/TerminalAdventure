Item = require("src.entities.collectables.baseItem")
local LifeJacketItem = Item:extend("LifeJacketItem")

LifeJacketItem.char = 'j'
LifeJacketItem.itemName = "Life Jacket" -- Display name
LifeJacketItem.acquireString = "You no longer drown in water"

function LifeJacketItem:payload()
  hasLifeJacket = true
end

return LifeJacketItem
