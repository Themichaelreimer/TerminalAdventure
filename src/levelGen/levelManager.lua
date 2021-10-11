level = nil
levels = {}
savedEntities = {}

require('src.enemies')
Level = require("src.levelGen.level")

SimplexCave = require('src.levelGen.maps.SimplexCave')
WetCave = require('src.levelGen.maps.wetCave')
LavaCave = require('src.levelGen.maps.lavacave')
LavaLake = require('src.levelGen.maps.lavalake')


entityFunctions = {
  Snake = makeSnake,
  Jackal = makeJackal,
  Plush = makePlush,
  Dragon = makeDragon,
  MapItem = makeMap,
  XRayItem = makeXRay,
  BombsItem = makeBombs,
  LifeJacketItem = makeLifeJacket,
  LifeUpItem = makeLifeUp,
  HSwordItem = makeHSword,
  DragonArmourItem = makeDragonArmour,
  AmuletItem = makeAmulet,
  WalletItem = makeWallet,
}

collectableItems = {
  BombsItem = {
    name = "BombsItem",
    constructor = entityFunctions.BombsItem,
    minFloor = 1,
    maxFloor = 4,
    easyAccess = true
  },
  HSword = {
    name = "HSwordItem",
    constructor = entityFunctions.HSwordItem,
    minFloor = 5,
    maxFloor = 8,
    easyAccess = false
  },
  LifeJacket = {
    name = "LifeJacketItem",
    constructor = entityFunctions.LifeJacketItem,
    minFloor = 3,
    maxFloor = 8,
    easyAccess = true
  },
  MapItem = {
    name = "MapItem",
    constructor = entityFunctions.MapItem,
    minFloor = 1,
    maxFloor = 2,
    easyAccess = false
  },
  XRayItem = {
    name = "XRayItem",
    constructor = entityFunctions.XRayItem,
    minFloor = 1,
    maxFloor = 8,
    easyAccess = false
  },
  --DragonArmourItem = { -- TODO: Dont need this after this is tested
  --  name = "DragonArmourItem",
  --  constructor = entityFunctions.DragonArmourItem,
  --  minFloor = 1,
  --  maxFloor = 1,
  --  easyAccess = false
  --},
  AmuletItem = {
    name = "AmuletItem",
    constructor = entityFunctions.AmuletItem,
    minFloor = 4,
    maxFloor = 7,
    easyAccess = false
  },
  WalletItem = {
    name = "WalletItem",
    constructor = entityFunctions.WalletItem,
    minFloor = 10,
    maxFloor = 10,
    easyAccess = false
  },
}

floorEnemies = {
  Snake = {5,5,5,5,5,5,5,5,5,10},
  Jackal = {0,1,2,4,8,8,8,8,0,10},
  Plush = {0,0,0,0,0,3,4,5,0,10},
  Dragon = {0,0,0,0,0,0,0,0,1,0},
}

numFloors = 10

-- This function popullates the inital map objects
function planGame()
  -- This function is kind of bad. It's very temporary pending rearchitecting of maps/levels,
  -- and a more interesting algorithm

  local mapType
  local map

  local floorItems = {}
  for i=1, 10 do
    table.insert(floorItems,{} )
  end

  for k, v in pairs(collectableItems) do
    local floor = randomNumInRange(v.minFloor, v.maxFloor)
    table.insert(floorItems[floor], v)
  end

  for i=1, numFloors do
    local lvl = makeNewLevel(i, floorItems[i])
    local levelData = {
      mapData = lvl,
      floorNum = i,
      entities = lvl.ents
    }
    table.insert(levels, levelData)
  end
  assert(#levels == 10)
end

function saveEntities(lvlNum)
  levels[lvlNum].entities = {}
  local expectedLen = #gameObjects
  for _, v in pairs(gameObjects) do
    if v.getSaveData then
      table.insert(levels[lvlNum].entities, v:getSaveData())
    end
  end

end

function loadSavedEntities(lvlNum)
  local ents = levels[lvlNum].entities
  if ents then
    for _, v in ipairs(ents) do
      if v.name then
        local name = v.name
        assert(v ~= nil)
        assert(v.x ~= nil)
        assert(v.y ~= nil)
        assert(v.name ~= nil)
        assert(entityFunctions[name], "Name:" .. name)
        local x = v.x
        local y = v.y
        entityFunctions[name](x,y,v)  -- Calls the constructor for the entity, at (x, y) and the saveData table from it's save function
      end
    end
   end
end

function saveLevel(lvlNum)
  levels[lvlNum] = level:getLevelSaveData()
  playerSaveData = player:getSaveData()
  saveEntities(lvlNum)
  player:destroy()
  player=nil
end

function nextLevel()

  local lvlNum = level.floorNum
  local dstNum = level.floorNum+1

  if dstNum <= numFloors then
    loadLevel(lvlNum,dstNum, true)
  end
end

function prevLevel()
  local lvlNum = level.floorNum
  local dstNum = level.floorNum-1

  if lvlNum > 1 then
    loadLevel(lvlNum, dstNum, false)
  elseif hasWallet and lvlNum == 1 then
    deathTime = 0
    gameWon = true
  end
end

function loadLevel(lvlNum, dstNum, fromAbove)

  if level and lvlNum then
    saveLevel(lvlNum)
    level:destroy()
    resetEntities()
  end

  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact)

  level = Level(dstNum, nil, levels[dstNum])
  local playerInitPos
  if fromAbove then playerInitPos = level.map.upstairs else playerInitPos = level.map.downstairs end

  player = Player(playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile, playerSaveData)
  ecsWorld:add(player)
  camera = makeCamera(world, playerInitPos.x* screen.tileSize, playerInitPos.y* screen.tileSize)
  loadSavedEntities(dstNum)
  lightingSystem.mustRefreshCanvas = true
  return level
end

function resetEntities()
  ecsWorld:clearEntities()
  ecsWorld:refresh()
  gameObjects = {}
end

function makeNewLevel(lvlNum, floorItems)

  local MapType
  if lvlNum <=4 then
    MapType = randomElement({SimplexCave, WetCave})
  elseif lvlNum <= 8 then
    MapType = randomElement({SimplexCave, WetCave, LavaCave})
  elseif lvlNum == 9 then
    MapType = LavaLake
  else
    MapType = LavaCave
  end

  local mapParams = {
    items = floorItems,
    floorNum = lvlNum,
  }
  local map = MapType(nil, mapParams)
  return map:getSaveData()
end
