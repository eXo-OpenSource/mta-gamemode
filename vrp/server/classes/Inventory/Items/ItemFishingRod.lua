-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFishingRod.lua
-- *  PURPOSE:     Fishing rod item class
-- *
-- ****************************************************************************
ItemFishingRod = inherit(ItemNew)

function ItemFishingRod:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end
	local level = player:getFishingLevel()

	if player.isTasered then return end

	if FISHING_EQUIPMENT[self.m_ItemData.TechnicalName].level > level then
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

function ItemFishingRod:useSecondary()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end
	local itemName = self.m_ItemData.TechnicalName
	
	if FISHING_RODS[itemName].baitSlots > 0 then
		local fishingRodEquipments = Fishing:getSingleton():getFishingRodEquipments(player, itemName)

		player:triggerEvent("showFishingRodGUI", itemName, {fishingRodEquipments["bait"], fishingRodEquipments["accessories"]})
		return
	else
		player:sendError("Diese Angel bietet keine Interaktion!")
	end
end

addEventHandler("onPlayerQuit", root, function()
	if source.m_FishingRod and isElement(source.m_FishingRod) then
		source.m_FishingRod:destroy()
	end
end)

function ItemFishingRod.canBuy(player, itemName)
	if not FISHING_EQUIPMENT[itemName] then return true end

	if player:getPrivateSync("FishingLevel") >= FISHING_EQUIPMENT[itemName].level then
		return true
	end

	return false, _("Du brauchst mind. Fischer Level %s um dieses Item zu kaufen!", player, FISHING_EQUIPMENT[itemName].level)
end