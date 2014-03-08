-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleGarage.lua
-- *  PURPOSE:     Vehicle garage class (respawn location etc.)
-- *
-- ****************************************************************************
VehicleGarage = inherit(Object)

function VehicleGarage:constructor(slotData, entryPosition, interiorPosition, interiorExitPosition, exitPosition, interiorId)
	self.m_Sessions = {}
	self.m_SlotData = slotData
	self.m_EnterColShape = createColSphere(entryPosition.X, entryPosition.Y, entryPosition.Z, 3)
	self.m_ExitColShape = createColSphere(interiorExitPosition.X, interiorExitPosition.Y, interiorExitPosition.Z, 2)
	
	addEventHandler("onColShapeHit", self.m_EnterColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				local session = self:openSessionForPlayer(hitElement)
				
				fadeCamera(hitElement, false)
				setTimer(
					function()
						local vehicle = getPedOccupiedVehicle(hitElement)
						setElementInterior(vehicle or hitElement, interiorId)
						setElementPosition(vehicle or hitElement, interiorPosition.X, interiorPosition.Y, interiorPosition.Z)
						setElementDimension(hitElement, session:getDimension())
						fadeCamera(hitElement, true)
						
						if vehicle then
							setElementDimension(vehicle, session:getDimension())
						end
						
						setTimer(function() session:addVehicle(createVehicle(411, 0, 0, 0)) end, 1000, 1)
					end, 2000, 1
				)
			end
		end
	)
	addEventHandler("onColShapeHit", self.m_ExitColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" then
				-- Todo: Close session
				
				fadeCamera(hitElement, false)
				setTimer(
					function()
						local vehicle = getPedOccupiedVehicle(hitElement)
						setElementInterior(vehicle or hitElement, 0)
						setElementPosition(vehicle or hitElement, exitPosition.X, exitPosition.Y, exitPosition.Z)
						setElementDimension(hitElement, 0)
						fadeCamera(hitElement, true)
						
						if vehicle then
							setElementDimension(vehicle, 0)
						end
					end, 1000, 1
				)
			end
		end
	)
end

function VehicleGarage:openSessionForPlayer(player)
	local sessionId = #self.m_Sessions + 1
	local session = VehicleGarageSession:new(sessionId, self, player)
	self.m_Sessions[sessionId] = session
	
	return session
end

function VehicleGarage:closeSession(session)
	local idx = table.find(self.m_Sessions, session)
	if not idx then
		return false
	end
	table.remove(self.m_Sessions, idx)
	delete(session)
end

function VehicleGarage:getSlotData(slotId)
	return self.m_SlotData[slotId]
end

function VehicleGarage:getMaxSlots()
	return #self.m_SlotData
end

function VehicleGarage.initalizeGarages()
	VehicleGarage:new(
		{
			{571.8, -2781.9, 705.2, 224},
			{570.5, -2765.8, 705.4, 260},
			{586.1, -2787.9, 705.2, 42},
			{586, -2766.2, 705.4, 160}
		},
		Vector(1877.2, -2092, 13.4),
		Vector(573.6, -2799.2, 705.5),
		Vector(573.7, -2804.4, 705.4),
		Vector(1877.7, -2102.8, 13.1),
		0
	)
    
end


VehicleGarageSession = inherit(Object)

function VehicleGarageSession:constructor(dimension, garage, player)
	self.m_Dimension = dimension
	self.m_Slots = {}
	self.m_Garage = garage
	self.m_Player = player
end

function VehicleGarageSession:addVehicle(vehicle)
	local slotId = #self.m_Slots + 1
	if slotId > self.m_Garage:getMaxSlots() then
		return false
	end
	
	local x, y, z = unpack(self.m_Garage:getSlotData(slotId))
	setElementInterior(vehicle, 0)
	setElementPosition(vehicle, x, y, z)
	
	self.m_Slots[slotId] = vehicle
	return slotId
end

function VehicleGarageSession:getDimension()
	return self.m_Dimension
end
