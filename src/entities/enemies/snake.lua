local Snake = class("Snake")

Snake.char = 's'
Snake.size = 14
Snake.damage = 6
Snake.speed = 9
Snake.dashSpeed = 800
Snake.dashChance = 0.5
Snake.force = 200
Snake.ld = 7
Snake.baseHP = 25
Snake.behaviour = "idle" -- Enables AI system
Snake.IDLE_TIME = 1.10
Snake.MOVE_TIME = 0.20
Snake.maxRange = 30
Snake.colourName = "red"

function Snake:init(x, y, saveData)
  self.deleted = false
  self.dead = false
  self.colour = colours[self.colourName]

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newRectangleShape(-5, 5, self.size, self.size)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
  self.fixture:setUserData(self)

  self.body:setFixedRotation(true)
  self.body:setLinearDamping(self.ld)

  self.maxHP = self.baseHP
  self.HP = self.maxHP

  self.moveTimer = 1
  self.idleTimer = 1

  if saveData then
    if saveData.HP then self.HP = saveData.HP end
  end
end

function Snake:getSaveData()
  return {
    name = self.class.name,
    hp = self.HP,
    x = self.body:getX(),
    y = self.body:getY()
  }
end

function Snake:destroy()
  -- Clean up resources to prevent leaks
  self.deleted = true
  self.fixture:destroy()
  self.shape:release()
  self.body:destroy()

end

function Snake:dealHit(otherEntity)
  if not self.lifetime and otherEntity.isPlayer then
    if otherEntity == self or not otherEntity.takeDamage then return nil end
    otherEntity:takeDamage(self.damage)

    local vx, vy = getDirectionVector(self.body, otherEntity.body, true)
    otherEntity.body:applyLinearImpulse(self.force * vx, self.force *  vy)
  end
end

function Snake:takeDamage(damage)

  if not self.lifetime then
    self.HP = self.HP - damage
    if self.HP < 1 then
      sfx.death2:play()
      self:die()
    else
      sfx.hit3:play()
    end
    self.invulnTime = 0.3
  end
end

-- draw handled by asciiDrawSystem

function Snake:update()
  if self.lifetime then
    self.alpha = 0.5 * (1 - math.cos(self.lifetime * self.lifetime * 4 * math.pi))
  end
end


function Snake:die()
  self.dead = true
  self.colour = colours.lightGray
  self.lifetime = 1.5  -- Sets the snake to auto delete in 1 second
  ecsWorld:add(self)  -- Needed to refresh what systems snek is part of
end

function Snake:dash()
  local dx, dy = getDirectionVector(self.body, player.body, true)
  self.body:setLinearVelocity(dx * self.dashSpeed, dy * self.dashSpeed)

  self.moveTimer = 0
  self.idleTimer = self.IDLE_TIME
end

function Snake:handleAI(dt)
  local path = findPathToEntity(self, player, self.maxRange)
  if path then

    -- MOVE PHASE
    if self.moveTimer > 0 then
      -- Beginning of move cycle
      if self.moveTimer == self.MOVE_TIME and chance(self.dashChance) then
        self:dash()
      else
        -- Normal movement
        moveToTarget(self, path[2])
        self.moveTimer = self.moveTimer - dt
        if self.moveTimer <= 0 then self.idleTimer = self.IDLE_TIME end
      end
    end

    -- IDLE PHASE
    if self.idleTimer > 0 then
      self.idleTimer = self.idleTimer - dt
      if self.idleTimer <= 0 then self.moveTimer = self.MOVE_TIME end
    end

  else
    self.moveTimer = self.MOVE_TIME
  end
end

function Snake:toString()
  return self.class.name .. ": ".. self.HP.. "- (".. self.body:getX() .. "," .. self.body:getY() .. ")"
end

return Snake
