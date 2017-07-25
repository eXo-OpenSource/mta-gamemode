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

	self.m_PosX = screenWidth/2 - screenHeight/2
	self.m_PosY = 0
	self.m_Width = screenHeight
	self.m_Height = screenHeight

	self.m_ClickOverlay = GUIElement:new(self.m_PosX, self.m_PosY, self.m_Width, self.m_Height)
	self.m_ClickOverlay:setVisible(false)
	self.m_ClickOverlay.onLeftDoubleClick = bind(self.Doubleclick_ClickOverlay, self)
	self.m_ClickOverlay.onRightClick = bind(self.Rightclick_ClickOverlay, self)

	self.m_BlipList = GUIGridList:new(self.m_PosX + self.m_Width + self.m_PosX * 0.1, self.m_PosY + self.m_PosX * 0.1, self.m_PosX * 0.8, self.m_Height - self.m_PosX * 0.2)
	self.m_BlipList:addColumn("", 0.1)
	self.m_BlipList:addColumn("Blip-Übersicht", 0.9)
	self.m_BlipList:setVisible(false)
end

function CustomF11Map:destructor()
	self:disable()
end

function CustomF11Map:toggleMapKeys(state)
	toggleControl("radar", state)
	toggleControl("radar_zoom_in", state)
	toggleControl("radar_zoom_out", state)
	toggleControl("radar_move_north", state)
	toggleControl("radar_move_south", state)
	toggleControl("radar_move_east", state)
	toggleControl("radar_move_west", state)
end

function CustomF11Map:enable()
	self:toggleMapKeys(false)

	forcePlayerMap(false)
	self.m_Enabled = true
end

function CustomF11Map:toggle()
	if not self.m_Enabled then return end

	self.m_Visible = not self.m_Visible
	self.m_ClickOverlay:setVisible(self.m_Visible)
	self.m_BlipList:setVisible(self.m_Visible)

	if self.m_Visible then
		HUDRadar:getSingleton():hide()
		HUDUI:getSingleton():hide()
		HUDSpeedo:getSingleton():hide()
		self:updateBlipList()
		addEventHandler("onClientRender", root, self.m_RenderFunc)
	else
		HUDRadar:getSingleton():show()
		HUDUI:getSingleton():show()
		HUDSpeedo:getSingleton():show()
		removeEventHandler("onClientRender", root, self.m_RenderFunc)
	end
end

function CustomF11Map:disable()
	self:toggleMapKeys(true)

	self.m_Enabled = false
	self.m_Visible = false
	self.m_ClickOverlay:setVisible(false)
	self.m_BlipList:setVisible(false)

	removeEventHandler("onClientRender", root, self.m_RenderFunc)
end

