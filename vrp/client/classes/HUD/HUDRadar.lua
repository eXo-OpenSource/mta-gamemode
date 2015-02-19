-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDRadar.lua
-- *  PURPOSE:     HUD radar class
-- *
-- ****************************************************************************
HUDRadar = inherit(Singleton)

function HUDRadar:constructor()
	self.m_ImageSize = 1536, 1536 --3072, 3072
	self.m_Width, self.m_Height = 340*screenWidth/1600, 200*screenHeight/900
	self.m_PosX, self.m_PosY = 20, screenHeight-self.m_Height-(self.m_Height/20+9)-20
	self.m_Diagonal = math.sqrt(self.m_Width^2+self.m_Height^2)
	self.m_DesignSet = tonumber(core:getConfig():get("HUD", "RadarDesign")) or RadarDesign.Monochrome
	if self.m_DesignSet == RadarDesign.Monochrome then
		CustomF11Map:getSingleton():enable()
	end
	
	self.m_Texture = dxCreateRenderTarget(self.m_ImageSize, self.m_ImageSize)
	self.m_Zoom = 1
	self.m_Rotation = 0
	self.m_Blips = {}
	self.m_Areas = {}
	self.m_Visible = false

    -- Link Blip.Blips to the HUDRadar.m_Blips
    Blip.Blips = self.m_Blips
	
	-- Set texture edge to border (no-repeat)
	dxSetTextureEdge(self.m_Texture, "border", tocolor(125, 168, 210))
	
	-- Create a renderTarget that has the size of the diagonal of the actual image
	self.m_RenderTarget = dxCreateRenderTarget(self.m_Diagonal, self.m_Diagonal)
	self:updateMapTexture()
	
	addEventHandler("onClientPreRender", root, bind(self.update, self))
	addEventHandler("onClientRender", root, bind(self.draw, self), true, "high+10")
	addEventHandler("onClientRestore", root, bind(self.restore, self))
	showPlayerHudComponent("radar", false)
end

function HUDRadar:hide()
	self.m_Visible = false
end

function HUDRadar:show()
	self.m_Visible = true
end

function HUDRadar:updateMapTexture()
	dxSetRenderTarget(self.m_Texture)
	
	-- Draw actual map texture
	dxDrawImage(0, 0, self.m_ImageSize, self.m_ImageSize, self:makePath("Radar.jpg", false))
	
	-- Draw radar areas
	for k, rect in pairs(self.m_Areas) do
		local mapX, mapY = self:worldToMapPosition(rect.X, rect.Y)
		
		local width, height = rect.Width/(6000/self.m_ImageSize), rect.Height/(6000/self.m_ImageSize)
		dxDrawRectangle(mapX, mapY, width, height, rect.color)
	end
	
	dxSetRenderTarget(nil)
end

function HUDRadar:makePath(fileName, isBlip)
	if isBlip then
		if self.m_DesignSet == RadarDesign.Monochrome then
			return "files/images/Radar_Monochrome/Blips/"..fileName
		elseif self.m_DesignSet == RadarDesign.GTA then
			return "files/images/Radar_GTA/Blips/"..fileName
		end
	else
		if self.m_DesignSet == RadarDesign.Monochrome then
			return "files/images/Radar_Monochrome/"..fileName
		elseif self.m_DesignSet == RadarDesign.GTA then
			return "files/images/Radar_GTA/"..fileName
		end
	end
end

function HUDRadar:setDesignSet(design)
	if design == RadarDesign.Monochrome then
		CustomF11Map:getSingleton():enable()
	else
		CustomF11Map:getSingleton():disable()
	end

	self.m_DesignSet = design
	core:getConfig():set("HUD", "RadarDesign", design)
	self:updateMapTexture()
	
	for k, blip in pairs(self.m_Blips) do
		blip:updateDesignSet()
	end
end

function HUDRadar:getDesignSet()
	return self.m_DesignSet
end

function HUDRadar:restore(clearedRenderTargets)
	if clearedRenderTargets then
		self:updateMapTexture()
	end
end

