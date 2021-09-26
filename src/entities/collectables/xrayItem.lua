Item = require("src.entities.collectables.baseItem")
local XRayItem = Item:extend("XRayItem")

XRayItem.char = 'x'
XRayItem.itemName = "X Ray Glasses" -- Display name
XRayItem.acquireString = "You can now see through walls"

function XRayItem:payload()
  hasXRay = true
end

return XRayItem
