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
	if not info.hideblip then
		local blip = Blip:new("Garage.png", enterX, enterY)
	end
	
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
	
	return session
end

function VehicleGarages:closeSession(session)
	local idx = table.find(self.m_Sessions, session)
	if not idx then
		return false
	end
	
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

function VehicleGarages:spawnPlayerInGarage(player, entranceId)
	local session = self:openSessionForPlayer(player, entranceId)
	player:triggerEvent("vehicleGarageSessionOpen", session:getDimension())
	
	local garageType = player:getGarageType()
	local interiorX, interiorY, interiorZ, rotation = unpack(self.m_Interiors[garageType].enter)
	setElementPosition(player, interiorX, interiorY, interiorZ)
	setElementRotation(player, 0, 0, rotation)
	setElementDimension(player, session:getDimension())
	session:furnish()
end

function VehicleGarages:EntranceShape_Hit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		local vehicle = getPedOccupiedVehicle(hitElement)
		
		if vehicle then
			if getPedOccupiedVehicleSeat(hitElement) ~= 0 then
				return
			end
			if #getVehicleOccupants(vehicle) > 1 then
				hitElement:sendError(_("Du kannst nur ohne Mitfahrer in deine Garage fahren!", hitElement))
				return
			end
			if not instanceof(vehicle, Vehicle) or not vehicle:isPermanent() then
				hitElement:sendError(_("Nicht-permanente Fahrzeuge können nicht in der Garage abgestellt werden!", hitElement))
				return
			end
			if not instanceof(vehicle, Vehicle) or vehicle:getOwner() ~= hitElement:getId() then
				hitElement:sendError(_("Du kannst nur deine eigenen Fahrzeuge in der Garage abstellen!", hitElement))
				return
			end
		end
		
		local session = self:openSessionForPlayer(hitElement, source.EntranceId)
		if vehicle then
			if #session:getSlots() == self:getMaxSlots(hitElement:getGarageType()) then
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
				-- Tell the player that we opened the garage session
				hitElement:triggerEvent("vehicleGarageSessionOpen", session:getDimension())
				hitElement:setSpawnLocation(SPAWN_LOCATION_GARAGE)
				hitElement:setLastGarageEntrance(session:getEntranceId())
				
				local garageType = hitElement:getGarageType()
				local interiorX, interiorY, interiorZ, rotation = unpack(self.m_Interiors[garageType].enter)
				setElementPosition(vehicle or hitElement, interiorX, interiorY, interiorZ)
				setElementRotation(vehicle or hitElement, 0, 0, rotation)
				setElementDimension(hitElement, session:getDimension())
				if vehicle then
					setElementDimension(vehicle, session:getDimension())
				end
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
		
		fadeCamera(hitElement, false, 1)
		setTimer(
			function()
				local vehicle = getPedOccupiedVehicle(hitElement)
				
				-- Remove the vehicle from the garage if exists
				if vehicle then
					vehicle:setInGarage(false)
				end
				-- Tell the player that we closed the garage session
				hitElement:triggerEvent("vehicleGarageSessionClose")
				hitElement:setSpawnLocation(SPAWN_LOCATION_DEFAULT)
				
				local exitX, exitY, exitZ, rotation = unpack(self.m_Entrances[entranceId].exit)
				setElementPosition(vehicle or hitElement, exitX, exitY, exitZ)
				setElementDimension(hitElement, 0)
				setElementRotation(vehicle or hitElement, 0, 0, rotation or 0)
				fadeCamera(hitElement, true)
				
				if vehicle then
					setElementDimension(vehicle, 0)
				end
			end, 1500, 1
		)
	end
end

-- Managing stuff
function VehicleGarages.initalizeAll()
	VehicleGarages:new(
		{ -- Eingänge -- Ausgänge
			{enter = {1877.2, -2092, 13.4}, exit = {1877.7, -2102.8, 13.1}, gtagarage = 2};
			{enter = {1004, -1368, 14.6}, exit = {1003.2, -1353.8, 13}};
			{enter = {1011.2, -1368, 14.6}, exit = {1010.4, -1353.8, 13}, hideblip = true};
			{enter = {410.70001, -1321.5, 16.2}, exit = {415.4, -1328.2, 14.6, 212}, hideblip = true};
			{enter = {2771.3, -1623.4, 12.2}, exit = {2770.6, -1614.6, 10.6}};
			{enter = {2778.5, -1623.4, 12.2}, exit = {2778.1, -1615.4, 10.6}, hideblip = true};
			{enter = {2785.6001, -1623.4, 12.2}, exit = {2784.7, -1614.3, 11}, hideblip = true};
			{enter = {1827.3, -1074.8, 25.3}, exit = {1819.8, -1075.3, 23.8, 90}};
			{enter = {1827.4, -1082, 25.3}, exit = {1819.8, -1082.2, 23.8, 90}, hideblip = true};
		},
		{
			[1] = {
				enter = {1615.9, 963.8, 11.5, 90}; -- Innen-Spawn
				exit = {1623.6, 966.2, 10.5}; -- Innen-Ausgang
				slots = {
					{1599.8, 965.6, 11, 270}, -- 10.4
					{1604.3, 974.8, 11, 180}, -- 10.6
					{1609, 961.3, 11, 300},  -- 10.7
				};
			};
			[2] = {
				enter = {1609.3, 1024.5, 10.8, 90};
				exit = {1619, 1025.5, 10.8};
				slots = {
					{1593.5, 1014.9, 10.8, 354},
					{1600.9, 1015, 10.8, 354},
					{1607.6, 1015.5, 10.8, 354},
					{1600, 1033, 10.8, 204},
					{1606.8, 1033.3, 10.8, 204},
					{1613.8, 1034, 10.8, 204}
				};
			};
			[3] = {
				enter = {1639.5, 1088.8, 10.8, 0};
				exit = {1646.9, 1088.8, 10.8};
				slots = {
					{1598.6, 1084, 11.2, 326},
					{1606, 1083.3, 11.2, 326},
					{1613.4, 1083, 11.2, 326},
					{1619.4, 1083.4, 11.2, 0},
					{1623.9, 1083.6, 11.2, 0},
					{1598, 1095.7, 11.2, 218},
					{1606.6, 1095.5, 11.2, 218},
					{1614, 1095, 11.2, 218},
					{1619.2, 1095.2, 11.2, 180},
					{1623.8, 1095.2, 11.2, 180}
				};
			};
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
	local playerVehicle = getPedOccupiedVehicle(self.m_Player)
	for k, vehicle in ipairs(self.m_Slots) do
		if vehicle:isInGarage() and playerVehicle ~= vehicle then
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
