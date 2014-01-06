-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleManager.lua
-- *  PURPOSE:     Vehicle manager class
-- *
-- ****************************************************************************
VehicleManager = inherit(Singleton)

function VehicleManager:constructor()
	self.m_Vehicles = {}

	-- Add events
	addEvent("vehicleBuy", true)
	addEvent("vehicleLock", true)
	addEvent("vehicleRequestKeys", true)
	addEvent("vehicleAddKey", true)
	addEvent("vehicleRemoveKey", true)
	addEventHandler("vehicleBuy", root, bind(self.Event_vehicleBuy, self))
	addEventHandler("vehicleLock", root, bind(self.Event_vehicleLock, self))
	addEventHandler("vehicleRequestKeys", root, bind(self.Event_vehicleRequestKeys, self))
	addEventHandler("vehicleAddKey", root, bind(self.Event_vehicleAddKey, self))
	addEventHandler("vehicleRemoveKey", root, bind(self.Event_vehicleRemoveKey, self))
	
	local result = sql:queryFetch("SELECT * FROM ??_vehicles", sql:getPrefix())
	outputServerLog(("Loading %d vehicles"):format(#result))
	for i, rowData in ipairs(result) do
		local vehicle = createVehicle(rowData.Model, rowData.PosX, rowData.PosY, rowData.PosZ, 0, 0, rowData.Rotation)
		enew(vehicle, Vehicle, tonumber(rowData.Id), rowData.Owner, fromJSON(rowData.Keys), rowData.Color, rowData.Health)
		table.insert(self.m_Vehicles, vehicle)
	end
end

function VehicleManager:destructor()
	for k, vehicle in ipairs(self.m_Vehicles) do
		vehicle:save()
	end
	outputServerLog("Saved "..#self.m_Vehicles.." vehicles")
end

function VehicleManager:addRef(vehicle)
	table.insert(self.m_Vehicles, vehicle)
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
	local vehicle = Vehicle.create(client:getId(), vehicleModel, spawnX, spawnY, spawnZ, rotation)
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
	
	if not source:hasKey(client) then
		client:sendError(_"You do not own a key for this vehicle")
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
	
	if not instanceof(source, Vehicle, true) then
		return
	end
	
	if source:getOwner() ~= player:getId() then
		client:sendWarning(_("You are not the owner of this vehicle!", client))
		-- Todo: Tell the anticheat that we found a possible cheat attempt
		return
	end
	
	-- Finally, add the key
	source:addKey(player)
	
	-- Todo: Tell the client that we added a new key
end

function VehicleManager:Event_vehicleRemoveKey(characterId)
	if not source:hasKey(characterId) then
		client:sendWarning(_("The specified player is not in percession of a key", client))
		return
	end
	
	source:removeKey(characterId)
	
	-- Todo: Tell the client that we removed the key
end
