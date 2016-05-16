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
	local cObj = player.m_Can
	if cObj then
		if isElementInWater( player ) then
			local inv = InventoryManager:getSingleton():getPlayerInventory(player)
			inv:removeItemFromPlace(bag, place, 1)
			inv:giveItem("Kanne-Voll", 1)
			inv:forceRefresh()
		else 
			Wearable:getSingleton():removeObj( cObj )
			player:sendError("Sie befinden sich nicht im Wasser!")
			destroyElement( cObj )
			player.m_Can = nil
		end
	else
		local x,y,z = getElementPosition( player )
		cObj = createObject( 2064, x,y,z )
		if cObj then
			Wearable:getSingleton():giveIntoPedHand( cObj, player, 2 )
			player.m_Can = cObj
		end 
	end
end