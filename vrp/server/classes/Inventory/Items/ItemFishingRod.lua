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
	player.m_FishingRodType = self.m_ItemData.TechnicalName
	player.m_FishingRodMeta = self.m_Item.Metadata

	local accessory = false
	local bait = false

	if self.m_Item.Metadata then
		accessory = self.m_Item.Metadata.accessory or false
		bait = self.m_Item.Metadata.bait or false
	end

	player:triggerEvent("onFishingStart", fishingRod, self.m_ItemData.TechnicalName, bait, accessory)

	return true
end

addEventHandler("onPlayerQuit", root, function()
	if source.m_FishingRod and isElement(source.m_FishingRod) then
		source.m_FishingRod:destroy()
	end
end)
