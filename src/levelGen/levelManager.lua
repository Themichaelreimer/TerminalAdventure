level = nil
levels = {}
savedEntities = {}

require('src.enemies')
Level = require("src.levelGen.level")

entityFunctions = {
  Snake = makeSnake,
  Jackal = makeJackal,
  Plush = makePlush,
  MapItem = makeMap,
  XRayItem = makeXRay
}

-- This function popullates the inital map objects
function planGame()

end

function saveEntities(lvlNum)
  savedEntities[lvlNum] = {}
  local expectedLen = #gameObjects
  for _, v in pairs(gameObjects) do
    if v.getSaveData then
      table.insert(savedEntities[lvlNum], v:getSaveData())
    end
  end

  checkSavedEntitiesState()
end

function checkSavedEntitiesState()
  for i, entities in ipairs(savedEntities) do
    for _, entityData in ipairs(entities[i]) do
      --assert(entityData.x ~= nil)
      --assert(entityData.y ~= nil)
      --assert(entityData.name ~= nil)
    end
  end
end

function loadSavedEntities(lvlNum)
  checkSavedEntitiesState()
  local ents = savedEntities[lvlNum]
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
  saveLevel(lvlNum)

  level:destroy()
  resetEntities()

  world = love.physics.newWorld(0, 0, true)
  world:setCallbacks(beginContact, endContact)

  if levels[dstNum] == nil then
    level = Level(dstNum)
    table.insert(levels, level)
  else
    level = Level(dstNum, levels[dstNum])
  end

  local playerInitPos = level.map.upstairs

  player = Player(playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile, playerSaveData)
  ecsWorld:add(player)
  camera = makeCamera(world, playerInitPos.x* screen.tileSize, playerInitPos.y* screen.tileSize)
  loadSavedEntities(dstNum)
  lightingSystem.mustRefreshCanvas = true

end

function prevLevel()
  local lvlNum = level.floorNum
  local dstNum = level.floorNum-1

  if lvlNum > 1 then
    saveLevel(lvlNum)

    level:destroy()
    resetEntities()

    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact)

    level = Level(dstNum, levels[dstNum])
    local playerInitPos = level.map.downstairs


    player = Player(playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile, playerSaveData)
    ecsWorld:add(player)
    camera = makeCamera(world, playerInitPos.x* screen.tileSize, playerInitPos.y* screen.tileSize)
    loadSavedEntities(dstNum)
    lightingSystem.mustRefreshCanvas = true
  end
end

function resetEntities()
  ecsWorld:clearEntities()
  ecsWorld:refresh()
  gameObjects = {}
end
