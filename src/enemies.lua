Snake = require('src.entities.enemies.snake')
Jackal = require('src.entities.enemies.jackal')
Plush = require('src.entities.enemies.plush')

function makeSnake(tileX, tileY, saveData)
  local item = Snake(tileX * screen.tileSize, tileY * screen.tileSize, saveData)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeJackal(tileX, tileY, saveData)
  local item = Jackal(tileX * screen.tileSize, tileY * screen.tileSize, saveData)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makePlush(tileX, tileY, saveData)
  local item = Plush(tileX * screen.tileSize, tileY * screen.tileSize, saveData)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end
