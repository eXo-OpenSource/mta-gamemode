-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ElevatorGUI.lua
-- *  PURPOSE:     Elevator GUI
-- *
-- ****************************************************************************
ElevatorGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showElevatorGUI"}

function ElevatorGUI:constructor(elevatorId, stationName, stations)
	GUIButtonMenu.constructor(self, "Aufzug "..stationName)

	self.m_ElevatorId = elevatorId

	for stationId, data in pairs(stations) do
		if data.name ~= stationName then
			self:addItem(data.name, Color.LightBlue, bind(self.itemCallback, self, stationId))
		end
	end
end

function ElevatorGUI:itemCallback(stationId)
	triggerServerEvent("elevatorDrive", localPlayer, self.m_ElevatorId, stationId)
	self:close()
end

addEventHandler("showElevatorGUI", root,
		function(elevatorId, stationName, stations)
			ElevatorGUI:new(elevatorId, stationName, stations)
		end
	)
