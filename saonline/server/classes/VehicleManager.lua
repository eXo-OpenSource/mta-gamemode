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
	addEventHandler("vehicleBuy", root, bind(self.Event_vehicleBuy, self))
	
	local result = sql:queryFetch("SELECT * FROM ??_vehicles", sql:getPrefix())
	outputServerLog(("Loading %d vehicles"):format(#result))
	for i, rowData in ipairs(result) do
		local vehicle = createVehicle(rowData.Model, rowData.PosX, rowData.PosY, rowData.PosZ, 0, 0, rowData.Rotation)
		enew(vehicle, Vehicle, tonumber(rowData.Id), rowData.Owner, fromJSON(rowData.Keys))
		table.insert(self.m_Vehicles, vehicle)
	end
end

function VehicleManager:destructor()
	for k, vehicle in ipairs(self.m_Vehicles) do
		vehicle:save()
	end
end

function VehicleManager:Event_vehicleBuy(vehicleModel, shop)
	if not VEHICLESHOPS[shop] then return end
	if not VEHICLESHOPS[shop].Vehicles then return end
	
	local price = VEHICLESHOPS[shop].Vehicles[vehicleModel]
	if not price then return end
	
	if getPlayerMoney(client) < price then
		client:sendMessage(_("You do not have enough money to buy this vehicle!", client), 255, 0, 0)
		return
	end
	
	local spawnX, spawnY, spawnZ = unpack(VEHICLESHOPS[shop].Spawn)
	local vehicle = Vehicle.create(client:getCharacterId(), vehicleModel, spawnX, spawnY, spawnZ, 0)
	if vehicle then
		takePlayerMoney(client, price)
		warpPedIntoVehicle(client, vehicle)
		client:triggerEvent("vehicleBought")
	else
		client:sendMessage(_("Failed to create the vehicle. Please notify an admin!", client), 255, 0, 0)
	end
end
