-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobMechanic.lua
-- *  PURPOSE:     Mechanic job
-- *
-- ****************************************************************************
JobMechanic = inherit(Job)
addRemoteEvents{"mechanicRepair", "mechanicRepairConfirm", "mechanicRepairCancel", "mechanicTakeVehicle"}

function JobMechanic:constructor()
	Job.constructor(self)

	for i = 0, 3 do
		AutomaticVehicleSpawner:new(getVehicleModelFromName("Towtruck"), 1086.7 + i * 7.8, -1245.5, 15.85, 0, 0, 0, nil, self)
	end

	self.m_VehicleTakeMarker = Marker.create(1086.8, -1214.8, 16.9, "cylinder", 1, 255, 255, 0)
	addEventHandler("onMarkerHit", self.m_VehicleTakeMarker, bind(self.VehicleTakeMarker_Hit, self))

	addEventHandler("mechanicRepair", root, bind(self.Event_mechanicRepair, self))
	addEventHandler("mechanicRepairConfirm", root, bind(self.Event_mechanicRepairConfirm, self))
	addEventHandler("mechanicRepairCancel", root, bind(self.Event_mechanicRepairCancel, self))
	addEventHandler("mechanicTakeVehicle", root, bind(self.Event_mechanicTakeVehicle, self))
end

function JobMechanic:start(player)

end

function JobMechanic:checkRequirements(player)
	if player:getCompany() ~= CompanyManager:getSingleton():getFromId(2) then
		player:sendError(_("Für diesen Job musst du Mitglied bei '%s' sein!", player, CompanyManager:getSingleton():getFromId(2):getName()))
		return false
	end
	if player:getJobLevel() < 3 then
		player:sendError(_("Für diesen Job benötigst du mindestens Joblevel 3", player), 255, 0, 0)
		return false
	end
	return true
end

function JobMechanic:respawnVehicle(vehicle)
	outputDebug("Respawning vehicle in mechanic base")

	vehicle:setPositionType(VehiclePositionType.Mechanic)
	vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
	vehicle:fix()
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

	local driver = source:getOccupant(0)
	if not driver then
		client:sendError(_("Jemand muss sich auf dem Fahrersitz befinden!", client))
		return
	end
	--[[if driver == client then
		client:sendError(_("Du kannst dein eigenes Fahrzeug nicht reparieren!", client))
		return
	end]]
	if source:getHealth() > 950 then
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

		-- Spawn vehicle in non-collision zone
		source:setPositionType(VehiclePositionType.World)
		source:setDimension(0)
		local x, y, z, rotation = unpack(Randomizer:getRandomTableValue(self.SpawnPositions))
		source:setPosition(x, y, z)
		source:setRotation(0, 0, rotation)
		client:warpIntoVehicle(source)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end

JobMechanic.SpawnPositions = {
	{1108.5, -1198.2, 17.70, 180},
	{1103, -1198.2, 17.7, 180},
	{1097.2, -1198.1, 17.70, 180},
	{1091.7, -1198.3, 17.70, 180},
	{1086.1, -1198.2, 17.70, 180},
}
