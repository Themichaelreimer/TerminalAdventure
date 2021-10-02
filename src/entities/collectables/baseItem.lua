local Item = class("Item")

-- OVERRIDE THESE PARAMS, AND "Item:payload()"
Item.char = 'i'
Item.itemName = "item" -- Display name
Item.acquireString = "[Base Item does nothing]"


Item.minTextTime = 2.0

function Item:init(x, y)
  self.colour = colours.yellow
  self.deleted = false

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(-5, 5, 22, 22)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setSensor(true)
  self.fixture:setUserData(self)
end

function Item:getSaveData()
  return {
    name = self.class.name,
    x = self.body:getX(),
    y = self.body:getY()
  }
end

-- OVERRIDE ME
function Item:payload()
end

function Item:collect()
  self:payload()
  local acquireText = self.itemName .. " acquired!"
  setBlockingText(acquireText, self.acquireString, self.minTextTime)
  self:destroy()
end

function Item:destroy()
  self.deleted = true
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
end

function Item:dealHit(other)
  if other.isPlayer then self:collect() end
end

function Item:toString()
  return self.class.name .. ": (".. self.body:getX() .. "," .. self.body:getY() .. ")"
end

return Item
