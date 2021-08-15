Item = {
  className = "Item"
}

function Item:new(o, world, x, y, char, colour, collectCallback)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  self.collectCallback = collectCallback
  self.colour = colour
  self.char = char
  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(-5, 5, 22,22)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setSensor(true)
  self.fixture:setUserData(self)

  --level:addItemToLevel(self)
  return self
end

function Item:destroy()

end

function Item:collect()
  level:removeItemFromLevel(self)
  self:collectCallback()
  self:destroy()
end

function Item:update(dt)

end

function Item:draw(dt)

  local x = self.body:getX()
  local y = self.body:getY()
  local size = screen.tileSize

  local c1,c2,c3,c4 = alphaBlendColour(self.colour, level:getLightnessAtTile(math.floor(x/size), math.floor(y/size)))
  love.graphics.setColor(self.colour)
  love.graphics.print(self.char, x-size/2, y-size/2)
end

-------------------------------------------------------------------
--  Creates and callbacks                                        --
-------------------------------------------------------------------

function createMapObject(world, x, y)

  local result = Item:new(nil, world, x, y, 'm', colours.yellow, collectMap)
  return result

end

function collectMap()
  hasMap = true
end
