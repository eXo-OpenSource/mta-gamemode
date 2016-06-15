-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/CustomF11Map.lua
-- *  PURPOSE:     Custom f11 map class
-- *
-- ****************************************************************************
CustomF11Map = inherit(Singleton)

function CustomF11Map:constructor()
	self.m_RenderFunc = bind(self.draw, self)
	self.m_Visible = false
	self.m_Enabled = false
end

function CustomF11Map:destructor()
	self:disable()
end

function CustomF11Map:enable()
	toggleControl("radar", false)
	forcePlayerMap(false)
	self.m_Enabled = true
end

function CustomF11Map:toggle()
	if not self.m_Enabled then return end

	self.m_Visible = not self.m_Visible

	if self.m_Visible then
		addEventHandler("onClientRender", root, self.m_RenderFunc)
	else
		removeEventHandler("onClientRender", root, self.m_RenderFunc)
	end
end

function CustomF11Map:disable()
	toggleControl("radar", true)

	self.m_Enabled = false
	self.m_Visible = false
	removeEventHandler("onClientRender", root, self.m_RenderFunc)
end

function CustomF11Map:draw()
	local height = screenHeight
	local mapPosX, mapPosY = screenWidth/2-height/2, 0

	-- Draw map
	dxDrawImage(mapPosX, mapPosY, height, height, HUDRadar:getSingleton():makePath("Radar.jpg"), 0, 0, 0, tocolor(255, 255, 255, 200))

	-- Draw gang areas
	if core:get("HUD", "drawGangAreas", true) then
		for i, v in pairs(HUDRadar:getSingleton().m_Areas) do
			local mapX, mapY = CustomF11Map.worldToMapPosition(v.X, v.Y)
			local width, height = v.Width/(6000/height), v.Height/(6000/height)
			local r, g, b = fromcolor(v.color)

			if v.flashing then
				dxDrawRectangle(mapPosX + mapX, mapPosY + mapY,  width, height, Color.Red)
				dxDrawRectangle(mapPosX + mapX + 2, mapPosY + mapY + 2,  width - 4, height - 4, tocolor(r, g, b, 165))
			else
				dxDrawRectangle(mapPosX + mapX, mapPosY + mapY,  width, height, tocolor(r, g, b, 165))
			end
		end
	end

	-- Draw blips
	if core:get("HUD", "drawBlips", true) then
		for i, blip in pairs(Blip.Blips) do
			local posX, posY = blip:getPosition()

			if Blip.AttachedBlips[blip] then
				posX, posY = getElementPosition(Blip.AttachedBlips[blip])
			end
			local mapX, mapY = CustomF11Map.worldToMapPosition(posX, posY)
			dxDrawImage(mapPosX + mapX - 9, mapPosY + mapY - 9, 18, 18, blip.m_ImagePath, 0)
		end
	end

	-- Draw local player blip
	local rotX, rotY, rotZ = getElementRotation(localPlayer)
	local posX, posY = getElementPosition(localPlayer)
	local mapX, mapY = CustomF11Map.worldToMapPosition(posX, posY)
	dxDrawImage(mapPosX + mapX - 8, mapPosY + mapY - 8, 16, 16, HUDRadar:getSingleton():makePath("LocalPlayer.png", true), -rotZ)
end

function CustomF11Map.worldToMapPosition(worldX, worldY)
	local height = screenHeight
	local mapX = worldX / ( 6000/height) + height/2
	local mapY = worldY / (-6000/height) + height/2
	return mapX, mapY
end
