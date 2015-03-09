-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleManager.lua
-- *  PURPOSE:     Vehicle manager class
-- *
-- ****************************************************************************
VehicleManager = inherit(Singleton)
VehicleManager.sPulse = TimedPulse:new(5*1000--[[*60*]])

function VehicleManager:constructor()
	self.m_Vehicles = {}
	self.m_TemporaryVehicles = {}

	-- Add events
	addRemoteEvents{"vehicleBuy", "vehicleLock", "vehicleRequestKeys", "vehicleAddKey", "vehicleRemoveKey", "vehicleRepair", "vehicleRespawn", "vehicleDelete", "vehicleSell", "vehicleRequestInfo", "vehicleUpgradeGarage", "vehicleHotwire", "vehicleEmpty"}
	addEventHandler("vehicleBuy", root, bind(self.Event_vehicleBuy, self))
	addEventHandler("vehicleLock", root, bind(self.Event_vehicleLock, self))
	addEventHandler("vehicleRequestKeys", root, bind(self.Event_vehicleRequestKeys, self))
	addEventHandler("vehicleAddKey", root, bind(self.Event_vehicleAddKey, self))
	addEventHandler("vehicleRemoveKey", root, bind(self.Event_vehicleRemoveKey, self))
	addEventHandler("vehicleRepair", root, bind(self.Event_vehicleRepair, self))
	addEventHandler("vehicleRespawn", root, bind(self.Event_vehicleRespawn, self))
	addEventHandler("vehicleDelete", root, bind(self.Event_vehicleDelete, self))
	addEventHandler("vehicleSell", root, bind(self.Event_vehicleSell, self))
	addEventHandler("vehicleRequestInfo", root, bind(self.Event_vehicleRequestInfo, self))
	addEventHandler("vehicleUpgradeGarage", root, bind(self.Event_vehicleUpgradeGarage, self))
	addEventHandler("vehicleHotwire", root, bind(self.Event_vehicleHotwire, self))
	addEventHandler("vehicleEmpty", root, bind(self.Event_vehicleEmpty, self))
	
	-- Prevent the engine from being turned on
	addEventHandler("onVehicleEnter", root,
		function(player, seat, jackingPlayer)
			if seat == 0 then
				self:checkVehicle(source)
				
				setVehicleEngineState(source, source:getEngineState())
				player:triggerEvent("vehicleFuelSync", source:getFuel())
				
				local vehicleType = source:getVehicleType()
				if (vehicleType == "Plane" or vehicleType == "Helicopter") and not player:hasPilotsLicense() then
					player:removeFromVehicle(source)
					player:setPosition(source.matrix:transformPosition(-1.5, 5, 0))
					player:sendShortMessage(_("Du hast keinen Flugschein!", player))
				end
			end
		end
	)
	
	outputServerLog("Loading vehicles...")
	local result = sql:queryFetch("SELECT * FROM ??_vehicles", sql:getPrefix())
	for i, rowData in ipairs(result) do
		local vehicle = createVehicle(rowData.Model, rowData.PosX, rowData.PosY, rowData.PosZ, 0, 0, rowData.Rotation)
		enew(vehicle, PermanentVehicle, tonumber(rowData.Id), rowData.Owner, fromJSON(rowData.Keys or "[]"), rowData.Color, rowData.Health, toboolean(rowData.IsInGarage))
		self:addRef(vehicle, false)
	end
	
	VehicleManager.sPulse:registerHandler(bind(VehicleManager.removeUnusedVehicles, self))
	
	setTimer(bind(self.updateFuelOfPermanentVehicles, self), 60*1000, 0)
end

function VehicleManager:destructor()
	for ownerId, vehicles in pairs(self.m_Vehicles) do
		for k, vehicle in pairs(vehicles) do
			vehicle:save()
		end
	end
	outputServerLog("Saved vehicles")
end

