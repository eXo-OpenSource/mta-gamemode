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

local TAXI_PRICE_PER_KM = 40
PublicTransport.m_TaxiSigns = {}

function PublicTransport:constructor()
	self.m_TaxiCustomer = {}
	self.m_ActiveBusVehicles = {}
	self.m_TaxoMeter = bind(self.updateTaxometer, self)
	Player.getQuitHook():register(bind(self.Event_onPlayerQuit, self))
	addRemoteEvents{"publicTransportStartTaxi", "publicTransportSetTargetMap", "publicTransportSetTargetTell", "publicTransportChangeBusDutyState", "publicTransportSwitchTaxiLight"}
	addEventHandler("publicTransportStartTaxi", root, bind(self.Event_OnTaxiDriverModeChange, self))
	addEventHandler("publicTransportSwitchTaxiLight", root, bind(self.Event_OnTaxiLightChange, self))
	addEventHandler("publicTransportSetTargetMap", root, bind(self.Event_setTargetFromMap, self))
	addEventHandler("publicTransportSetTargetTell", root, bind(self.Event_sendTargetTellMessage, self))
	addEventHandler("publicTransportChangeBusDutyState", root, bind(self.Event_changeBusDutyState, self))
	addEventHandler("playerReady", root, bind(self.Event_PlayerRequestBusData, self))

	Gate:new(968, Vector3(1811.2,-1893,13.2,0), Vector3(0, 90, 90), Vector3(1811.2,-1893,13.2,0), Vector3(0, 5, 90), false).onGateHit = bind(self.onBarrierHit, self)
	
	InteriorEnterExit:new(Vector3(1743.05, -1864.12, 13.59), Vector3(1225.84, -68.98, 1011.33), 0, 0, 12, 4) --front door
	InteriorEnterExit:new(Vector3(1752.86, -1894.19, 13.56), Vector3(1210.65, -55.02, 1011.34), 270, 270, 12, 4) --parking lot
	InteriorEnterExit:new(Vector3(1733.27, -1912.00, 13.56), Vector3(1235.94, -46.98, 1011.33), 90, 90, 12, 4) --side


	self.m_BankAccountServer = BankServer.get("company.public_transport")
	local safe = createObject(2332, 1236, -62.10, 1011.8, 0, 0, -90)
	safe:setInterior(12)
	safe:setDimension(4)
	self:setSafe(safe)
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
			object:setData("EPT_bus_station", stationName, true)
			object:setData("EPT_bus_station_lines", lines, true)
		busStop:setData("object", object, true)
		local markerX, markerY, markerZ = getPositionFromElementOffset(object, -1 * markerDistance, 0, -1)
		--Blip:new("Marker.png", markerX, markerY, root, 400):setColor(PublicTransport.ms_BusLineData[tonumber(lines[1])].color)
		local signX, signY, signZ = getPositionFromElementOffset(object, -1.5, 3.4, 0.2)
		local signObject = createObject(1229, signX, signY, signZ, 0, 0, rz)

		-- Push to the bus stop list and add the hit event
		table.insert(self.m_BusStops, {object = object, marker = {}, markerPos = Vector3(markerX, markerY, markerZ), sign = signObject, name = stationName})

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
						position = serialiseVector(self.m_BusStops[id].object.position)
					})
				end
				if quitNextStation then
					break
				end
			end
		end
	end
	triggerClientEvent(client, "recieveEPTBusData", resourceRoot, self.m_BusStationDataForClient, self.m_ActiveBusVehicles)
end

function PublicTransport:onBarrierHit(player)
    return player:getCompany() == self
end

