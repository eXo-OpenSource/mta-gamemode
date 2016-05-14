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
		local inv = InventoryManager:getPlayerInventory(player)
		inv:removeItemFromPlace(bag, place, 1)
	end
end