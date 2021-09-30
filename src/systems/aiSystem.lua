local aiSystem = tiny.processingSystem(class "aiSystem")

aiSystem.filter = tiny.requireAll("handleAI", "body")
aiSystem.maxRange = 30  -- 30 tiles

function aiSystem:process(e, dt)

  if not e.deleted and not e.dead then
    e:handleAI(dt)
  end
end

function moveToTarget(e, pathCell)
  local tx = (pathCell.x * screen.tileSize) - e.body:getX() + 0.5*screen.tileSize
  local ty = (pathCell.y * screen.tileSize) - e.body:getY() + 0.5*screen.tileSize
  e.body:setLinearVelocity(e.speed*tx, e.speed*ty)
end

return aiSystem