function PublicTransport:onVehicleEnter(veh, player, seat)
	if seat == 0 then
		if player:getCompany() == self and player:isCompanyDuty() then
			if veh:getModel() ~= 437 and veh:getModel() ~= 409  then -- as EPT gets more taxi models, it is easier to just exclude Buses and Stretch Limos
				player:triggerEvent("showTaxoMeter")
				veh:setData("EPT_Taxi", true, true)
			elseif veh:getModel() == 437 then
				veh:setVariant(0, 0)
				veh:setData("EPT_Bus", true, true)
				veh:setHandling("handlingFlags", 18874448)
				veh:setHandling("maxVelocity", 120) -- ca. 130 km/h
				if self:isBusOnTour(veh) then
					self:startBusTour_Driver(player, veh.Bus_NextStop, veh.Bus_Line)
				else
					triggerClientEvent("busReachNextStop", root, veh, "Ausser Dienst", false)
				end
			end
		end
	else
		if veh:getData("EPT_Taxi") then
			if veh.controller then
				veh.controller.m_TaxiData = veh
				veh.controller:triggerEvent("showPublicTransportTaxiGUI", true, player)
			end
		end
	end
end

function PublicTransport:createTaxiSign(veh)
	if veh then
		self.m_TaxiSigns[veh] = createObject(1853, veh:getPosition())
		self.m_TaxiSigns[veh]:attach(veh, 0, -0.23, 0.9175)
	end
end

function PublicTransport:onVehicleStartEnter(veh, player, seat)
	if seat > 0 and not veh:getOccupant(0) then
		if veh:getModel() ~= 437 and veh:getModel() ~= 409  then -- as EPT gets more taxi models, it is easier to just exclude Buses and Stretch Limos
			cancelEvent()
			player:sendError(_("Es sitzt kein %s.", player, veh:getModel() == 487 and "Pilot im Helikopter" or "Fahrer im Taxi"))
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
		if veh:getModel() ~= 437 and veh:getModel() ~= 409  then -- as EPT gets more taxi models, it is easier to just exclude Buses and Stretch Limos
			player:triggerEvent("hideTaxoMeter")
			if veh:getModel() == 420 or veh:getModel() == 438 then
				veh:setTaxiLightOn(false)
			end
			player.m_TaxiData = nil
		elseif veh:getModel() == 437 then
			self:stopBusTour_Driver(player)
		end
	else
		self:endTaxiDrive(player)
	end
end

function PublicTransport:startTaxiDrive(veh, customer, isFree)
	self.m_TaxiCustomer[customer] = {}
	self.m_TaxiCustomer[customer]["customer"] = customer
	self.m_TaxiCustomer[customer]["vehicle"] = veh
	self.m_TaxiCustomer[customer]["driver"] = veh:getOccupant(0)
	self.m_TaxiCustomer[customer]["driverName"] = veh:getOccupant(0):getName()
	self.m_TaxiCustomer[customer]["startMileage"] = veh:getMileage()
	self.m_TaxiCustomer[customer]["diff"] = 0
	self.m_TaxiCustomer[customer]["price"] = 0
	self.m_TaxiCustomer[customer]["isFree"] = isFree
	self.m_TaxiCustomer[customer]["timer"] = setTimer(self.m_TaxoMeter, 1000, 0, customer)
	customer:triggerEvent("showTaxoMeter")
	customer:triggerEvent("showPublicTransportTaxiGUI")
	--triggerClientEvent(self.m_TaxiCustomer[customer]["driver"], "showTaxoMeter", self.m_TaxiCustomer[customer]["driver"])
end

