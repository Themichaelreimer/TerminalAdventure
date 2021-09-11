----------------------------------------------------------------------------------
Bomb = {
  char = 'b',
  explodeChar = '*',
  fuseTime = 2.0,
  explosionTime = 0.5,
  explosionForce = 100000,
  explosionSize = 4,
  ld = 5,
}

function Bomb:throwBomb(world, ox, oy, vx, vy)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.colour = colours.darkGray
  self.t = 0
  self.deleted = false

  -- boiler plate physics setup
  o.body = love.physics.newBody(world, ox, oy, "dynamic")
  o.shape = love.physics.newRectangleShape(-5, 5, 22, 22)
  o.fixture = love.physics.newFixture(o.body, o.shape, 1)
  o.body:setLinearVelocity(3*vx, 3*vy)
  o.body:setLinearDamping(self.ld)
  o.fixture:setRestitution(0.1)
  o.fixture:setMask(collisionCategories.player)
  o.fixture:setUserData(o)

  o.state = 0 -- 0 is fuse burning, 1 is actively exploding (maybe 2 is remove?)
  return o

end

function Bomb:explode()

  local bx = math.floor(self.body:getX() / screen.tileSize)
  local by = math.floor(self.body:getY() / screen.tileSize)

  -- Damage walls
  for i=-self.explosionSize, self.explosionSize do
    for j=-self.explosionSize, self.explosionSize do
      if math.abs(i) + math.abs(j) < self.explosionSize-1 then
        local x = bx + j
        local y = by + i
        local tile = level:getTileAtCoordinates(x, y)
        if tile == tiles.wall then
          level.map.map[y][x] = tiles.floor
          level:redrawCell(x, y)
        end
      end
    end
  end

  -- Update wall colliders
  local startX = bx - self.explosionSize - 1
  local endX = bx + self.explosionSize + 1
  local startY = by - self.explosionSize - 1
  local endY = by + self.explosionSize + 1
  level:recalculateWallColliders(startX, startY, endX, endY)

  -- Apply force to enemies, items, and player

  local dx = player.body:getX() - self.body:getX()
  local dy = player.body:getY() - self.body:getY()

  if math.abs(dx) + math.abs(dy) < self.explosionSize * screen.tileSize then

    local dmg = math.floor(24 / math.pow((dx + dy + 1)/screen.tileSize, 2))
    player.HP = player.HP - dmg
    if player.HP < 0 then player.HP = 0 end

    local fx
    if dx*dx > 1 then fx = 10000 * dx / math.pow(dx, 2) else fx = 0 end

    local fy
    if dy*dy > 1 then fy = 10000 * dy / math.pow(dy, 2) else fy = 0 end

    player.body:applyLinearImpulse(fx, fy)
  end

end

function Bomb:destroy()
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
end


function Bomb:update(dt)
  self.t = self.t + dt
  local theta = self.t * 2 * math.pi

  -- FUSE BURNING STATE
  if self.state == 0 then
    if self.t > self.fuseTime then
      -- Check state transition. Reset timer
      self.state = 1
      self.t = 0
      self.fixture:setSensor(true)
      self:explode()
    end

    -- Update bomb colour
    local c = math.sin(-theta)
    if c > 0.5 then self.colour = colours.white
    elseif c > -0.5 then self.colour = colours.darkGray
    else self.colour = colours.red end

  end

  if self.state == 1 then
    -- Apply physics to nearby bodies

    -- Update explosion colour
    local c = -math.cos(2*theta)
    if c < -0.33 then self.colour = colours.red
    elseif c < 0.33 then self.colour = colours.yellow
    else self.colour = colours.yellow end

    if self.t > self.explosionTime then
      -- Causes self to be removed from the projectiles set, and have destructor called
      -- on the next level update
      self.deleted = true
    end

  end
end

function Bomb:draw()
  local x = self.body:getX()
  local y = self.body:getY()
  local size = screen.tileSize/2
  love.graphics.setColor(self.colour)
  if self.state == 0 then
    love.graphics.print(self.char, x - size, y - size)
  else
    for i=-self.explosionSize, self.explosionSize do
      for j=-self.explosionSize, self.explosionSize do
        if math.abs(i) + math.abs(j) < self.explosionSize then
          local expX = x + ( j * screen.tileSize ) - size
          local expY = y + ( i * screen.tileSize ) - size
          love.graphics.print(self.explodeChar, expX, expY)
        end
      end
    end
  end
end
