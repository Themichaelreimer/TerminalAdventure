MapItem = require('src.entities.collectables.mapItem')
XRay = require('src.entities.collectables.xrayItem')
Bombs = require('src.entities.collectables.bombsItem')
LifeJacket = require('src.entities.collectables.lifejacket')
LifeUp = require('src.entities.collectables.lifeupItem')
HSword = require('src.entities.collectables.heroSwordItem')
WalletItem = require('src.entities.collectables.walletItem')
AmuletItem = require('src.entities.collectables.amuletOfRecovery')
DragonArmourItem = require('src.entities.collectables.dragonarmour')
UpStairs = require('src.entities.upstairs')
DownStairs = require('src.entities.downstairs')

-- NOTE: Entity save/load process requires X and Y to be in pixels, and
-- Any other initial properties to be in a table after that (eg, saved properties)
function makeUpStairs(x, y)
  local stairs = UpStairs(x, y)
  ecsWorld:add(stairs)
  table.insert(gameObjects, stairs)
end

function makeDownStairs(x, y)
  local stairs = DownStairs(x, y)
  ecsWorld:add(stairs)
  table.insert(gameObjects, stairs)
end


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

function makeWallet(x, y)
  local item = WalletItem(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeAmulet(x, y)
  local item = AmuletItem(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeDragonArmour(x, y)
  local item = DragonArmourItem(x, y)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end
