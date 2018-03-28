-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ElevatorGUI.lua
-- *  PURPOSE:     Elevator GUI
-- *
-- ****************************************************************************
ElevatorGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showElevatorGUI"}

function ElevatorGUI:constructor(elevatorId, stationName, stations, pos, int)
	GUIButtonMenu.constructor(self, "Aufzug "..stationName)
	self.m_ElevatorId = elevatorId

	self.m_Pos = pos
	self.m_Int = int
	self.m_CamBind = bind(self.renderCam, self)

	for stationId, data in pairs(stations) do
		if data.name ~= stationName then
			self:addItem(data.name, Color.LightBlue, bind(self.itemCallback, self, stationId, stations))
		end
	end
end

function ElevatorGUI:itemCallback(stationId, station)
	local check1 = self.m_Int == getElementInterior(localPlayer)
	local mx,my,mz = unpack(self.m_Pos)
	local px,py,pz = getElementPosition(localPlayer)
	local check2 = getDistanceBetweenPoints3D(mx,my,mz,px,py,pz ) <= 5
	if not check1 or not check2 then return delete(self) end
	if not localPlayer.m_inElevator then
		localPlayer.m_inElevator = true
		local music = Sound.create("files/audio/ElevatorMusic.ogg")
		fadeCamera(false,1,0,0,0)
		setTimer( function()
			triggerServerEvent("elevatorStartDrive", localPlayer, self.m_ElevatorId, stationId)
			setElementDimension(localPlayer,0)
			setElementInterior(localPlayer,18)
			localPlayer:setPosition(1709.42, -1643.27, 20.23)
			localPlayer:setRotation(0, 0, 245)
			localPlayer:setFrozen(true)
			self:toggleKeys(false)
			HUDRadar:getSingleton():setEnabled(false)
		end, 1500,1)
		setTimer(function() fadeCamera(true,1) end, 1500, 1)
		setTimer(function() addEventHandler("onClientPreRender", root, self.m_CamBind) end, 1500 ,1)


		setTimer(function()
			Sound.create("files/audio/ElevatorDing.mp3")
			music:destroy()
			fadeCamera(false,1,0,0,0)
			setTimer(function() fadeCamera(true,1) end, 1500, 1)
			setTimer(function()
				localPlayer:setFrozen(false)
				setElementDimension(localPlayer,0)
				setElementInterior(localPlayer,0)
				self:toggleKeys(true)
				HUDRadar:getSingleton():setEnabled(true)
				removeEventHandler("onClientPreRender", root, self.m_CamBind)
				triggerServerEvent("elevatorDrive", localPlayer, self.m_ElevatorId, stationId)
				localPlayer.m_inElevator = false
				setCameraTarget(localPlayer)
				setTimer(
					function()
						NoDm:getSingleton():checkNoDm()
					end, 500, 1
				)
			end, 1250, 1)
		end, 8000, 1)
		delete(self)
	end
end

function ElevatorGUI:renderCam()
	local posPlayer = localPlayer.position

	if not self.m_Object then
		local posObject = posPlayer --+ localPlayer.matrix.forward*2
		posObject.z = posObject.z-0.5
		self.m_Object = createObject(1337, posObject)
		self.m_Object:setAlpha(0)
		self.m_Object:setCollisionsEnabled(false)
		self.m_Object:move(4000, posObject.x, posObject.y, posObject.z+1.5, 0, 0, 0, "InOutQuad")
	end
	local pos2 = self.m_Object.position
	setCameraMatrix(Vector3(1709.5, -1641.2, 21.6), pos2)
end

addEventHandler("showElevatorGUI", root,
		function(elevatorId, stationName, stations, posTable , int)
			if not localPlayer.m_inElevator then
				ElevatorGUI:new(elevatorId, stationName, stations, posTable, int)
			end
		end
	)

	createObject(3051, 1710.8086, -1643.141, 20.58095):setInterior(18)
	createObject(3051, 1709.9536, -1643.9614, 20.58095, 0, 0, 180):setInterior(18)
	--[[<object id="object (lift_dr) (1)" breakable="true" interior="18" alpha="255" model="3051" doublesided="false" scale="1" dimension="0" posX="1710.8086" posY="-1643.141" posZ="20.58095" rotX="0" rotY="0" rotZ="0"></object>
	<object id="object (lift_dr) (2)" breakable="true" interior="18" alpha="255" model="3051" doublesided="false" scale="1" dimension="0" posX="1709.9536" posY="-1643.9614" posZ="20.58095" rotX="0" rotY="0" rotZ="180"></object>
]]