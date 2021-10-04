Item = require("src.entities.collectables.baseItem")
local BombsItem = Item:extend("BombsItem")

BombsItem.char = 'b'
BombsItem.itemName = "Bombs" -- Display name
BombsItem.acquireString = "Blow up walls and creatures"

function BombsItem:payload()
  hasBombs = true  -- Probably deprecated now. Delete once I confirm
  table.insert(inventory, makeBombAdapter())
end

return BombsItem
