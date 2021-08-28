NORTH = 0
EAST = 1
SOUTH = 2
WEST = 3

Player = {
  className = "Player",
  shape = {},
  body = {},
  size = 22,
  moveSpeed = 100,
  isSwinging = false,
  swordObject = {},
  facing = NORTH,
  swingDuration = 0.75
}

function Player:new(o, world, x, y)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.body:setMass(5000)
  self.body:setFixedRotation(true)
  self.shape = love.physics.newRectangleShape(-5, 5, self.size, self.size)
  self.fixture = love.physics.newFixture(self.body, self.shape)
  self.fixture:setCategory(collisionCategories.player)
  self.fixture:setUserData(o)
  return o
end

function Player:draw()
  local px = self.body:getX()
  local py = self.body:getY()
  local playerStep = 2*math.sin((px + py)/4)
  local tSize = screen.tileSize
  local swordBody = self.swordObject.body

  love.graphics.setColor(colours.black)
  --love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))

  love.graphics.setColor(colours.green) -- nord green
  love.graphics.print("@", px-tSize/2, py-tSize/2 + playerStep, self.body:getAngle())
  if self.isSwinging then
    local swordOriginX = swordBody:getX() -- - self.swordObject.width/2
    local swordOriginY = swordBody:getY() -- - self.swordObject.height/2 --+ tSize/2
    local swordAngle = swordBody:getAngle()
    love.graphics.print("l", swordOriginX, swordOriginY, swordAngle, 1, 1, self.swordObject.width/2, self.swordObject.height/2)
  end

    -- DEBUG
  if debugRender then
    love.graphics.setColor(0.1, 0.1, 0.5, 0.5)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
    if self.isSwinging then
      love.graphics.setColor(0,0,1,0.6)
      love.graphics.polygon("fill", self.swordObject.body:getWorldPoints(self.swordObject.shape:getPoints()))
      local itemX, itemY = self:getItemPosition()

      love.graphics.circle("fill", itemX, itemY, 4)
    end
    love.graphics.setColor(1, 1, 1, 1)
  end

end

function Player:update(dt)
  local tileSize = screen.tileSize
  local halfTile = tileSize/2
  local dx = 0
  local dy = 0

  local px = self.body:getX()
  local py = self.body:getY()
  displayedTileHintThisFrame = false

  if love.keyboard.isDown("down") and py < level.pixelHeight - halfTile then
    dy = self.moveSpeed
    self.facing = SOUTH
  end

  if love.keyboard.isDown("up") and py > halfTile then
    dy = -self.moveSpeed
    self.facing = NORTH
  end

  if love.keyboard.isDown("left") and px > 0 then
    dx = -self.moveSpeed
    self.facing = WEST
  end

  if love.keyboard.isDown("right") and px < level.pixelWidth then
    dx = self.moveSpeed
    self.facing = EAST
  end

  if love.keyboard.isDown("x") and not self.isSwinging then
    self:swingSword()
  end

  if level:getTileAtCoordinates(px/tileSize, py/tileSize) == tiles.downstairs then
    debugString = "Stairs leading downwards. Press > to go down a floor."
    if love.keyboard.isDown(">") then
      nextLevel()
    end
    displayedTileHintThisFrame = true
  end

  if level:getTileAtCoordinates(px/tileSize, py/tileSize) == tiles.upstairs then
    debugString = "Stairs leading upwards. Press < to go up a floor."
    if love.keyboard.isDown("<") then
      prevLevel()
    end
    displayedTileHintThisFrame = true
  end

  if not displayedTileHintThisFrame then
    debugString = ''
  end

  -- Normalize speed on diagonal
  if normalizeDiagonalSpeed then
    local sqrt2 = math.sqrt(2)
    if dx ~= 0 and dy ~=0 then
      dx = dx/sqrt2
      dy = dy/sqrt2
    end
  end

  self.body:setLinearVelocity(dx,dy)

  if self.isSwinging then
    self.swordObject.timeElapsed = self.swordObject.timeElapsed + dt
    if self.swordObject.timeElapsed > self.swordObject.timeMax then
      self:endSwingSword()
    else
      self:updateSword()
    end
  end
end

function Player:getMapCoordinates()
  return math.floor(self.body:getX()/screen.tileSize), math.floor(self.body:getY()/screen.tileSize)
end

function Player:getItemPosition()
  local xOffset = 0
  local yOffset = 0
  if self.facing == WEST then
    xOffset = -self.size
  elseif self.facing == EAST then
    xOffset = self.size
  elseif self.facing == NORTH then
    yOffset = -self.size
  else
    yOffset = self.size
  end
  return self.body:getX() - self.size/4, self.body:getY() + self.size/4
end

function Player:updateSword(dt)
  local body = self.swordObject.body
  -- Update Angle of Sword
  local angularVelocity = (self.swordObject.stopAngle - self.swordObject.startAngle) / self.swordObject.timeMax
  local angle = self.swordObject.startAngle + angularVelocity * self.swordObject.timeElapsed
  body:setAngle(angle + math.pi/2)

  -- Update position of sword, which follows a circle centered on the owner
  local itemX, itemY = self:getItemPosition()
  local r = self.swordObject.height
  body:setPosition(itemX - r * math.cos(angle), itemY -  r * math.sin(angle))
end

function Player:getSwordAngleRange()
  if self.facing == NORTH then
    local start = math.pi * 1 / 4
    local stop = start + math.pi/2
    return start, stop

  elseif self.facing == EAST then

    local start = math.pi * 3 / 4
    local stop = start + math.pi/2
    return start, stop

  elseif self.facing == SOUTH then

    local start = math.pi * 5 / 4
    local stop = start + math.pi/2
    return start, stop

  else -- WEST
    local start = math.pi * 7 / 4
    local stop = start + math.pi/2
    return start, stop
  end
end

function Player:swingSword()
  local start, stop = self:getSwordAngleRange()
  self.isSwinging = true
  self.swordObject = {
      body = love.physics.newBody(world, self.body:getX(), self.body:getY(), "kinematic"),
      shape =  love.physics.newRectangleShape(8,24),
      width = 8,
      height = 24,
      timeMax = 0.25,
      timeElapsed = 0.0,
      startAngle = start,
      stopAngle = stop
    }
  self.swordObject.fixture = love.physics.newFixture(self.swordObject.body, self.swordObject.shape)
  self.swordObject.fixture:setMask(collisionCategories.player) -- Might not be necessary with the joint

end

function Player:endSwingSword()
  self.swordObject.fixture:destroy()
  --swordObject.shape:destroy()  -- Can't seem to call this destructor, but I think I need one for memory leakage?
  self.swordObject.body:destroy()
  self.swordObject = {}
  self.isSwinging = false
end
