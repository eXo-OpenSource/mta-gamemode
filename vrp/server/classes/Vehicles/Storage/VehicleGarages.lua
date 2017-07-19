-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Storage/VehicleGarages.lua
-- *  PURPOSE:     Vehicle garage class (respawn location etc.)
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
		local blip = Blip:new("Garage.png", enterX, enterY,root,600)
		blip:setDisplayText("Garage", BLIP_CATEGORY.VehicleMaintenance)
		blip:setOptionalColor({0, 188, 212})
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

	-- Hack to ensure garage sessions are destroyed
	local garageZone = createColSphere(exitX, exitY, exitZ, 80)
	addEventHandler("onColShapeLeave", garageZone,
		function(player, matchingDimension)
			if getElementType(player) == "player" and matchingDimension then
				local session = self:getSessionByPlayer(player)
				if session then
					self:closeSession(session)
				end
			end
		end
	)
end

function VehicleGarages:openSessionForPlayer(player, entranceId)
	local sessionId = self:getFreeSessionId()
	local session = VehicleGarageSession:new(sessionId, player, entranceId)
	self.m_Sessions[sessionId] = session

  player:setPrivateSync("isInGarage", true)
	player.m_GarageSession = session

	player:setSpawnLocation(SPAWN_LOCATIONS.GARAGE)
	player:setLastGarageEntrance(session:getEntranceId())
	player:setDimension(session:getDimension())

	return session
end

function VehicleGarages:closeSession(session)
	local idx = table.find(self.m_Sessions, session)
	if not idx then
		return false
	end

	local session = self.m_Sessions[idx]
	local sessionOwner = session.m_Player
	sessionOwner:setPrivateSync("isInGarage", false)
	sessionOwner.m_GarageSession = nil

	-- Tell the player that we closed the garage session
	sessionOwner:triggerEvent("vehicleGarageSessionClose")
	sessionOwner:setSpawnLocation(SPAWN_LOCATIONS.DEFAULT)
	sessionOwner:setDimension(0)

	self.m_Sessions[idx] = nil
	delete(session)
end

function VehicleGarages:getFreeSessionId()
	local sessionId = 0
	repeat
		sessionId = sessionId + 1
	until not self.m_Sessions[sessionId]
	return sessionId
end

function VehicleGarages:getSessionByPlayer(player)
	--[[for k, v in pairs(self.m_Sessions) do
		if v.m_Player == player then
			return v
		end
	end]]
	return player.m_GarageSession
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
	player:respawn(Vector3(interiorX, interiorY, interiorZ))
	setElementRotation(player, 0, 0, rotation)
	setElementDimension(player, session:getDimension())
	session:furnish()
end

