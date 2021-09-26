function randomElement(arr)
  -- Given a table representing an array, returns a random element
  local index = love.math.random(1, #arr)
  return arr[index]
end

function chance(x)
  assert(0 <= x and x <= 1)
  return love.math.random() <= x
end

function round(x)
  return math.floor(0.5 + x)
end

-- I think west and east should be flipped, but this gives the correct behaviour in src/entities/sword
function angleFromDirection(dir)
  if dir == EAST then return math.pi end
  if dir == NORTH then return math.pi / 2 end
  if dir == WEST then return 0 end
  if dir == SOUTH then return 3 * math.pi / 2 end
end

function getDirectionVector(body1, body2, normalized)
  -- Returns a vector from body1 to body2. If normalized, then this vector has length=1
  local normalized = normalized or false
  local dx = body2:getX() - body1:getX()
  local dy = body2:getY() - body1:getY()
  if normalized == false then
    return dx, dy
  else
    local r = math.sqrt(dx * dx + dy * dy)
    return dx/r, dy/r
  end
end

function getDistanceBetweenBodies(body1, body2)
  dx = body2:getX() - body1:getX()
  dy = body2:getY() - body1:getY()
  return math.sqrt(dx*dx + dy*dy)
end

function pixelsToTiles(x, y)
  local result = {
    x = math.floor(x/screen.tileSize),
    y = math.floor(y/screen.tileSize)
  }
  return result
end
