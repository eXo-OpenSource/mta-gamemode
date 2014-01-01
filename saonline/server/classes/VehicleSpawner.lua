-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleSpawner.lua
-- *  PURPOSE:     VehicleSpawner class
-- *
-- ****************************************************************************
VehicleSpawner = inherit(Object)
VehicleSpawner.Map = {}

function VehicleSpawner:constructor(x, y, z, vehicles, rotation)
	VehicleSpawner.Map[#VehicleSpawner.Map + 1] = self
	self.m_Id = #VehicleSpawner.Map
	self.m_Vehicles = {}
	for k, v in ipairs(vehicles) do
		self.m_Vehicles[type(v) == "number" and v or getVehicleModelFromName(v)] = true
	end
	
	self.m_Position = Vector(x, y, z)
	self.m_Rotation = rotation or 0

	self.m_Marker = createMarker(x, y, z, "cylinder", 1, 255, 0, 0)
	addEventHandler("onMarkerHit", self.m_Marker, bind(self.markerHit, self))
end

function VehicleSpawner:markerHit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		hitElement:triggerEvent("vehicleSpawnGUI", self.m_Id, self.m_Vehicles)
	end
end

addEvent("vehicleSpawn", true)
addEventHandler("vehicleSpawn", root,
	function(spawnerId, vehicleId)
		local shop = VehicleSpawner.Map[spawnerId]
		if not shop then return end
		
		if not shop.m_Vehicles[vehicleId] then
			-- Todo: Report possible attack
			return
		end
		
		local vehicle = createVehicle(vehicleId, shop.m_Position.X, shop.m_Position.Y, shop.m_Position.Z, 0, 0, shop.m_Rotation)
		warpPedIntoVehicle(client, vehicle)
	end
)

VehicleSpawner:new(0, 40, 3, {"Infernus", "Banshee", "Bullet", "BMX", "Bike", "Caddy"})