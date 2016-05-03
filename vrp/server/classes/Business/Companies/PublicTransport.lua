PublicTransport = inherit(Company)
local TAXI_PRICE_PER_KM = 20

function PublicTransport:constructor()
	self.m_TaxiCustomer = {}
	self.m_TaxoMeter = bind(self.updateTaxometer, self)
	Player.getQuitHook():register(bind(self.Event_onPlayerQuit, self))
	addRemoteEvents{"publicTransportSetTargetMap", "publicTransportSetTargetTell"}
	addEventHandler("publicTransportSetTargetMap", root, bind(self.Event_setTargetFromMap))
	addEventHandler("publicTransportSetTargetTell", root, bind(self.Event_sendTargetTellMessage))

	VehicleBarrier:new(Vector3(1811.2,-1893,13.2,0), Vector3(0, 90, 90), 0).onBarrierHit = bind(self.onBarrierHit, self)

	self:addBusStops()
end

function PublicTransport:destuctor()
	for k, info in pairs(self.m_BusStops) do
		destroyElement(info.object)
		destroyElement(info.marker)
		destroyElement(info.sign)
	end
end

function PublicTransport:addBusStops()
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

function PublicTransport:onBarrierHit(player)
    if player:getCompany() ~= self then
        player:sendError(_("Zufahrt Verboten!", player))
        return false
    end
    return true
end

function PublicTransport:onVehiceEnter(veh, player, seat)
	if seat == 0 then
		if veh:getModel() == 420 or veh:getModel() == 438 then
			triggerClientEvent(player, "showTaxoMeter", player)
		elseif veh:getModel() == 437 then
			self:startBusTour(player)
		end
	else
		if veh:getModel() == 420 or veh:getModel() == 438 then
			self:startTaxiDrive(veh, player)
			triggerClientEvent(player, "showPublicTransportTaxiGUI", player)
		end
	end
end

function PublicTransport:onVehiceStartEnter(veh, player, seat)
	if seat > 0 and not veh:getOccupant(0) then
		if veh:getModel() == 420 or veh:getModel() == 438 then
			cancelEvent()
			player:sendError(_("Es sitzt kein Fahrer im Taxi", player))
		elseif veh:getModel() == 437 then
			cancelEvent()
			player:sendError(_("Es sitzt kein Fahrer im Bus", player))
		end
	end
end

function PublicTransport:onVehiceExit(veh, player, seat)
	if seat == 0 then
		if veh:getModel() == 420 or veh:getModel() == 438 then
			triggerClientEvent(player, "hideTaxoMeter", player)
		elseif veh:getModel() == 437 then
			self:stopBusTour(player)
		end
	else
		self:endTaxiDrive(player)
	end
end

function PublicTransport:startTaxiDrive(veh, customer)
	self.m_TaxiCustomer[customer] = {}
	self.m_TaxiCustomer[customer]["customer"] = customer
	self.m_TaxiCustomer[customer]["vehicle"] = veh
	self.m_TaxiCustomer[customer]["driver"] = veh:getOccupant(0)
	self.m_TaxiCustomer[customer]["startMileage"] = veh:getMileage()
	self.m_TaxiCustomer[customer]["diff"] = 0
	self.m_TaxiCustomer[customer]["price"] = 0
	self.m_TaxiCustomer[customer]["timer"] = setTimer(self.m_TaxoMeter, 1000, 0, customer)
	triggerClientEvent(customer, "showTaxoMeter", customer)
	--triggerClientEvent(self.m_TaxiCustomer[customer]["driver"], "showTaxoMeter", self.m_TaxiCustomer[customer]["driver"])
end

function PublicTransport:endTaxiDrive(customer)
	if self.m_TaxiCustomer[customer] then
		local driver = self.m_TaxiCustomer[customer]["driver"]
		local price = self.m_TaxiCustomer[customer]["price"]
		local vehicle = self.m_TaxiCustomer[customer]["vehicle"]
		customer:takeMoney(price, "Public Transport Taxi")
		driver:giveMoney(price, "Public Transport Taxi")
		customer:sendInfo(_("Du bist aus dem Taxi ausgestiegen! Die Fahrt hat dich %d$ gekostet!", customer, price))
		driver:sendInfo(_("Der Spieler %s ist ausgestiegen! Die Fahrt hat dir %d$ eingebracht!", driver, customer:getName(), price))
		killTimer(self.m_TaxiCustomer[customer]["timer"])
		if self.m_TaxiCustomer[customer]["blip"] then delete(self.m_TaxiCustomer[customer]["blip"]) end
		self.m_TaxiCustomer[customer] = nil
		triggerClientEvent(customer, "hideTaxoMeter", customer)
		updateDriverTaxometer(vehicle, driver)
	end
