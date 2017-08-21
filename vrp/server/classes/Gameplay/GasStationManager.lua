-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
GasStationManager = inherit(Singleton)
GasStationManager.Shops = {}
addRemoteEvents{"gasStationTakeFuelNozzle", "gasStationRejectFuelNozzle", "gasStationStartTransaction", "gasStationConfirmTransaction"}

function GasStationManager:constructor()
	self.m_PendingTransaction = {}

	for _, station in pairs(GAS_STATIONS) do
		local instance = GasStation:new(station.stations, station.accessible, station.name)

		if station.name then
			GasStationManager.Shops[station.name] = instance
		end
	end

	PlayerManager:getSingleton():getQuitHook():register(bind(self.onPlayerQuit, self))

	addEventHandler("gasStationTakeFuelNozzle", root, bind(GasStationManager.takeFuelNozzle, self))
	addEventHandler("gasStationRejectFuelNozzle", root, bind(GasStationManager.rejectFuelNozzle, self))
	--addEventHandler("gasStationStartTransaction", root, bind(GasStationManager.startTransaction, self))
	addEventHandler("gasStationConfirmTransaction", root, bind(GasStationManager.confirmTransaction, self))
end

function GasStationManager:destructor()
end

function GasStationManager:onPlayerQuit(player)
	if isElement(player.gs_fuelNozzle) then
		player.gs_fuelNozzle:destroy()
	end
end

function GasStationManager:takeFuelNozzle(element)
	if GasStation.Map[element] then
		if isElement(client.gs_fuelNozzle) then
			GasStation.Map[element]:rejectFuelNozzle(client, element)
			return
		end

		GasStation.Map[element]:takeFuelNozzle(client, element)
	end
end

function GasStationManager:rejectFuelNozzle()
	local element = client.gs_usingFuelStation

	if GasStation.Map[element] then
		if isElement(client.gs_fuelNozzle) then
			GasStation.Map[element]:rejectFuelNozzle(client, element)
		end
	end
end

--[[function GasStationManager:startTransaction(vehicle, fuel, station)
	if GasStation.Map[station] then
		self.m_PendingTransaction[client] = {station = station, vehicle = vehicle, fuel = math.round(fuel)}
	end
end]]

function GasStationManager:confirmTransaction(vehicle, fuel, station)
	local station = GasStation.Map[station]
	if station then
		if instanceof(vehicle, PermanentVehicle, true) or instanceof(vehicle, GroupVehicle, true) or instanceof(vehicle, FactionVehicle, true) or instanceof(vehicle, CompanyVehicle, true) then
			local fuel = vehicle:getFuel() + fuel > 100 and math.floor(100 - vehicle:getFuel()) or math.floor(fuel)
			local price = math.floor(fuel * 2)

			if fuel == 0 then
				client:sendError("Dein Fahrzeug ist bereits vollgetankt!")
				return
			end

			if client:getMoney() >= price then
				client:takeMoney(price, "Tanken")
				vehicle:setFuel(vehicle:getFuel() + fuel)

				client:sendInfo(_("%s bedankt sich für deinen Einkauf!", client, station:getName()))
				client:triggerEvent("gasStationReset")

				if station:getShop() then
					station:getShop():giveMoney(price/2, "Betankung")
				end
			else
				client:sendError("Du hast nicht genügend Geld dabei!")
			end
		end
	end
end

