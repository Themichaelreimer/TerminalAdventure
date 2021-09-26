Snake = require('src.entities.enemies.snake')
Jackal = require('src.entities.enemies.jackal')

function makeSnake(tileX, tileY)
  ecsWorld:add(Snake(tileX * screen.tileSize, tileY * screen.tileSize))
end

function makeJackal(tileX, tileY)
  ecsWorld:add(Jackal(tileX * screen.tileSize, tileY * screen.tileSize))
end
