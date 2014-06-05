-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleGarages.lua
-- *  PURPOSE:     Vehicle garage class (respawn location etc.)
-- *  ISSUES:      - If the player gets teleported somehow, the garage session will never be closed (Todo)
-- *			   - Player spawns somewhere in the sky after reconnect
-- *
-- ****************************************************************************
VehicleGarages = inherit(Singleton)

function VehicleGarages:constructor(entranceData, interiorData)
	self.m_Entrances = {}
	self.m_Interiors = {}
	self.m_Sessions = {}

	-- Create entrances
	for k, entranceInfo in pairs(entranceData) do
		self:createEntrance(entranceInfo, k)
	end

	-- Create garage interiors
	for k, interiorInfo in pairs(interiorData) do
		self:createInteror(interiorInfo)
	end
end

function VehicleGarages:destructor()
	destroyElement(self.m_EnterColShape)
	destroyElement(self.m_ExitColShape)
	delete(self.m_Blip)
end

function VehicleGarages:createEntrance(info, Id)
	local enterX, enterY, enterZ = unpack(info.enter)
	local entranceShape = createColSphere(enterX, enterY, enterZ, 3)
	local blip = Blip:new("files/images/Blips/Garage.png", enterX, enterY)
	
	addEventHandler("onColShapeHit", entranceShape, bind(self.EntranceShape_Hit, self))
	entranceShape.EntranceId = Id
	self.m_Entrances[#self.m_Entrances+1] = {exit = info.exit, shape = entranceShape, blip = blip}
	if info.gtagarage then
		setGarageOpen(info.gtagarage, true)
	end
end

function VehicleGarages:createInteror(info)
	local exitX, exitY, exitZ = unpack(info.exit)
	local exitShape = createColSphere(exitX, exitY, exitZ, 2)
	addEventHandler("onColShapeHit", exitShape, bind(self.ExitShape_Hit, self))
	
	self.m_Interiors[#self.m_Interiors+1] = {enter = info.enter, slots = info.slots, shape = exitShape}
end

function VehicleGarages:openSessionForPlayer(player, entranceId)
	local sessionId = #self.m_Sessions + 1
	local session = VehicleGarageSession:new(sessionId, player, entranceId)
	self.m_Sessions[sessionId] = session
	
	-- Tell the player that we opened the garage session
	player:triggerEvent("vehicleGarageSessionOpen", self.m_Id, sessionId)
	
	return session
end

function VehicleGarages:closeSession(session)
	local idx = table.find(self.m_Sessions, session)
	if not idx then
		return false
	end
	
	-- Tell the player that we closed the garage session
	session:getPlayer():triggerEvent("vehicleGarageSessionClose", self.m_Id)
	
	table.remove(self.m_Sessions, idx)
	delete(session)
end

function VehicleGarages:getSessionByPlayer(player)
	for k, v in pairs(self.m_Sessions) do
		if v.m_Player == player then
			return v
		end
	end
end

function VehicleGarages:getSlotData(garageType, slotId)
	return self.m_Interiors[garageType].slots[slotId]
end

function VehicleGarages:getMaxSlots(garageType)
	return #self.m_Interiors[garageType].slots
end

function VehicleGarages:EntranceShape_Hit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		local session = self:openSessionForPlayer(hitElement, source.EntranceId)
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
				
				local garageType = hitElement:getGarageType()
				local interiorX, interiorY, interiorZ = unpack(self.m_Interiors[garageType].enter)
				--setElementInterior(vehicle or hitElement, interiorId)
				setElementPosition(vehicle or hitElement, interiorX, interiorY, interiorZ)
				setElementDimension(hitElement, session:getDimension())
				fadeCamera(hitElement, true, 2)
				
				setTimer(function() session:furnish() end, 1000, 1)
			end, 2000, 1
		)
	end
end

function VehicleGarages:ExitShape_Hit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" then
		local session = self:getSessionByPlayer(hitElement)
		if not session then
			return
		end
		
		local entranceId = session:getEntranceId()
		self:closeSession(session)
		setElementVelocity(getPedOccupiedVehicle(hitElement) or hitElement, 0, 0, 0)
		
		fadeCamera(hitElement, false)
		setTimer(
			function()
				local vehicle = getPedOccupiedVehicle(hitElement)
				
				-- Remove the vehicle from the garage if exists
				if vehicle then
					vehicle:setInGarage(false)
				end
				
				local exitX, exitY, exitZ = unpack(self.m_Entrances[entranceId].exit)
				--setElementInterior(vehicle or hitElement, 0)
				setElementPosition(vehicle or hitElement, exitX, exitY, exitZ)
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

-- Managing stuff
function VehicleGarages.initalizeAll()
	VehicleGarages:new(
		{ -- Eingänge -- Ausgänge
			{enter = {1877.2, -2092, 13.4}, exit = {1877.7, -2102.8, 13.1}, gtagarage = 2};
		},
		{
			[1] = {
				enter = {1, 2, 3}; -- Innen-Spawn
				exit = {1, 2, 3}; -- Innen-Ausgang
				slots = {
					{1, 2, 3}
				};
				interior = 1;
			}
		}
	);
end


VehicleGarageSession = inherit(Object)

function VehicleGarageSession:constructor(dimension, player, entranceId)
	self.m_Dimension = dimension
	self.m_Slots = {}
	self.m_Player = player
	self.m_GarageType = player:getGarageType()
	self.m_EntranceId = entranceId
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
	if slotId > VehicleGarages:getSingleton():getMaxSlots(self.m_GarageType) then
		return false
	end
	
	local x, y, z, rotation = unpack(VehicleGarages:getSingleton():getSlotData(self.m_GarageType, slotId))
	--setElementInterior(vehicle, 0)
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
