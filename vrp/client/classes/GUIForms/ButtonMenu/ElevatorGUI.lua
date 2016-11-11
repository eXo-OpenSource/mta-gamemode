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
	local music = Sound.create("files/audio/ElevatorMusic.ogg")
	fadeCamera(false,1,0,0,0)
    setTimer( function() localPlayer:setPosition(1800.19, -1723.73, 5.89) end, 1250,1)
	outputChatBox("Todo: Port to elevator interior, (made by krox)")
    setTimer(function() fadeCamera(true,1) end, 1500, 1)

	setTimer(function()
		Sound.create("files/audio/ElevatorDing.mp3")
		music:destroy()
		fadeCamera(false,1,0,0,0)
    	setTimer(function() fadeCamera(true,1) end, 1500, 1)
		setTimer(function()
			triggerServerEvent("elevatorDrive", localPlayer, self.m_ElevatorId, stationId)
		end, 1250, 1)
	end, 8000, 1)
	delete(self)
end

addEventHandler("showElevatorGUI", root,
		function(elevatorId, stationName, stations)
			ElevatorGUI:new(elevatorId, stationName, stations)
		end
	)
