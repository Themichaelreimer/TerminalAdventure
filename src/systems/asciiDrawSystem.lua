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
    --love.graphics.setColor(e.colour)

    local c1,c2,c3,c4 = alphaBlendColour(e.colour, level:getLightnessAtTile(math.floor(x/tileSize), math.floor(y/tileSize)))
    love.graphics.setColor(c1, c2, c3, c4)

    love.graphics.print(e.char, x - halfsize, y - halfsize)

    if debugRender and e.shape then
      love.graphics.setColor(0.1, 0.1, 0.5, 0.5)
      love.graphics.polygon("fill", e:getWorldPoints(e.shape:getPoints()))
      love.graphics.setColor(1, 1, 1, 1)
    end
  end
end

return asciiDrawSystem
