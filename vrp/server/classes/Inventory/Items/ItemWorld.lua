-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemWorld.lua
-- *  PURPOSE:     Item World item class
-- *
-- ****************************************************************************
ItemWorld = inherit(ItemNew)
ItemWorld.Map = {}


function ItemWorld:constructor()
	self.m_WorldItemClass = KeyPadWorldItem -- TODO: Create GenericWorldItem
end

function ItemWorld:destructor()
end

function ItemWorld:use()
	local player = self.m_Inventory:getPlayer()

	if player.m_PlacingInfo then
		player:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", player))
		return false
	end
	if player:getData("inJail") or player:getData("inAdminPrison") then
		player:sendError(_("Du kannst hier keine Objekte platzieren.", player))
		return false
	end

	player:triggerEvent("objectPlacerStart", self.m_ItemData.ModelId, "itemPlaced")
	player.m_PlacingInfo = {
		itemData = self.m_ItemData,
		inventory = self.m_Inventory,
		item = self.m_Item,
		worldItemClass = self.m_WorldItemClass
	}
end
