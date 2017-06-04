-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StateFactionGasStationGUI.lua
-- *  PURPOSE:     State Faction Refill/Repair GUI
-- *
-- ****************************************************************************
StateFactionGasStationGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showStateFactionGasStationGUI"}

function StateFactionGasStationGUI:constructor()
	GUIButtonMenu.constructor(self, "Staatsfraktion Duty Menü")

	-- Add the Items
	self:addItems()

	-- Events
end

function StateFactionGasStationGUI:addItems()
	self:addItem(_"Fahrzeug betanken", Color.Green, bind(self.itemCallback, self, 1))
	self:addItem(_"Fahrzeug reparieren", Color.Green, bind(self.itemCallback, self, 2))
	self:addItem(_"Schließen", Color.Red, bind(self.itemCallback, self))
end

function StateFactionGasStationGUI:itemCallback(type)
	if type == 1 then
		triggerServerEvent("factionStateFillRepairVehicle", localPlayer, "fill")
	elseif type == 2 then
		triggerServerEvent("factionStateFillRepairVehicle", localPlayer, "repair")
	else
		triggerServerEvent("factionStateFillRepairVehicle", localPlayer) --to release hand brake
		self:close()
	end

end

addEventHandler("showStateFactionGasStationGUI", root,
		function()
			StateFactionGasStationGUI:new()
		end
	)
