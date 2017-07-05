PublicTransport = inherit(Company)
PublicTransport.ms_BusLineData = { --this information can't be parsed out of the bus station map file
	[1] = {
		displayName = "Downtown - Blueberry",
		color = {50, 200, 255}, -- LightBlue
	},
	[2] = {
		displayName = "East LS - Montgomery",
		color = {180, 0, 170}, -- Pink
	},
}

local TAXI_PRICE_PER_KM = 20

function PublicTransport:constructor()
	self.m_TaxiCustomer = {}
	self.m_TaxoMeter = bind(self.updateTaxometer, self)
	Player.getQuitHook():register(bind(self.Event_onPlayerQuit, self))
	addRemoteEvents{"publicTransportSetTargetMap", "publicTransportSetTargetTell", "publicTransportChangeBusDutyState"}
	addEventHandler("publicTransportSetTargetMap", root, bind(self.Event_setTargetFromMap, self))
	addEventHandler("publicTransportSetTargetTell", root, bind(self.Event_sendTargetTellMessage, self))
	addEventHandler("publicTransportChangeBusDutyState", root, bind(self.Event_changeBusDutyState, self))
	addEventHandler("playerReady", root, bind(self.Event_PlayerRequestBusData, self))

	VehicleBarrier:new(Vector3(1811.2,-1893,13.2,0), Vector3(0, 90, 90), 0).onBarrierHit = bind(self.onBarrierHit, self)

	self:setSafe(createObject(2332, 1733.52, -1931.28, 13, 0, 0, 270))
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
		local signObject = createObject(1229, signX, signY, signZ, 0, 0, rz)

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

function PublicTransport:Event_PlayerRequestBusData()
	if not self.m_BusStationDataForClient then -- create new cache
		self.m_BusStationDataForClient = {
			line = {},
			lineDisplayData = PublicTransport.ms_BusLineData
		}
		local data = self.m_BusStationDataForClient.line
		for line, stationids in ipairs(self.m_Lines) do
			data[line] = {}
			local endStationFound
			local quitNextStation
			for i, id in ipairs(stationids) do -- this does not accept routes with end stations at the very beginning!
				if i >= 2 and i <= #stationids-1 then
					local prevName = self.m_BusStops[id-1].name
					local nextName = self.m_BusStops[id+1].name
					if prevName == nextName then -- end station found
						if not endStationFound then 
							endStationFound = true -- start collecting stations
						else
							quitNextStation = true -- don't quit here, but collect the second end station
						end
					end
				end
				if endStationFound then
					table.insert(data[line], {
						name = self.m_BusStops[id].name,
						position = serialiseVector(self.m_BusStops[id].marker.position)
					})
				end
				if quitNextStation then 
					break 
				end
			end
		end
	end
	triggerClientEvent(client, "recieveEPTBusData", resourceRoot, self.m_BusStationDataForClient)
end

function PublicTransport:onBarrierHit(player)
    return player:getCompany() == self
end

function PublicTransport:onVehiceEnter(veh, player, seat)
	if seat == 0 then
		if veh:getModel() == 420 or veh:getModel() == 438 then
			player:triggerEvent("showTaxoMeter")
		elseif veh:getModel() == 437 then
			veh:setVariant(0, 0)
			veh:setHandling("handlingFlags", 18874448)
			veh:setHandling("maxVelocity", 120) -- ca. 130 km/h
			triggerClientEvent("busReachNextStop", root, player.vehicle, "Ausser Dienst", false)
		end
	else
		if veh:getModel() == 420 or veh:getModel() == 438 then
			self:startTaxiDrive(veh, player)
			player:triggerEvent("showPublicTransportTaxiGUI")
		end
	end
end

function PublicTransport:onVehiceStartEnter(veh, player, seat)
	if seat > 0 and not veh:getOccupant(0) then
		if veh:getModel() == 420 or veh:getModel() == 438 then
			cancelEvent()
			player:sendError(_("Es sitzt kein Fahrer im Taxi.", player))
		elseif veh:getModel() == 437 then
			cancelEvent()
			player:sendError(_("Es sitzt kein Fahrer im Bus.", player))
		end
	elseif veh:getModel() == 437 and not veh.Bus_OnDuty then
		cancelEvent()
		player:sendError(_("Dieser Bus ist nicht im Dienst.", player))
	end
end

