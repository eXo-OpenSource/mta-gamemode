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

				client:sendInfo(_("Tankstelle %s bedankt sich für deinen Einkauf!", client, station:getName()))
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
	[1] = {
		name = "Idlewood",
		stations = {
			{Vector3(1941.7, -1776.6, 14.17), 90, 2},
			{Vector3(1941.7, -1769.4, 14.17), 90, 2},
		},
		accessible =  {0, 0},
	},
}

