-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleSpawner.lua
-- *  PURPOSE:     VehicleSpawner class
-- *
-- ****************************************************************************
VehicleSpawner = inherit(Object)
VehicleSpawner.Map = {}

function VehicleSpawner:constructor(x, y, z, vehicles, rotation, spawnConditionFunc, postSpawnFunc)
	VehicleSpawner.Map[#VehicleSpawner.Map + 1] = self
	self.m_Id = #VehicleSpawner.Map
	self.m_Hook = Hook:new()
	self.m_Vehicles = {}
	for k, v in ipairs(vehicles) do
		self.m_Vehicles[type(v) == "number" and v or getVehicleModelFromName(v)] = true
	end

	self.m_Allowed = {}

	self.m_Position = Vector3(x, y, z)
	self.m_Rotation = rotation or 0
	self.m_ConditionFunc = spawnConditionFunc
	self.m_PostSpawnFunc = postSpawnFunc

	self.m_Marker = createMarker(x, y, z, "cylinder", 1.2, 255, 0, 0)
	addEventHandler("onMarkerHit", self.m_Marker, bind(self.markerHit, self))
end

function VehicleSpawner:markerHit(hitElement, matchingDimension)
	if not self.m_Disabled or (self.m_Disabled and self.m_Allowed[hitElement]) then
		if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) then
			if self.m_ConditionFunc and not self.m_ConditionFunc(hitElement) then
				hitElement:sendError(_("Du bist nicht berechtigt dieses Fahrzeug zu erstellen!", hitElement))
				return
			end

			hitElement:triggerEvent("vehicleSpawnGUI", self.m_Id, self.m_Vehicles)
		end
	end
end

addEvent("vehicleSpawn", true)
addEventHandler("vehicleSpawn", root,
	function(spawnerId, vehicleModel)
		local shop = VehicleSpawner.Map[spawnerId]
		if not shop then return end

		if not shop.m_Vehicles[vehicleModel] then
			-- Todo: Report possible attack
			return
		end

		if client:getJobVehicle() and isElement(client:getJobVehicle()) then
			destroyElement(client:getJobVehicle())
		end



		local vehicle = TemporaryVehicle.create(vehicleModel, shop.m_Position.x, shop.m_Position.y, shop.m_Position.z + 1.5, shop.m_Rotation)

		if not client:hasCorrectLicense(vehicle) then
			client:sendWarning(_("Du hast nicht den passenden Führerschein!", client))
			vehicle:destroy()
			return
		end

		if shop.m_PostSpawnFunc then
			shop.m_PostSpawnFunc(vehicle, client)
		end

		if shop.m_Hook then
			shop.m_Hook:call(client,vehicleModel,vehicle)
		end

		warpPedIntoVehicle(client, vehicle)
		client:setJobVehicle(vehicle)
	end
)

function VehicleSpawner:disable()
	setElementVisibleTo(self.m_Marker, root, false)
	self.m_Disabled = true
end

function VehicleSpawner:toggleForPlayer(player, state)
	if state then
		setElementVisibleTo(self.m_Marker, player, true)
		self.m_Allowed[player] = true
	else
		setElementVisibleTo(self.m_Marker, player, false)
		self.m_Allowed[player] = false
	end
end

function VehicleSpawner:setSpawnPosition(pos, rot)
	self.m_Position = pos
	self.m_Rotation = rot or 0
end


function VehicleSpawner:initializeAll()
	-- Create 'general' vehicle spawners
	VehicleSpawner:new( 1508.79, -1749.41, 12.55, {"Bike", "BMX", "Faggio"}, 0)
	VehicleSpawner:new(1805.58, -1292.58, 12.58, {"Bike", "BMX", "Faggio"}, 65)
	VehicleSpawner:new(1742.06, -1742.61, 12.55, {"Bike", "BMX", "Faggio"}, 0)
end
