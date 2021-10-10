Bomb = require("src.entities.bomb")
Sword = require("src.entities.sword")
HeroSword = require("src.entities.heroSword")

local Player = class("Player")

Player.char = '@'
Player.size = 20
Player.speed = 20
Player.ld = 7
Player.baseHP = 24
Player.lightDistance = 8
Player.bouncyStep = true -- Enables bouncy step in asciiDrawSystem
Player.isPlayer = true -- Used in collision handling with enemies
Player.waterPenalty = 4
Player.HPVelocity = 12
Player.reboundForce = 200

function Player:init(x, y, initParams)
    initParams = initParams or {}
    self.deleted = false
    self.physicsable = true
    self.isSwinging = false
    self.colour = colours.green

    self.body = love.physics.newBody(world, x, y, "dynamic")
    self.shape = love.physics.newRectangleShape(-5, 5, self.size, self.size)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData(self)

    self.fixture:setCategory(collisionCategories.player)
    self.body:setFixedRotation(true)
    self.body:setLinearDamping(self.ld)

    local maxhp = initParams.maxHP or self.baseHP
    local hp = initParams.HP or maxhp

    self.facing = initParams.facing or SOUTH
    self.HP = hp
    self.maxHP = maxhp
    self._HP = hp

    table.insert(gameObjects, self)
end

function Player:getSaveData()
  return {
    HP = self.HP,
    maxHP = self.maxHP,
    facing = self.facing,
  }
end

function Player:destroy()
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
  self.deleted = true
end

function Player:updateRollingHP(dt)
  if self.HP - self._HP < self.HPVelocity * dt then
    self.HP = self._HP
  else
    self.HP = self.HP - self.HPVelocity * dt
  end
end

function Player:update(dt)

  self:updateRollingHP(dt)

  local tileSize = screen.tileSize
  local halfTile = tileSize/2
  local dx = 0
  local dy = 0

  local px = self.body:getX()
  local py = self.body:getY()
  displayedTileHintThisFrame = false

  if love.keyboard.isDown("down") then
    dy = self.speed
    self.facing = SOUTH
  end

  if love.keyboard.isDown("up") then
    dy = -self.speed
    self.facing = NORTH
  end

  if love.keyboard.isDown("left") then
    dx = -self.speed
    self.facing = WEST
  end

  if love.keyboard.isDown("right") then
    dx = self.speed
    self.facing = EAST
  end

  -- Normalize speed on diagonal
  if normalizeDiagonalSpeed then
    local sqrt2 = math.sqrt(2)
    if dx ~= 0 and dy ~=0 then
      dx = dx/sqrt2
      dy = dy/sqrt2
    end
  end

  if self.waterTime then
    dx = dx / self.waterPenalty
    dy = dy / self.waterPenalty
  end

  -- TODO: Replace isSwinging with flags that let you use x and z
  if activeInventory.x then
    if keyboard.x then
      activeInventory.x:use()
    end
    activeInventory.x:update(dt)
  end

  if activeInventory.z then
    if keyboard.z then
      activeInventory.z:use()
    end
    activeInventory.z:update(dt)
  end

  if keyboard.q then
    prevLevel()
  end

  if keyboard.w then
    nextLevel()
  end

  if keyboard['return'] and not menuClosedThisFrame then
    menuOpen = true
  end

  local myTile = level:getTileAtCoordinates(px/tileSize, py/tileSize)
  if myTile == tiles.downstairs then
    debugString = "Stairs leading downwards. Press 'a' to go down a floor."
    if keyboard.a then
      nextLevel()
    end
    displayedTileHintThisFrame = true
  end

  if myTile == tiles.upstairs then
    debugString = "Stairs leading upwards. Press 'a' to go up a floor."
    if keyboard.a then
      prevLevel()
    end
    displayedTileHintThisFrame = true
  end

  if myTile == tiles.floor then
    self.lastSafeTile = {x = round(px/tileSize), y = round(py/tileSize)}
  end


  if not self.deleted then
    self.body:applyForce(self.speed * dx, self.speed * dy)
  end

end

function Player:getMapCoordinates()
  return math.floor(self.body:getX()/screen.tileSize), math.floor(self.body:getY()/screen.tileSize)
end

function Player:takeDamage(dmg)
  local roundedDmg = math.floor(dmg + 0.5)
  self._HP = self._HP - roundedDmg
  if self._HP < 0 then self._HP = 0 end
  self.invulnTime = 0.2
  sfx.hit2:play()
end

function Player:dealHit(otherEntity)
-- This callback is normally used to deal contact damage to the player from an enemy
-- But on the player, this will be used to apply a rebound force to the enemy attacking the player
  local vx, vy = getDirectionVector(self.body, otherEntity.body, true)
  otherEntity.body:applyLinearImpulse(self.reboundForce * vx, self.reboundForce *  vy)
end

return Player
