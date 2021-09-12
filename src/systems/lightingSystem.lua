local lightingSystem = tiny.processingSystem(class "lightingSystem")

lightingSystem.filter = tiny.requireAll("lightDistance")

function lightingSystem.process(entity, dt)
  -- The entities represent light sources
  
end

return lightingSystem
