-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDRadar.lua
-- *  PURPOSE:     HUD radar class
-- *
-- ****************************************************************************
HUDRadar = inherit(Singleton)

function HUDRadar:constructor()
	self.m_ImageWidth, self.m_ImageHeight = 1024, 1024
	self.m_Width, self.m_Height = 340*screenWidth/1600, 200*screenHeight/900
	self.m_PosX, self.m_PosY = 20, screenHeight-self.m_Height-(self.m_Height/20+9)-20
	self.m_Diagonal = math.sqrt(self.m_Width^2+self.m_Height^2)
	
	self.m_Texture = dxCreateTexture("files/images/Radar.jpg")
	self.m_Zoom = 1
	self.m_Rotation = 0
	self.m_Blips = {}
	self.m_Visible = false
	
	-- Set texture edge to border (no-repeat)
	dxSetTextureEdge(self.m_Texture, "border", tocolor(51, 70, 77))
	
	-- Create a renderTarget that has the size of the diagonal of the actual image
	self.m_RenderTarget = dxCreateRenderTarget(self.m_Diagonal, self.m_Diagonal)
	
	addEventHandler("onClientPreRender", root, bind(self.update, self))
	addEventHandler("onClientRender", root, bind(self.draw, self))
	showPlayerHudComponent("radar", false)
end

function HUDRadar:hide()
	self.m_Visible = false
end

function HUDRadar:show()
	self.m_Visible = true
end

function HUDRadar:update()
	if not self.m_Visible then return end

	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and (getControlState("vehicle_look_behind") or
		(getControlState("vehicle_look_left") and getControlState("vehicle_look_right")) or
		(getVehicleType(vehicle) ~= "Plane" and getVehicleType(vehicle) ~= "Helicopter" and (getControlState("vehicle_look_left") or getControlState("vehicle_look_right")))) then
	
		local element = vehicle or localPlayer
		local _, _, rotation = getElementRotation(element)
		self.m_Rotation = rotation
	elseif getControlState("look_behind") then
		self.m_Rotation = -math.rad(getPedRotation(localPlayer))
	else
		local camX, camY, camZ, lookAtX, lookAtY, lookAtZ = getCameraMatrix()
		self.m_Rotation = math.deg(6.2831853071796 - math.atan2 ( ( lookAtX - camX ), ( lookAtY - camY ) ) % 6.2831853071796)
	end
end

