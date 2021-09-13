function randomElement(arr)
  -- Given a table representing an array, returns a random element
  local index = love.math.random(1, #arr)
  return arr[index]
end

function round(x)
  return math.floor(0.5 + x)
end