function CustomF11Map:updateBlipList()
	if self.m_Visible then
		self.m_BlipList:clear()
		self.m_CurrentClickedBlip = nil
		for i, cat in pairs(BLIP_CATEGORY_ORDER) do
			local texts = Blip.DisplayTexts[cat]
			if texts then
				self.m_BlipList:addItemNoClick("", cat)
				for text, blips in pairs(texts) do
					local blip = blips[1]
					local item = self.m_BlipList:addItem(blip:getImagePath(), text..(#blips > 1 and " ("..(#blips)..")" or ""))
					local color = blip:getColor()
					local saveName = blip:getSaveName()
					if color == Color.White and core:get("HUD", "coloredBlips", true) then color = blip:getOptionalColor() end
					item:setColumnToImage(1, true, item.m_Height - 6)
					item:setColumnColor(1, core:get("BlipVisibility", saveName, true) and color or Color.Clear)
					item:setColor(core:get("BlipVisibility", saveName, true) and Color.White or Color.LightGrey)
					item.onLeftDoubleClick = function()
						local closest, target = math.huge
						for i, b in pairs(blips) do
							if getDistanceBetweenPoints3D(localPlayer.position, b:getPosition(true)) < closest then
								closest = getDistanceBetweenPoints3D(localPlayer.position, b:getPosition(true))
								target = b
							end
						end
						GPS:getSingleton():startNavigationTo(target:getPosition(true))
					end	
					item.onLeftClick = function()
						self.m_CurrentClickedBlip = text
					end	
					item.onRightClick = function()
						core:set("BlipVisibility", saveName, not core:get("BlipVisibility", saveName, true))
						item:setColumnColor(1, core:get("BlipVisibility", saveName, true) and color or Color.Clear)
						item:setColor(core:get("BlipVisibility", saveName, true) and Color.White or Color.LightGrey)
					end	

					core:get("HUD", "coloredBlips", true)
				end
			end
		end
	end
end

function CustomF11Map:draw()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/F11Map") end
	local height = self.m_Height
	local mapPosX, mapPosY = self.m_PosX, self.m_PosY

	-- Draw map
	dxDrawImage(mapPosX, mapPosY, height, height, HUDRadar:getSingleton():makePath("Radar.jpg"), 0, 0, 0, tocolor(255, 255, 255, 200))
	local routeRenderTarget = HUDRadar:getSingleton():getRouteRenderTarget()
	if routeRenderTarget then
		dxDrawImage(mapPosX, mapPosY, height, height, routeRenderTarget, 0, 0, 0, tocolor(255, 255, 255, 200))
	end

	-- Draw GPS info
	dxDrawRectangle(self.m_PosX, 0, self.m_Width, 25, tocolor(0, 0, 0, 140))
	dxDrawText("Doppelklick auf die Karte, um die Zielposition des GPS zu setzen. Rechtsklick, um die Navigation zu beenden.", screenWidth/2, 5, nil, nil, Color.White, 1, "default-bold", "center")

	-- Draw gang areas
	if core:get("HUD", "drawGangAreas", true) then
		for i, v in pairs(HUDRadar:getSingleton().m_Areas) do
			local mapX, mapY = self:worldToMapPosition(v.X, v.Y)
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
			if DEBUG then ExecTimeRecorder:getSingleton():addIteration("UI/HUD/F11Map") end
			local display = true
			local posX, posY = blip:getPosition()

			if blip:getSaveName() and not core:get("BlipVisibility", blip:getSaveName(), true) then
				display = false
			end

			if Blip.AttachedBlips[blip] then
				if not isElement(Blip.AttachedBlips[blip]) then Blip.AttachedBlips[blip] = nil end
				local int, dim = Blip.AttachedBlips[blip]:getInterior(), Blip.AttachedBlips[blip]:getDimension()
				if int == 0 and dim == 0 then
					posX, posY = getElementPosition(Blip.AttachedBlips[blip])
				else
					display = false
				end
			end
			if display then
				if DEBUG then ExecTimeRecorder:getSingleton():addIteration("UI/HUD/F11Map", true) end
				local mapX, mapY = self:worldToMapPosition(posX, posY)
				local size = blip:getSize() * Blip.getScaleMultiplier()
				if self.m_CurrentClickedBlip and self.m_CurrentClickedBlip == blip:getDisplayText() then size = size * 1.5 end
				
				local color = blip:getColor()
				if color == Color.White and core:get("HUD", "coloredBlips", true) then color = blip:getOptionalColor() end
				
				local imagePath = blip:getImagePath()
				if blip.m_RawImagePath == "Marker.png" and blip:getZ() then
					if math.abs(pz - blip:getZ()) > 3 then
						local markerImage = blip:getZ() > pz and "Marker_up.png" or "Marker_down.png"
						imagePath = HUDRadar:getSingleton():makePath(markerImage, true)
					end
				end

				dxDrawImage(mapPosX + mapX - size/2, mapPosY + mapY - size/2, size, size, imagePath, 0, 0, 0, color)
			end
		end
	end

	-- Draw local player blip
	local rotX, rotY, rotZ = getElementRotation(localPlayer)
	local posX, posY = getElementPosition(localPlayer)
	local mapX, mapY = self:worldToMapPosition(posX, posY)
	local size = Blip.getDefaultSize() * Blip.getScaleMultiplier()
	dxDrawImage(mapPosX + mapX - size/2, mapPosY + mapY - size/2, size, size, HUDRadar:getSingleton():makePath("LocalPlayer.png", true), -rotZ)

	--draw coordinate and zone info
	if isCursorOverArea(self.m_PosX, self.m_PosY, self.m_Width, self.m_Height) and getKeyState("lshift") then
		local cursorX, cursorY = getCursorPosition()
			cursorX = cursorX * screenWidth cursorY = cursorY * screenHeight
		local overlayX, overlayY = self.m_ClickOverlay:getPosition(true)
		local mapX, mapY = cursorX - overlayX, cursorY - overlayY
		local worldX, worldY = self:mapToWorldPosition(mapX, mapY)
		local text = getOpticalZoneName(worldX, worldY)
		if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["gotocords"] then
			text = ("%s\nX:%s  Y:%s"):format(getOpticalZoneName(worldX, worldY), math.floor(worldX), math.floor(worldY))
		end
		--dxDrawRectangle(cx, cy, self.m_Width, 25, tocolor(0, 0, 0, 140))
		dxDrawText(text, cursorX + 1, cursorY + 1, cursorX + 1, cursorY + 1, Color.Black, 1, "default-bold", "center", "bottom")
		dxDrawText(text, cursorX, cursorY, cursorX, cursorY, Color.White, 1, "default-bold", "center", "bottom")
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/F11Map") end
end

function CustomF11Map:worldToMapPosition(worldX, worldY)
	local mapX = worldX / ( 6000/self.m_Width) + self.m_Width/2
	local mapY = worldY / (-6000/self.m_Height) + self.m_Height/2

	return mapX, mapY
end

function CustomF11Map:mapToWorldPosition(mapX, mapY)
	local worldX = (mapX - self.m_Width/2) * 6000/self.m_Width
	local worldY = (mapY - self.m_Height/2) * -6000/self.m_Height

	return worldX, worldY
end

function CustomF11Map:Doubleclick_ClickOverlay(element, cursorX, cursorY)
	-- Get position on map
	local overlayX, overlayY = self.m_ClickOverlay:getPosition(true)
	local mapX, mapY = cursorX - overlayX, cursorY - overlayY

	-- Calculate world position
	local worldX, worldY = self:mapToWorldPosition(mapX, mapY)

	-- Start navigation to that point
	GPS:getSingleton():startNavigationTo(Vector3(worldX, worldY, 0))
end

function CustomF11Map:Rightclick_ClickOverlay(element, cursorX, cursorY)
	if getKeyState("lshift") and localPlayer:getRank() >= ADMIN_RANK_PERMISSION["gotocords"] then
		fadeCamera(false)
		setTimer(function()
			local overlayX, overlayY = self.m_ClickOverlay:getPosition(true)
			local mapX, mapY = cursorX - overlayX, cursorY - overlayY
			local worldX, worldY = self:mapToWorldPosition(mapX, mapY)
			local teleportElement = localPlayer.vehicle and localPlayer.vehicle or localPlayer
			teleportElement:setFrozen(true)
			teleportElement:setPosition(worldX, worldY, 0)
			teleportElement:setInterior(0)
			teleportElement:setDimension(0)
			if not teleportElement.vehicle then
				localPlayer:setInterior(0)
				localPlayer:setDimension(0)
			end

			setTimer(function()
				local z = getGroundPosition(worldX, worldY, 500)
				teleportElement:setPosition(worldX, worldY, z + 2)
				fadeCamera(true)
				teleportElement:setFrozen(false)
			end, 250, 1)
		end, 2000, 1)	
	else
		GPS:getSingleton():stopNavigation()
	end
end
