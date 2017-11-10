-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Storage/VehicleHarbor.lua
-- *  PURPOSE:     Vehicle harbor class (respawn location etc.)
-- *
-- ****************************************************************************
VehicleHarbor = inherit(Singleton)
addRemoteEvents{"harborTakeVehicle"}

function VehicleHarbor:constructor()
	self.m_Ped = GuardActor:new(Vector3(2368.210, -2538.178, 13.330))
	self.m_Ped:setModel(27)
	self.m_Ped:giveWeapon(31, 999999999, true) -- Todo: change weapon
	self.m_Ped:setRotation(Vector3(0, 0, 324.654))
	self.m_Ped:setFrozen(true)
	self.m_RespawnPos = Vector3(2368.210, -2538.178, 13.330)
	self.m_RespawnRot = Vector3(0, 0, 324.654)
	self.m_Marker = Marker.create(Vector3(2368.729, -2537.533, 12.431), "cylinder", 1, 255, 255, 0)
	self.m_BankAccountServer = BankServer.get("vehicle.harbor")

	--Events
	--addEventHandler("onPedWasted", self.m_Ped, bind(VehicleHarbor.onPedWasted, self))
	addEventHandler("onMarkerHit", self.m_Marker, bind(VehicleHarbor.VehicleTakeMarker_Hit, self))
	addEventHandler("harborTakeVehicle", root, bind(VehicleHarbor.Event_harborTakeVehicle, self))
end

function VehicleHarbor:respawnVehicle(vehicle)
	outputDebug("Respawning boat at the harbor")

	vehicle:setPositionType(VehiclePositionType.Harbor)
	vehicle:setDimension(PRIVATE_DIMENSION_SERVER)
	vehicle:fix()
end

function VehicleHarbor:VehicleTakeMarker_Hit(hitElement, matchingDimension)
	if hitElement:getType() == "player" and matchingDimension then
		local vehicles = {}
		for k, vehicle in pairs(VehicleManager:getSingleton():getPlayerVehicles(hitElement)) do
			if vehicle:getPositionType() == VehiclePositionType.Harbor then
				vehicles[#vehicles + 1] = vehicle
			end
		end

		if #vehicles > 0 then
			-- Open "vehicle take GUI"
			hitElement:triggerEvent("vehicleTakeMarkerGUI", vehicles, "harborTakeVehicle")
		else
			hitElement:sendWarning(_("Keine abholbaren Boote vorhanden!", hitElement))
		end
	end
end

function VehicleHarbor:Event_harborTakeVehicle()
	if client:getMoney() >= 500 then
		client:transferMoney(self.m_BankAccountServer, 500, "Hafen", "Vehicle", "Repair")
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

VehicleHarbor.SpawnPositions = {
	{2356.005, -2542.984, -0.545, 180},
	{2356.005, -2524.984, -0.545, 180},
	{2356.005, -2506.984, -0.545, 180},
}
