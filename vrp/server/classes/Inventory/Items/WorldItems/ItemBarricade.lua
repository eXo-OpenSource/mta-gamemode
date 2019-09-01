-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBarricade.lua
-- *  PURPOSE:     Barricade item class
-- *
-- ****************************************************************************
ItemBarricade = inherit(ItemWorld)

function ItemBarricade:constructor()
	self.m_WorldItemClass = BarricadeWorldItem
end

function ItemBarricade:destructor()
end

function ItemBarricade:use()
	local player = self.m_Inventory:getPlayer()

	if player.m_PlacingInfo then
		player:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", player))
		return false
	end

	if player:getData("inJail") or player:getData("inAdminPrison") then
		player:sendError(_("Du kannst hier keine Objekte platzieren.", player))
		return false
	end

	if not player:isFactionDuty() then
		player:sendError(_("Du bist nicht im Dienst!", player))
		return false, false, true
	end

	player:triggerEvent("objectPlacerStart", self.m_ItemData.ModelId, "itemPlaced")
	player.m_PlacingInfo = {
		itemData = self.m_ItemData,
		inventory = self.m_Inventory,
		item = self.m_Item,
		worldItemClass = self.m_WorldItemClass
	}
end
