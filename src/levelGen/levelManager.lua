level = nil
levels = {}

Level = require("src.levelGen.level")

-- This function populates the inital map objects
function planGame()

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