function VehicleManager:addRef(vehicle, isTemp)
	if isTemp then
		self.m_TemporaryVehicles[#self.m_TemporaryVehicles+1] = vehicle
		return
	end

	local ownerId = vehicle:getOwner()
	assert(ownerId, "Bad owner specified")
	
	if not self.m_Vehicles[ownerId] then
		self.m_Vehicles[ownerId] = {}
	end
	
	table.insert(self.m_Vehicles[ownerId], vehicle)
end

function VehicleManager:removeRef(vehicle, isTemp)
	if isTemp then
		local idx = table.find(self.m_TemporaryVehicles, vehicle)
		if idx then
			table.remove(self.m_TemporaryVehicles, idx)
		end
		return
	end

	local ownerId = vehicle:getOwner()
	assert(ownerId, "Bad owner specified")
	
	if self.m_Vehicles[ownerId] then
		local idx = table.find(self.m_Vehicles[ownerId], vehicle)
		if idx then
			table.remove(self.m_Vehicles[ownerId], idx)
		end
	end
end

function VehicleManager:removeUnusedVehicles()
	-- ToDo: Lateron, do not loop through all vehicles
	for ownerid, data in pairs(self.m_Vehicles) do 
		for k, vehicle in pairs(data) do
			if vehicle:getLastUseTime() < getTickCount() - 30*1000*60 then
				vehicle:respawn()
			end
		end
	end
	
	for k, vehicle in pairs(self.m_TemporaryVehicles) do
		if vehicle:getLastUseTime() < getTickCount() - 5*1000 then
			vehicle:respawn()
		end	
	end
end

function VehicleManager:getPlayerVehicles(player)
	if type(player) == "userdata" then
		player = player:getId()
	end
	return self.m_Vehicles[player] or {}
end

function VehicleManager:updateFuelOfPermanentVehicles()
	for k, player in pairs(getElementsByType("player")) do
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle and vehicle.getFuel and vehicle:getEngineState() then
			vehicle:setFuel(vehicle:getFuel() - 0.5)
		end
	end
end

function VehicleManager:checkVehicle(vehicle)
	-- Lightweight instanceof(vehicle, Vehicle)
	if not vehicle.toggleLight then
		-- Make a temporary vehicle if vehicle is not yet instance of any class
		enew(vehicle, TemporaryVehicle)
	end
end


function VehicleManager:Event_vehicleBuy(vehicleModel, shop)
	if not VEHICLESHOPS[shop] then return end
	if not VEHICLESHOPS[shop].Vehicles then return end
	
	local price = VEHICLESHOPS[shop].Vehicles[vehicleModel]
	if not price then return end
	
	if client:getMoney() < price then
		client:sendError(_("Du hast nicht genügend Geld!", client), 255, 0, 0)
		return
	end
	
	local spawnX, spawnY, spawnZ, rotation = unpack(VEHICLESHOPS[shop].Spawn)
	local vehicle = PermanentVehicle.create(client, vehicleModel, spawnX, spawnY, spawnZ, rotation)
	if vehicle then
		client:takeMoney(price)
		warpPedIntoVehicle(client, vehicle)
		client:triggerEvent("vehicleBought")
	else
		client:sendMessage(_("Fehler beim Erstellen des Fahrzeugs. Bitte benachrichtige einen Admin!", client), 255, 0, 0)
	end
end

function VehicleManager:Event_vehicleLock()
	if not source or not isElement(source) then return end
	self:checkVehicle(source)
	
	if not source:hasKey(client) and client:getRank() <= RANK.User then
		client:sendError(_("Du hast keinen Schlüssel für dieses Fahrzeug", client))
		return
	end
	
	source:setLocked(not source:isLocked())
end

function VehicleManager:Event_vehicleRequestKeys()
	if not instanceof(source, PermanentVehicle, true) then
		triggerClientEvent(client, "vehicleKeysRetrieve", source, false)
		return
	end
	
	local names = source:getKeyNameList()
	triggerClientEvent(client, "vehicleKeysRetrieve", source, names)
end

function VehicleManager:Event_vehicleAddKey(player)
	if not player or not isElement(player) then return end
	if not player:isLoggedIn() then return end
	if not instanceof(source, PermanentVehicle, true) then return end
	
	if not source:isPermanent() then
		client:sendError(_("Nur nicht-permanente Fahrzeuge können Schlüssel haben", client))
		return
	end
	
	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end
	
	-- Finally, add the key
	source:addKey(player)
	
	-- Todo: Tell the client that we added a new key
end

function VehicleManager:Event_vehicleRemoveKey(characterId)
	if not source:hasKey(characterId) then
		client:sendWarning(_("The specified player is not in possession of a key", client))
		return
	end
	
	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end
	
	source:removeKey(characterId)
	
	-- Todo: Tell the client that we removed the key
end

function VehicleManager:Event_vehicleRepair()
	if client:getRank() < RANK.Moderator then
		AntiCheat:getSingleton():report(client, "DisallowedEvent", CheatSeverity.High)
		return
	end
	
	fixVehicle(source)
end

function VehicleManager:Event_vehicleRespawn()
	if not instanceof(source, PermanentVehicle, true) then return end

	if source:getOwner() ~= client:getId() then
		client:sendError(_("Du bist nicht der Besitzer dieses Fahrzeugs!", client))
		return
	end
	if client:getMoney() < 100 then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end
	if source:isInGarage() then
		fixVehicle(source)
		client:takeMoney(100)
		client:sendShortMessage(_("Fahrzeug repariert!", client))
		return
	end
	local occupants = getVehicleOccupants(source)
	for seat, player in pairs(occupants) do
		removePedFromVehicle(player)
	end
	
	-- Todo: Check if slot limit is reached
	source:respawn()
	client:takeMoney(100)
	fixVehicle(source)
	client:sendShortMessage(_("Dein Fahrzeug wurde erfolgreich in der Garage respawnt!", client))
	
	-- Refresh location in the self menu
	local vehicles = {}
	for k, vehicle in pairs(self:getPlayerVehicles(client)) do
		vehicles[vehicle:getId()] = {vehicle, vehicle:isInGarage()}
	end
	client:triggerEvent("vehicleRetrieveInfo", vehicles)
end

function VehicleManager:Event_vehicleDelete()
	self:checkVehicle(source)
	
	if client:getRank() < RANK.Moderator then
		-- Todo: Report cheat attempt
		return
	end
	
	if source:isPermanent() then
		source:purge()
	else
		destroyElement(source)
	end
end

function VehicleManager:Event_vehicleSell()
	if not instanceof(source, PermanentVehicle, true) then return end
	if source:getOwner() ~= client:getId() then	return end
	
	-- Search for price in vehicle shops table
	local getPrice = function(model)
		for shopName, shopInfo in pairs(VEHICLESHOPS) do
			local price = shopInfo.Vehicles[model]
			if price then
				return price
			end
		end
		return false
	end
	
	local price = getPrice(source:getModel())
	if price then
		source:purge()
		client:giveMoney(math.floor(price * 0.75))
	end
end

function VehicleManager:Event_vehicleRequestInfo()
	local vehicles = {}
	for k, vehicle in pairs(self:getPlayerVehicles(client)) do
		vehicles[vehicle:getId()] = {vehicle, vehicle:isInGarage()}
	end
	
	client:triggerEvent("vehicleRetrieveInfo", vehicles, client:getGarageType())
end

function VehicleManager:Event_vehicleUpgradeGarage()
	local UpgradeToPrices = {[2] = 100000, [3] = 500000}
	local currentGarage = client:getGarageType()
	if currentGarage > 0 then
		local price = UpgradeToPrices[currentGarage + 1]
		if price then
			if client:getMoney() >= price then
				client:takeMoney(price)
				client:setGarageType(currentGarage + 1)
				client:triggerEvent("vehicleRetrieveInfo", false, client:getGarageType())
			else
				client:sendError(_("Du hast nicht genügend Geld, um deine Garage zu upgraden", client))
			end
		else
			client:sendError(_("Deine Garage ist bereits auf dem höchsten Level", client))
		end
	else
		client:sendError(_("Du besitzt keine gültige Garage!", client))
	end
end

function VehicleManager:Event_vehicleHotwire()
	if client:getInventory():hasItem(ITEM_HOTWIREKIT) then
		client:sendInfoTimeout(_("Schließe kurz...", client), 20000)
		client:reportCrime(Crime.Hotwire)
		client:giveKarma(-0.1)
		
		setTimer(
			function(source)
				if isElement(source) then
					source:setEngineState(true)
				end
			end, 20000, 1, source
		)
	else
		client:sendWarning(_("Hierfür brauchst du ein Kurzschließkit!", client))
	end
end

function VehicleManager:Event_vehicleEmpty()
	if source:hasKey(client) or client:getRank() >= RANK.Moderator then
		for seat, occupant in pairs(getVehicleOccupants(source) or {}) do
			if seat ~= 0 then
				removePedFromVehicle(occupant)
			end
		end
		client:sendShortMessage(_("Mitfahrer wurden herausgeworfen!", client))
	else
		client:sendError(_("Hierzu hast du keine Berechtigungen!", client))
	end
end