function HUDRadar:draw()
	if not self.m_Visible then return end
	-- Draw the rectangle (the border)
	dxDrawRectangle(self.m_PosX, self.m_PosY, self.m_Width+6, self.m_Height+self.m_Height/20+9, tocolor(0, 0, 0))
	
	-- Draw the map
	local posX, posY, posZ = getElementPosition(localPlayer)
	local mapX, mapY = self:worldToMapPosition(posX, posY)
	
	-- Render (rotated) image section to renderTarget
	dxSetRenderTarget(self.m_RenderTarget, true)
	dxDrawImageSection(0, 0, self.m_Diagonal, self.m_Diagonal, mapX - self.m_Diagonal/2, mapY - self.m_Diagonal/2, self.m_Diagonal, self.m_Diagonal, self.m_Texture, self.m_Rotation)
	dxSetRenderTarget()
	
	-- Draw renderTarget
	dxDrawImageSection(self.m_PosX+3, self.m_PosY+3, self.m_Width, self.m_Height, self.m_Diagonal/2-self.m_Width/2, self.m_Diagonal/2-self.m_Height/2, self.m_Width, self.m_Height, self.m_RenderTarget)
	--dxDrawImage(200, 300, self.m_Diagonal, self.m_Diagonal, self.m_RenderTarget) -- test
	
	-- Draw health bar (at the bottom)
	dxDrawRectangle(self.m_PosX+3, self.m_PosY+self.m_Height+6, self.m_Width/2, self.m_Height/20, tocolor(71, 86, 75))
	dxDrawRectangle(self.m_PosX+3, self.m_PosY+self.m_Height+6, self.m_Width/2 * getElementHealth(localPlayer)/100, self.m_Height/20, tocolor(100, 121, 105))
	
	-- Draw armor bar
	dxDrawRectangle(self.m_PosX+self.m_Width/2+6, self.m_PosY+self.m_Height+6, self.m_Width/4, self.m_Height/20, tocolor(63, 105, 202))
	dxDrawRectangle(self.m_PosX+self.m_Width/2+6, self.m_PosY+self.m_Height+6, self.m_Width/4 * (getPedArmor(localPlayer)/100), self.m_Height/20, tocolor(77, 154, 202))
	
	-- Draw oxygen bar
	dxDrawRectangle(self.m_PosX+self.m_Width*3/4+9, self.m_PosY+self.m_Height+6, self.m_Width/4-6, self.m_Height/20, tocolor(65, 56, 15))
	dxDrawRectangle(self.m_PosX+self.m_Width*3/4+9, self.m_PosY+self.m_Height+6, (self.m_Width/4-6) * (getPedOxygenLevel(localPlayer)/1000), self.m_Height/20, tocolor(91, 79, 21))
	
	local mapCenterX, mapCenterY = self.m_PosX + self.m_Width/2, self.m_PosY + self.m_Height/2
	
	for k, blip in ipairs(self.m_Blips) do
		local blipX, blipY = blip:getPosition()
		if getDistanceBetweenPoints2D(posX, posY, blipX, blipY) < blip:getStreamDistance() then
			
			local blipMapX, blipMapY = self:worldToMapPosition(blipX, blipY)
			local distanceX, distanceY = blipMapX - mapX, blipMapY - mapY
			local distance = getDistanceBetweenPoints2D(blipMapX, blipMapY, mapX, mapY) --blipMapX - mapX, blipMapY - mapY
			local rotation = findRotation(mapCenterX, mapCenterY, mapCenterX + distanceX, mapCenterY + distanceY)
			
			local screenX =  mapCenterX - math.sin(math.rad(rotation + self.m_Rotation)) * distance
			local screenY =  mapCenterY + math.cos(math.rad(rotation + self.m_Rotation)) * distance ---distanceY
			
			if screenX < self.m_PosX then
				screenX = self.m_PosX
			end
			if screenY < self.m_PosY then
				screenY = self.m_PosY
			end
			if screenX > self.m_PosX + self.m_Width then
				screenX = self.m_PosX + self.m_Width
			end
			if screenY > self.m_PosY + self.m_Height then
				screenY = self.m_PosY + self.m_Height
			end
			
			local blipSize = blip:getSize()
			dxDrawImage(screenX - blipSize/2, screenY - blipSize/2, blipSize, blipSize, blip:getImagePath())
		end
	end

	-- Draw the player blip
	local rotX, rotY, rotZ = getElementRotation(localPlayer)
	dxDrawImage(self.m_PosX+self.m_Width/2-8, self.m_PosY+2+self.m_Height/2-8, 16, 16, "files/images/Blips/LocalPlayer.png", self.m_Rotation - rotZ)
end
angle = 0
addCommandHandler("angle", function(cmd, a) angle = tonumber(a) end)

function HUDRadar:worldToMapPosition(worldX, worldY)
	local mapX = worldX / ( 6000/1024) + 1024/2
	local mapY = worldY / (-6000/1024) + 1024/2
	return mapX, mapY
end

function HUDRadar:setZoom(zoom)
	error("Not implemented yet")
	self.m_Zoom = zoom
end

function HUDRadar:getZoom()
	return self.m_Zoom
end

function HUDRadar:addBlip(blipPath, worldX, worldY)
	local blip = RadarBlip:new(blipPath, worldX, worldY)
	table.insert(self.m_Blips, blip)
	return blip
end

function HUDRadar:removeBlip(blip)
	for k, v in ipairs(self.m_Blips) do
		if blip == v then
			table.remove(self.m_Blips, k)
			return true
		end
	end
	return false
end
