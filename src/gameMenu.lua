require('src.adapters')

menuOpen = false
menuIndex = 1
menuClosedThisFrame = false

------------------------------------
hasMap = false
hasXRay = false
hasBombs = false
hasLifeJacket = false
hasArmour = false
hasAmulet = false
hasWallet = false
------------------------------------

inventory = {makeSwordAdapter()}
activeInventory = {
  x = inventory[1],
  z = nil,
}

function menuDraw()
  local margin = 24
  local lineHeight = 36
  local cellWidth = 256
  local halfHeight = screen.height/2
  local halfWidth = screen.width/2
  local quarterHeight = screen.height/4

  -- Transparent background
  love.graphics.setColor(colours.black[1], colours.black[2], colours.black[3], 0.95)
  love.graphics.rectangle("fill", 0, 0, screen.width, screen.height)

  love.graphics.setColor(colours.white)
  love.graphics.print("Active Inventory: ", margin, margin)

  for i, v in ipairs(inventory) do
    if i == menuIndex then love.graphics.setColor(colours.green) else love.graphics.setColor(colours.white) end
    local str = ""
    if v == activeInventory.x then str = "[x]" end
    if v == activeInventory.z then str = "[z]" end

    love.graphics.print(str..v.name, margin, margin + i * lineHeight)
  end

  love.graphics.setColor(colours.yellow)
  love.graphics.print("Passive Inventory:", margin, 3 * quarterHeight)
  if hasMap then
    love.graphics.print("Map", margin, 3* quarterHeight + lineHeight)
  end
  if hasXRay then
    love.graphics.print("X-Ray Glasses", margin, 3* quarterHeight + 2*lineHeight)
  end
  if hasLifeJacket then
    love.graphics.print("Life Jacket", margin + cellWidth, 3* quarterHeight + lineHeight)
  end
  if hasAmulet then
    love.graphics.print("Recovery Amulet", 2*cellWidth, 3* quarterHeight + lineHeight)
  end
  if hasArmour then
    love.graphics.print("Dragon Armour",  3*cellWidth, 3* quarterHeight + lineHeight)
  end
  if hasWallet then
    love.graphics.print("Your Wallet",  3*cellWidth, 3* quarterHeight + 3*lineHeight)
  end

end

function menuUpdate(dt)
  if not menuOpen then return end

  -- Handle index input
  if keyboard.down then
    menuIndex = menuIndex + 1
  end
  if keyboard.up then
    menuIndex = menuIndex - 1
  end

  -- Handle roll over
  if menuIndex > #inventory then
    menuIndex = 1
  elseif menuIndex < 1 then
    menuIndex = #inventory
  end

  if keyboard.x then
    trySetActiveInventory("x")
  end

  if keyboard.z then
    trySetActiveInventory("z")
  end

  if keyboard['return'] then
    menuOpen = false
    menuClosedThisFrame = true
  end

end

function trySetActiveInventory(key)
  if not inventory[menuIndex] then return end

  if inventory[menuIndex] == activeInventory[key] then
    activeInventory[key] = nil
  else
    activeInventory[key] = inventory[menuIndex]
  end
end
