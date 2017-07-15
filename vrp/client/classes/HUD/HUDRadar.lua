-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: client/classes/HUD/HUDRadar.lua
-- * PURPOSE: HUD radar class
-- *
-- ****************************************************************************
HUDRadar = inherit(Singleton)
addRemoteEvents{ "HUDRadar:showRadar", "HUDRadar:hideRadar" }

function HUDRadar:constructor()
	self.m_ImageSize = 1536, 1536 --3072, 3072
	self.m_Width, self.m_Height = 340*screenWidth/1600, 200*screenHeight/900
	self.m_PosX, self.m_PosY = 20, screenHeight-self.m_Height-(self.m_Height/20+9)-30
	self.m_Diagonal = math.sqrt(self.m_Width^2+self.m_Height^2)
	self.m_DesignSet = tonumber(core:getConfig():get("HUD", "RadarDesign")) or RadarDesign.Monochrome

	if self.m_DesignSet == RadarDesign.Monochrome or self.m_DesignSet == RadarDesign.GTA then
		CustomF11Map:getSingleton():enable()
		setPlayerHudComponentVisible("radar", false)
	else
		CustomF11Map:getSingleton():disable()
	end

	self.m_Zoom = 1
	self.m_Rotation = 0
	self.m_Blips = Blip.Blips
	self.m_Areas = {}
	self.m_Visible = false
	self.m_InInterior = false
	self.m_Enabled = core:get("HUD", "showRadar", true)
	if self.m_DesignSet == RadarDesign.Default then
		setPlayerHudComponentVisible("radar", self.m_Enabled)
		self.m_DefaultBlips = {}
	end

	-- Create a renderTarget that has the size of the diagonal of the actual image
	self.m_RenderTarget = dxCreateRenderTarget(self.m_Diagonal, self.m_Diagonal)
	self:updateMapTexture()

	-- Settings
	if core:get("HUD", "showRadar", nil) == nil then
		core:set("HUD", "showRadar", true)
	end
	if core:get("HUD", "drawGangAreas", nil) == nil then
		core:set("HUD", "drawGangAreas", true)
	end
	if core:get("HUD", "drawBlips", nil) == nil then
		core:set("HUD", "drawBlips", true)
	end

	addEventHandler("onClientPreRender", root, bind(self.update, self))
	addEventHandler("onClientRender", root, bind(self.draw, self))
	addEventHandler("onClientRestore", root, bind(self.restore, self))

	addEventHandler("HUDRadar:showRadar", root, bind(self.show, self))
	addEventHandler("HUDRadar:hideRadar", root, bind(self.hide, self))

	self.m_NoRadarColShapes = {
		createColSphere(164.21, 359.71, 7983.66, 200)
	}
	self.m_HitColFunc = bind(self.Event_colEnter,self)
	self.m_LeaveColFunc = bind(self.Event_colLeave,self)
	for index, col in pairs(self.m_NoRadarColShapes) do
		addEventHandler("onClientColShapeHit", col, self.m_HitColFunc)
		addEventHandler("onClientColShapeLeave", col, self.m_LeaveColFunc)
	end
end

function HUDRadar:Event_colEnter( elem, dim)
	if elem == localPlayer then
		if dim then
			self:hide()
		end
	end
end

function HUDRadar:Event_colLeave(elem, dim)
	if elem == localPlayer then
		if dim then
			self:show()
		end
	end
end

function HUDRadar:hide()
	self.m_Visible = false

	-- Recalc shortmessage positions
	MessageBoxManager.onRadarToggle(false)
end

function HUDRadar:show()
	self.m_Visible = true

	-- Recalc shortmessage positions
	MessageBoxManager.onRadarToggle(true)
end

function HUDRadar:updateMapTexture()
	if self.m_DesignSet == RadarDesign.Default then
		return
	end

	-- Recreate map texture
	if self.m_Texture and isElement(self.m_Texture) then
		destroyElement(self.m_Texture)
	end
	self.m_Texture = dxCreateRenderTarget(self.m_ImageSize, self.m_ImageSize)
	dxSetTextureEdge(self.m_Texture, "border", tocolor(125, 168, 210))

	dxSetRenderTarget(self.m_Texture)

	-- Draw actual map texture
	dxDrawImage(0, 0, self.m_ImageSize, self.m_ImageSize, self:makePath("Radar.jpg", false))

	-- Draw radar areas
	if core:get("HUD", "drawGangAreas", true) then
		for k, rect in pairs(self.m_Areas) do
			local mapX, mapY = self:worldToMapPosition(rect.X, rect.Y)
			local width, height = rect.Width/(6000/self.m_ImageSize), rect.Height/(6000/self.m_ImageSize)

			if rect.flashing then
				dxDrawRectangle(mapX, mapY, width, height, Color.Red)
				dxDrawRectangle(mapX+2, mapY+2, width-4, height-4, rect.color)
			else
				dxDrawRectangle(mapX, mapY, width, height, rect.color)
			end
		end
	end

	dxSetRenderTarget(nil)