function PublicTransport:onVehiceExit(veh, player, seat)
	if seat == 0 then
		if veh:getModel() == 420 or veh:getModel() == 438 then
			player:triggerEvent("hideTaxoMeter")
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
	customer:triggerEvent("showTaxoMeter")

	--triggerClientEvent(self.m_TaxiCustomer[customer]["driver"], "showTaxoMeter", self.m_TaxiCustomer[customer]["driver"])
end

function PublicTransport:endTaxiDrive(customer)
	if self.m_TaxiCustomer[customer] then
		local driver = self.m_TaxiCustomer[customer]["driver"]
		local price = self.m_TaxiCustomer[customer]["price"]
		local vehicle = self.m_TaxiCustomer[customer]["vehicle"]
		if price > customer:getMoney() then price = customer:getMoney() end
		customer:takeMoney(price, "Public Transport Taxi")
		driver:giveMoney(price, "Public Transport Taxi")
		customer:sendInfo(_("Du bist aus dem Taxi ausgestiegen! Die Fahrt hat dich %d$ gekostet!", customer, price))
		driver:sendInfo(_("Der Spieler %s ist ausgestiegen! Die Fahrt hat dir %d$ eingebracht!", driver, customer:getName(), price))
		killTimer(self.m_TaxiCustomer[customer]["timer"])
		if self.m_TaxiCustomer[customer]["blip"] then delete(self.m_TaxiCustomer[customer]["blip"]) end
		self.m_TaxiCustomer[customer] = nil
		customer:triggerEvent("hideTaxoMeter")
		self:updateDriverTaxometer(vehicle, driver)
	end
end

function PublicTransport:updateTaxometer(customer)
	if self.m_TaxiCustomer[customer] and isElement(customer) then
		self.m_TaxiCustomer[customer]["diff"] = (self.m_TaxiCustomer[customer]["vehicle"]:getMileage() - self.m_TaxiCustomer[customer]["startMileage"])/1000
		self.m_TaxiCustomer[customer]["price"] = math.floor(self.m_TaxiCustomer[customer]["diff"] * TAXI_PRICE_PER_KM)
		customer:triggerEvent("syncTaxoMeter", self.m_TaxiCustomer[customer]["diff"], self.m_TaxiCustomer[customer]["price"])

		if customer:getMoney() < self.m_TaxiCustomer[customer]["price"] then
			customer:sendError(_("Du hast kein Geld mehr dabei! Du wurdest aus dem Taxi geschmissen!", customer, price))
			customer:removeFromVehicle()
			self:endTaxiDrive(customer)
		end
		self:updateDriverTaxometer(self.m_TaxiCustomer[customer]["vehicle"], self.m_TaxiCustomer[customer]["driver"])
	else
		if isTimer(sourceTimer) then killTimer(sourceTimer) end
		self:endTaxiDrive(customer)

	end
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
		driver:triggerEvent("syncDriverTaxoMeter", customers)
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
		driver:startNavigationTo(Vector3(posX, posY, 0))

		self.m_TaxiCustomer[client]["blip"] = Blip:new("Waypoint_ept.png", posX, posY, driver, 10000)
	end
end

function PublicTransport:Event_sendTargetTellMessage(posX, posY)
	local driver = self.m_TaxiCustomer[client]["driver"]
	if driver then
		driver:sendInfo(_("Der Kunde %s wird dir sein Ziel mitteilen!", driver, source:getName()))
		client:sendInfo(_("Bitte nenne dem Fahrer %s dein Ziel", client, driver:getName()))
	end
end


function PublicTransport:Event_changeBusDutyState(state, arg)
	if state == "dutyLine" then
		self:startBusTour(client.vehicle, client, arg)
	elseif state == "dutySpecial" then
		if client.vehicle.Bus_Line then
			self:stopBusTour(client.vehicle, client)
		end
		self:startBusTour(client.vehicle, client, 0)
	else
		if client.vehicle.Bus_OnDuty then
			self:stopBusTour(client.vehicle, client)
		end
	end
end

function PublicTransport:stopBusTour_Driver(player) --also gets triggered when player changes to off-duty
	if player.Bus_Blip then
		delete(player.Bus_Blip)
		player.Bus_Blip = nil
	end
end

function PublicTransport:isBusOnTour(vehicle)
	return vehicle and (vehicle.Bus_OnDuty and true or false) 
end

