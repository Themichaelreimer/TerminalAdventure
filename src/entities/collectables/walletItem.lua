Item = require("src.entities.collectables.baseItem")
local WalletItem = Item:extend("WalletItem")

WalletItem.char = 'w'
WalletItem.itemName = "Your Wallet" -- Display name
WalletItem.acquireString = "You got what you came for! Now you can return to the surface"

function WalletItem:payload()
  hasWallet = true
end

return WalletItem
