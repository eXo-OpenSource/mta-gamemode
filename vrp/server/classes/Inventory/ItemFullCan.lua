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
	local cObj = player.m_Can
	local plant = ItemGrowable:getNextWaterPlant( player )
	if plant then
		local inv = InventoryManager:getSingleton():getPlayerInventory(player)
		player.m_removeCanFunc = bind( ItemFullCan.removeCan, self)
		inv:removeItemFromPlace(bag, place, 1)
		inv:giveItem("Kanne-Leer", 1)
		inv:forceRefresh()
		local bHyd = plant:getData( "Plant:Hydration") 
		plant:setData( "Plant:Hydration", bHyd + 1, true)
		setPedAnimation( player, "bomber", "BOM_Plant_Loop", 2000, true, false)
		if plant.m_OnWaterRemoteEvent then
			player:triggerEvent( plant.m_OnWaterRemoteEvent, plant )
		end
		if cObj then
			setTimer( player.m_removeCanFunc, 2000, 1, cObj)
		end
	else 
		if cObj then 
			Wearable:getSingleton():removeObj( cObj )
			destroyElement( cObj )
			player.m_Can = nil
		end
		player:sendError("Es befindet sich keine Pflanze in der Nähe!")
	end
end

function ItemFullCan:removeCan( obj )
	if obj then 
		Wearable:getSingleton():removeObj( cObj )
		destroyElement( cObj )
		player.m_Can = nil
		player.m_removeCanFunc = nil
	end
end