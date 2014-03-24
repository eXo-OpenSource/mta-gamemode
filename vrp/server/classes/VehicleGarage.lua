-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleGarage.lua
-- *  PURPOSE:     Vehicle garage class (respawn location etc.)
-- *  ISSUES:      - If the player gets teleported somehow, the garage session will never be closed (Todo)
-- *			   - Player spawns somewhere in the sky after reconnect
-- *
-- ****************************************************************************
VehicleGarage = inherit(Object)
VehicleGarage.Map = {}

function VehicleGarage:constructor(slotData, entryPosition, interiorPosition, interiorExitPosition, exitPosition, interiorId)
	self.m_Id = #VehicleGarage.Map + 1
	self.m_Sessions = {}
	self.m_SlotData = slotData
	self.m_EnterColShape = createColSphere(entryPosition.X, entryPosition.Y, entryPosition.Z, 3)
	self.m_ExitColShape = createColSphere(interiorExitPosition.X, interiorExitPosition.Y, interiorExitPosition.Z, 2)
	
	addEventHandler("onColShapeHit", self.m_EnterColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				local session = self:openSessionForPlayer(hitElement)
				local vehicle = getPedOccupiedVehicle(hitElement)
				
				if vehicle then
					if not instanceof(vehicle, Vehicle) or not vehicle:isPermanent() then
						hitElement:sendError(_("Nicht-permanente Fahrzeuge können nicht in der Garage abgestellt werden!", hitElement))
						return
					end
					if not instanceof(vehicle, Vehicle) or vehicle:getOwner() ~= hitElement:getId() then
						hitElement:sendError(_("Du kannst nur deine eigenen Fahrzeuge in der Garage abstellen!", hitElement))
						return
					end
					if #session:getSlots() == self:getMaxSlots() then
						hitElement:sendError(_("Diese Garage bietet keinen Platz für ein weiteres Fahrzeug! Steige aus!", hitElement))
						return
					end
				end
				
				fadeCamera(hitElement, false)
				setTimer(
					function()
						local vehicle = getPedOccupiedVehicle(hitElement)
						if vehicle then
							vehicle:setInGarage(true)
						end
						
						setElementInterior(vehicle or hitElement, interiorId)
						setElementPosition(vehicle or hitElement, interiorPosition.X, interiorPosition.Y, interiorPosition.Z)
						setElementDimension(hitElement, session:getDimension())
						fadeCamera(hitElement, true, 2)
						
						setTimer(function() session:furnish() end, 1000, 1)
					end, 2000, 1
				)
			end
		end
	)
	addEventHandler("onColShapeHit", self.m_ExitColShape,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" then
				local session = self:getSessionByPlayer(hitElement)
				if not session then return end
				self:closeSession(session)
				
				fadeCamera(hitElement, false)
				setTimer(
					function()
						local vehicle = getPedOccupiedVehicle(hitElement)
						
						-- Remove the vehicle from the garage if exists
						if vehicle then
							vehicle:setInGarage(false)
						end
						
						setElementInterior(vehicle or hitElement, 0)
						setElementPosition(vehicle or hitElement, exitPosition.X, exitPosition.Y, exitPosition.Z)
						setElementDimension(hitElement, 0)
						setElementRotation(vehicle or hitElement, 0, 0, 0)
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
	
	-- Tell the player that we opened the garage session
	player:triggerEvent("vehicleGarageSessionOpen", self.m_Id, sessionId)
	
	return session
end

function VehicleGarage:closeSession(session)
	local idx = table.find(self.m_Sessions, session)
	if not idx then
		return false
	end
	
	-- Tell the player that we closed the garage session
	session:getPlayer():triggerEvent("vehicleGarageSessionClose", self.m_Id)
	
	table.remove(self.m_Sessions, idx)
	delete(session)
end

function VehicleGarage:getSessionByPlayer(player)
	for k, v in ipairs(self.m_Sessions) do
		if v.m_Player == player then
			return v
		end
	end
end

function VehicleGarage:getSlotData(slotId)
	return self.m_SlotData[slotId]
end

function VehicleGarage:getMaxSlots()
	return #self.m_SlotData
end

-- Managing stuff
function VehicleGarage.initalizeAll()
	VehicleGarage.Map = {
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
		);
	}
end


VehicleGarageSession = inherit(Object)

function VehicleGarageSession:constructor(dimension, garage, player)
	self.m_Dimension = dimension
	self.m_Slots = {}
	self.m_Garage = garage
	self.m_Player = player
end

function VehicleGarageSession:destructor()
	for k, vehicle in ipairs(self.m_Slots) do
		if vehicle:isInGarage() then
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
	local slotId = #self.m_Slots + 1
	if slotId > self.m_Garage:getMaxSlots() then
		return false
	end
	
	local x, y, z, rotation = unpack(self.m_Garage:getSlotData(slotId))
	setElementInterior(vehicle, 0)
	setElementPosition(vehicle, x, y, z)
	setElementDimension(vehicle, self.m_Dimension)
	setElementRotation(vehicle, 0, 0, rotation)
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
