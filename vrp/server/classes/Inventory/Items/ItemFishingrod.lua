-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/ItemFishingrod.lua
-- *  PURPOSE:     FishingRod item class
-- *
-- ****************************************************************************
ItemFishingrod = inherit(Item)

function ItemFishingrod:constructor()

end

function ItemFishingrod:destructor()

end

function ItemFishingrod:use(player)
	Fishing:getSingleton():inventoryUse(player)
end
