-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/PlantWeed.lua
-- *  PURPOSE:     Weed-Seed class
-- *
-- ****************************************************************************
PlantWeed = inherit(ItemGrowable)

function PlantWeed:constructor()

end

function PlantWeed:destructor()

end

function PlantWeed:use( player )
	outputChatBox( tostring( player.name ))
	local x,y,z = getElementPosition( player )
	createObject( 1337, x,y,z)
end
