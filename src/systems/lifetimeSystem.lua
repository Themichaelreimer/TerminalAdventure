local LifeTimeSystem = tiny.processingSystem(class "LifeTimeSystem")

LifeTimeSystem.filter = tiny.requireAll("lifetime")

function LifeTimeSystem:process(entity, dt)

  entity.lifetime = entity.lifetime - dt
  if not entity.deleted and entity.lifetime < 0 then
    if entity.onExpire then
      entity:onExpire()
    end
    if not entity.deleted and entity.destroy then entity:destroy() end
    ecsWorld:remove(entity)
  end
end

return LifeTimeSystem