end

function HUDRadar:makePath(fileName, isBlip)
	if isBlip then return "files/images/Radar/Blips/"..fileName end
	if self.m_DesignSet == RadarDesign.Monochrome then
		return "files/images/Radar/Radar_Monochrome/"..fileName
	elseif self.m_DesignSet == RadarDesign.GTA then
		return "files/images/Radar/Radar_GTA/"..fileName
	end
end

function HUDRadar:setDesignSet(design)
	if design == RadarDesign.Monochrome or design == RadarDesign.GTA then
		CustomF11Map:getSingleton():enable()
	else
		CustomF11Map:getSingleton():disable()
	end

	if design ~= RadarDesign.Default then
		setPlayerHudComponentVisible("radar",false)
		self.m_DesignSet = design
		core:getConfig():set("HUD", "RadarDesign", design)
		self:updateMapTexture()

		for k, blip in pairs(self.m_Blips) do
			blip:updateDesignSet()
		end
	else
		self.m_DesignSet = design
		core:getConfig():set("HUD", "RadarDesign", design)
		setPlayerHudComponentVisible("radar",true)
	end
end

function HUDRadar:getDesignSet()
	return self.m_DesignSet
end

function HUDRadar:setEnabled(state)
	self.m_Enabled = state
	if self.m_DesignSet == RadarDesign.Default then
		setPlayerHudComponentVisible("radar", state)
	end
end

function HUDRadar:isEnabled()
	return self.m_Enabled
end

function HUDRadar:restore(clearedRenderTargets)
	if clearedRenderTargets then
		self:updateMapTexture()
	end
end

function HUDRadar:update()
	if self.m_DesignSet == RadarDesign.Default or not self.m_Visible or isPlayerMapVisible() then
		return
	end

	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and getVehicleType(vehicle) ~= "Plane" and getVehicleType(vehicle) ~= "Helicopter"
	and (getControlState("vehicle_look_behind") or getControlState("vehicle_look_left") or getControlState("vehicle_look_right")) then

		local element = vehicle or localPlayer
		local _, _, rotation = getElementRotation(element)
		self.m_Rotation = rotation
	elseif getControlState("look_behind") then
		self.m_Rotation = -getPedRotation(localPlayer)
	else
		local camX, camY, camZ, lookAtX, lookAtY, lookAtZ = getCameraMatrix()
		self.m_Rotation = 360 - math.deg(math.atan2(lookAtX - camX, lookAtY - camY)) % 360
	end
end

