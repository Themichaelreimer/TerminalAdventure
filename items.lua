Item = {
  className = "Item",
  minTextTime = 2.0,
}

function Item:new(o, world, x, y, char, colour, collectCallback)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  o.collectCallback = collectCallback
  o.colour = colour
  o.char = char
  o.body = love.physics.newBody(world, x, y, "dynamic")
  o.shape = love.physics.newRectangleShape(-5, 5, 22,22)
  o.fixture = love.physics.newFixture(o.body, o.shape, 1)
  o.fixture:setSensor(true)
  o.fixture:setUserData(o)

  --level:addItemToLevel(self)
  return o
end

function Item:destroy()
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
end

function Item:collect()
  local acquireText = self.itemName .. " acquired!"
  setBlockingText(acquireText, self.acquireString, self.minTextTime)
  level:removeItemFromLevel(self)
  self:collectCallback()
  self:destroy()
end

function Item:update(dt)

end

function Item:draw()

  local x = self.body:getX()
  local y = self.body:getY()
  local size = screen.tileSize

  love.graphics.setColor(colours.black)
  --love.graphics.rectangle("fill", x-size, y, size, size)
  love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))

  local c1,c2,c3,c4 = alphaBlendColour(self.colour, level:getLightnessAtTile(math.floor(x/size), math.floor(y/size)))
  love.graphics.setColor(c1, c2, c3, c4)
  love.graphics.print(self.char, x-size/2, y-size/2)

  if debugRender then
    love.graphics.setColor(0.1, 0.1, 0.5, 0.5)
    love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
  end
end

-------------------------------------------------------------------
--  Creates and callbacks                                        --
-------------------------------------------------------------------

function createMapObject(world, x, y)

  local result = Item:new(nil, world, x, y, 'm', colours.yellow, collectMap)
  result.itemName = "Map"
  result.acquireString = "Explored area is permanently illuminated"
  return result

end

function createCoinsObject(world, x, y)
  local result = Item:new(nil, world, x, y, '$', colours.yellow, badCallback)
  result.itemName = "Coins"
  return result
end

function createXRayGlassesObject(world, x, y)
  local result = Item:new(nil, world, x, y, 'x', colours.yellow, collectXRay)
  result.itemName = "X Ray Glasses"
  result.acquireString = "You can now see through walls"
  return result
end

function collectXRay()
  hasXRay = true
end

function collectMap()
  hasMap = true
end

function badCallback()
  debugString = "COLLECT GOLD CALLBACK - THIS SHOULDN'T HAVE RUN"
end
