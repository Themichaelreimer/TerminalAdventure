level = nil
levels = {}
savedEntities = {}

require('src.enemies')
Level = require("src.levelGen.level")

entityFunctions = {
  snake = makeSnake,
  jackal = makeJackal,
  plush = makePlush,
  map = makeMap,
  xray = makeXRay
}

-- This function popullates the inital map objects
function planGame()

end

function getSavedEntities(lvlNum)
  savedEntities[lvlNum] = {}
  for _, v in ipairs(gameObjects) do
    if v.getSaveData then
      table.insert(savedEntities, v:getSaveData())
    end
  end
end

function loadSavedEntities(lvlNum)
  local loadEntities = savedEntities[lvlNum]
  for _, v in ipairs(loadEntities) do
    local name = v.name
    local x = v.x
    local y = v.y
    entityFunctions[name](x,y,v)  -- Calls the constructor for the entity, at (x, y) and the saveData table from it's save function
   end
end

function saveLevel()
  local lvlNum = level.floorNum
  levels[lvlNum] = level:getLevelSaveData()
  playerSaveData = player:getSaveData()
  player:destroy()
  player=nil
end

function nextLevel()

  local lvlNum = level.floorNum
  local dstNum = level.floorNum+1
  saveLevel()

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

end

function prevLevel()
  local lvlNum = level.floorNum
  local dstNum = level.floorNum-1

  if lvlNum > 1 then
    saveLevel()
    levels[lvlNum] = level:getLevelSaveData()

    level:destroy()
    resetEntities()

    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact)

    level = Level(dstNum, levels[dstNum])
    local playerInitPos = level.map.downstairs

    player = Player(playerInitPos.x * screen.tileSize + halfTile, playerInitPos.y * screen.tileSize + halfTile, playerSaveData)
    ecsWorld:add(player)
    camera = makeCamera(world, playerInitPos.x* screen.tileSize, playerInitPos.y* screen.tileSize)
  end
end
