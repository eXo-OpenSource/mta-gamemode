-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Storage/VehicleHangarSession.lua
-- *  PURPOSE:     Vehicle garage session class
-- *
-- ****************************************************************************
VehicleHangarSession = inherit(Object)

function VehicleHangarSession:constructor(dimension, player, entranceId)
	self.m_Dimension = dimension
	self.m_Slots = {}
	self.m_Player = player
	self.m_HangarType = player:getHangarType()
	self.m_EntranceId = entranceId
end

function VehicleHangarSession:destructor()
	local playerVehicle = getPedOccupiedVehicle(self.m_Player)
	for k, vehicle in ipairs(self.m_Slots) do
		if vehicle and isElement(vehicle) and vehicle:isInGarage() and playerVehicle ~= vehicle then
			setElementDimension(vehicle, PRIVATE_DIMENSION_SERVER)
		end
	end
end

function VehicleHangarSession:furnish()
	-- Add vehicles to the session (and teleport them into the garage)
	for k, vehicle in ipairs(self.m_Player:getVehicles()) do
		if vehicle:isInHangar() then
			self:addVehicle(vehicle)
		end
	end

end

function VehicleHangarSession:addVehicle(vehicle)
	local slotId = #self.m_Slots + 1
	if slotId > VehicleHangars:getSingleton():getMaxSlots(self.m_HangarType) then
		return false
	end
	local x, y, z, rotation = unpack(VehicleHangars:getSingleton():getSlotData(self.m_HangarType, slotId))
	setElementPosition(vehicle, x, y, z)
	setElementDimension(vehicle, self.m_Dimension)
	setElementRotation(vehicle, 0, 0, rotation or 0)
	setVehicleLocked(vehicle, false)

	self.m_Slots[slotId] = vehicle
	return slotId
end

function VehicleHangarSession:getDimension()
	return self.m_Dimension
end

function VehicleHangarSession:getPlayer()
	return self.m_Player
end

function VehicleHangarSession:getSlots()
	return self.m_Slots
end

function VehicleHangarSession:getEntranceId()
	return self.m_EntranceId
end