function HUDRadar:update()
	if not self.m_Visible or isPlayerMapVisible() then return end

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
	if not self.m_Visible or isPlayerMapVisible() then return end
	local isNotInInterior = getElementInterior(localPlayer) == 0
	local isInWater = isElementInWater(localPlayer)
	
	-- Draw the rectangle (the border)
	dxDrawRectangle(self.m_PosX, self.m_PosY, self.m_Width+6, self.m_Height+self.m_Height/20+9, tocolor(0, 0, 0))
	
	-- Draw the map
	local posX, posY, posZ = getElementPosition(localPlayer)
	local mapX, mapY = self:worldToMapPosition(posX, posY)
	
	-- Render (rotated) image section to renderTarget
	if isNotInInterior then
		dxSetRenderTarget(self.m_RenderTarget, true)
		dxDrawImageSection(0, 0, self.m_Diagonal, self.m_Diagonal, mapX - self.m_Diagonal/2, mapY - self.m_Diagonal/2, self.m_Diagonal, self.m_Diagonal, self.m_Texture, self.m_Rotation)
		dxSetRenderTarget(nil)
	end
	
	-- Draw renderTarget
	if isNotInInterior then
		dxDrawImageSection(self.m_PosX+3, self.m_PosY+3, self.m_Width, self.m_Height, self.m_Diagonal/2-self.m_Width/2, self.m_Diagonal/2-self.m_Height/2, self.m_Width, self.m_Height, self.m_RenderTarget)
		--dxDrawImage(200, 300, self.m_Diagonal, self.m_Diagonal, self.m_RenderTarget) -- test
	else
		dxDrawRectangle(self.m_PosX+3, self.m_PosY+3, self.m_Width, self.m_Height, tocolor(125, 168, 210))
	end
	
	-- Draw health bar (at the bottom)
	dxDrawRectangle(self.m_PosX+3, self.m_PosY+self.m_Height+6, self.m_Width/2, self.m_Height/20, tocolor(71, 86, 75))
	dxDrawRectangle(self.m_PosX+3, self.m_PosY+self.m_Height+6, self.m_Width/2 * getElementHealth(localPlayer)/100, self.m_Height/20, tocolor(100, 121, 105))
	
	-- Draw armor bar
	if isInWater then
		dxDrawRectangle(self.m_PosX+self.m_Width/2+6, self.m_PosY+self.m_Height+6, self.m_Width/4, self.m_Height/20, tocolor(63, 105, 202))
		dxDrawRectangle(self.m_PosX+self.m_Width/2+6, self.m_PosY+self.m_Height+6, self.m_Width/4 * (getPedArmor(localPlayer)/100), self.m_Height/20, tocolor(77, 154, 202))
	else
		dxDrawRectangle(self.m_PosX+self.m_Width/2+6, self.m_PosY+self.m_Height+6, self.m_Width/2-3, self.m_Height/20, tocolor(63, 105, 202))
		dxDrawRectangle(self.m_PosX+self.m_Width/2+6, self.m_PosY+self.m_Height+6, (self.m_Width/2-3) * (getPedArmor(localPlayer)/100), self.m_Height/20, tocolor(77, 154, 202))
	end
	
	-- Draw oxygen bar
	if isInWater then
		dxDrawRectangle(self.m_PosX+self.m_Width*3/4+9, self.m_PosY+self.m_Height+6, self.m_Width/4-6, self.m_Height/20, tocolor(65, 56, 15))
		dxDrawRectangle(self.m_PosX+self.m_Width*3/4+9, self.m_PosY+self.m_Height+6, (self.m_Width/4-6) * (getPedOxygenLevel(localPlayer)/1000), self.m_Height/20, tocolor(91, 79, 21))
	end
	
	if isNotInInterior then
		local mapCenterX, mapCenterY = self.m_PosX + self.m_Width/2, self.m_PosY + self.m_Height/2
		for k, blip in pairs(self.m_Blips) do
			local blipX, blipY = blip:getPosition()
			if getDistanceBetweenPoints2D(posX, posY, blipX, blipY) < blip:getStreamDistance() then
				
				local blipMapX, blipMapY = self:worldToMapPosition(blipX, blipY)
				local distanceX, distanceY = blipMapX - mapX, blipMapY - mapY
				local distance = getDistanceBetweenPoints2D(blipMapX, blipMapY, mapX, mapY)
				local rotation = findRotation(mapCenterX, mapCenterY, mapCenterX + distanceX, mapCenterY + distanceY)
				
				local screenX =  mapCenterX - math.sin(math.rad(rotation + self.m_Rotation)) * distance
				local screenY =  mapCenterY + math.cos(math.rad(rotation + self.m_Rotation)) * distance
				
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
	end

	-- Draw the player blip
	local rotX, rotY, rotZ = getElementRotation(localPlayer)
	dxDrawImage(self.m_PosX+self.m_Width/2-6, self.m_PosY+2+self.m_Height/2-6, 16, 16, self:makePath("LocalPlayer.png", true), self.m_Rotation - rotZ) -- dunno where the 6 comes from but it matches better
end

function HUDRadar:worldToMapPosition(worldX, worldY)
	local mapX = worldX / ( 6000/self.m_ImageSize) + self.m_ImageSize/2
	local mapY = worldY / (-6000/self.m_ImageSize) + self.m_ImageSize/2
	return mapX, mapY
end

function HUDRadar:setZoom(zoom)
	error("Not implemented yet")
	self.m_Zoom = zoom
end

function HUDRadar:getZoom()
	return self.m_Zoom
end

function HUDRadar:addBlip(blip)
	table.insert(self.m_Blips, blip)
end

function HUDRadar:removeBlip(blip)
	local idx = table.find(self.m_Blips, blip)
	if idx then
		table.remove(self.m_Blips, idx)
	end
end

function HUDRadar:addArea(worldX, worldY, width, height, color)
	local area = Rect:new(worldX, worldY, width, height)
	if type(color) == "table" then
		color = tocolor(unpack(color))
	end
	area.color = color
	local r, g, b, a = getBytesInInt32(area.color)
	area.mtaElement = createRadarArea(worldX, worldY-height, width, height, r, g, b, a)
	table.insert(self.m_Areas, area)
	self:updateMapTexture()
	return area
end

function HUDRadar:removeArea(area)
	local idx = table.find(self.m_Areas)
	if idx then
		destroyElement(self.m_Areas[idx].mtaElement)
		table.remove(self.m_Areas, idx)
		self:updateMapTexture()
	end
end


-- Radar area RPCs
HUDRadar.ServerAreas = {}
addEvent("radarAreaCreate", true)
addEventHandler("radarAreaCreate", root,
	function(index, x, y, width, height, color)
		HUDRadar.ServerAreas[index] = HUDRadar:getSingleton():addArea(x, y, width, height, color)
	end
)

addEvent("radarAreaDestroy", true)
addEventHandler("radarAreaDestroy", root,
	function(index)
		if HUDRadar.ServerAreas[index] then
			HUDRadar:getSingleton():removeArea(HUDRadar.ServerAreas[index])
		end
	end
)

addEvent("radarAreasRetrieve", true)
addEventHandler("radarAreasRetrieve", root,
	function(data)
		for k, v in pairs(data) do
			HUDRadar.ServerAreas[k] = HUDRadar:getSingleton():addArea(unpack(v))
		end
	end
)
