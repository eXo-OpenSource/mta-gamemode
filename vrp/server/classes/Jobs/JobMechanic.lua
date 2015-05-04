-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobMechanic.lua
-- *  PURPOSE:     Mechanic job
-- *
-- ****************************************************************************
JobMechanic = inherit(Job)

function JobMechanic:constructor()
	Job.constructor(self)

	for i = 0, 3 do
		AutomaticVehicleSpawner:new(getVehicleModelFromName("Towtruck"), 686.9 + i*4.8, -1571.9, 14.1, 0, 0, 180, nil, self)
	end

	addEvent("mechanicRepair", true)
	addEventHandler("mechanicRepair", root, bind(self.Event_mechanicRepair, self))
	addEvent("mechanicRepairConfirm", true)
	addEventHandler("mechanicRepairConfirm", root, bind(self.Event_mechanicRepairConfirm, self))
	addEvent("mechanicRepairCancel", true)
	addEventHandler("mechanicRepairCancel", root, bind(self.Event_mechanicRepairCancel, self))
end

function JobMechanic:start(player)

end

function JobMechanic:checkRequirements(player)
	if not (player:getJobLevel() >= 3) then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel 3", player), 255, 0, 0)
		return false
	end
	return true
end

function JobMechanic:respawnVehicle(vehicle)
	outputDebug("PLACEHOLDER: Respawning vehicle in mechanic base")
end

function JobMechanic:Event_mechanicRepair()
	if client:getJob() ~= self then
		return
	end

	local driver = getVehicleOccupant(source, 0)
	if not driver then
		client:sendError(_("Jemand muss sich auf dem Fahrersitz befinden!", client))
		return
	end
	--[[if driver == client then
		client:sendError(_("Du kannst dein eigenes Fahrzeug nicht reparieren!", client))
		return
	end]]
	if getElementHealth(source) > 950 then
		client:sendError(_("Dieses Fahrzeug hat keine nennenswerten Beschädigungen!", client))
		return
	end

	source.PendingMechanic = client
	local price = math.floor((1000 - getElementHealth(source))*0.5)
	driver:triggerEvent("questionBox", _("Darf %s dein Fahrzeug reparieren? Dies kostet dich zurzeit %d$!\nBeim nächsten Pay'n'Spray zahlst du einen Aufschlag von +33%%!", client, getPlayerName(client), price), "mechanicRepairConfirm", "mechanicRepairCancel", source)
end

function JobMechanic:Event_mechanicRepairConfirm(vehicle)
	local price = math.floor((1000 - getElementHealth(vehicle))*0.5)
	if client:getMoney() >= price then
		fixVehicle(vehicle)
		client:takeMoney(price)

		if vehicle.PendingMechanic then
			if client ~= vehicle.PendingMechanic then
				vehicle.PendingMechanic:giveMoney(price)
				vehicle.PendingMechanic:givePoints(5)
				vehicle.PendingMechanic:sendInfo(_("Du hast das Fahrzeug von %s erfolgreich repariert! Du hast %s$ verdient!", vehicle.PendingMechanic, getPlayerName(client), price))
				client:sendInfo(_("%s hat dein Fahrzeug erfolgreich repariert!", client, getPlayerName(vehicle.PendingMechanic)))
			else
				client:sendInfo(_("Du hat dein Fahrzeug erfolgreich repariert!", client))
			end
			vehicle.PendingMechanic = nil
		end
	else
		client:sendError(_("Du hast nicht genügend Geld! Benötigt werden %d$!", client, price))
	end
end

function JobMechanic:Event_mechanicRepairCancel(vehicle)
	if vehicle.PendingMechanic then
		vehicle.PendingMechanic:sendWarning(_("Der Reperaturvorgang wurde von der Gegenseite abgebrochen!", vehicle.PendingMechanic))
		vehicle.PendingMechanic = nil
	end
end
