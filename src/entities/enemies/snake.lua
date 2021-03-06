local Snake = class("Snake")
local Heart = require('src.entities.heart')

Snake.char = 's'
Snake.size = 14
Snake.damage = 6
Snake.speed = 9
Snake.randomWalkSpeed = 20
Snake.dashSpeed = 800
Snake.dashChance = 0.5
Snake.force = 200
Snake.ld = 7
Snake.baseHP = 25
Snake.behaviour = "idle" -- Enables AI system
Snake.stunTime = 0.35
Snake.IDLE_TIME = 1.10
Snake.MOVE_TIME = 0.20
Snake.maxRange = 30
Snake.colourName = "red"
Snake.waterPenalty = 2

Snake.heartProbability = 0.2
Snake.heartRecovery = 3

function Snake:init(x, y, saveData)
  self.deleted = false
  self.dead = false
  self.colour = colours[self.colourName]

  self.body = love.physics.newBody(world, x, y, "dynamic")
  self.shape = love.physics.newCircleShape(self.size)
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
  if chance(self.heartProbability) then ecsWorld:add( Heart(self.body:getX(), self.body:getY(), self.heartRecovery) ) end
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
    self:idle(self.stunTime)  -- This defaults to IDLE_TIME, but can be overridden for shorter stun times
  end
end

-- draw handled by asciiDrawSystem

function Snake:update()
  if self.lifetime then
    self.alpha = 0.5 * (1 - math.cos(self.lifetime * self.lifetime * 4 * math.pi))
  end
end


function Snake:die()
  --ecsWorld:add( Heart(self.body:getX(), self.body:getY(), self.heartRecovery) )
  self.dead = true
  self.colour = colours.lightGray
  self.lifetime = 1.5  -- Sets the snake to auto delete in 1 second
  ecsWorld:add(self)  -- Needed to refresh what systems snek is part of
end

function Snake:dash()
  local dx, dy = getDirectionVector(self.body, player.body, true)
  if self.waterTime then
    dx = dx / self.waterPenalty
    dy = dy / self.waterPenalty
  end
  self.body:setLinearVelocity(dx * self.dashSpeed, dy * self.dashSpeed)

  self:idle()
end

function Snake:idle(time)
  -- Snake will idle for time if given, or IDLE_TIME if none is given
  local t = time or self.IDLE_TIME
  self.moveTimer = 0
  self.idleTimer = t
end

function Snake:handleAI(dt)
  local path = findPathToEntity(self, player, self.maxRange)

  -- IDLE PHASE
  if self.idleTimer > 0 then
    self.idleTimer = self.idleTimer - dt
    if self.idleTimer <= 0 then self.moveTimer = self.MOVE_TIME end
    return
  end

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

  else
    self:randomWalk()
  end
end

function Snake:toString()
  return self.class.name .. ": ".. self.HP.. "- (".. self.body:getX() .. "," .. self.body:getY() .. ")"
end

function Snake:randomWalk()


  self.moveTimer = 0
  self.idleTimer = self.IDLE_TIME

  local dv = randomElement({{x=-1,y= 0}, {x=0, y=1}, {x=1, y=0}, {x=0, y=-1}})
  local tx = self.body:getX()/screen.tileSize + dv.x
  local ty = self.body:getY()/screen.tileSize + dv.y
  local myTile = level:getTileAtCoordinates(tx, ty)
  if myTile and myTile.aiAvoid then return end

  local dx = dv.x * self.randomWalkSpeed
  local dy = dv.y * self.randomWalkSpeed

  self.body:applyLinearImpulse(dx, dy)

end

return Snake
