-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: client/classes/HUD/TreasureRadar.lua
-- * PURPOSE: Treasure Radar class for TreasureSeeker Job
-- *
-- ****************************************************************************
TreasureRadar = inherit(Singleton)

function TreasureRadar:constructor()
	self.m_Angle = 0
	self.m_ElementsDetected = {}
	self.m_Radius = 200
	self.m_Radars = {}

	self.m_RadarColshape = createColCircle(0 ,0 , self.m_Radius)
	self.m_RadarColshape:attach(localPlayer)

	local posX, posY = screenWidth - 250, screenHeight/2-100
	local size = 200
	self.m_RadarPosition = {x = posX, y = posY, s = size, r = (size - (size*40/300))/2}

	addEventHandler("onClientRender", root, bind(self.render, self))
	addEventHandler("onClientPreRender", root, bind(self.preRender, self))

end

function TreasureRadar:render()
	if localPlayer:getOccupiedVehicle() and localPlayer:getOccupiedVehicle():getModel() == 453 then
		local now = getTickCount()
		if now-self.m_Angle >= 50 then
			self.m_Angle = self.m_Angle < 360 and self.m_Angle + 2 or 0
		end
		local radar = self.m_RadarPosition
		dxDrawImage(radar.x, radar.y, radar.s, radar.s, "files/images/Other/TreasureRadar.png")
		local centerX, centerY = radar.x+radar.s/2, radar.y+radar.s/2

		for i = -30, 1 do
			local alpha = 8.5*i
			local endX = math.cos( math.rad( self.m_Angle + i*2 ) ) * radar.r
			local endY = -math.sin( math.rad( self.m_Angle + i*2 ) ) * radar.r

			local lineX, lineY = centerX, centerY
			dxDrawLine(lineX, lineY, endX + lineX, endY + lineY, tocolor(0, 255, 0, alpha), 7)
		end
		for element, data in pairs(self.m_ElementsDetected) do
			local eAngle, hipotenusa = unpack(data)
			local hip = (radar.r*hipotenusa)/self.m_Radius
			local x, y = math.cos(eAngle) / hip, math.sin(eAngle) * hip

			dxDrawImage(centerX-8+x, centerY-8-y, 16, 16, "files/images/Other/TreasureRadarBlip.png", 0, 0, 0, tocolor(255, 255, 255, 255))
		end

		local rot = localPlayer:getOccupiedVehicle():getRotation()
		dxDrawImage(centerX-8, centerY-8, 16, 16, "files/images/Radar_Monochrome/Blips/LocalPlayer.png", rot.z)

	end
end

function TreasureRadar:preRender()
	if localPlayer:getOccupiedVehicle() and localPlayer:getOccupiedVehicle():getModel() == 453 then
		local centerX, centerY, centerZ = getElementPosition(localPlayer)
		local elements = getElementsWithinColShape(self.m_RadarColshape, "object")
		for index, element in pairs(elements) do
			if isElement(element) and getElementData(element, "Treasure") then
				local x, y, z = getElementPosition(element)
				local hipotenusa = ( (x-centerX)^2 + (y-centerY)^2 ) ^ .5
				local eAngle = math.acos( (x-centerX) / hipotenusa )
				eAngle = (y-centerY) < 0 and math.pi*2 - eAngle or eAngle
				self.m_ElementsDetected[element] = {eAngle, hipotenusa}

			end
		end
	end
end
