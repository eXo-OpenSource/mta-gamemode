-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
GasStationMouseMenu = inherit(GUIMouseMenu)

function GasStationMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1)

	local name = element:getData("Name")

	--self:addItem(_("Besitzer: %s", name))
	self:addItem(_("Tankstelle: %s", name)):setTextColor(Color.Accent)

	if localPlayer:getPrivateSync("hasGasStationFuelNozzle") then
		self:addItem(_"Zapfpistole einhängen",
			function()
				if localPlayer.vehicle then return end
				triggerServerEvent("gasStationTakeFuelNozzle", localPlayer, element)
			end
		):setIcon(FontAwesomeSymbols.Fire)
	else
		for fuelType in pairs(element:getData("FuelTypes")) do
			local price = element:getData("FuelTypePrices")[fuelType]
			local multiplier
			if element:getData("isServiceStation") then
				multiplier = SERVICE_FUEL_PRICE_MULTIPLICATOR
			elseif element:getData("isEvilStation") then
				multiplier = EVIL_FUEL_PRICE_MULTIPLICATOR
			else
				multiplier = 1
			end
			
			self:addItem(_("Zapfpistole nehmen (%s) (%s$ pro Liter)", FUEL_NAME[fuelType], math.round(price * multiplier, 1)),
				function()
					if localPlayer.vehicle then return end
					triggerServerEvent("gasStationTakeFuelNozzle", localPlayer, element, fuelType)
				end
			):setIcon(FontAwesomeSymbols.Fire)
		end
	end

	--self:addItem(_"Zapfpistole nehmen (Diesel)", function() end):setIcon(FontAwesomeSymbols.Fire)
	--self:addItem(_"Ladekabel nehmen (Elektro)", function() end):setIcon(FontAwesomeSymbols.Bolt)

	if element:getData("isServiceStation") and localPlayer.vehicle then
		self:addItem(_"Service: Fahrzeug reparieren",
			function()
				if localPlayer.vehicle and localPlayer.vehicle:getData("syncEngine") then WarningBox:new("Bitte schalte den Motor aus!") return end

				triggerServerEvent("gasStationRepairVehicle", localPlayer, element)
			end
		):setIcon(FontAwesomeSymbols.Wrench)
	end

	self:adjustWidth()
end
