local Explosion = class("Explosion")

Explosion.char = '*'
Explosion.time = 0.5  -- duration
Explosion.force = 5000000
Explosion.maxForce = 10000
Explosion.baseDamage = 24
Explosion.className = "Explosion" -- Used for contact callback

function Explosion:init(x, y, size, maxDamage)
  self.lifetime = self.time
  self.size = size
  self.r2 = (size * screen.tileSize) * ( size * screen.tileSize)
  self.colour = colours.yellow
  self.deleted = false

  -- pixel coordinates
  self.x = x
  self.y = y

  -- tile coordinates
  self.tx = math.floor(x / screen.tileSize)
  self.ty = math.floor(y / screen.tileSize)
  self.damage = maxDamage or self.baseDamage -- Allow damage to be overridable

  self:damageWalls(self.tx, self.ty)
  self:scrambleFloor(self.tx, self.ty)
  self:applyExplosionToBodies()
  if chance(0.5) then
    sfx.explosion1:play()
  else
    sfx.explosion2:play()
  end

  table.insert(gameObjects, self)
end

function Explosion:destroy()
  self.deleted = true
end

function Explosion:update(dt)
  -- Update explosion colour
  local theta = 2 * math.pi * self.lifetime
  local c = -math.cos(2*theta)
  if c < -0.33 then self.colour = colours.red
  elseif c < 0.33 then self.colour = colours.yellow
  else self.colour = colours.yellow end
end

function Explosion:scrambleFloor(tx, ty)
  for i=-self.size, self.size do
    for j=-self.size, self.size do
      if math.abs(i) + math.abs(j) < self.size then
        local x = tx + j
        local y = ty + i
        if level:tileInLevel(x,y) then
          local rand = love.math.random()
          if level.map.map[y][x] and level.map.map[y][x] == tiles.floor and rand < 0.15 then

            local tile
            if rand < 0.05 then
              tile = tiles.floor1
            elseif rand < 0.1 then
              tile = tiles.floor2
            else
              tile = tiles.floor3
            end

            level.map.map[y][x] = tile
            lightingSystem:redrawCell(x, y)
          end
        end
      end
    end
  end
end
function Explosion:draw()
  love.graphics.setColor(self.colour)
  for i=-self.size, self.size do
    for j=-self.size, self.size do
      if math.abs(i) + math.abs(j) < self.size then
        local expX = self.x + ( j * screen.tileSize ) - screen.tileSize/2
        local expY = self.y + ( i * screen.tileSize ) - screen.tileSize/2
        love.graphics.print(self.char, expX, expY)
      end
    end
  end
end

function Explosion:damageWalls(tileX, tileY)

  -- Damage walls

  for i=-self.size, self.size do
    for j=-self.size, self.size do
      if math.abs(i) + math.abs(j) < self.size-1 then
        local x = self.tx + j
        local y = self.ty + i
        local tile = level:getTileAtCoordinates(x, y)
        if tile == tiles.wall then
          level.map.map[y][x] = tiles.floor
          lightingSystem:redrawCell(x, y)
        end
      end
    end
  end

  -- Update colliders
  local startX = self.tx - self.size - 1
  local endX = self.tx + self.size + 1
  local startY = self.ty - self.size - 1
  local endY = self.ty + self.size + 1
  level:recalculateWallColliders(startX, startY, endX, endY)

end

function Explosion:applyExplosionToBodies()
  for _, object in ipairs(gameObjects) do
    if not object.deleted and object.body then
      local body = object.body
      local dx = body:getX() - self.x
      local dy = body:getY() - self.y
      local dist2 = dx*dx + dy*dy
      if dist2 < self.r2 then
        if object.body then self:applyForce(body, dx, dy, dist2) end
        if object.takeDamage then self:applyDamage(object, dx, dy, dist2) end
      end
    end
  end
end

function Explosion:applyForce(body, dx, dy, dist2)
  local f = self.force / (1 + dist2)
  if f > self.maxForce then f = self.maxForce end
  body:applyLinearImpulse(f * dx / dist2, f * dy / dist2)
end

function Explosion:applyDamage(entity, dx, dy, dist2)
  if entity == nil then return nil end
  local dmg = self.damage / (0.1 + math.sqrt(dist2)/screen.tileSize)
  entity:takeDamage(dmg)
end

return Explosion
