-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
GasStation = inherit(Object)
GasStation.Map = {}

function GasStation:constructor(stations, accessible, name)
	self.m_Stations = {}
	self.m_Accessible = accessible
	self.m_Name = name

	for _, station in pairs(stations) do
		local position, rotation = unpack(station)
		local object = createObject(1676, position, 0,0, rotation)

		table.insert(self.m_Stations, object)
		GasStation.Map[object] = self

		if self.m_Name then
			object:setData("Name", self.m_Name, true)
		end
	end
end

function GasStation:destructor()
end

function GasStation:addShopRef(shop)
	self.m_Shop = shop
end

function GasStation:hasPlayerAccess(player)
	if self.m_Accessible[1] == 0 then return true end

	if self.m_Accessible[1] == 1 then
		if self.m_Accessible[2] == 0 and player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
			return true
		end

		if player:getFaction() and player:getFaction():getId() == self.m_Accessible[2] and (player:getFaction():isEvilFaction() or player:isFactionDuty()) then
			return true
		end
	elseif self.m_Accessible[1] == 2 then
		if player:getCompany() and player:getCompany():getId() == self.m_Accessible[2] and player:isCompanyDuty() then
			return true
		end
	end
end

function GasStation:takeFuelNozzle(player, element)
	if not self:hasPlayerAccess(player) then
		player:sendError("Du bist nicht berechtigt diese Tankstelle zu nutzen!")
		return
	end

	player.gs_fuelNozzle = createObject(1909, player.position)
	exports.bone_attach:attachElementToBone(player.gs_fuelNozzle, player, 12, -0.03, 0.02, 0.05, 180, 320, 0)
	player:setPrivateSync("hasGasStationFuelNozzle", element)
	toggleControl(player, "fire", false)
end

----------------------------------------------

GasStationManager = inherit(Singleton)
GasStationManager.Shops = {}
addRemoteEvents{"gasStationTakeFuelNozzle"}

function GasStationManager:constructor()
	for _, station in pairs(GAS_STATIONS) do
		local instance = GasStation:new(station.stations, station.accessible, station.name)

		if station.name then
			GasStationManager.Shops[station.name] = instance
		end
	end

	PlayerManager:getSingleton():getQuitHook():register(bind(self.onPlayerQuit, self))

	addEventHandler("gasStationTakeFuelNozzle", root, bind(GasStationManager.takeFuelNozzle, self))
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
			client:setPrivateSync("hasGasStationFuelNozzle", false)
			toggleControl(client, "fire", true)
			client.gs_fuelNozzle:destroy()
			return
		end

		GasStation.Map[element]:takeFuelNozzle(client, element)
	end
end

-- accessible: {type, id} || type: 0 = all, 1 = faction, 2 = company || id = faction or company id (0 == state faction)
GAS_STATIONS = {
	[1] = {
		name = "Idlewood",
		stations = {
			{Vector3(1941.7, -1776.6, 14.17), 90},
			{Vector3(1941.7, -1769.4, 14.17), 90},
			},
		accessible =  {0, 0},
	},
}
