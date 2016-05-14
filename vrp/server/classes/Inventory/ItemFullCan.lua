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
	if isElementInWater( player ) then
		player.m_FullWaterBottleCount = player.m_FullWaterBottleCount +1
	end
end