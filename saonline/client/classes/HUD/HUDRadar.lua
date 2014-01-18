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
	self.m_Texture = dxCreateRenderTarget(self.m_ImageWidth, self.m_ImageHeight)
	self.m_Width, self.m_Height = 340*screenWidth/1600, 200*screenHeight/900
	self.m_PosX, self.m_PosY = 20, screenHeight-self.m_Height-(self.m_Height/20+9)-20
	self.m_Zoom = 1
	self.m_Rotation = 0
	self.m_Diagonal = math.sqrt(self.m_Width^2+self.m_Height^2)
	self.m_Blips = {}
	
	-- Set texture edge to border (no-repeat) | Not yet available in current 1.3.4 build (probably 1.3.5 onwards)
	if dxSetTextureEdge then
		dxSetTextureEdge(self.m_Texture, "border", tocolor(51, 70, 77))
	end
	
	-- Render the map texture (incl. blips)
	self:rerenderMapTexture()
	
	-- Create a renderTarget that has the size of the diagonal of the actual image
	self.m_RenderTarget = dxCreateRenderTarget(self.m_ImageWidth, self.m_ImageHeight)
	
	addEventHandler("onClientPreRender", root, bind(self.update, self))
	addEventHandler("onClientRender", root, bind(self.draw, self))
	addEventHandler("onClientRestore", root, bind(self.restore, self))
	showPlayerHudComponent("radar", false)
end

function HUDRadar:update()
	if getControlState("forwards") or isPedInVehicle(localPlayer)  then
		local element = getPedOccupiedVehicle(localPlayer) or localPlayer
		local _, _, rotation = getElementRotation(element)
		self.m_Rotation = rotation
	end
end

function HUDRadar:draw()
	-- Draw the rectangle (the border)
	dxDrawRectangle(self.m_PosX, self.m_PosY, self.m_Width+6, self.m_Height+self.m_Height/20+9, tocolor(0, 0, 0))
	
	-- Draw the map
	local posX, posY, posZ = getElementPosition(localPlayer)
	local mapX = posX / (6000 /self.m_ImageWidth)  + self.m_ImageWidth/2  - self.m_Diagonal / 2 / self.m_Zoom
	local mapY = posY / (-6000/self.m_ImageHeight) + self.m_ImageHeight/2 - self.m_Diagonal / 2 / self.m_Zoom
	local leftX, leftY = mapX+self.m_Diagonal/2, mapY+self.m_Diagonal/2
	
	-- Render (rotated) image section to renderTarget
	dxSetRenderTarget(self.m_RenderTarget, true)
	--local rightEdge, bottomEdge = mapX + self.m_Diagonal/self.m_Zoom, mapY + self.m_Diagonal/self.m_Zoom
	dxDrawRectangle(0, 0, self.m_Diagonal, self.m_Diagonal, tocolor(255,255,255))
	dxDrawImageSection(0, 0, self.m_Diagonal, self.m_Diagonal, mapX, mapY, self.m_Diagonal/self.m_Zoom, self.m_Diagonal/self.m_Zoom, self.m_Texture, self.m_Rotation)
	dxSetRenderTarget()
	
	-- Draw renderTarget
	dxDrawImageSection(self.m_PosX+3, self.m_PosY+3, self.m_Width, self.m_Height, self.m_Diagonal/2-self.m_Width/2, self.m_Diagonal/2-self.m_Height/2, self.m_Width, self.m_Height, self.m_RenderTarget)
	
	-- Draw health bar (at the bottom)
	dxDrawRectangle(self.m_PosX+3, self.m_PosY+self.m_Height+6, self.m_Width/2, self.m_Height/20, tocolor(71, 86, 75))
	dxDrawRectangle(self.m_PosX+3, self.m_PosY+self.m_Height+6, self.m_Width/2 * getElementHealth(localPlayer)/100, self.m_Height/20, tocolor(100, 121, 105))
	
	-- Draw armor bar
	dxDrawRectangle(self.m_PosX+self.m_Width/2+6, self.m_PosY+self.m_Height+6, self.m_Width/4, self.m_Height/20, tocolor(63, 105, 202))
	dxDrawRectangle(self.m_PosX+self.m_Width/2+6, self.m_PosY+self.m_Height+6, self.m_Width/4 * (getPedArmor(localPlayer)/100), self.m_Height/20, tocolor(77, 154, 202))
	
	-- Draw oxygen bar
	dxDrawRectangle(self.m_PosX+self.m_Width*3/4+9, self.m_PosY+self.m_Height+6, self.m_Width/4-6, self.m_Height/20, tocolor(65, 56, 15))
	dxDrawRectangle(self.m_PosX+self.m_Width*3/4+9, self.m_PosY+self.m_Height+6, (self.m_Width/4-6) * (getPedOxygenLevel(localPlayer)/1000), self.m_Height/20, tocolor(91, 79, 21))
	
	-- Draw the player blip
	dxDrawImage(self.m_PosX+self.m_Width/2-8, self.m_PosY+2+self.m_Height/2-8, 16, 16, "files/images/Blips/LocalPlayer.png", 0)
	
	-- Test
	--[[local wX, wY = self.m_Blips[1]:getPosition()
	wX, wY = self:worldToMapPosition(wX, wY)
	outputDebugString(("%d %d"):format(leftX, leftY))
	local x, y = self:getBlipRenderPosition(wX-leftX, wY-leftY)
	dxDrawImage(self.m_PosX+x, self.m_PosY+y, 16, 16, self.m_Blips[1]:getImagePath())
	dxDrawLine(self.m_PosX+self.m_Width/2, self.m_PosY+self.m_Height/2, x, y, tocolor(255,0,0))]]
