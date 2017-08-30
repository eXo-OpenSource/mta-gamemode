-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: client/classes/HUD/TreasureRadar.lua
-- * PURPOSE: Treasure Radar class for TreasureSeeker Job
-- *
-- ****************************************************************************
TreasureRadar = inherit(Singleton)

local TREASURE_ZOOM = 5
local TREASURE_RADIUS = 200

function TreasureRadar:constructor()
	self.m_Angle = 0
	self.m_Blips = {}
	self.m_Rotation = 0

	self.m_RadarColshape = createColCircle(0, 0, TREASURE_RADIUS)
	self.m_RadarColshape:attach(localPlayer)

	local posX, posY = screenWidth - 250, screenHeight/2-100
	local size = 200
	self.m_RadarPosition = {x = posX, y = posY, s = size, r = (size - (size*40/300))/2}

	addEventHandler("onClientRender", root, bind(self.render, self))
	addEventHandler("onClientPreRender", root, bind(self.preRender, self))
end

function TreasureRadar:render()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/TreasureRadar") end
	if localPlayer:getOccupiedVehicle() and localPlayer:getOccupiedVehicle():getModel() == 453 then
		local now = getTickCount()
		if now - self.m_Angle >= 50 then
			self.m_Angle = self.m_Angle < 360 and self.m_Angle + 2 or 0
		end
		local radar = self.m_RadarPosition
		dxDrawImage(radar.x, radar.y, radar.s, radar.s, "files/images/Other/TreasureRadar.png", self.m_Rotation)
		local centerX, centerY = radar.x+radar.s/2, radar.y+radar.s/2

		for i = -30, 1 do
			local alpha = 8.5*i
			local endX = math.cos( math.rad( self.m_Angle + i*2 ) ) * radar.r
			local endY = -math.sin( math.rad( self.m_Angle + i*2 ) ) * radar.r

			local lineX, lineY = centerX, centerY
			dxDrawLine(lineX, lineY, endX + lineX, endY + lineY, tocolor(0, 255, 0, alpha), 7)
		end

		-- Draw blips
		local localX, localY = getElementPosition(localPlayer)
		for k, blip in pairs(self.m_Blips) do
			if DEBUG then ExecTimeRecorder:getSingleton():addIteration("UI/HUD/TreasureRadar") end
			if isElement(blip) then
				local blipX, blipY = getElementPosition(blip)
				local angle = math.deg(math.atan2(blipY - localY, blipX - localX))
				local distance = math.sqrt((blipX - localX)^2 + (blipY - localY)^2)

				local x = math.cos(math.rad(self.m_Rotation - angle)) * distance / TREASURE_ZOOM
				local y = math.sin(math.rad(self.m_Rotation - angle)) * distance / TREASURE_ZOOM

				if DEBUG then ExecTimeRecorder:getSingleton():addIteration("UI/HUD/TreasureRadar", true) end
				dxDrawImage(centerX - 8 + x, centerY - 8 + y, 16, 16, "files/images/Other/TreasureRadarBlip.png", 0, 0, 0, Color.White)
			else
				self.m_Blips[k] = nil
			end
		end

		local rot = getPedRotation(localPlayer)
		dxDrawImage(centerX-8, centerY-8, 16, 16, "files/images/Radar_Monochrome/Blips/LocalPlayer.png", self.m_Rotation - rot)
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/TreasureRadar") end
end

function TreasureRadar:preRender()
	if localPlayer:getOccupiedVehicle() and localPlayer:getOccupiedVehicle():getModel() == 453 then
		if vehicle and (getControlState("vehicle_look_behind") or getControlState("vehicle_look_left") or getControlState("vehicle_look_right")) then
			local element = vehicle or localPlayer
			local _, _, rotation = getElementRotation(element)
			self.m_Rotation = rotation
		elseif getControlState("look_behind") then
			self.m_Rotation = -getPedRotation(localPlayer)
		else
			local camX, camY, camZ, lookAtX, lookAtY, lookAtZ = getCameraMatrix()
			self.m_Rotation = 360 - math.deg(math.atan2(lookAtX - camX, lookAtY - camY)) % 360
		end

		self.m_Blips = {}
		for i, element in pairs(getElementsWithinColShape(self.m_RadarColshape, "object")) do
			if isElement(element) and getElementData(element, "Treasure") == localPlayer then
				self.m_Blips[#self.m_Blips + 1] = element
			end
		end
	end
end
