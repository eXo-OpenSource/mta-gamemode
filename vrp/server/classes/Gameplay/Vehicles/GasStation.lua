-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/GasStation.lua
-- *  PURPOSE:     Gas stations
-- *
-- ****************************************************************************
GasStation = inherit(Object)
GasStation.Map = {}

function GasStation:constructor(stations, accessible, name, nonInterior, serviceStation, evilStation, fuelTypes, blipPosition)
	self.m_Stations = {}
	self.m_Accessible = accessible
	self.m_Name = name
	self.m_NonInterior = nonInterior
	self.m_ServiceStation = serviceStation
	self.m_EvilStation = evilStation
	self.m_Position = stations[1][1] -- for gps
	self.m_FuelTypes = {}
	self.m_FuelTypePrices = {}
	for i, v in pairs(fuelTypes) do self.m_FuelTypes[v] = true end -- invert table
	
	for	i, type in pairs(fuelTypes) do
		if FUEL_PRICE_RANGE[type][2] > 0 then
			self.m_FuelTypePrices[type] = math.round(math.random(FUEL_PRICE_RANGE[type][1], FUEL_PRICE_RANGE[type][2]) + math.random(), 1)
		else
			self.m_FuelTypePrices[type] = 0
		end
	end 

	for _, station in pairs(stations) do
		local position, rotation, maxHoses = unpack(station)
		local object = createObject(1676, position, 0,0, rotation)

		self.m_Stations[object] = {maxHoses = maxHoses, players = {}}
		GasStation.Map[object] = self

		if self.m_Name then
			object:setData("Name", self.m_Name, true)
		end

		if self.m_ServiceStation then
			object:setData("isServiceStation", true, true)
		end

		if self.m_EvilStation then
			object:setData("isEvilStation", true, true)
		end
		object:setData("FuelTypes", self.m_FuelTypes, true, true)
		object:setData("FuelTypePrices", self.m_FuelTypePrices, true)
	end
	if blipPosition then
		self.m_Blip = Blip:new("Fuelstation.png", blipPosition.x, blipPosition.y, root, 300):setDisplayText("Tankstelle", BLIP_CATEGORY.VehicleMaintenance):setOptionalColor({0, 150, 136})
	end
end

function GasStation:destructor()
end

function GasStation:addShopRef(shop)
	self.m_Shop = shop
end

function GasStation:getShop()
	return self.m_Shop
end

function GasStation:getName()
	return self.m_Name
end

function GasStation:hasPlayerAccess(player)
	if self:isUserFuelStation() then return true end

	if self:isFactionFuelStation() then
		if self.m_Accessible[2] == 0 and player:getFaction() and player:getFaction():isStateFaction() and player:isFactionDuty() then
			return true
		end

		if player:getFaction() and player:getFaction():getId() == self.m_Accessible[2] and (player:getFaction():isEvilFaction() or player:isFactionDuty()) then
			return true
		end
	elseif self:isCompanyFuelStation() then
		if player:getCompany() and player:getCompany():getId() == self.m_Accessible[2] and player:isCompanyDuty() then
			return true
		end
	end
end

function GasStation:isUserFuelStation()
	return self.m_Accessible[1] == 0
end

function GasStation:isFactionFuelStation()
	return self.m_Accessible[1] == 1
end

function GasStation:isCompanyFuelStation()
	return self.m_Accessible[1] == 2
end

function GasStation:isServiceStation()
	return self.m_ServiceStation
end

function GasStation:isEvilStation()
	return self.m_EvilStation
end

function GasStation:takeFuelNozzle(player, element, fuelType)
	if not self:hasPlayerAccess(player) then
		player:sendError(_("Du bist nicht berechtigt diese Tankstelle zu nutzen!", player))
		return
	end

	local playersInUse = 0
	for i, v in pairs(self.m_Stations[element].players) do
		if isElement(i) then
			playersInUse = playersInUse + 1
		else
			self.m_Stations[element].players[i] = nil
		end
	end
	if playersInUse >= self.m_Stations[element].maxHoses then
		player:sendError(_("Diese Zapfsäule ist bereits belegt!", player))
		return
	end

	player.gs_fuelNozzle = createObject(1909, player.position)
	player.gs_fuelNozzle:setData("attachedGasStation", element, true)
	player.gs_fuelNozzle:setData("attachedPlayer", player, true)
	client:setPrivateSync("hasGasStationFuelNozzle", fuelType)
	player.gs_usingFuelStation = element

	exports.bone_attach:attachElementToBone(player.gs_fuelNozzle, player, 12, -0.03, 0.02, 0.05, 180, 320, 0)
	toggleControl(player, "fire", false)

	self.m_Stations[element].players[player] = fuelType
end

function GasStation:rejectFuelNozzle(player, element)
	self.m_Stations[element].players[player] = nil

	player:setPrivateSync("hasGasStationFuelNozzle", false)
	player:triggerEvent("forceCloseVehicleFuel")
	player.gs_usingFuelStation = nil
	player.gs_fuelNozzle:destroy()
	toggleControl(player, "fire", true)

	if self.m_NonInterior then
		client:triggerEvent("gasStationNonInteriorRequest")
	end
end
