local DrawSystem = tiny.processingSystem(class "DrawSystem")

DrawSystem.filter = tiny.requireAll("draw")

function DrawSystem:process(entity, dt)
  if entity.draw and not entity.deleted then entity:draw() end
end

return DrawSystem
