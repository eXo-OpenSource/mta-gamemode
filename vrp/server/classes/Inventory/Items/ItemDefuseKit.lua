-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/ItemDefuseKit.lua
-- *  PURPOSE:     Smoke Grenade Item
-- *
-- ****************************************************************************
ItemDefuseKit = inherit(ItemNew)
ItemDefuseKit.Map = { }

function ItemDefuseKit:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

end
