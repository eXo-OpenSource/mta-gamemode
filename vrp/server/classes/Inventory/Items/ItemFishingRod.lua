-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFishingRod.lua
-- *  PURPOSE:     Fishing rod item class
-- *
-- ****************************************************************************
ItemFishingRod = inherit(ItemNew)

local FISHING_ROD_LEVEL_REQUIREMENT = {
	["bambooFishingRod"] = 0,
	["fishingRod"] = 3,
	["expertFishingRod"] = 7,
	["legendaryFishingRod"] = 13
}

function ItemFishingRod:use()
	local player = self.m_Inventory:getPlayer()
	local level = player:getFishingLevel()

	if FISHING_ROD_LEVEL_REQUIREMENT[self.m_ItemData.TechnicalName] > level then
		player:sendError(_("Du kannst diese Angel noch nicht verwenden", player))
		return false
	end

	if player.m_FishingRod and isElement(player.m_FishingRod) then
		player.m_FishingRod:destroy()

		player:triggerEvent("onFishingStop")
		return true
	end

	local fishingRod = createObject(1826, player.position)
	fishingRod:setDimension(player.dimension)
	fishingRod:setInterior(player.interior)
	player:attachPlayerObject(fishingRod)
	player.m_FishingRod = fishingRod
	player.m_FishingRodId = self.m_Item.Id
	player.m_FishingRodMeta = self.m_Item.Metadata

	return true
end
