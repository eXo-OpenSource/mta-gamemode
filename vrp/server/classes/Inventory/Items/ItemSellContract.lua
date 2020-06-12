-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemSellContract.lua
-- *  PURPOSE:     SellContract Item Class
-- *
-- ****************************************************************************
ItemSellContract = inherit(ItemNew)

function ItemSellContract:use()
	local player = self.m_Inventory:getPlayer()
	if not player then return false end

	if not player.vehicle then
		player:sendError(_("Du sitzt nicht in einem Fahrzeug!", player))
		return
	end

	if not player.vehicle:isPermanent() then
		player:sendError(_("Ungültiges Fahrzeug!", player))
		return
	end

	if player.vehicle:isPremiumVehicle() then
		player:sendError(_("Dieses Fahrzeug ist ein Premium Fahrzeug und darf nicht verkauft werden!", player))
		return
	end

	if player.vehicle:getOwner() ~= player:getId() then
		player:sendError(_("Dieses Fahrzeug gehört dir nicht!", player))
		return
	end

	ItemSellContractManager:getSingleton():addVehicleTrade(player, player.vehicle)
end
