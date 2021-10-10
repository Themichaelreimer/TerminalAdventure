MapItem = require('src.entities.collectables.mapItem')
XRay = require('src.entities.collectables.xRayItem')
Bombs = require('src.entities.collectables.BombsItem')
LifeJacket = require('src.entities.collectables.LifeJacket')
LifeUp = require('src.entities.collectables.LifeUpItem')
HSword = require('src.entities.collectables.heroSwordItem')

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

function makeBombs(x, y)
  local item = Bombs(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeLifeJacket(x, y)
  local item = LifeJacket(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeLifeUp(x, y)
  local item = LifeUp(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeHSword(x, y)
  local item = HSword(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end
