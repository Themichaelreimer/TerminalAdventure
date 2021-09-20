-- This system deals damage and applies force to entities
-- on collision with a fixture

-- THIS SYSTEM IS LIKELY DEPRECATED IN FAVOUR OF BOX2D EVENT HANDLING

local collisionDamageSystem = tiny.processingSystem(class "CollisionDamageSystem")
collisionDamageSystem.filter = tiny.requireAll("dealHit", "body")

function collisionDamageSystem:process(entity, dt)
  if entity.dealHit and not entity.deleted then
    local contacts = entity.body:getContacts()
    -- Idea: Iterate over collection of contacts and call dealHit
    for _, contact in pairs(contacts) do
      fixture1, fixture2 = contact:getFixtures()
      e1 = fixture1:getUserData()
      e2 = fixture2:getUserData()
      handlePossibleHit(entity, e1)
      handlePossibleHit(entity, e2)
    end

  end
end

-- This function should determine if the fixture hit
-- is part of an entity, and if it's an entity, trigger the
-- appropriate response
function handlePossibleHit(giver, receiver)
  -- Note: receiver is the userData on a fixture
  -- By convention, I will only set this value on the
  -- fixtures of game objects. (Therefore, non-null implies ECS gameobject)
  if receiver == nil then return nil end
  if giver.dealHit then giver:dealHit(receiver) end
end

return collisionDamageSystem
