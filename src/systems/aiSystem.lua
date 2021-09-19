local aiSystem = tiny.processingSystem(class "aiSystem")

-- Enemy component just has to exist, doesn't have useful data. Just marks an entity as needing AI
aiSystem.filter = tiny.requireAll("enemy", "body")
aiSystem.maxRange = 30  -- 30 tiles

function aiSystem:process(e, dt)
  if not e.deleted then

  end
end

function aiSystem.findPath(startBody, stopBody, maxDist)
  local pixelDistance 
end

return aiSystem
