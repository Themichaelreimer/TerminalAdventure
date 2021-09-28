Snake = require('src.entities.enemies.snake')
Jackal = require('src.entities.enemies.jackal')
Plush = require('src.entities.enemies.plush')

function makeSnake(tileX, tileY)
  ecsWorld:add(Snake(tileX * screen.tileSize, tileY * screen.tileSize))
end

function makeJackal(tileX, tileY)
  ecsWorld:add(Jackal(tileX * screen.tileSize, tileY * screen.tileSize))
end

function makePlush(tileX, tileY)
  ecsWorld:add(Plush(tileX * screen.tileSize, tileY * screen.tileSize))
end
