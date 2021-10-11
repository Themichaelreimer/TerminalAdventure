Snake = require('src.entities.enemies.snake')
Jackal = require('src.entities.enemies.jackal')
Plush = require('src.entities.enemies.plush')
Dragon = require('src.entities.enemies.dragon')

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

function makeDragon(x, y, saveData)
  local enemy = Dragon(x,y,saveData)
  ecsWorld:add(enemy)
  table.insert(gameObjects,enemy)
end
