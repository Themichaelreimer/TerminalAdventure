Snake = require('src.entities.enemies.snake')
function makeSnake(tileX, tileY)
  ecsWorld:add(Snake(tileX * screen.tileSize, tileY * screen.tileSize))
end
