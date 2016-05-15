-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/ItemFullCan.lua
-- *  PURPOSE:     Item Full Watering-Can class
-- *
-- ****************************************************************************
ItemFullCan = inherit(Item)

function ItemFullCan:constructor( )

end

function ItemFullCan:destructor()

end

function ItemFullCan:use( player, itemId, bag, place, itemName )
	local plant = ItemGrowable:getNextWaterPlant( player )
	if plant then
		local inv = InventoryManager:getSingleton():getPlayerInventory(player)
		inv:removeItemFromPlace(bag, place, 1)
		inv:giveItem("Kanne-Leer", 1)
		inv:forceRefresh()
		--// INCREASE WATER OF PLANT 
	end
end

