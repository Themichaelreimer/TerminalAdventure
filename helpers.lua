function randomElement(arr)
  -- Given a table representing an array, returns a random element
  local index = love.math.random(1, #arr)
  return arr[index]
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
