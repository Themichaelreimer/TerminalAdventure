-- This file defines the general behaviour of adapters
-- This is probably not the file to edit for adding content. See src/adapters.lua

local Adapter = class("adapter")

Adapter.baseCoolTime = 0.5
Adapter.baseReleaseTime = 1.0  -- Recovery time when released is used

function Adapter:init(name, useFcn, holdFcn, releaseFcn, cooldownTime, releaseTime)
  self.timer = 0
  self.holdTimer = 0
  self.cooldown = cooldownTime or self.baseCoolTime
  self.useFcn = useFcn
  self.holdFcn = holdFcn
  self.releaseFcn = releaseFcn
  self.name = name
  self.releaseTime = releaseTime
  self.persistentObject = nil  -- Reference to object for holding and releasing
end

function Adapter:use(...)
  if self.timer <= 0 then
    local obj = self.useFcn(arg)
    if obj then self.persistentObject = nil end
    self.timer = self.cooldown
  end
end

function Adapter:hold(dt)
  self.holdTimer = self.holdTimer + dt
  if self.holdFcn and self.persistentObject then self.holdFcn(persistentObject, dt) end
end

function Adapter:release(...)
  if self.releaseFcn then
    local success = self.releaseFcn(arg, self.holdTimer)
    if success then self.timer = self.releaseTime end
    self.persistentObject = nil
  end
  self.holdTimer = 0

end

function Adapter:update(dt)
  if self.timer > 0 then
    self.timer = self.timer - dt
  end
end

return Adapter
