Snake = require('src.entities.enemies.snake')
Jackal = require('src.entities.enemies.jackal')
Plush = require('src.entities.enemies.plush')

function makeSnake(x, y, saveData)
  local item = Snake(x, y, saveData)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeJackal(x, y, saveData)
  local item = Jackal(x, y, saveData)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makePlush(x, y, saveData)
  local item = Plush(x, y, saveData)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end
