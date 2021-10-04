local WaterSystem =  tiny.processingSystem(class "WaterSystem")

WaterSystem.filter = tiny.requireAll("speed", "body")
WaterSystem.drownTime = 1.0
WaterSystem.drownDamage = 4

function WaterSystem:process(entity, dt)
  if not entity.deleted then
    local tileX = math.floor((entity.body:getX() + 0.5) / screen.tileSize)
    local tileY = math.floor((entity.body:getY() + 0.5) / screen.tileSize)
    if level and level:tileInLevel(tileX,tileY) and level.map.map[tileY][tileX] == tiles.water then
      if not entity.waterTime or (entity == player and hasLifeJacket) then
        entity.waterTime = self.drownTime
      else
        entity.waterTime = entity.waterTime - dt
        if entity.waterTime < 0 then
          -- deal hit
          if entity.takeDamage then
            entity:takeDamage(self.drownDamage)
            entity.waterTime = nil
          end
          -- teleport back to a safe tile
          if entity.lastSafeTile then
            local targetTile = entity.lastSafeTile
            entity.body:setPosition( (targetTile.x+0.5)*screen.tileSize, (targetTile.y+0.5)*screen.tileSize )
          end
        end
      end

    else
      entity.waterTime = nil
    end
  end
end

return WaterSystem
