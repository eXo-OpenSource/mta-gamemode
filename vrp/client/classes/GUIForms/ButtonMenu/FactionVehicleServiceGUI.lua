-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionVehicleServiceGUI.lua
-- *  PURPOSE:     State Faction Refill/Repair GUI
-- *
-- ****************************************************************************
FactionVehicleServiceGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showFactionVehicleServiceGUI"}

function FactionVehicleServiceGUI:constructor()
	GUIButtonMenu.constructor(self, "Fahrzeug-Service")
	self:addItems()
end

function FactionVehicleServiceGUI:addItems()
	self:addItem(_"Fahrzeug betanken", Color.Green, bind(self.itemCallback, self, 1))
	self:addItem(_"Fahrzeug reparieren", Color.Green, bind(self.itemCallback, self, 2))
	self:addItem(_"Schließen", Color.Red, bind(self.itemCallback, self))
end

function FactionVehicleServiceGUI:itemCallback(type)
	if type == 1 then
		triggerServerEvent("factionVehicleServiceMarkerPerformAction", localPlayer, "fill")
	elseif type == 2 then
		triggerServerEvent("factionVehicleServiceMarkerPerformAction", localPlayer, "repair")
	else
		self:close()
	end

end

addEventHandler("showFactionVehicleServiceGUI", root,
		function()
			FactionVehicleServiceGUI:new()
		end
	)
