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

	self.m_VehicleTakeMarker = Marker.create(1810.2, -1601.6, 12.5, "cylinder", 1, 255, 255, 0)
	addEventHandler("onMarkerHit", self.m_VehicleTakeMarker, bind(self.VehicleTakeMarker_Hit, self))
	
	addEvent("mechanicRepair", true)
	addEventHandler("mechanicRepair", root, bind(self.Event_mechanicRepair, self))
	addEvent("mechanicRepairConfirm", true)
	addEventHandler("mechanicRepairConfirm", root, bind(self.Event_mechanicRepairConfirm, self))
	addEvent("mechanicRepairCancel", true)
	addEventHandler("mechanicRepairCancel", root, bind(self.Event_mechanicRepairCancel, self))
	addEvent("mechanicTakeVehicle", true)
	addEventHandler("mechanicTakeVehicle", root, bind(self.Event_mechanicTakeVehicle, self))
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

	vehicle:setPositionType(VehiclePositionType.Mechanic)
	self:setDimension(PRIVATE_DIMENSION_SERVER)
	self:fix()
end

function JobMechanic:VehicleTakeMarker_Hit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		-- Get a list of vehicles that need manual repairing
		local vehicles = {}
		for k, vehicle in pairs(VehicleManager:getSingleton():getPlayerVehicles(hitElement)) do
			if vehicle:getPositionType() == VehiclePositionType.Mechanic then
				vehicles[#vehicles + 1] = vehicle
			end
		end

		if #vehicles > 0 then
			-- Open "vehicle take GUI"
			hitElement:triggerEvent("vehicleTakeMarkerGUI", vehicles)
		else
			hitElement:sendWarning(_("Keine abholbaren Fahrzeuge vorhanden!", hitElement))
		end
	end
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

function JobMechanic:Event_mechanicTakeVehicle()
	if client:getMoney() >= 500 then
		client:takeMoney(500)
		source:fix()

		-- TODO: Spawn vehicle in non-collision zone
		source:setDimension(0)
		source:setPosition(0, 0, 0)
		client:warpIntoVehicle(source)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end
