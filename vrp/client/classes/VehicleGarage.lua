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

function VehicleGarage.initializeGarages()
	VehicleGarage.Map = {
		VehicleGarage:new({
			{12814, 577.4, -2779.7, 704.4, 0, 0, 0},
			{8674, 562.8, -2760, 705.9, 0, 0, 90},
			{8674, 562.8, -2770.4, 705.9, 0, 0, 90},
			{8674, 562.8, -2780.8, 705.9, 0, 0, 90},
			{8674, 562.8, -2791.2, 705.9, 0, 0, 90},
			{8674, 562.7, -2801.5, 705.9, 0, 0, 90},
			{8674, 567.5, -2755, 705.9, 0, 0, 0},
			{8674, 577.5, -2755, 705.9, 0, 0, 0},
			{8674, 587, -2755, 705.9, 0, 0, 0},
			{8674, 592.2, -2759.8, 705.9, 0, 0, 270},
			{8674, 592.1, -2770, 705.9, 0, 0, 270},
			{8674, 592, -2780.2, 705.9, 0, 0, 270},
			{8674, 591.9, -2789.7, 705.9, 0, 0, 270},
			{8674, 591.8, -2799.7, 705.9, 0, 0, 270},
			{8674, 587.1, -2804.5, 705.9, 0, 0, 180},
			{8674, 583.1, -2804.3, 705.9, 0, 0, 179.995},
			{8674, 564.6, -2804.6, 705.9, 0, 0, 179.995},
			{8041, 578, -2804.2, 710.2, 0, 0, 90}
		});
	}
end