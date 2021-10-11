Item = require("src.entities.collectables.baseItem")
local ArmourItem = Item:extend("DragonArmourItem")

ArmourItem.char = 'D'
ArmourItem.itemName = "Dragon Armour" -- Display name
ArmourItem.acquireString = "Your defensive capabilities are greatly increased!"

function ArmourItem:payload()
  hasArmour = true
end

return ArmourItem