function PublicTransport:stopBusTour(vehicle, player)
	if not vehicle.Bus_OnDuty then return false end
	if player then
		self:stopBusTour_Driver(player)
	end
	vehicle.Bus_OnDuty = nil
	vehicle.Bus_LastStop = nil
	vehicle.Bus_NextStop = nil
	vehicle.Bus_Line = nil
	vehicle:setColor(companyColors[4].r, companyColors[4].g, companyColors[4].b, companyColors[4].r, companyColors[4].g, companyColors[4].b)
	for i,v in pairs(vehicle:getOccupants()) do
		if v.vehicleSeat ~= 0 then
			v:removeFromVehicle()
			v:sendWarning(_("Dieser Bus ist nicht mehr auf dieser Route im Dienst.", v))
		end
	end
	triggerClientEvent("busReachNextStop", root, vehicle, "Ausser Dienst", false)
end

function PublicTransport:startBusTour(vehicle, player, line)
	if vehicle.Bus_OnDuty and line == vehicle.Bus_Line then return false end
	vehicle.Bus_OnDuty = true
	if self.m_Lines[line] then -- otherwise special service
		if vehicle.Bus_Line then -- lines changed, so notify that the old bus route no longer recieves service
			self:stopBusTour_Driver(player)
		end
		vehicle.Bus_NextStop = 1
		vehicle.Bus_Line = line
		vehicle:setColor(companyColors[4].r, companyColors[4].g, companyColors[4].b, unpack(PublicTransport.ms_BusLineData[line].color))
		local x, y, z = getElementPosition(self.m_BusStops[self.m_Lines[line][1]].object)
		player.Bus_Blip = Blip:new("Waypoint.png", x, y, player)
		triggerClientEvent("busReachNextStop", root, player.vehicle, self.m_BusStops[self.m_Lines[line][vehicle.Bus_NextStop]].name, false, line)
		player:giveAchievement(17)
	else
		triggerClientEvent("busReachNextStop", root, client.vehicle, "Sonderfahrt", false)
	end
end

function PublicTransport:BusStop_Hit(player, matchingDimension)
	if getElementType(player) == "player" and matchingDimension and getPedOccupiedVehicleSeat(player) == 0 then
		local vehicle = getPedOccupiedVehicle(player)
		if not vehicle or getElementModel(vehicle) ~= 437 then
			return
		end

		-- Check if this is really the destination bus stop
		local lastId = vehicle.Bus_LastStop
		local destinationId = vehicle.Bus_NextStop
		local line = vehicle.Bus_Line
		if not destinationId or not line then
			return
		end

		local stopId = self.m_Lines[line][destinationId]
		if not stopId or not self.m_BusStops[stopId] or self.m_BusStops[stopId].marker ~= source then
			-- Show an error message maybe?
			return
		end

		-- Give the player some money and switch to the next bus stop
		if lastId then 
			local dist = getDistanceBetweenPoints3D(self.m_BusStops[lastId].marker.position, self.m_BusStops[stopId].marker.position)
			player:addBankMoney(math.round(340 * (dist/1000)), "Public Transport Bus")	-- 340 / km
			player:givePoints(math.round(5 * (dist/1000))) --5 / km
			self:giveMoney(math.round(30 * (dist/1000)), ("Busfahrt Linie %d von %s"):format(line, player:getName()))
			self:addLog(player, "Kasse", ("hat %s in die Kasse gelegt (Busfahrt Linie %d)!"):format(toMoneyString(math.round(30 * (dist/1000))), line))
		end
		player:districtChat(("Ein Bus der Linie %d ist an der Haltestelle '%s' eingetroffen!"):format(line, self.m_BusStops[stopId].name))
		local newDestinationId = self.m_Lines[line][destinationId + 1] and destinationId + 1 or 1
		vehicle.Bus_NextStop = newDestinationId


		local nextStopId = self.m_Lines[line][newDestinationId]
		local x, y, z = getElementPosition(self.m_BusStops[nextStopId].object)
		delete(player.Bus_Blip)
		player.Bus_Blip = Blip:new("Waypoint.png", x, y, player,9999)

		-- Tell other players that we reached a bus stop (to adjust the bus display labels)
		local nextNewDestinationId = self.m_Lines[line][newDestinationId + 1] and newDestinationId + 1 or 1
		local nextNewStopId = self.m_Lines[line][nextNewDestinationId] -- get the stop two stations ahead to determine if next stop is an end station
		triggerClientEvent("busReachNextStop", root, vehicle, self.m_BusStops[nextStopId].name, self.m_BusStops[nextNewStopId].name == self.m_BusStops[stopId].name, line)

		vehicle.Bus_LastStop = stopId
	end
end
