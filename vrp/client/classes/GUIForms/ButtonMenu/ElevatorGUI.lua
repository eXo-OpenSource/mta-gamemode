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

	self.m_CamBind = bind(self.renderCam, self)

	for stationId, data in pairs(stations) do
		if data.name ~= stationName then
			self:addItem(data.name, Color.LightBlue, bind(self.itemCallback, self, stationId))
		end
	end
end

function ElevatorGUI:itemCallback(stationId)
	local music = Sound.create("files/audio/ElevatorMusic.ogg")
	fadeCamera(false,1,0,0,0)
    setTimer( function()
		localPlayer:setPosition(1783.68, -1750.25, 13.554)
		localPlayer:setFrozen(true)
	end, 1250,1)
	outputChatBox("Todo: Port to elevator interior, (made by krox)")
    setTimer(function() fadeCamera(true,1) end, 1500, 1)
	setTimer(function() addEventHandler("onClientPreRender", root, self.m_CamBind) end, 1800 ,1)


	setTimer(function()
		Sound.create("files/audio/ElevatorDing.mp3")
		music:destroy()
		fadeCamera(false,1,0,0,0)
    	setTimer(function() fadeCamera(true,1) end, 1500, 1)
		setTimer(function()
			localPlayer:setFrozen(false)
			removeEventHandler("onClientPreRender", root, self.m_CamBind)
			triggerServerEvent("elevatorDrive", localPlayer, self.m_ElevatorId, stationId)
			setCameraTarget(localPlayer)
		end, 1250, 1)
	end, 8000, 1)
	delete(self)
end

function ElevatorGUI:renderCam()
	local pos1 = localPlayer:getPosition()

	if not self.m_Object then
		self.m_Object = createObject(1337, pos1.x+4, pos1.y, pos1.z-1)
		self.m_Object:setAlpha(0)
		self.m_Object:move(4000, pos1.x+4, pos1.y, pos1.z+3, 0, 0, 0, "InOutQuad")
	end
	local pos2 = self.m_Object:getPosition()
	setCameraMatrix(pos1, pos2)
end

addEventHandler("showElevatorGUI", root,
		function(elevatorId, stationName, stations)
			ElevatorGUI:new(elevatorId, stationName, stations)
		end
	)
