-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemFuelcan.lua
-- *  PURPOSE:     Fuel Can item class
-- *
-- ****************************************************************************
ItemRepairKit = inherit(Item)

function ItemFuelcan:constructor()
end

function ItemRepairKit:destructor()

end

function ItemRepairKit:use(player)
	if player.vehicle then
		if player.vehicle:getHealth() <= 310  then
			player:meChat(true, "steigt aus und legt einige Kabel an den Motor an!")
			local irandom = math.random(1,100)
			if irandom >= 50 then
				setElementHealth(player.vehicle, 500)
				player.vehicle:setBroken(false)
				player:sendSuccess(_("Dein Fahrzeug funktioniert wieder einigermaßen!", player))
				player:getInventory():removeItem(self:getName(), 1)
				setVehicleEngineState(player.vehicle, true)
				player:meChat(true, "versucht den Motor zu starten, welcher daraufhin angeht!")
			else
				player:getInventory():removeItem(self:getName(), 1)
				player:meChat(true, "brennt die angelegten Kabel nach einigen Versuchen durch!")
				player:sendInfo(_("Das Reparaturkit ist zerstört!", player))
			end
		else
			player:sendError(_("Dein Fahrzeug ist nicht kaputt!", player))
		end
	else
		player:sendError(_("Du musst in einem Fahrzeug sitzen!", player))
	end
end
