-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Storage/VehicleGarageSession.lua
-- *  PURPOSE:     Vehicle garage session class
-- *
-- ****************************************************************************
VehicleGarageSession = inherit(Object)

function VehicleGarageSession:constructor(dimension, player, entranceId)
	self.m_Dimension = dimension
	self.m_Slots = {}
	self.m_Player = player
	self.m_GarageType = player:getGarageType()
	self.m_EntranceId = entranceId
end

function VehicleGarageSession:destructor()
	local playerVehicle = getPedOccupiedVehicle(self.m_Player)
	for k, vehicle in ipairs(self.m_Slots) do
		if vehicle and isElement(vehicle) and vehicle:isInGarage() and playerVehicle ~= vehicle then
			setElementDimension(vehicle, PRIVATE_DIMENSION_SERVER)
		end
	end
end

function VehicleGarageSession:furnish()
	-- Add vehicles to the session (and teleport them into the garage)
	for k, vehicle in ipairs(self.m_Player:getVehicles()) do
		if vehicle:isInGarage() then
			self:addVehicle(vehicle)
		end
	end

end

function VehicleGarageSession:addVehicle(vehicle)
	if vehicle:getModel() ~= 539 and (vehicle:getVehicleType() == VehicleType.Plane or vehicle:getVehicleType() == VehicleType.Helicopter or vehicle:getVehicleType() == VehicleType.Boat) then
		self.m_Player:sendError("Es können nur Autos und Motorräder in der Garage geparkt werden! (VehicleType:"..vehicle:getVehicleType()..")")
		return false
	end

	local slotId = #self.m_Slots + 1
	if slotId > VehicleGarages:getSingleton():getMaxSlots(self.m_GarageType) then
		return false
	end
	local x, y, z, rotation = unpack(VehicleGarages:getSingleton():getSlotData(self.m_GarageType, slotId))
	setElementPosition(vehicle, x, y, z)
	setElementDimension(vehicle, self.m_Dimension)
	setElementRotation(vehicle, 0, 0, rotation or 0)
	setVehicleLocked(vehicle, false)

	self.m_Slots[slotId] = vehicle
	return slotId
end

function VehicleGarageSession:getDimension()
	return self.m_Dimension
end

function VehicleGarageSession:getPlayer()
	return self.m_Player
end

function VehicleGarageSession:getSlots()
	return self.m_Slots
end

function VehicleGarageSession:getEntranceId()
	return self.m_EntranceId
end
