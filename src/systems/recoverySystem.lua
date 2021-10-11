local RecoverySystem = tiny.processingSystem(class "RecoverySystem")

RecoverySystem.filter = tiny.requireAll("recoverAmount", "recoverInterval", "HP")

function RecoverySystem:process(entity, dt)

  if not hasAmulet and entity == player then
    return
  end

  if entity.deleted or entity.HP == 0 or entity.HP == entity.maxHP then
    return
  end

  if not entity.recoverTimer then entity.recoverTimer = entity.recoverInterval end
  entity.recoverTimer = entity.recoverTimer - dt

  if entity.recoverTimer < 0 then
    entity.recoverTimer = entity.recoverInterval
    if entity._HP then
      entity._HP = entity._HP + entity.recoverAmount
      if entity._HP > entity.maxHP then entity._HP = entity.maxHP end
    else
      entity.HP = entity.HP + entity.recoverAmount
      if entity.HP > entity.maxHP then entity.HP = entity.maxHP end
    end
  end
end

return RecoverySystem
