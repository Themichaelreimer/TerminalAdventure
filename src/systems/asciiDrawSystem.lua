local asciiDrawSystem = tiny.processingSystem(class "asciiDrawSystem")

-- Entities must have body, colour, and char,
-- and NOT have a draw method. Those are handled in drawSystem
asciiDrawSystem.filter = tiny.filter("body&colour&char&!draw")

function asciiDrawSystem:process(e, dt)
  if not e.deleted then
    local x = e.body:getX()
    local y = e.body:getY()

    if e.bouncyStep and e.bouncyStep == true then
      y = y + 2*math.sin((x + y) / 4)
    end

    local tileSize = screen.tileSize
    local halfsize = screen.tileSize/2
    local xScale = e.xScale or 1
    local yScale = e.yScale or 1

    local lightness = level:getLightnessAtTile(math.floor(x/tileSize), math.floor(y/tileSize))

    -- Actual render block
    local c1, c2, c3, c4 = self:determineColour(e, lightness)
    if e.alpha then c4 = c4 * e.alpha end
    love.graphics.setColor(c1, c2, c3, c4)
    love.graphics.print(e.char, x - halfsize, y - halfsize, 0, xScale, yScale)

    -- Update invuln time if the property exists
    -- It's probably better to make a new invulnTime system, but ehh
    if e.invulnTime and e.invulnTime > 0 then e.invulnTime = e.invulnTime - dt end

    if debugRender and e.shape then
      love.graphics.setColor(0.1, 0.1, 0.5, 0.5)
      love.graphics.polygon("fill", e.body:getWorldPoints(e.shape:getPoints()))
      love.graphics.setColor(1, 1, 1, 1)
    end
  end
end

function asciiDrawSystem:determineColour(e, lightness)

  local baseColour = e.colour
  if e.waterTime and e.waterTime > 0 then
    baseColour = colours.blue
  end

  if e.fireTime and e.fireTime > 0 then
    baseColour = colours.red
  end

  if not e.invulnTime or e.invulnTime < 0 then
    return alphaBlendColour(baseColour, lightness)
  end

  local cIndex = math.floor((e.invulnTime * 10)) % 2
  if cIndex == 0 then
    return alphaBlendColour(colours.white, 0)
  else
    return alphaBlendColour(colours.white, lightness)
    --return 0, 0, 0, 0
  end
end

return asciiDrawSystem