end

function PublicTransport:updateTaxometer(customer)
	self.m_TaxiCustomer[customer]["diff"] = (self.m_TaxiCustomer[customer]["vehicle"]:getMileage() - self.m_TaxiCustomer[customer]["startMileage"])/1000
	self.m_TaxiCustomer[customer]["price"] = math.floor(self.m_TaxiCustomer[customer]["diff"] * TAXI_PRICE_PER_KM)
	if customer:getMoney() < self.m_TaxiCustomer[customer]["price"] then
		customer:sendError(_("Du hast kein Geld mehr dabei! Du wurdest aus dem Taxi geschmissen!", customer, price))
		customer:removeFromVehicle()
		self:endTaxiDrive(customer)
	end
	triggerClientEvent(customer, "syncTaxoMeter", customer, self.m_TaxiCustomer[customer]["diff"], self.m_TaxiCustomer[customer]["price"])

	self:updateDriverTaxometer(self.m_TaxiCustomer[customer]["vehicle"], self.m_TaxiCustomer[customer]["driver"])
end

function PublicTransport:updateDriverTaxometer(vehicle, driver)
	local customers = {}
	for seat, customer in pairs(vehicle:getOccupants()) do
		if seat > 0 then
			if self.m_TaxiCustomer[customer] then
				customers[seat] = self.m_TaxiCustomer[customer]
			end
		end
	end
	if driver then
		triggerClientEvent(driver, "syncDriverTaxoMeter", driver, customers)
	end
end

function PublicTransport:Event_onPlayerQuit()
	if self.m_TaxiCustomer[source] then
		local driver = self.m_TaxiCustomer[source]["driver"]
		driver:sendError(_("Der Kunde %s ist offline gegangen!", driver, source:getName()))
		self:endTaxiDrive(source)
	end
end

function PublicTransport:Event_setTargetFromMap(posX, posY)

	if self.m_TaxiCustomer[client]["driver"] then
		local driver = self.m_TaxiCustomer[client]["driver"]
		driver:sendInfo(_("Der Kunde %s hat sein Ziel auf der Karte markiert! Ziel: %s/%s", driver, client:getName(), getZoneName(posX, posY, 0), getZoneName(posX, posY, 0, true)))
		client:sendInfo(_("Du hast dein Ziel auf der Karte markiert! Ziel: %s/%s", client, getZoneName(posX, posY, 0), getZoneName(posX, posY, 0, true)))
		self.m_TaxiCustomer[client]["blip"] = Blip:new("Waypoint.png", posX, posY)
	end
end

function PublicTransport:Event_sendTargetTellMessage(posX, posY)
	local driver = self.m_TaxiCustomer[client]["driver"]
	if driver then
		driver:sendInfo(_("Der Kunde %s wird dir sein Ziel mitteilen!", driver, source:getName()))
		client:sendInfo(_("Bitte nenne dem Fahrer %s dein Ziel", client, driver:getName()))
	end
end

function PublicTransport:stopBusTour(player)
	player.Bus_NextStop = nil
	player.Bus_Line = nil
	delete(player.Bus_Blip)
	player.Bus_Blip = nil
end

function PublicTransport:startBusTour(player)
	local line = math.random(1, #self.m_Lines) -- Note: Lines have to be sequent (1, 2, 3, 4, ...)
	player.Bus_NextStop = 1
	player.Bus_Line = line

	local x, y, z = getElementPosition(self.m_BusStops[self.m_Lines[line][1]].object)
	player.Bus_Blip = Blip:new("Waypoint.png", x, y, player)

	player:giveAchievement(17)
end

function PublicTransport:BusStop_Hit(player, matchingDimension)
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
		player:giveMoney(50)
		local newDestination = self.m_Lines[line][destinationId + 1] and destinationId + 1 or 1
		player.Bus_NextStop = newDestination

		-- Pay extra money for extra occupants
		player:giveMoney((table.size(getVehicleOccupants(vehicle)) - 1) * 40)
		player:givePoints(2)
		for seat, player in pairs(getVehicleOccupants(vehicle)) do
			if seat ~= 0 then
				player:takeMoney(40, "Public Transport Bus")
			end
		end

		local stopId = self.m_Lines[line][newDestination]
		local x, y, z = getElementPosition(self.m_BusStops[stopId].object)
		delete(player.Bus_Blip)
		player.Bus_Blip = Blip:new("Waypoint.png", x, y, player)

		-- Tell other players that we reached a bus stop (to adjust the bus display labels)
		triggerClientEvent("busReachNextStop", root, vehicle, self.m_BusStops[stopId].name)
	end
end
