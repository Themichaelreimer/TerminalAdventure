local FireSystem = tiny.processingSystem(class "FireSystem")

FireSystem.filter = tiny.requireAll("fireTime", "takeDamage")

function FireSystem:process(entity, dt)

  if entity.deleted or not entity.fireTime then
    return
  end

  entity.fireTime = entity.fireTime - dt
  if entity.fireTime < 0 then
    entity.fireTime = nil
    entity.lastFireDamageTime = nil
  else
    if not entity.lastFireDamageTime or entity.lastFireDamageTime - entity.fireTime >= 1 then
      entity.lastFireDamageTime = entity.fireTime
      entity:takeDamage(1)
    end
  end
end

return FireSystem
