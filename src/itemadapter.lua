-- This file defines the general behaviour of adapters
-- This is probably not the file to edit for adding content. See src/adapters.lua

local Adapter = class("adapter")

Adapter.baseCoolTime = 0.5

function Adapter:init(name, useFcn, cooldownTime)
  self.timer = 0
  self.cooldown = cooldownTime or self.baseCoolTime
  self.useFcn = useFcn
  self.name = name
end

function Adapter:use(...)
  if self.timer <= 0 then
    self.useFcn(arg)
    self.timer = self.cooldown
  end

end

function Adapter:update(dt)
  if self.timer > 0 then
    self.timer = self.timer - dt
  end
end

return Adapter
