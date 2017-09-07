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

	self.m_CenterPosX = screenWidth/2  -- point on screen where the world center point is
	self.m_CenterPosY = screenHeight/2
	self.m_Height = screenHeight
	self.m_Zoom = 1

	self.m_ClickOverlay = GUIElement:new(0, 0, screenWidth, screenHeight)
	self.m_ClickOverlay:setVisible(false)
	self.m_ClickOverlay.onLeftDoubleClick = bind(self.Doubleclick_ClickOverlay, self)
	self.m_ClickOverlay.onRightClick = bind(self.Rightclick_ClickOverlay, self)
	self.m_ClickOverlay.onMouseWheelUp = bind(self.zoom, self, true)
	self.m_ClickOverlay.onMouseWheelDown = bind(self.zoom, self, false)
	self.m_ClickOverlay.onLeftClickDown = bind(self.move, self, true)
	self.m_ClickOverlay.onLeftClick = bind(self.move, self, false)

	self.m_BlipList = GUIGridList:new(screenWidth - self.m_Height * 0.3, 0, self.m_Height * 0.3, self.m_Height)
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

function CustomF11Map:setCustomClickCallback(func)
	outputDebug(func)
	if not self.m_CustomCallback then
		self.m_CustomCallback = func
		if not self.m_Visible then
			self:toggle()
		end
		showCursor(true)
	end
end