-- accessible: {type, id} || type: 0 = all, 1 = faction, 2 = company || id = faction or company id (0 == state faction)
GAS_STATIONS = {
	{
		name = "Tankstelle Temple",
		stations = {
			{Vector3(1000.23, -937.42, 42.86), 8, 2},
			{Vector3(1006.91, -936.43, 42.86), 8, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "San Fierro Downtown",
		stations = {
			{Vector3(-1676.68, 419.11, 7.90), 223, 2},
			{Vector3(-1681.68, 413.94, 7.90), 223, 2},
			{Vector3(-1675.17, 407.36, 7.90), 223, 2},
			{Vector3(-1669.84, 412.59, 7.90), 223, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "San Fierro Juniper Hill",
		stations = {
			{Vector3(-2410.8994, 972, 46), 90, 2},
			{Vector3(-2410.8994, 979, 46), 90, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Angle Pine",
		stations = {
			{Vector3(-2246.67, -2559.59, 32.6), 243, 1},
			{Vector3(-2241.68, -2562.21, 32.6), 243, 1},
		},
		accessible =  {0, 0},
	},
	{
		name = "Tankstelle Dillimore",
		stations = {
			{Vector3(655.68, -569.92, 16.6), 90, 2},
			{Vector3(655.68, -559.91, 16.6), 90, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Tankstelle Flint County",
		stations = {
			{Vector3(-85.41, -1165.00, 2.9), 65, 2},
			{Vector3(-90.01, -1175.99, 2.81), 65, 2},
			{Vector3(-92.22, -1162.38, 3), 65, 2},
			{Vector3(-96.84, -1173.24, 3), 65, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "The Emerald Isle",
		stations = {
			{Vector3(2196.89, 2480, 11.5), 90, 2},
			{Vector3(2196.89, 2475, 11.5), 90, 2},
			{Vector3(2196.89, 2469.8, 11.5), 90, 2},
			{Vector3(2207.69, 2469.8, 11.5), 90, 2},
			{Vector3(2207.69, 2475, 11.5), 90, 2},
			{Vector3(2207.69, 2480, 11.5), 90, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Red Sands West",
		stations = {
			{Vector3(1596.2, 2193.7, 11.5), 0, 2},
			{Vector3(1596.1, 2204.5, 11.5), 0, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Spinybed",
		stations = {
			{Vector3(2147.64, 2753.28, 11.4), 0, 2},
			{Vector3(2147.63, 2742.5, 11.4), 0, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Las Venturas 2",
		stations = {
			{Vector3(2114.80, 925.53, 11.45), 0, 2},
			{Vector3(2114.8999, 914.72, 11.45), 0, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Valle Ocultado",
		stations = {
			{Vector3(-740.41, 2753.35, 47.7), 90, 1},
		},
		accessible =  {0, 0},
	},
	{
		name = "Tierra Roboda 2",
		stations = {
			{Vector3(-1328.1, 2680.2, 51), 354, 1},
			{Vector3(-1328.84, 2674.84, 51), 354, 1},
			{Vector3(-1327.72, 2685.76, 51), 354, 1},
			{Vector3(-1329.68, 2669.25, 51), 354, 1},
		},
		accessible =  {0, 0},
	},
	{
		name = "Idlewood",
		stations = {
			{Vector3(1941.7, -1776.6, 14.17), 90, 2},
			{Vector3(1941.7, -1769.4, 14.17), 90, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Fort Carson",
		stations = {
			{Vector3(68.1, 1221.3, 19.6), 252, 1},
			{Vector3(73.80, 1219.45, 19.6), 252, 1},
		},
		accessible =  {0, 0},
	},
	{
		name = "Whetstone",
		stations = {
			{Vector3(-1611.35, -2720.47, 49.4), 324, 1},
			{Vector3(-1607.80, -2716.16, 49.4), 324, 1},
			{Vector3(-1604.70, -2711.75, 49.4), 324, 1},
			{Vector3(-1601.41, -2707.17, 49.4), 324, 1},
		},
		accessible =  {0, 0},
	},
	{
		name = "Last Venturas East",
		stations = {
			{Vector3(2639.9, 1100.9, 11.5), 0, 2},
			{Vector3(2639.9, 1111.83, 11.5), 0, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Montegomery",
		stations = {
			{Vector3(1379.81, 460.5, 20.8), 155.5, 2},
			{Vector3(1384.36, 458.6, 20.8), 155.5, 2},
		},
		accessible =  {0, 0},
	},
	{
		name = "Bone County",
		stations = {
			{Vector3(624.06, 1677.63, 7.7), 35.5, 1},
			{Vector3(620.85, 1682.64, 7.7), 35.5, 1},
			{Vector3(617.42, 1687.44, 7.7), 35.5, 1},
			{Vector3(613.90, 1692.40, 7.7), 35.5, 1},
			{Vector3(610.33, 1697.42, 7.7), 35.5, 1},
			{Vector3(606.91, 1702.24, 7.7), 35.5, 1},
			{Vector3(603.53, 1707, 7.7), 35.5, 1},
		},
		accessible =  {0, 0},
	},
	{
		name = "Tierra Roboda 1",
		stations = {
			{Vector3(-1465.5, 1868.2, 33.3), 3.24, 1},
			{Vector3(-1464.78, 1860.43, 33.3), 3.24, 1},
			{Vector3(-1477.91, 1859.74, 33.3), 3.24, 1},
			{Vector3(-1478.72, 1867.25, 33.3), 3.24, 1},
		},
		accessible =  {0, 0},
	},
}
