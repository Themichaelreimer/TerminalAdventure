local updateSystem = tiny.processingSystem(class "updateSystem")

updateSystem.filter = tiny.requireAll("update")

function updateSystem:process(entity, dt)
  -- Do not run update methods while the game should be "paused", which is true if
  -- We have blocking text or an open menu (not implemented yet)
  if entity and not blockingText then
    if entity.update and not entity.deleted then entity:update(dt) end
    self:cleanupGameObjects()
  end
end

-- Updates the table of references to accessible game objects
function updateSystem:cleanupGameObjects()
  local newGameobjects = {}
  for i=1, #gameObjects do
    if gameObjects[i].deleted == false then
      table.insert(newGameobjects, gameObjects[i])
    end
  end
  gameObjects = newGameobjects
end

return updateSystem