function PublicTransport:endTaxiDrive(customer)
	if self.m_TaxiCustomer[customer] then
		local driver = self.m_TaxiCustomer[customer]["driver"]
		local driverName = self.m_TaxiCustomer[customer]["driverName"]
		local price = self.m_TaxiCustomer[customer]["price"]
		local vehicle = self.m_TaxiCustomer[customer]["vehicle"]
		if price > customer:getBankMoney() then price = customer:getBankMoney() end
		customer:transferBankMoney(self.m_BankAccountServer, price, "Public Transport Taxi", "Company", "Taxi")
		customer:sendInfo(_("Du bist aus dem Taxi ausgestiegen! Die Fahrt hat dich %d$ gekostet!", customer, price))
		local priceForEPT = price*2
		if priceForEPT > 0 then 
			if not customer:getCompany() or customer:getCompany():getId() ~= CompanyStaticId.EPT then
				self.m_BankAccountServer:transferMoney({self, nil, true}, priceForEPT, ("Taxifahrt von %s mit %s"):format(driverName, customer:getName()), "Company", "Taxi")
			end
		end
		self:addLog(driver, "Taxi", (" hat %s gefahren (+%s)"):format(customer:getName(), toMoneyString(priceForEPT)))
		
		if isElement(driver) then 
			driver:sendInfo(_("Der Spieler %s ist ausgestiegen! Die Fahrt hat dir %d$ eingebracht!", driver, customer:getName(), price))
			self.m_BankAccountServer:transferMoney(driver, price, "Public Transport Taxi", "Company", "Taxi")
		end

		killTimer(self.m_TaxiCustomer[customer]["timer"])
		if self.m_TaxiCustomer[customer]["blip"] then delete(self.m_TaxiCustomer[customer]["blip"]) end
		self.m_TaxiCustomer[customer] = nil
		customer:triggerEvent("hideTaxoMeter")
		self:updateDriverTaxometer(vehicle, driver)
	end
end

function PublicTransport:updateTaxometer(customer)
	if self.m_TaxiCustomer[customer] and isElement(customer) and self.m_TaxiCustomer[customer]["driver"] and isElement(self.m_TaxiCustomer[customer]["driver"]) then
		self.m_TaxiCustomer[customer]["diff"] = (self.m_TaxiCustomer[customer]["vehicle"]:getMileage() - self.m_TaxiCustomer[customer]["startMileage"])/1000
		if not self.m_TaxiCustomer[customer]["isFree"] then
			self.m_TaxiCustomer[customer]["price"] = math.floor(self.m_TaxiCustomer[customer]["diff"] * TAXI_PRICE_PER_KM)
		end
		customer:triggerEvent("syncTaxoMeter", self.m_TaxiCustomer[customer]["diff"], self.m_TaxiCustomer[customer]["price"])

		if customer:getBankMoney() < self.m_TaxiCustomer[customer]["price"] and not self.m_TaxiCustomer[customer]["moneyWarningSent"] then
			self.m_TaxiCustomer[customer]["moneyWarningSent"] = true
			customer:sendWarning(_("Du hast nicht mehr genügend Geld dabei!", customer))
			self.m_TaxiCustomer[customer]["driver"]:sendWarning(_("Der Spieler hat nicht mehr genügend Geld dabei!", customer))
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
	if isElement(driver) then
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

function PublicTransport:Event_OnTaxiDriverModeChange(customer, withTaxometer)
	if not client.m_TaxiData or client.m_TaxiData ~= client.vehicle then return client:sendError(_("Du musst im Taxi sitzen!", client)) end
	if not customer.vehicle or customer.vehicle ~= client.m_TaxiData then return client:sendError(_("Der Spieler sitzt nicht mehr im Taxi!", client)) end
	self:startTaxiDrive(client.m_TaxiData, customer, not withTaxometer)
end

function PublicTransport:Event_setTargetFromMap(posX, posY)
	if self.m_TaxiCustomer[client] and self.m_TaxiCustomer[client]["driver"] then
		local driver = self.m_TaxiCustomer[client]["driver"]
		driver:sendInfo(_("Der Kunde %s hat sein Ziel auf der Karte markiert! Ziel: %s/%s", driver, client:getName(), getZoneName(posX, posY, 0), getZoneName(posX, posY, 0, true)))
		client:sendInfo(_("Du hast dein Ziel auf der Karte markiert! Ziel: %s/%s", client, getZoneName(posX, posY, 0), getZoneName(posX, posY, 0, true)))
		driver:startNavigationTo(Vector3(posX, posY, 0))

		self.m_TaxiCustomer[client]["blip"] = Blip:new("Marker.png", posX, posY, driver, 10000, {50,200, 50})
	end
end

function PublicTransport:Event_sendTargetTellMessage(posX, posY)
	local driver = self.m_TaxiCustomer[client]["driver"]
	if driver then
		driver:sendInfo(_("Der Kunde %s wird dir sein Ziel mitteilen!", driver, source:getName()))
		client:sendInfo(_("Bitte nenne dem Fahrer %s dein Ziel", client, driver:getName()))
	end