end

function HUDRadar:worldToMapPosition(worldX, worldY)
	local mapX = worldX / (6000 /self.m_ImageWidth)  + self.m_ImageWidth/2
	local mapY = worldY / (-6000/self.m_ImageHeight) + self.m_ImageHeight/2
	return mapX, mapY
end

function HUDRadar:setZoom(zoom)
	self.m_Zoom = zoom
end

function HUDRadar:getZoom()
	return self.m_Zoom
end

function HUDRadar:addBlip(blipPath, worldX, worldY)
	local blip = new(RadarBlip, blipPath, worldX, worldY)
	table.insert(self.m_Blips, blip)
	
	self:rerenderMapTexture()
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

function HUDRadar:rerenderMapTexture()
	-- Enter map render zone
	dxSetRenderTarget(self.m_Texture, true)
	
	-- Draw the map
	dxDrawImage(0, 0, self.m_ImageWidth, self.m_ImageHeight, "files/images/Radar.jpg")
	
	-- Draw the other, "normal" blips
	for k, blip in ipairs(self.m_Blips) do
		local blipX, blipY = blip:getPosition()
		local mapX, mapY = self:worldToMapPosition(blipX, blipY)
		local size = blip:getSize()
		dxDrawImage(mapX-size/2, mapY-size/2, size, size, blip:getImagePath())
	end
	
	-- Leave map render zone
	dxSetRenderTarget()
end

function HUDRadar:restore(clearedRenderTargets)
	if clearedRenderTargets then
		self:rerenderMapTexture()
	end
end

function HUDRadar:getBlipRenderPosition(blipX, blipY)
	-- Check if we're colliding with the border (the blip is outside of the radar box)
	local borders = {
		{position = {0, 0}, direction = {1, 0}}, -- top
		{position = {0, 0}, direction = {0, -1}}, -- left
		{position = {0, self.m_Height}, direction = {1, 0}}, -- bottom
		{position = {self.m_Width, self.m_Height}, direction = {0, 1}} -- right
	}
	local w = {position = {self.m_Width/2, self.m_Height/2}, direction = {blipX - self.m_Width/2, blipY - self.m_Height/2}}
	
	-- Get point of intersection
	for k, v in ipairs(borders) do
		local d = v.direction[1] * w.direction[2] - v.direction[2] * w.direction[1]
		if d ~= 0 then
			local d1 = (w.position[1]-v.position[1])*w.direction[2] - (w.position[2]-v.position[2])*w.direction[1]
			local d2 = (w.position[2]-v.position[2])*v.direction[1] - (w.position[1]-v.position[1])*v.direction[2]
			local px = v.position[1] + d1/d * v.direction[1]
			local py = v.position[2] + d1/d * v.direction[2]
			
			return px, py
		end
	end
	
	return 0, 0 --blipX, blipY
end