function HUDRadar:draw()
	if not self.m_Enabled or not self.m_Visible or self.m_DesignSet == RadarDesign.Default or isPlayerMapVisible() then
		return
	end

	local isNotInInterior = getElementInterior(localPlayer) == 0
	local isInWater = isElementInWater(localPlayer)
	if not isNotInInterior or localPlayer:getPrivateSync("isInGarage") then
		if MessageBoxManager.Mode == true then -- Todo: find better way to do this
			MessageBoxManager.onRadarToggle(false)
		end
		return
	else
		if MessageBoxManager.Mode == false then -- Todo: find better way to do this
			MessageBoxManager.onRadarToggle(true)
		end
	end

	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/Radar") end
	-- Draw the rectangle (the border)
	dxDrawRectangle(self.m_PosX, self.m_PosY, self.m_Width+6, self.m_Height+self.m_Height/20+9, tocolor(0, 0, 0))

	-- Draw the map
	local posX, posY, posZ = getElementPosition(localPlayer)
	local mapX, mapY = self:worldToMapPosition(posX, posY)
	local obj = localPlayer:getPrivateSync("isSpecting")
	if obj then
		posX, posY, posZ = getElementPosition(obj)
		mapX, mapY = self:worldToMapPosition(posX, posY)
	else
		posX, posY, posZ = getElementPosition(localPlayer)
		mapX, mapY = self:worldToMapPosition(posX, posY)
	end

	-- Render (rotated) image section to renderTarget
	if isNotInInterior then
		dxSetRenderTarget(self.m_RenderTarget, true)

		-- Draw radar map
		dxDrawImageSection(0, 0, self.m_Diagonal, self.m_Diagonal, mapX - self.m_Diagonal/2, mapY - self.m_Diagonal/2, self.m_Diagonal, self.m_Diagonal, self.m_Texture, self.m_Rotation)

		-- Draw route map overlay
		if self.m_RouteRenderTarget then
			dxDrawImageSection(0, 0, self.m_Diagonal, self.m_Diagonal, mapX - self.m_Diagonal/2, mapY - self.m_Diagonal/2, self.m_Diagonal, self.m_Diagonal,
				self.m_RouteRenderTarget, self.m_Rotation)
		end

		dxSetRenderTarget(nil)
	end

	-- Draw renderTarget
	if isNotInInterior then
		dxDrawImageSection(self.m_PosX+3, self.m_PosY+3, self.m_Width, self.m_Height, self.m_Diagonal/2-self.m_Width/2, self.m_Diagonal/2-self.m_Height/2, self.m_Width, self.m_Height, self.m_RenderTarget)
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

	if isNotInInterior and core:get("HUD", "drawBlips", true) then
		self:drawBlips()
	end

	-- Draw region name (above health bar)
	if core:get("HUD", "drawZone", true) then
		dxDrawRectangle(self.m_PosX+3, self.m_PosY+3+self.m_Height-self.m_Height/10, self.m_Width, self.m_Height/10, tocolor(0, 0, 0, 150))
		dxDrawText(getZoneName(localPlayer:getPosition(), false), self.m_PosX+3, self.m_PosY+3+self.m_Height-self.m_Height/10, self.m_Width, self.m_PosY+self.m_Height+3,
			Color.White, 1, VRPFont(self.m_Height/10), "center", "center")
	end

	-- Draw the player blip
	local rotX, rotY, rotZ = getElementRotation(localPlayer)
	dxDrawImage(self.m_PosX+self.m_Width/2-6, self.m_PosY+2+self.m_Height/2-6, 16, 16, self:makePath("LocalPlayer.png", true), self.m_Rotation - rotZ) -- dunno where the 6 comes from but it matches better
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/Radar") end
end

function HUDRadar:drawBlips()
	-- Build matrix that converts world coordinates into the map coordinate system
	--
	-- Steps:
	-- 1) Move world coordinate system so that the player is the center of the world
	-- 2) Scale the coordinate system to the size of our map image (also invert the Y axis here)
	-- 3) Rotate coordinate system
	-- All steps are intrinsic, so multiply matrices the other way round
	--
	local px, py, pz = getElementPosition(localPlayer)
	local mapCenterX, mapCenterY = self.m_PosX + self.m_Width/2, self.m_PosY + self.m_Height/2
	local mat = math.matrix.three.rotate_z(math.rad(self.m_Rotation)) * math.matrix.three.scale(self.m_ImageSize/6000, -self.m_ImageSize/6000, 1) * math.matrix.three.translate(-px, -py, -pz)
	local rotLimit = math.atan2(self.m_Height, self.m_Width)
	local obj = localPlayer:getPrivateSync("isSpecting")

	if obj then
		px, py, pz = getElementPosition(obj)
		mat = math.matrix.three.rotate_z(math.rad(self.m_Rotation)) * math.matrix.three.scale(self.m_ImageSize/6000, -self.m_ImageSize/6000, 1)
			* math.matrix.three.translate(-px, -py, -pz)
	end

	for k, blip in pairs(self.m_Blips) do
		if DEBUG then ExecTimeRecorder:getSingleton():addIteration("UI/HUD/Radar") end
		local display = true
		local blipX, blipY = blip:getPosition()

		if Blip.AttachedBlips[blip] then
			if not isElement(Blip.AttachedBlips[blip]) then
				delete(self.m_Blips[k])
				break
			end

			local int, dim = Blip.AttachedBlips[blip]:getInterior(), Blip.AttachedBlips[blip]:getDimension()
			if int == 0 and dim == 0 then
				blipX, blipY = getElementPosition(Blip.AttachedBlips[blip])
			else
				display = false
			end
		end

		if blipX and display then -- TODO: hotfix for #236
			if getDistanceBetweenPoints2D(px, py, blipX, blipY) < blip:getStreamDistance() then
				-- Do transformation
				local pos = mat * math.matrix.three.hvector(blipX, blipY, 0, 1)
				local x, y = pos[1][1], pos[2][1]

				-- Check borders and fix position if necessary
				if x < -self.m_Width/2 or x > self.m_Width/2 or y < -self.m_Height/2 or y > self.m_Height/2 then
					-- Calculate angle
					local rotation = math.atan2(y, x)

					-- Identify and fix edges
					-- Use the 2. intercept theorem (ger. Strahlensatz)
					if rotation < -rotLimit and rotation > -math.pi+rotLimit then -- top
						x = -self.m_Height/2 / y * x
						y = -self.m_Height/2
					elseif rotation > rotLimit and rotation < math.pi-rotLimit then -- bottom
						x = self.m_Height/2 / y * x
						y = self.m_Height/2
					elseif rotation >= -rotLimit and rotation <= rotLimit then -- right
						y = self.m_Width/2 / x * y
						x = self.m_Width/2
					else -- left
						y = -self.m_Width/2 / x * y
						x = -self.m_Width/2
					end
				end

				-- Translate map to screen coordinates
				local screenX, screenY = mapCenterX + x, mapCenterY + y

				-- Finally, draw
				local blipSize = blip:getSize()
				local imagePath = blip:getImagePath()

				if blip.m_RawImagePath == "Marker.png" and blip:getZ() then
					if math.abs(pz - blip:getZ()) > 3 then
						local markerImage = blip:getZ() > pz and "Marker_up.png" or "Marker_down.png"
						imagePath = HUDRadar:getSingleton():makePath(markerImage, true)
					end
				end
				if fileExists(imagePath) then
					if DEBUG then ExecTimeRecorder:getSingleton():addIteration("UI/HUD/Radar", true) end
					dxDrawImage(screenX - blipSize/2, screenY - blipSize/2, blipSize, blipSize, imagePath, 0, 0, 0, blip:getColor())
				else
					outputDebugString("Blip not found: "..imagePath)
				end
			end
		end
	end
