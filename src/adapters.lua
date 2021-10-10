-- This file defines specific adapters, and functions for the adapters to run
-- This is probably the file you want to edit for adding active inventory

Adapter = require('src.itemadapter')

function useSword()
  if not player.isSwinging then
    ecsWorld:add(Sword(player))
  end
end

function makeSwordAdapter()
  return Adapter("Sword", useSword, 0.1)
end

function useHeroSword()
  if not player.isSwinging then
    ecsWorld:add(HeroSword(player))
  end
end

function makeHSwordAdapter()
  return Adapter("HeroSword", useHeroSword, 0.1)
end

function useBomb()
  local px = player.body:getX()
  local py = player.body:getY()
  local dx, dy = player.body:getLinearVelocity()
  ecsWorld:add(Bomb(px, py, dx, dy))
end

function makeBombAdapter()
  return Adapter("Bombs", useBomb, 0.3)
end
