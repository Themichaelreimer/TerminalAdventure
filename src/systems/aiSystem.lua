local aiSystem = tiny.processingSystem(class "aiSystem")

-- Enemy component just has to exist, doesn't have useful data. Just marks an entity as needing AI
aiSystem.filter = tiny.requireAll("behaviour", "body")
aiSystem.maxRange = 30  -- 30 tiles

function aiSystem:process(e, dt)
  if not e.deleted then

    local distance = getDistanceBetweenBodies(player.body, e.body)
    if distance < self.maxRange * screen.tileSize then
      local path = aStarSearch(e.body, player.body, 30)
    end

  end
end

-- Performs A* search on the active map, between two bodies
function aStarSearch(startBody, stopBody, maxDist)
  local map = level.map.map
  local nodes = {}

end

return aiSystem
