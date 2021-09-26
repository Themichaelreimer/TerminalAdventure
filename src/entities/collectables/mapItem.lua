Item = require("src.entities.collectables.baseItem")
local MapItem = Item:extend("MapItem")

MapItem.char = 'm'
MapItem.itemName = "Map" -- Display name
MapItem.acquireString = "Explored area is permanently illuminated"

function MapItem:payload()
  hasMap = true
end

return MapItem
