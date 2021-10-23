Snake = require('src.entities.enemies.snake')
Jackal = require('src.entities.enemies.jackal')
Plush = require('src.entities.enemies.plush')
Dragon = require('src.entities.enemies.dragon')
GSlime = require('src.entities.enemies.gslime')
BSlime = require('src.entities.enemies.bslime')

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

function makeDragon(x, y, saveData)
  local item = Dragon(x, y, saveData)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end


function makePlush(x, y, saveData)
  local item = Plush(x, y, saveData)
  ecsWorld:add(item)
  table.insert(gameObjects, item)
end

function makeGSlime(x, y, saveData)
  local enemy = GSlime(x,y,saveData)
  ecsWorld:add(enemy)
  table.insert(gameObjects,enemy)
end

function makeBSlime(x, y, saveData)
  local enemy = BSlime(x,y,saveData)
  ecsWorld:add(enemy)
  table.insert(gameObjects,enemy)
end
