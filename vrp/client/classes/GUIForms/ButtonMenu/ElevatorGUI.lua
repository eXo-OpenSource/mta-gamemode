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
		localPlayer:setPosition(1744.80, -1746.90, 13.30)
		localPlayer:setRotation(0, 0, 170)
		localPlayer:setFrozen(true)
	end, 1250,1)
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
	local posPlayer = localPlayer.position

	if not self.m_Object then
		local posObject = posPlayer + localPlayer.matrix.forward*2
		posObject.z = posObject.z-0.5
		self.m_Object = createObject(1337, posObject)
		self.m_Object:setAlpha(0)
		self.m_Object:move(4000, posObject.x, posObject.y, posObject.z+1, 0, 0, 0, "InOutQuad")
	end
	local pos2 = self.m_Object.position
	setCameraMatrix(posPlayer, pos2)
end

addEventHandler("showElevatorGUI", root,
		function(elevatorId, stationName, stations)
			ElevatorGUI:new(elevatorId, stationName, stations)
		end
	)
