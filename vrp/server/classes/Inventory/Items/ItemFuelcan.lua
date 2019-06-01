-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFuelcan.lua
-- *  PURPOSE:     Fuel Can item class
-- *
-- ****************************************************************************
ItemFuelcan = inherit(Item)
ItemFuelcan.Fill = 20

function ItemFuelcan:constructor()
end

function ItemFuelcan:destructor()

end

function ItemFuelcan:use(player)
	if player.vehicle then
		if player.vehicle:getFuel() and player.vehicle:getFuel() <= 100-ItemFuelcan.Fill then
			player.vehicle:setFuel(player.vehicle:getFuel() + ItemFuelcan.Fill)
			player:sendSuccess(_("Dein Fahrzeug wurde betankt!", player))
			player:getInventoryOld():removeItem(self:getName(), 1)
		else
			player:sendError(_("Dein Tank ist bereits voll!", player))
		end
	else
		player:sendError(_("Du musst in einem Fahrzeug sitzen!", player))
	end
end
