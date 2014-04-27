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
	addEvent("vehicleBuy", true)
	addEvent("vehicleLock", true)
	addEvent("vehicleRequestKeys", true)
	addEvent("vehicleAddKey", true)
	addEvent("vehicleRemoveKey", true)
	addEvent("vehicleRepair", true)
	addEvent("vehicleRespawn", true)
	addEvent("vehicleDelete", true)
	addEventHandler("vehicleBuy", root, bind(self.Event_vehicleBuy, self))
	addEventHandler("vehicleLock", root, bind(self.Event_vehicleLock, self))
	addEventHandler("vehicleRequestKeys", root, bind(self.Event_vehicleRequestKeys, self))
	addEventHandler("vehicleAddKey", root, bind(self.Event_vehicleAddKey, self))
	addEventHandler("vehicleRemoveKey", root, bind(self.Event_vehicleRemoveKey, self))
	addEventHandler("vehicleRepair", root, bind(self.Event_vehicleRepair, self))
	addEventHandler("vehicleRespawn", root, bind(self.Event_vehicleRespawn, self))
	addEventHandler("vehicleDelete", root, bind(self.Event_vehicleDelete, self))
	
	outputServerLog("Loading vehicles...")
	local result = sql:queryFetch("SELECT * FROM ??_vehicles", sql:getPrefix())
	for i, rowData in ipairs(result) do
		local vehicle = createVehicle(rowData.Model, rowData.PosX, rowData.PosY, rowData.PosZ, 0, 0, rowData.Rotation)
		enew(vehicle, PermanentVehicle, tonumber(rowData.Id), rowData.Owner, fromJSON(rowData.Keys), rowData.Color, rowData.Health, toboolean(rowData.IsInGarage))
		self:addRef(vehicle)
	end
	
	VehicleManager.sPulse:registerHandler(bind(VehicleManager.removeUnusedVehicles, self))
end

function VehicleManager:destructor()
	for ownerId, vehicles in pairs(self.m_Vehicles) do
		for k, vehicle in ipairs(vehicles) do
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


function VehicleManager:Event_vehicleBuy(vehicleModel, shop)
	if not VEHICLESHOPS[shop] then return end
	if not VEHICLESHOPS[shop].Vehicles then return end
	
	local price = VEHICLESHOPS[shop].Vehicles[vehicleModel]
	if not price then return end
	
	if client:getMoney() < price then
		client:sendMessage(_("You do not have enough money to buy this vehicle!", client), 255, 0, 0)
		return
	end
	
	local spawnX, spawnY, spawnZ, rotation = unpack(VEHICLESHOPS[shop].Spawn)
	local vehicle = PermanentVehicle.create(client:getId(), vehicleModel, spawnX, spawnY, spawnZ, rotation)
	if vehicle then
		client:takeMoney(price)
		warpPedIntoVehicle(client, vehicle)
		client:triggerEvent("vehicleBought")
	else
		client:sendMessage(_("Failed to create the vehicle. Please notify an admin!", client), 255, 0, 0)
	end
end

function VehicleManager:Event_vehicleLock()
	if not source or not isElement(source) then return end
	
	if not instanceof(source, Vehicle, true) then
		return
	end
	
	if not source:hasKey(client) and client:getRank() <= RANK.User then
		client:sendError(_("You do not own a key for this vehicle", client))
		return
	end
	
	source:setLocked(not source:isLocked())
end

function VehicleManager:Event_vehicleRequestKeys()
	if not instanceof(source, Vehicle, true) then
		return
	end
	
	local names = source:getKeyNameList()
	triggerClientEvent(client, "vehicleKeysRetrieve", source, names)
end

function VehicleManager:Event_vehicleAddKey(player)
	if not player or not isElement(player) then return end
	if not player:isLoggedIn() then return end
	
	if not instanceof(source, Vehicle, true) then
		return
	end
	
	if not source:isPermanent() then
		client:sendError(_("Nur nicht-permanente Fahrzeuge können Schlüssel haben", client))
		return
	end
	
	if source:getOwner() ~= client:getId() then
		client:sendWarning(_("You are not the owner of this vehicle!", client))
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
		client:sendWarning(_("You are not the owner of this vehicle!", client))
		return
	end
	
	source:removeKey(characterId)
	
	-- Todo: Tell the client that we removed the key
end

function VehicleManager:Event_vehicleRepair()
	if client:getRank() < RANK.Moderator then
		-- Todo: Report cheat attempt
		return
	end
	
	fixVehicle(source)
end

function VehicleManager:Event_vehicleRespawn()
	if source:getOwner() ~= client:getId() then
		client:sendWarning(_("You are not the owner of this vehicle!", client))
		return
	end
	if source:isInGarage() then
		client:sendError(_("Dieses Fahrzeug ist bereits in der Garage!", client))
		return
	end
	if client:getMoney() < 100 then
		client:sendWarning(_("You do not have enough money!", client))
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
end

function VehicleManager:Event_vehicleDelete()
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
