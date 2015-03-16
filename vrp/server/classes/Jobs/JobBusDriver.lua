-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobBusDriver.lua
-- *  PURPOSE:     Bus driver job class
-- *
-- ****************************************************************************
JobBusDriver = inherit(Job)

function JobBusDriver:constructor()
	Job.constructor(self)

	-- Prepare job base
	createObject(9131, 1729.8, -1751, 13.7, 0, 0, 0.5)
	createObject(7018, 1770.6, -1779.3, 13.8, 0, 0, 269.75)
	createObject(7018, 1770.4, -1757.8, 13.8, 0, 0, 89.747)
	createObject(9131, 1811.2, -1743.3, 13.7, 0, 0, 0)
	createObject(9131, 1811.4, -1764.6, 13.7, 0, 0, 0)
	createObject(9131, 1811.3, -1781.2, 13.7, 0, 0, 0)
	createObject(9131, 1811.3, -1785.8, 13.7, 0, 0, 0)
	createObject(9131, 1811.3, -1794.3, 13.7, 0, 0, 0)
	createObject(9131, 1737.5, -1794, 13.7, 0, 0, 0)
	createObject(9131, 1729.7, -1743, 13.7, 0, 0, 0)
	removeWorldModel(4019, 77, 1777.8, -1773.9, 12.5)
	removeWorldModel(4025, 77, 1777.8, -1773.9, 12.5)
	removeWorldModel(4215, 77, 1777.8, -1773.9, 12.5)
	for i = 0, 7 do
		AutomaticVehicleSpawner:new(437, 1799 - i * 6, -1770.2, 13.9, 0, 0, 0, function(vehicle) setVehicleVariant(vehicle, 1, 255) end, self)
	end

	-- Create bus stops
	self.m_BusStops = {}
	self.m_Lines = {}
	self.m_FuncStopHit = bind(self.BusStop_Hit, self)

	for k, busStop in pairs(getElementsByType("bus_stop", resourceRoot)) do
		local markerDistance = getElementData(busStop, "markerdistance")
		local lines = split(getElementData(busStop, "lines"), ",")
		local x, y, z = getElementData(busStop, "posX"), getElementData(busStop, "posY"), getElementData(busStop, "posZ")
		local rx, ry, rz = getElementData(busStop, "rotX"), getElementData(busStop, "rotY"), getElementData(busStop, "rotZ")
		local stationName = getElementData(busStop, "name")

		local object = createObject(1257, x, y, z, rx, ry, rz)
		local markerX, markerY, markerZ = getPositionFromElementOffset(object, -1 * markerDistance, 0, -1)
		local marker = createColSphere(markerX, markerY, markerZ, 5)
		local signX, signY, signZ = getPositionFromElementOffset(object, -1.5, 3.4, 0.2)
		local signObject = createObject(1229, signX, signY, signZ)

		-- Push to the bus stop list and add the hit event
		table.insert(self.m_BusStops, {object = object, marker = marker, sign = signObject, name = stationName})
		addEventHandler("onColShapeHit", marker, self.m_FuncStopHit)

		-- Push bus stop id to the line lists
		for i, lineString in pairs(lines) do
			local line = tonumber(lineString)
			if not line then
				error("Error loading bus stops: Invalid line specified")
			end

			if not self.m_Lines[line] then
				self.m_Lines[line] = {}
			end

			table.insert(self.m_Lines[line], k)
		end
	end
end

function JobBusDriver:destructor()
	for k, info in pairs(self.m_BusStops) do
		destroyElement(info.object)
		destroyElement(info.marker)
		destroyElement(info.sign)
	end
end

function JobBusDriver:start(player)
	local line = math.random(1, #self.m_Lines) -- Note: Lines have to be sequent (1, 2, 3, 4, ...)

	player.Bus_NextStop = 1
	player.Bus_Line = line

	local x, y, z = getElementPosition(self.m_BusStops[self.m_Lines[line][1]].object)
	player.Bus_Blip = Blip:new("Waypoint.png", x, y, player)
end

function JobBusDriver:stop(player)
	player.Bus_NextStop = nil
	player.Bus_Line = nil
	delete(player.Bus_Blip)
	player.Bus_Blip = nil
end

function JobBusDriver:BusStop_Hit(player, matchingDimension)
	if getElementType(player) == "player" and matchingDimension and getPedOccupiedVehicleSeat(player) == 0 then
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle or getElementModel(vehicle) ~= 437 then
			return
		end

		-- Check if this is really the destination bus stop
		local destinationId = player.Bus_NextStop
		local line = player.Bus_Line
		if not destinationId or not line then
			return
		end

		local stopId = self.m_Lines[line][destinationId]
		if not stopId or not self.m_BusStops[stopId] or self.m_BusStops[stopId].marker ~= source then
			-- Show an error message maybe?
			return
		end

		-- Give the player some money and switch to the next bus stop
		player:giveMoney(200)
		local newDestination = self.m_Lines[line][destinationId + 1] and destinationId + 1 or 1
		player.Bus_NextStop = newDestination

		-- Pay extra money for extra occupants
		player:giveMoney((table.size(getVehicleOccupants(vehicle)) - 1) * 40)
		player:givePoints(3)
		for seat, player in pairs(getVehicleOccupants(vehicle)) do
			if seat ~= 0 then
				player:takeMoney(40)
			end
		end

		local stopId = self.m_Lines[line][newDestination]
		local x, y, z = getElementPosition(self.m_BusStops[stopId].object)
		outputDebug(("Deleting and recreating blip %s for player %s"):format(tostring(player.Bus_Blip), getPlayerName(player)))
		delete(player.Bus_Blip)
		player.Bus_Blip = Blip:new("Waypoint.png", x, y, player)

		-- Tell other players that we reached a bus stop (to adjust the bus display labels)
		triggerClientEvent("busReachNextStop", root, vehicle, self.m_BusStops[stopId].name)
	end
end
