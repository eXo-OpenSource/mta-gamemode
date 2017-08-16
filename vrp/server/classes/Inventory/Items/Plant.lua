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
	if not GrowableManager:getSingleton():getNextPlant(player, 3) then
		player:triggerEvent("Plant:sendClientCheck", itemName)
	else
		player:sendInfo(_("Du bist zu nah an einer anderen Pflanze!", player))
	end
end


