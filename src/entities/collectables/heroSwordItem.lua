Item = require("src.entities.collectables.baseItem")
local HSwordItem = Item:extend("HSwordItem")

HSwordItem.char = 'I'
HSwordItem.itemName = "Hero Sword" -- Display name
HSwordItem.acquireString = "You feel the strength of a long dead hero in your grip"

function HSwordItem:payload()
  table.insert(inventory, makeHSwordAdapter())
end

return HSwordItem
