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
	self.m_Radius = 100
	self.m_Radars = {}

	self.m_AllowedElementModels = {
		[1208] = true,
		[3013] = true
	}

	self.m_RadarColshape = createColCircle(0 ,0 , self.m_Radius)
	self.m_RadarColshape:attach(localPlayer)

	self:addRadar(screenWidth - 366, screenHeight - 318, 200)

	addEventHandler("onClientRender", root, bind(self.render, self))
	addEventHandler("onClientPreRender", root, bind(self.preRender, self))

end

function TreasureRadar:addRadar(posX, posY, size)
	table.insert(self.m_Radars, {x = posX, y = posY, s = size, r = (size - (size*40/300))/2})
end

function TreasureRadar:render()
	local now = getTickCount()
	if now-self.m_Angle >= 50 then
		self.m_Angle = self.m_Angle < 360 and self.m_Angle + 2 or 0
	end
	for _, v in ipairs(self.m_Radars) do
		dxDrawImage(v.x, v.y, v.s, v.s, "files/images/Other/TreasureRadar.png")
		local centerX, centerY = v.x+v.s/2, v.y+v.s/2

		for i = -30, 1 do
			local alpha = 8.5*i
			local endX = math.cos( math.rad( self.m_Angle + i*2 ) ) * v.r
			local endY = -math.sin( math.rad( self.m_Angle + i*2 ) ) * v.r

			local lineX, lineY = centerX, centerY
			dxDrawLine(lineX, lineY, endX + lineX, endY + lineY, tocolor(0, 255, 0, alpha), 7)
		end
		for element, b in pairs(self.m_ElementsDetected) do
			local elapsedTime = now - b[1]
			if elapsedTime < 3000 then
				local alpha = linear(elapsedTime, 255, -255, 3000)

				local hip = (v.r*b[3])/self.m_Radius
				local x, y = math.cos(b[2]) * hip, math.sin(b[2]) * hip

				dxDrawImage(centerX-8+x, centerY-8-y, 16, 16, "files/images/Other/TreasureRadarBlip.png", _, _, _, tocolor(255, 255, 255, alpha))
			else
				self.m_ElementsDetected[element] = nil
			end
		end
	end
end

function TreasureRadar:preRender()
	local centerX, centerY, centerZ = getElementPosition(localPlayer)
	local elements = getElementsWithinColShape(self.m_RadarColshape, "object")
	for e = 1, #elements do
		if self.m_AllowedElementModels[elements[e]:getModel()] then
			local x, y, z = getElementPosition(elements[e])
			local hipotenusa = ( (x-centerX)^2 + (y-centerY)^2 ) ^ .5
			local eAngle = math.acos( (x-centerX) / hipotenusa )
			eAngle = (y-centerY) < 0 and math.pi*2 - eAngle or eAngle

			--local xFrom, yFrom = math.cos(eAngle)*hipotenusa, math.sin(eAngle)*hipotenusa
			--dxDrawLine3D(centerX, centerY, 7, xFrom + centerX, yFrom + centerY, z, tocolor(0, 255, 0, 150), 3) -- To see where the element is supposed to be

			if eAngle >= math.rad( self.m_Angle - 10 ) and eAngle <= math.rad ( self.m_Angle ) then
				if visible and not self.m_ElementsDetected[elements[e]] then
					playSoundFrontEnd(5)
				end
				self.m_ElementsDetected[elements[e]] = {getTickCount(), eAngle, hipotenusa}
			end
		end
	end
end
