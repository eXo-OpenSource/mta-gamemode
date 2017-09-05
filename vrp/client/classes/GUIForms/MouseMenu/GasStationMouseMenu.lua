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
	self:addItem(_("Tankstelle: %s", name)):setTextColor(Color.LightBlue)

	self:addItem(_("Zapfpistole %s (Benzin)", localPlayer:getPrivateSync("hasGasStationFuelNozzle") and "einhängen" or "nehmen"),
		function()
			if localPlayer.vehicle then return end
			triggerServerEvent("gasStationTakeFuelNozzle", localPlayer, element)
		end
	):setIcon(FontAwesomeSymbols.Fire)

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
