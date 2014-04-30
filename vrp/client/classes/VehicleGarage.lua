-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/VehicleGarage.lua
-- *  PURPOSE:     Vehicle garage class (respawn location etc.)
-- *
-- ****************************************************************************
VehicleGarage = inherit(Object)
VehicleGarage.Map = {}
addEvent("vehicleGarageSessionOpen", true)
addEvent("vehicleGarageSessionClose", true)

function VehicleGarage:constructor(mapData)
	self.m_Id = #VehicleGarage.Map + 1
	self.m_MapData = mapData or {}
	self.m_MapObjects = {}
	self.m_CurrentDimension = 0
	
	-- Todo: Optimize the following
	addEventHandler("vehicleGarageSessionOpen", root,
		function(Id, dimension)
			if self.m_Id == Id then
				self.m_CurrentDimension = dimension
				self:createMap()
			end
		end
	)
	addEventHandler("vehicleGarageSessionClose", root,
		function(Id)
			if self.m_Id == Id then
				self:destroyMap()
			end
		end
	)
end

function VehicleGarage:createMap()
	for k, objectInfo in ipairs(self.m_MapData) do
		local model, x, y, z, rx, ry, rz = unpack(objectInfo)
		local object = createObject(model, x, y, z, rx, ry, rz)
		setElementDimension(object, self.m_CurrentDimension)
		table.insert(self.m_MapObjects, object)
	end
end

function VehicleGarage:destroyMap()
	for k, object in ipairs(self.m_MapObjects) do
		destroyElement(object)
	end
	self.m_MapObjects = {}
end

function VehicleGarage.initializeAll()
	VehicleGarage.Map = {
		VehicleGarage:new(GarageData);
	}
end