end

function PublicTransport:Event_OnTaxiLightChange()
	if not client.vehicle then return false end
	client.vehicle:setTaxiLightOn(not client.vehicle:isTaxiLightOn())
end

function PublicTransport:Event_changeBusDutyState(state, arg, arg2) -- from clientside mouse menu
	if not client.vehicle then return end
	if state == "dutyLine" then
		self:startBusTour(client.vehicle, client, arg, arg2)
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
	if player.Bus_Statistics then
		self:addLog(player, "Bus", (" hat Linie %d bedient (%s Stationen, +%s$)!"):format(player.Bus_Statistics.line, player.Bus_Statistics.stations, player.Bus_Statistics.money))
		player.Bus_Statistics = nil
	end
	player:setPublicSync("EPT:BusDuty", false)
end

function PublicTransport:startBusTour_Driver(player, nextStation, line)
	if player.Bus_Blip then
		delete(player.Bus_Blip)
	end
	if not nextStation or not self.m_BusStops[nextStation] then
		player:sendShortMessage(_("Dieser Bus hat keine Linie mehr - Wenn du weißt, was zuvor mit dem Bus passiert ist (z.B. wenn der Busfahrer Offline oder Offduty gegangen ist), dann melde dies bitte im Bugtracker", player))
	else
		local x, y, z = getElementPosition(self.m_BusStops[self.m_Lines[line][nextStation]].object)
		player.Bus_Blip = Blip:new("Marker.png", x, y, player, 9999, PublicTransport.ms_BusLineData[line].color)
		player.Bus_Blip:setZ(z)
		player.Bus_Blip:setDisplayText("Bushaltestelle")
		player:setPublicSync("EPT:BusDuty", true)
		player.Bus_Statistics = {
			line = line,
			money = 0,
			stations = 0,
		}
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
	if vehicle.Bus_NextStop then
		if self.m_BusStops[vehicle.Bus_NextStop] then
			if self.m_BusStops[vehicle.Bus_NextStop].marker then
				if isElement(self.m_BusStops[vehicle.Bus_NextStop].marker[vehicle]) then
					destroyElement(self.m_BusStops[vehicle.Bus_NextStop].marker[vehicle])
				end
			end
		end
	end
	for i,v in pairs(vehicle:getOccupants()) do
		if v.vehicleSeat ~= 0 then
			v:removeFromVehicle()
			v:sendWarning(_("Dieser Bus ist nicht mehr auf dieser Route im Dienst.", v))
		end
	end
	vehicle.Bus_OnDuty = nil
	vehicle.Bus_LastStop = nil
	vehicle.Bus_NextStop = nil
	vehicle.Bus_Line = nil
	vehicle:setData("EPT_bus_duty", false, true)
	self.m_ActiveBusVehicles[vehicle] = nil
	vehicle:setColor(companyColors[4].r, companyColors[4].g, companyColors[4].b, companyColors[4].r, companyColors[4].g, companyColors[4].b)

	triggerClientEvent("busReachNextStop", root, vehicle, "Ausser Dienst", false)
end

