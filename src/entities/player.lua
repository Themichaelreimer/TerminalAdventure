Bomb = require("src.entities.bomb")
Sword = require("src.entities.sword")

local Player = class("Player")

Player.char = '@'
Player.size = 20
Player.speed = 20
Player.ld = 7
Player.baseHP = 24
Player.lightDistance = 8
Player.bouncyStep = true -- Enables bouncy step in asciiDrawSystem
Player.isPlayer = true -- Used in collision handling with enemies

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

function Player:update(dt)

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

  -- TODO: Replace isSwinging with flags that let you use x and z
  if keyboard.x and not self.isSwinging then
    ecsWorld:add(Sword(self))
  end

  if keyboard.z then
    if hasBombs then
      ecsWorld:add(Bomb(px, py, dx, dy))
    end
  end

  if keyboard.q then
    prevLevel()
  end

  if keyboard.w then
    nextLevel()
  end

  if level:getTileAtCoordinates(px/tileSize, py/tileSize) == tiles.downstairs then
    debugString = "Stairs leading downwards. Press 'a' to go down a floor."
    if keyboard.a then
      nextLevel()
    end
    displayedTileHintThisFrame = true
  end

  if level:getTileAtCoordinates(px/tileSize, py/tileSize) == tiles.upstairs then
    debugString = "Stairs leading upwards. Press 'a' to go up a floor."
    if keyboard.a then
      prevLevel()
    end
    displayedTileHintThisFrame = true
  end

  if not displayedTileHintThisFrame then
    debugString = ''
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
  self.HP = self.HP - roundedDmg
  if self.HP < 0 then self.HP = 0 end
  self.invulnTime = 0.2
end

return Player