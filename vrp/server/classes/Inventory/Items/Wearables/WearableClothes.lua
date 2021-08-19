-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Wearables/WearableClothes.lua
-- *  PURPOSE:     Wearable Clothes
-- *
-- ****************************************************************************
WearableClothes = inherit(ItemNew)

function WearableClothes:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	local skinId = self.m_Item.Metadata and self.m_Item.Metadata.ModelId or false

	if table.find(getValidPedModels(), skinId) then
		if player:getData("isInDeathMatch") then
			player:sendError(_("Du kannst deine Kleidung nicht während des Aufenthaltes in einer DM-Lobby wechseln!", player))
			return false
		end
		if player:isFactionDuty() then
			if player:getFaction():isEvilFaction() then
				player:sendError(_("Du musst die Farben deiner Fraktion tragen!", player))
				return false
			else
				player:sendError(_("Du kannst im Dienst nicht deine Kleidung wechseln!", player))
				return false
			end
		end
		player:setSkin(skinId, true)
		player:meChat(true, "wechselt seine Kleidung.")
		return true
	else
		player:sendError(_("Dieser Skin kann nicht getragen werden! (ItemId %s)", client, self.m_Item.Id))
		return false
	end
end