function CustomF11Map:toggle()
	if not self.m_Enabled then return end
	if isPedDead(localPlayer) then return end

	if not self.m_Visible then
		self.m_Visible = true
		HUDRadar:getSingleton():hide()
		HUDUI:getSingleton():hide()
		HUDSpeedo:getSingleton():hide()
		self:updateBlipList()
		addEventHandler("onClientRender", root, self.m_RenderFunc, false, "high")
		self.m_ClickOverlay:setVisible(true)
		self.m_BlipList:setVisible(true)
	elseif not self.m_CustomCallback then
		self.m_Visible = false
		HUDRadar:getSingleton():show()
		HUDUI:getSingleton():show()
		HUDSpeedo:getSingleton():show()
		self.m_ClickOverlay:setVisible(false)
		self.m_BlipList:setVisible(false)
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
	local height = self.m_Height * self.m_Zoom
	local centerPosX, centerPosY = self.m_CenterPosX, self.m_CenterPosY
	local px, py, pz = getElementPosition(localPlayer)

	if self.m_Moving then
		local mapX, mapY = self:cursorToMapPosition()
		if mapX and self.m_ClickOverlay == GUIElement.getHoveredElement() then
			centerPosX = centerPosX + (mapX - self.m_MoveStartCursorMap[1])
			centerPosY = centerPosY + (mapY - self.m_MoveStartCursorMap[2])
			centerPosX, centerPosY = self:snapMapToScreenBounds(centerPosX, centerPosY, height) --snap moving
		else
			self:move() -- stop moving when user hides his cursor
		end
	else
		centerPosX, centerPosY = self:snapMapToScreenBounds(centerPosX, centerPosY, height, true) --snap actual map to prevent move bugs
	end
	
	local mapPosX, mapPosY = centerPosX - height /2, centerPosY - height /2 
	-- Draw map
	dxDrawImage(mapPosX, mapPosY, height, height, HUDRadar:getSingleton():getImagePath(false, true), 0, 0, 0, tocolor(255, 255, 255, core:get("HUD","mapOpacity", 0.7)*255))
	local routeRenderTarget = HUDRadar:getSingleton():getRouteRenderTarget()
	if routeRenderTarget then
		dxDrawImage(mapPosX, mapPosY, height, height, routeRenderTarget, 0, 0, 0, tocolor(255, 255, 255, core:get("HUD","mapOpacity", 0.7)*255))
	end

	-- Draw GPS info
	dxDrawRectangle(0, 0, screenWidth, 30, tocolor(0, 0, 0, 140))
	dxDrawText(_"Informationen zur Bedienung der Karte findest du im F1-Hilfemenü", screenWidth/2, 15, nil, nil, Color.White, 1, VRPFont(25), "center", "center")

	-- Draw gang areas
	if core:get("HUD", "drawGangAreas", true) then
		for i, v in pairs(HUDRadar:getSingleton().m_Areas) do
			local mapX, mapY = self:worldToMapPosition(v.X, v.Y)
			local width, height = v.Width/(6000/height), v.Height/(6000/height)
			local r, g, b = fromcolor(v.color)

			if v.flashing then
				dxDrawRectangle(centerPosX + mapX, centerPosY + mapY,  width, height, Color.Red)
				dxDrawRectangle(centerPosX + mapX + 2, centerPosY + mapY + 2,  width - 4, height - 4, tocolor(r, g, b, core:get("HUD","mapOpacity", 0.7)*165))
			else
				dxDrawRectangle(centerPosX + mapX, centerPosY + mapY,  width, height, tocolor(r, g, b, core:get("HUD","mapOpacity", 0.7)*165))
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
				local isMouseOverBlip = isCursorOverArea(centerPosX + mapX - size/2, centerPosY + mapY - size/2, size, size) and not self.m_BlipToolTipShowing
				if (self.m_CurrentClickedBlip and self.m_CurrentClickedBlip == blip:getDisplayText()) or isMouseOverBlip then size = size * 1.5 end
				
				local color = blip:getColor()
				if color == Color.White and core:get("HUD", "coloredBlips", true) then color = blip:getOptionalColor() end
				
				local imagePath = blip:getImagePath()
				if blip.m_RawImagePath == "Marker.png" and blip:getZ() then
					if math.abs(pz - blip:getZ()) > 3 then
						local markerImage = blip:getZ() > pz and "Marker_up.png" or "Marker_down.png"
						imagePath = HUDRadar:getSingleton():getImagePath(markerImage)
					end
				end
				dxDrawImage(centerPosX + mapX - size/2, centerPosY + mapY - size/2, size, size, imagePath, 0, 0, 0, color)
				if isMouseOverBlip and blip:getDisplayText() then
					self.m_BlipToolTipShowing = {blip, centerPosX + mapX, centerPosY + mapY - size/2}
				end
			end
		end
		if self.m_BlipToolTipShowing then --always draw tooltips on top of other blips
			blip, x, y = unpack(self.m_BlipToolTipShowing)
			dxDrawToolTip(x, y, blip:getDisplayText())
		end
		self.m_BlipToolTipShowing = nil
	end

	-- Draw local player blip
	local rotX, rotY, rotZ = getElementRotation(localPlayer)
	local posX, posY = getElementPosition(localPlayer)
	local mapX, mapY = self:worldToMapPosition(posX, posY)
	local size = Blip.getDefaultSize() * Blip.getScaleMultiplier()
	dxDrawImage(centerPosX + mapX - size/2, centerPosY + mapY - size/2, size, size, HUDRadar:getSingleton():getImagePath("LocalPlayer.png"), -rotZ)

	--draw coordinate and zone info
	if isCursorOverArea(mapPosX, mapPosY, height, height) and getKeyState("lshift") then
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
		local mapX, mapY = self:cursorToMapPosition()
		
		local worldX, worldY = self:mapToWorldPosition(mapX, mapY)
		local text = getOpticalZoneName(worldX, worldY)
		if localPlayer:getRank() >= ADMIN_RANK_PERMISSION["gotocords"] then
			text = ("%s\nX:%s  Y:%s"):format(getOpticalZoneName(worldX, worldY), math.floor(worldX), math.floor(worldY))
		end
		dxDrawText(text, cursorX + 1, cursorY + 1, cursorX + 1, cursorY + 1, Color.Black, 1, "default-bold", "center", "bottom")
		dxDrawText(text, cursorX, cursorY, cursorX, cursorY, Color.White, 1, "default-bold", "center", "bottom")
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/F11Map") end
end

function CustomF11Map:setWorldCenterPosition(worldX, worldY)
	local mapX, mapY = self:worldToMapPosition(worldX, worldY)
	self.m_CenterPosX = screenWidth/2 - mapX -- point on screen where the world center point is
	self.m_CenterPosY = screenHeight/2 - mapY
end

function CustomF11Map:setMapCenterPosition(mapX, mapY)
	self.m_CenterPosX = screenWidth/2 - mapX -- point on screen where the world center point is
	self.m_CenterPosY = screenHeight/2 - mapY
end


function CustomF11Map:worldToMapPosition(worldX, worldY)
	local mapX = worldX / ( 6000/self.m_Height/self.m_Zoom)
	local mapY = worldY / (-6000/self.m_Height/self.m_Zoom)
	
	return mapX, mapY
