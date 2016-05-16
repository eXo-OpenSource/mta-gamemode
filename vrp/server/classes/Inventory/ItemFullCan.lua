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
		local bHyd = plant:getData( "Plant:Hydration") 
		plant:setData( "Plant:Hydration", bHyd + 1, true)
		setPedAnimation( player, "bomber", "BOM_Plant_Loop", 2000, true, false)
		if plant.m_OnWaterRemoteEvent then
			player:triggerEvent( plant.m_OnWaterRemoteEvent, plant )
		end
	end
end