end

function HUDRadar:drawRoute()
	dxSetRenderTarget(self.m_RouteRenderTarget, true)

	for i = 1, #self.m_GPSNodes-1 do
		local node = self.m_GPSNodes[i]
		local previousNode = self.m_GPSNodes[i+1]

		local x, y = self:worldToMapPosition(node.x, node.y)
		local prevX, prevY = self:worldToMapPosition(previousNode.x, previousNode.y)

		dxDrawLine(x, y, prevX, prevY, tocolor(10, 149, 240), 5, false)
	end

	dxSetRenderTarget(nil)
end

function HUDRadar:setGPSRoute(nodes)
	-- Delete route if nodes is nil
	if not nodes then
		if self.m_RouteRenderTarget then
			destroyElement(self.m_RouteRenderTarget)
			self.m_RouteRenderTarget = nil
		end
		self.m_GPSNodes = nil
		return
	end

	-- Create render target if not created yet
	if not self.m_RouteRenderTarget then
		self.m_RouteRenderTarget = dxCreateRenderTarget(1536, 1536, true)
	end

	-- Update nodes and redraw route
	self.m_GPSNodes = nodes
	self:drawRoute()
end

function HUDRadar:getRouteRenderTarget()
	return self.m_RouteRenderTarget
end

function HUDRadar:worldToMapPosition(worldX, worldY)
	if worldX and worldY then
		local mapX = worldX / ( 6000/self.m_ImageSize) + self.m_ImageSize/2
		local mapY = worldY / (-6000/self.m_ImageSize) + self.m_ImageSize/2
		return mapX, mapY
	end
	return 0, 0
end

function HUDRadar:setZoom(zoom)
	error("Not implemented yet")
	self.m_Zoom = zoom
end

function HUDRadar:getZoom()
	return self.m_Zoom
end

function HUDRadar:syncBlips()
	self.m_Blips = Blip.Blips
end

function HUDRadar:addArea(worldX, worldY, width, height, color)
	local area = Rect:new(worldX, worldY, width, height)
	if type(color) == "table" then
		color = tocolor(unpack(color))
	end
	area.color = color
	local r, g, b, a = fromcolor(area.color)

	area.mtaElement = createRadarArea(worldX, worldY-height, width, height, r, g, b, a)
	table.insert(self.m_Areas, area)
	self:updateMapTexture()
	return area
end

function HUDRadar:removeArea(area)
	local idx = table.find(self.m_Areas, area)
	if idx then
		destroyElement(self.m_Areas[idx].mtaElement)
		table.remove(self.m_Areas, idx)
		self:updateMapTexture()
	end
end

function HUDRadar:setRadarAreaFlashing(serverAreaId, state)
	local area = HUDRadar.ServerAreas[serverAreaId]
	if area then
		area.flashing = state
		self:updateMapTexture()
		if isElement(area.mtaElement) then
			setRadarAreaFlashing(area.mtaElement,state)
		end
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
			local id, x, y, width, height, color = unpack(v)
			HUDRadar.ServerAreas[id] = HUDRadar:getSingleton():addArea(x, y, width, height, color)
		end
	end
)

addEvent("radarAreaFlash", true)
addEventHandler("radarAreaFlash", root,
	function(id, state)
		HUDRadar:getSingleton():setRadarAreaFlashing(id, state)
	end
)
