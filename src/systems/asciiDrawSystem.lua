-- TODO:
-- Implement system to draw entities that have the following components:
--    - body
--    - colour
--    - char
--    - bouncy (optional: boolean)
--    - angle (optional: number)


local asciiDrawSystem = tiny.processingSystem(class "asciiDrawSystem")

-- Entities must have body, colour, and char,
-- and NOT have a draw method. Those are handled in drawSystem
asciiDrawSystem.filter = tiny.filter("body&colour&char&!draw")

function asciiDrawSystem:process(e, dt)
  if not e.deleted then
    local x = e.body:getX()
    local y = e.body:getY()
    local size = screen.tileSize/2
    love.graphics.setColor(e.colour)
    love.graphics.print(e.char, x - size, y - size)

    if debugRender and e.shape then
      love.graphics.setColor(0.1, 0.1, 0.5, 0.5)
      love.graphics.polygon("fill", e:getWorldPoints(e.shape:getPoints()))
      love.graphics.setColor(1, 1, 1, 1)
    end
  end
end

return asciiDrawSystem
