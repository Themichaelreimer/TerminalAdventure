local LavaSystem =  tiny.processingSystem(class "LavaSystem")

LavaSystem.filter = tiny.requireAll("speed", "body")
LavaSystem.drownTime = 0.5
LavaSystem.drownDamage = 4
LavaSystem.fireTime = 4.0

function LavaSystem:process(entity, dt)
  if not entity.deleted then
    local tileX = math.floor((entity.body:getX() + 0.5) / screen.tileSize)
    local tileY = math.floor((entity.body:getY() + 0.5) / screen.tileSize)
    local addEntityToFireSystem = false
    if level and level:tileInLevel(tileX,tileY) and level.map.map[tileY][tileX] == tiles.lava then

      if not entity.fireTime then addEntityToFireSystem = true end
      entity.fireTime = self.fireTime
      if addEntityToFireSystem then ecsWorld:add(entity) end

      if not entity.lavaTime or (entity == player and false) then -- replace false with hasDragonArmour
        entity.lavaTime = self.drownTime
      else
        entity.lavaTime = entity.lavaTime - dt
        if entity.lavaTime < 0 then
          -- deal hit
          if entity.takeDamage then
            entity:takeDamage(self.drownDamage)
            entity.lavaTime = nil
          end
          -- teleport back to a safe tile
          if entity.lastSafeTile then
            local targetTile = entity.lastSafeTile
            entity.body:setPosition( (targetTile.x+0.5)*screen.tileSize, (targetTile.y+0.5)*screen.tileSize )
          end
        end
      end

    else
      entity.lavaTime = nil
    end
  end
end

return LavaSystem
