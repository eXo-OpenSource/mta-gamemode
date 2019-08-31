-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/ItemPlant.lua
-- *  PURPOSE:     Weed-Seed class
-- *
-- ****************************************************************************
ItemPlant = inherit(ItemNew)

function ItemPlant:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	if not GrowableManager:getSingleton():getNextPlant(player, GrowableManager.Types[GrowableManager:getSingleton():getPlantNameFromSeed(self:getTechnicalName())].SizeBetweenPlants) then
		player:triggerEvent("Plant:sendClientCheck", self:getTechnicalName())
	else
		player:sendInfo(_("Du bist zu nah an einer anderen Pflanze!", player))
	end
end
