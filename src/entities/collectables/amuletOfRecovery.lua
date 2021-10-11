Item = require("src.entities.collectables.baseItem")
local AmuletItem = Item:extend("AmuletItem")

AmuletItem.char = 'a'
AmuletItem.itemName = "Amulet of Recovery" -- Display name
AmuletItem.acquireString = "You now passively recover health"

function AmuletItem:payload()
  hasAmulet = true
end

return AmuletItem
