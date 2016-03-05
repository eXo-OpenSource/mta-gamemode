PublicTransport = inherit(Company)
local TAXI_PRICE_PER_KM = 20

function PublicTransport:constructor()
	outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))
	self.m_TaxiCustomer = {}
	self.m_TaxoMeter = bind(self.updateTaxometer, self)
	Player.getQuitHook():register(bind(self.Event_onPlayerQuit, self))
	addRemoteEvents{"publicTransportSetTargetMap", "publicTransportSetTargetTell"}
	addEventHandler("publicTransportSetTargetMap", root, bind(self.Event_setTargetFromMap))
	addEventHandler("publicTransportSetTargetTell", root, bind(self.Event_sendTargetTellMessage))
end

function PublicTransport:destuctor()

end

function PublicTransport:onVehiceEnter(veh, player, seat)
	if seat == 0 then
		triggerClientEvent(player, "showTaxoMeter", player)
	else
		self:startTaxiDrive(veh, player)
		triggerClientEvent(player, "showPublicTransportTaxiGUI", player)
	end
end

function PublicTransport:onVehiceStartEnter(veh, player, seat)
	if seat > 0 and not veh:getOccupant(0) then
		cancelEvent()
		player:sendError(_("Es sitzt kein Fahrer im Taxi", player))
	end
end

function PublicTransport:onVehiceExit(veh, player, seat)
	if seat == 0 then
		triggerClientEvent(player, "hideTaxoMeter", player)
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
		customer:takeMoney(price)
		driver:giveMoney(price)
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