function VehicleGarages:EntranceShape_Hit(hitElement, matchingDimension)
	if getElementType(hitElement) == "player" and matchingDimension then
		-- Do not open garage sessions twice
		if self:getSessionByPlayer(hitElement) then
			return
		end

		local vehicle = getPedOccupiedVehicle(hitElement)

		if vehicle then
			if getPedOccupiedVehicleSeat(hitElement) ~= 0 then
				return
			end
			if table.size(getVehicleOccupants(vehicle)) > 1 then
				hitElement:sendError(_("Du kannst nur ohne Mitfahrer in deine Garage fahren!", hitElement))
				return
			end
			if not instanceof(vehicle, Vehicle) or not vehicle:isPermanent() then
				hitElement:sendError(_("Nicht-permanente Fahrzeuge können nicht in der Garage abgestellt werden!", hitElement))
				return
			end
			if instanceof(vehicle, CompanyVehicle) then
				hitElement:sendError(_("Du kannst keine Firmenwagen in der Garage abstellen!", hitElement))
				return
			end
			if instanceof(vehicle, FactionVehicle) then
				hitElement:sendError(_("Du kannst keine Fraktions-Fahrzeuge in der Garage abstellen!", hitElement))
				return
			end
			if instanceof(vehicle, GroupVehicle) then
				hitElement:sendError(_("Du kannst keine Gang-Fahrzeuge in der Garage abstellen!", hitElement))
				return
			end
			if not instanceof(vehicle, Vehicle) or vehicle:getOwner() ~= hitElement:getId() then
				hitElement:sendError(_("Du kannst nur deine eigenen Fahrzeuge in der Garage abstellen!", hitElement))
				return
			end
    	end

	    if hitElement:getGarageType() == 0 then
	      hitElement:sendError(_("Du besitzt keine Garage!", hitElement))
	      return
	    end

		fadeCamera(hitElement, false)

		local session = false
		setTimer(
			function (source)
				session = self:openSessionForPlayer(hitElement, source.EntranceId)
				if vehicle then
					if #session:getSlots() == self:getMaxSlots(hitElement:getGarageType()) then
						hitElement:sendError(_("Diese Garage bietet keinen Platz für ein weiteres Fahrzeug! Steige aus!", hitElement))
						return
					end
				end
			end, 1000, 1, source
		)

		setTimer(
			function()
				if not isElement(hitElement) then
					return
				end

				local vehicle = getPedOccupiedVehicle(hitElement)

				-- Tell the player that we opened the garage session
				hitElement:triggerEvent("vehicleGarageSessionOpen", session:getDimension())

				local garageType = hitElement:getGarageType()
				local interiorX, interiorY, interiorZ, rotation = unpack(self.m_Interiors[garageType].enter)
				setElementPosition(vehicle or hitElement, interiorX, interiorY, interiorZ)
				setElementRotation(vehicle or hitElement, 0, 0, rotation)
				if vehicle then
					setElementDimension(vehicle, session:getDimension())
				end

				-- Hackfix for MTA issue #4658
				if vehicle and getVehicleType(vehicle) == VehicleType.Bike then
					teleportPlayerNextToVehicle(hitElement, vehicle)
				end
				fadeCamera(hitElement, true, 1)

				if vehicle then
					vehicle:setInGarage(true)
				--	vehicle:setCurrentPositionAsSpawn(VehiclePositionType.Garage)
 				--	hitElement:sendInfo(_("Das Fahrzeug wurde in der Garage geparkt!", hitElement))
				end

				setTimer(function() session:furnish() end, 1000, 1)
			end, 1050, 1
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
		setElementVelocity(getPedOccupiedVehicle(hitElement) or hitElement, 0, 0, 0)

		fadeCamera(hitElement, false, 1)

		setTimer(
			function()
				if not isElement(hitElement) then
					return
				end

				self:closeSession(session)
				local vehicle = getPedOccupiedVehicle(hitElement)

				-- Remove the vehicle from the garage if exists
				if vehicle then
					vehicle:setInGarage(false)
					vehicle:setPositionType(VehiclePositionType.World)
				end

				local exitX, exitY, exitZ, rotation = unpack(self.m_Entrances[entranceId].exit)
				setElementPosition(vehicle or hitElement, exitX, exitY, exitZ)
				setElementRotation(vehicle or hitElement, 0, 0, rotation or 0)

				-- Hackfix for MTA issue #4658
				if vehicle and getVehicleType(vehicle) == VehicleType.Bike then
					teleportPlayerNextToVehicle(hitElement, vehicle)
				end
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
			{enter = {410.70001, -1321.5, 16.2}, exit = {415.4, -1328.2, 14.6, 212}};
			{enter = {2771.3, -1623.4, 12.2}, exit = {2770.6, -1614.6, 10.6}};
			{enter = {2778.5, -1623.4, 12.2}, exit = {2778.1, -1615.4, 10.6}, hideblip = true};
			{enter = {2785.6001, -1623.4, 12.2}, exit = {2784.7, -1614.3, 11}, hideblip = true};
			{enter = {1827.3, -1074.8, 25.3}, exit = {1819.8, -1075.3, 23.8, 90}};
			{enter = {1827.4, -1082, 25.3}, exit = {1819.8, -1082.2, 23.8, 90}, hideblip = true};
			{enter = {667.6, -582.3, 16.3}, exit = {668.25, -590.8, 16, 180}};
			{enter = {251.4, -155.3, 1}, exit = {241.75, -156.4, 1.2}};
			{enter = {-2199.5, -2350.6, 29.9}, exit = {-2195.3, -2353, 30.3}}; -- rotation is missing here
			{enter = {-1845, 117.1, 15.1}, exit = {-1845.4, 123.6, 14.8}};
			{enter = {-1851.6, 116.8, 15.3}, exit = {-1852.7, 123.2, 14.8, 230}, hideblip = true};
			{enter = { 2433.537, -4.047, 26.484}, exit = {2433.669, -13.215, 26.484}};
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
					{1620.5, 1081.6, 11.2, 338},
					{1615.3, 1081.6, 11.2, 338},
					{1609.9, 1081.6, 11.2, 338},
					{1604.7, 1081.6, 11.2, 338},
					{1599.5, 1081.6, 11.2, 338},
					{1599.3, 1097.0, 11.2, 202},
					{1604.5, 1097.0, 11.2, 202},
					{1609.6, 1097.0, 11.2, 202},
					{1614.8, 1097.0, 11.2, 202},
					{1620.5, 1097.0, 11.2, 202}
				};
			};
		}
	);
end
