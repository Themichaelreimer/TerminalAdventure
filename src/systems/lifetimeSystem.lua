local LifeTimeSystem = tiny.processingSystem(class "LifeTimeSystem")

LifeTimeSystem.filter = tiny.requireAll("lifetime")

function LifeTimeSystem:process(entity, dt)

  entity.lifetime = entity.lifetime - dt
  if entity.lifetime < 0 then
    if entity.onExpire then
      entity:onExpire()
    end
    if entity.destroy then entity:destroy() end
    ecsWorld:remove(entity)
  end
end

return LifeTimeSystem
