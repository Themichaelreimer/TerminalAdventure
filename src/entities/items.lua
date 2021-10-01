MapItem = require('src.entities.collectables.mapItem')
XRay = require('src.entities.collectables.xRayItem')

-- NOTE: Entity save/load process requires X and Y to be in pixels, and
-- Any other initial properties to be in a table after that (eg, saved properties)

function makeMap(x, y)
  local item = MapItem(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeXRay(x, y)
  local item = XRay(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end
