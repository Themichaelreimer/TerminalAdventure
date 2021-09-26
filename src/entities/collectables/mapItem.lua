local MapItem = class("MapItem")

MapItem.char = 'm'
MapItem.itemName = "Map" -- Display name
MapItem.acquireString = "Explored area is permanently illuminated"
MapItem.minTextTime = 2.0

function MapItem:init(x, y)
  self.colour = colours.yellow
  self.deleted = false

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(-5, 5, 22, 22)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setSensor(true)
  self.fixture:setUserData(self)
end

function MapItem:payload()
  hasMap = true
end

function MapItem:collect()
  self:payload()
  local acquireText = self.itemName .. " acquired!"
  setBlockingText(acquireText, self.acquireString, self.minTextTime)
  self:destroy()
end

function MapItem:destroy()
  self.deleted = true
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()
end

function MapItem:dealHit(other)
  if other.isPlayer then self:collect() end
end

return MapItem
