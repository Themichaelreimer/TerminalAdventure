local updateSystem = tiny.processingSystem(class "updateSystem")

updateSystem.filter = tiny.requireAll("update")

function updateSystem:process(entity, dt)
  if entity.update then entity:update(dt) end
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
