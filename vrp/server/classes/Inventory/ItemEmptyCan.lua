-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/ItemEmptyCan.lua
-- *  PURPOSE:     Item Empty Watering-Can class
-- *
-- ****************************************************************************

ItemEmptyCan = inherit(Item)

function ItemEmptyCan:constructor( )

end

function ItemEmptyCan:destructor()

end

function ItemEmptyCan:use( player, itemId, bag, place, itemName )
	if isElementInWater( player ) then
		local inv = InventoryManager:getSingleton():getPlayerInventory(player)
		inv:removeItemFromPlace(bag, place, 1)
		inv:giveItem("Kanne-Voll", 1)
		inv:forceRefresh()
	else player:sendError("Sie befinden sich nicht im Wasser!")
	end
end