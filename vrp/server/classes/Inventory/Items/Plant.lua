-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/Plant.lua
-- *  PURPOSE:     Weed-Seed class
-- *
-- ****************************************************************************
Plant = inherit(Item)

function Plant:constructor()
	self.m_Name = "Plant"
end

function Plant:destructor()
end

function Plant:use(player, itemId, bag, place, itemName)
	if GrowableManager:getSingleton():checkPlantConditionsForPlayer(player, itemName) then
		player:triggerEvent("Plant:sendClientCheck", itemName)
	end
end