end

function CustomF11Map:mapToWorldPosition(mapX, mapY)
	local worldX = mapX * 6000/self.m_Height/self.m_Zoom
	local worldY = mapY * -6000/self.m_Height/self.m_Zoom

	return worldX, worldY
end

function CustomF11Map:cursorToMapPosition(fallback)
	if isCursorShowing() then
		local cx, cy = getCursorPosition()
		cx, cy = cx * screenWidth, cy * screenHeight
		return cx - self.m_CenterPosX, cy - self.m_CenterPosY
	elseif fallback then -- take the screen center
		return screenWidth/2 - self.m_CenterPosX, screenHeight/2 - self.m_CenterPosY
	end
end

function CustomF11Map:snapMapToScreenBounds(centerX, centerY, height, withUpdate)
	local offsX = screenWidth/2 - screenHeight/2
	if centerX - height/2 > offsX then
		centerX = offsX + height/2
	elseif centerX + height/2 < screenWidth - offsX then
		centerX = screenWidth - height/2 - offsX
	end
	if centerY - height/2 > 0 then 
		centerY = height/2 
	elseif centerY + height/2 < screenHeight then
		centerY = screenHeight - height/2 
	end
	if withUpdate then
		self.m_CenterPosX = centerX
		self.m_CenterPosY = centerY
	end
	return centerX, centerY
end

function CustomF11Map:Doubleclick_ClickOverlay(element, cursorX, cursorY)
	local mapX, mapY = self:cursorToMapPosition()
	local worldX, worldY = self:mapToWorldPosition(mapX, mapY)
	if self.m_CustomCallback then
		if self.m_CustomCallback(worldX, worldY) then
			self.m_CustomCallback = nil
			self:toggle()
		end
	else
		-- Start navigation to that point
		GPS:getSingleton():startNavigationTo(Vector3(worldX, worldY, 0))
	end
end

function CustomF11Map:Rightclick_ClickOverlay(element, cursorX, cursorY)
	if getKeyState("lshift") and localPlayer:getRank() >= ADMIN_RANK_PERMISSION["gotocords"] then
		fadeCamera(false)
		local cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX * screenWidth, cursorY * screenHeight
		local mapX, mapY = self:cursorToMapPosition(cursorX, cursorY)
		local worldX, worldY = self:mapToWorldPosition(mapX, mapY)
		setTimer(function()
			local teleportElement = localPlayer.vehicle and localPlayer.vehicle or localPlayer
			teleportElement:setFrozen(true)
			teleportElement:setPosition(worldX, worldY, 0)
			setTimer(function()
				local z = getGroundPosition(worldX, worldY, 500)
				triggerServerEvent("adminTriggerFunction", root, "gotocords", {worldX, worldY, z+2})
				fadeCamera(true)
				teleportElement:setFrozen(false)
			end, 250, 1)
		end, 2000, 1)	
	else
		GPS:getSingleton():stopNavigation()
	end
end

function CustomF11Map:zoom(zoomIn)
	if self.m_Moving then return false end -- otherwise this causes trouble with the map center
	local oldMapCenterX = screenWidth/2 - self.m_CenterPosX -- this saves the world position at the map center to re-center the map 
	local oldMapCenterY = screenHeight/2 - self.m_CenterPosY
	local oldWorldPosX, oldWorldPosY = self:mapToWorldPosition(oldMapCenterX, oldMapCenterY)
	self.m_Zoom = math.clamp(1, self.m_Zoom + (zoomIn and 0.05 or -0.05), 2)
	self.m_Height = screenHeight * self.m_Zoom
	self:setWorldCenterPosition(oldWorldPosX, oldWorldPosY)
end

function CustomF11Map:move(start)
	if start and not self.m_Moving and self.m_ClickOverlay == GUIElement.getHoveredElement() then
		self.m_MoveStartCursorMap = {self:cursorToMapPosition()}
		self.m_Moving = true
	elseif not start and self.m_Moving then
		local mapX, mapY = self:cursorToMapPosition(true)
		self:setMapCenterPosition((screenWidth/2 - self.m_CenterPosX) + (self.m_MoveStartCursorMap[1] - mapX), (screenHeight/2 - self.m_CenterPosY) + (self.m_MoveStartCursorMap[2] - mapY))
		self.m_Moving = false
	end
end