function PublicTransport:startBusTour(vehicle, player, line, backwards)
	if vehicle.Bus_OnDuty and line == vehicle.Bus_Line then return false end
	if self.m_Lines[line] then -- otherwise special service
		if vehicle.Bus_Line then -- lines changed, so notify that the old bus route no longer recieves service
			self:stopBusTour(vehicle, player)
		end
		vehicle.Bus_OnDuty = true
		vehicle.Bus_NextStop = 1

		if backwards then --search for the same station but in opposite direction
			local firstName = self.m_BusStops[self.m_Lines[line][1]].name -- name of the first station
			for i = 2, #self.m_Lines[line] do
				if self.m_BusStops[self.m_Lines[line][i]].name == firstName then
					vehicle.Bus_NextStop = i
					break
				end
			end
		end

		local nextStop = self.m_BusStops[self.m_Lines[line][vehicle.Bus_NextStop]]
		local marker = createColSphere(nextStop.markerPos, 5)
		addEventHandler("onColShapeHit", marker, self.m_FuncStopHit)
		nextStop.marker[vehicle] = marker

		vehicle.Bus_Line = line
		vehicle:setData("EPT_bus_duty", line, true)
		vehicle:setColor(companyColors[4].r, companyColors[4].g, companyColors[4].b, unpack(PublicTransport.ms_BusLineData[line].color))
		triggerClientEvent("busReachNextStop", root, player.vehicle, nextStop.name, false, line)
		player:giveAchievement(17)
		self:startBusTour_Driver(player, vehicle.Bus_NextStop, line) 
		self.m_ActiveBusVehicles[vehicle] = line
	else
		vehicle.Bus_OnDuty = true
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
		if not stopId or not self.m_BusStops[stopId] or self.m_BusStops[stopId].marker[vehicle] ~= source then
			-- Show an error message maybe?
			return
		end

		if vehicle:getSpeed() > 30 then 
			player:sendError(_("Du fährst zu schnell!", player))
			return false 
		end

		-- Give the player some money and switch to the next bus stop
		if lastId then 
			local dist = math.round(getDistanceBetweenPoints3D(self.m_BusStops[lastId].object.position, self.m_BusStops[stopId].object.position) * (math.random(998, 1002)/1000))
	
			player:giveCombinedReward("Busfahrer-Gehalt", {
				money = {
					mode = "give",
					bank = true,
					amount = math.round(490 * (dist/1000)),-- 340 / km
					toOrFrom = self.m_BankAccountServer,
					category = "Company",
					subcategory = "Bus"
				},
				points = math.round(5 * (dist/1000)),--5 / km
			})
			self.m_BankAccountServer:transferMoney({self, nil, true}, math.round(490 * (dist/1000)), ("Busfahrt Linie %d von %s"):format(line, player:getName()), "Company", "Bus")
			player.Bus_Statistics.money = player.Bus_Statistics.money + math.round(490 * (dist/1000))
			player.Bus_Statistics.stations = player.Bus_Statistics.stations + 1
		end

		local newDestinationId = self.m_Lines[line][destinationId + 1] and destinationId + 1 or 1
		vehicle.Bus_NextStop = newDestinationId
		local nextStopId = self.m_Lines[line][newDestinationId]
		local x, y, z = getElementPosition(self.m_BusStops[nextStopId].object)
		delete(player.Bus_Blip)
		player.Bus_Blip = Blip:new("Marker.png", x, y, player, 9999, PublicTransport.ms_BusLineData[line].color)
		player.Bus_Blip:setZ(z)
		player.Bus_Blip:setDisplayText("Bushaltestelle")

		if isElement(self.m_BusStops[stopId].marker[vehicle]) then
			destroyElement(self.m_BusStops[stopId].marker[vehicle])

			local marker = createColSphere(self.m_BusStops[nextStopId].markerPos, 5)
			addEventHandler("onColShapeHit", marker, self.m_FuncStopHit)
			self.m_BusStops[nextStopId].marker[vehicle] = marker
		else
			player:sendError(_("Interner Fehler: Bitte Linie neu starten", player))
		end

		-- Tell other players that we reached a bus stop (to adjust the bus display labels)
		local nextNewDestinationId = self.m_Lines[line][newDestinationId + 1] and newDestinationId + 1 or 1
		local nextNewStopId = self.m_Lines[line][nextNewDestinationId] -- get the stop two stations ahead to determine if next stop is an end station
		triggerClientEvent("busReachNextStop", root, vehicle, self.m_BusStops[nextStopId].name, self.m_BusStops[nextNewStopId].name == self.m_BusStops[stopId].name, line)

		vehicle.Bus_LastStop = stopId
		vehicle:setData("EPT:Bus_LastStopName", self.m_BusStops[stopId].name, true)
		vehicle:setData("EPT:Bus_NextStopName", self.m_BusStops[nextStopId].name, true)
	end
end
