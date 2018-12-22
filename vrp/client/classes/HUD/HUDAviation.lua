-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDAviation.lua
-- *  PURPOSE:     HUD aviation class
-- *
-- ****************************************************************************
HUDAviation = inherit(Singleton)

function HUDAviation:constructor()
	self.m_FirstLoad = true

	self.m_DisplayFontHeight =  dxGetFontHeight(1,"default")


	self.m_EngineCircle = dxCreateTexture("files/images/Speedo/aviation_engine_circle.png", "argb", true, "clamp")
	self.m_NeedleTex = dxCreateTexture("files/images/Speedo/needle.png", "argb", true, "clamp")
	self.m_RadarTex = dxCreateTexture("files/images/Speedo/radar_circle.png", "argb", true, "clamp")
	self.m_Width = screenWidth*0.4
	self.m_Height = screenHeight*0.2 
	self.m_StartX = screenWidth*0.5 - ((self.m_Width*0.9)/2 )
	self.m_StartY = screenHeight - self.m_Height*1.2

	self.m_Panels = {}
	self.m_PanelsOffset = {}

	self.m_PitchRenderTarget = dxCreateRenderTarget(self.m_Width*0.2, self.m_Height)
	self.m_PitchRenderHorizon = dxCreateRenderTarget(self.m_Width*0.2, self.m_Height)
	dxSetTextureEdge(self.m_PitchRenderTarget, "clamp")
	dxSetTextureEdge(self.m_RadarTex, "border", tocolor(0, 0, 0, 0))

	self.m_Draw = bind(self.draw, self)
	self.m_DragAndDropBind = bind(self.Event_DragAndDrop, self)

	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle then 
		local type = self:getAviationType(vehicle)
		if type > 0 then
			self:show(type)
		end
	end

	addEventHandler("onClientPlayerVehicleEnter", localPlayer, 
		function(vehicle, seat)
			if seat == 0 or seat == 1 then
				local type = self:getAviationType(vehicle)
				if type > 0 then
					self:show(type)
				end
			end
		end
	)

	addEventHandler("onClientPlayerVehicleExit", localPlayer,
		function(vehicle, seat)
			if seat == 0 or seat == 1 then
				if self.m_Active then 
					self:hide()
				end
			end
		end
	)
	
	self:setupSettings()

end

function HUDAviation:destructor() 
	self:saveOffsets()
end


function HUDAviation:show(type)
	self.m_RadarDirection = true 
	self.m_InternalCount = 0
	self.m_AviationType = type
	self:setupPanels()
	self.m_Active = true
	addEventHandler("onClientRender", root, self.m_Draw, true, "high+10")
	addEventHandler("onClientClick", root, self.m_DragAndDropBind)
	addEventHandler("onClientKey", root, self.m_DragAndDropBind)
	self.m_RadarPulse = setTimer(bind(self.radarPulse, self), 200, 0)
	ShortMessage:new("Halte [Shift] und die [linke Maustaste] gedrückt um die Fluginstrumente zu bewegen!", "Fluginstrument-Anzeige")
	if self.m_Texture then 
		self.m_Texture:delete()
		self.m_Texture = nil
	end
	self.m_Texture = GUIMiniMap:new(self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.5)
	self.m_Texture.m_Color = tocolor(0, 200, 0, 100)
end

function HUDAviation:hide()
	removeEventHandler("onClientRender", root, self.m_Draw)
	removeEventHandler("onClientClick", root, self.m_DragAndDropBind)
	removeEventHandler("onClientKey", root, self.m_DragAndDropBind)
	self.m_Active = false
	self.m_Started = false
	self.m_StartTime = false
	self.m_Texture:delete()
	if isTimer(self.m_RadarPulse) then killTimer(self.m_RadarPulse) end
end

function HUDAviation:setupSettings()
	self:setPFD(core:get("HUD", "AviationPFDOverlay", true))
	self:setSFD(core:get("HUD", "AviationSFDOverlay", true))
	self:setECAS(core:get("HUD", "AviationECASOverlay", true))
end

function HUDAviation:setPFD(bool) self.m_PFD = bool end 
function HUDAviation:getPFD() return self.m_PFD  end

function HUDAviation:setSFD(bool) 
	self.m_SFD = bool 	
	if not bool then 
		if self.m_Texture then 
			self.m_Texture:delete()
			self.m_Texture = nil
		end
	else 
		if not self.m_Texture then
			self.m_Texture = GUIMiniMap:new(self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.5)
			self.m_Texture.m_Color = tocolor(0, 200, 0, 100)
		end
	end	
end 
function HUDAviation:getSFD() return self.m_SFD  end

function HUDAviation:setECAS(bool) self.m_ECAS = bool end 
function HUDAviation:getECAS() return self.m_ECAS end

function HUDAviation:loadOffsets()
	local pfdOffsetX = core:get("HUD", "aviationOffsetPFDX", 0) or 0
	local pfdOffsetY = core:get("HUD", "aviationOffsetPFDY", 0) or 0

	self:setOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.PFD.INDEX, pfdOffsetX, pfdOffsetY)

	local sfdOffsetX = core:get("HUD", "aviationOffsetSFDX", 0) or 0 
	local sfdOffsetY = core:get("HUD", "aviationOffsetSFDY", 0) or 0 
	self:setOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.SFD.INDEX, sfdOffsetX, sfdOffsetY)

	local ecasOffsetX = core:get("HUD", "aviationOffsetECASX", 0) or 0 
	local ecasOffsetY = core:get("HUD", "aviationOffsetECASY", 0) or 0 
	self:setOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.ECAS.INDEX, ecasOffsetX, ecasOffsetY)
	outputDebugString("Loaded HUDAviation-Offsets...")
end


function HUDAviation:saveOffsets()
	local pfdOffsetX, pfdOffsetY = false, false
	if self:getOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.PFD.INDEX) then
		pfdOffsetX, pfdOffsetY = unpack(self:getOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.PFD.INDEX))
	end
	core:set("HUD", "aviationOffsetPFDX", pfdOffsetX or core:get("HUD", "aviationOffsetPFDX", 0))
	core:set("HUD", "aviationOffsetPFDY", pfdOffsetY or core:get("HUD", "aviationOffsetPFDY", 0))

	local sfdOffsetX, sfdOffsetY = false, false
	if self:getOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.SFD.INDEX) then
		sfdOffsetX, sfdOffsetY = unpack(self:getOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.SFD.INDEX))
	end
	core:set("HUD", "aviationOffsetSFDX", sfdOffsetX or core:get("HUD", "aviationOffsetSFDX", 0))
	core:set("HUD", "aviationOffsetSFDY", sfdOffsetY or core:get("HUD", "aviationOffsetSFDY", 0))


	local ecasOffsetX, ecasOffsetY = false, false 
	if self:getOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.ECAS.INDEX) then
		ecasOffsetX, ecasOffsetY = unpack(self:getOffset(ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.ECAS.INDEX))
	end
	core:set("HUD", "aviationOffsetECASX", ecasOffsetX or core:get("HUD", "aviationOffsetECASX", 0))
	core:set("HUD", "aviationOffsetECASY", ecasOffsetY or core:get("HUD", "aviationOffsetECASY", 0))
	outputDebugString("Saved HUDAviation-Offsets...")
end


function HUDAviation:getAviationType(vehicle)
	local model = getElementModel(vehicle)
	local isSER = PLANES_SINGLE_ENGINE[model] 
	local isTE = PLANES_TWIN_ENGINE[model] 
	local isJET = PLANES_JET[model] 
	local isJumboJET = PLANES_JUMBO_JET[model] 
	local aviationType = 0
	if isSER then 
		aviationType = 1
	elseif isTE then 
		aviationType = 2 
	elseif isJET then 
		aviationType = 3 
	elseif isJumboJET then 
		aviationType = 4
	end
	return aviationType
end

function HUDAviation:setupPanels()
	local category = ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.PFD
	self:setPanelBound(category.INDEX, self.m_StartX, self.m_StartY, self.m_Width*0.2, self.m_Height, category.GROUNDSPEED_DISPLAY)
	self:setPanelBound(category.INDEX, self.m_StartX+self.m_Width*0.2, self.m_StartY, self.m_Width*0.1, self.m_Height, category.ARTIFICIAL_HORIZON)
	self:setPanelBound(category.INDEX, self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*0.1, self.m_Height, category.ALTIMETER)

	category = ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.SFD
	self:setPanelBound(category.INDEX, self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.5, category.CAUTION_WARNING_DISPLAY)
	self:setPanelBound(category.INDEX, self.m_StartX+self.m_Width*0.3, self.m_StartY+self.m_Height*0.5, self.m_Width*0.3, self.m_Height*0.5, category.HEADING_INDICATOR)

	category = ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.ECAS
	self:setPanelBound(category.INDEX, self.m_StartX+self.m_Width*0.6, self.m_StartY, self.m_Width*0.3, self.m_Height, category.ENGINE_PANEL)

	if self.m_FirstLoad then 
		self.m_FirstLoad = false 
		self:loadOffsets()
	end
end


function HUDAviation:draw()	
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/Aviation") end
	if not isPedInVehicle(localPlayer) or localPlayer.vehicleSeat > 1 then
		self:hide()
		return
	end
	if not self.m_Active then 
		self:hide() 
	end
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then 
		self:hide()
		return
	end
	local aircraft = getPedOccupiedVehicle(localPlayer) 
	if aircraft then
		if getVehicleEngineState(aircraft) then
			if not self.m_StartTime then
				self.m_StartTime = getTickCount() + 2000 
			else 
				if getTickCount() >= self.m_StartTime then 
					self.m_Started = true 
				end
			end
		else 
			self.m_Started = false 
		end
		if self.m_RadarDirection then
			self.m_InternalCount = self.m_InternalCount + 1
			if self.m_InternalCount > 360 then self.m_InternalCount = 0 end
		end
		self:drawPFD()
		self:drawSFD()
		self:drawECAS()

		self:clickRoutine()
	end

	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/Speedo", 1, 1) end
end

function HUDAviation:drawPFD()
	if self:getPFD() then
		local category = ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.PFD
		self:drawPitchDisplay(self.m_StartX, self.m_StartY, self.m_Width*0.2, self.m_Height, category.INDEX, category.GROUNDSPEED_DISPLAY)
		self:drawAltitudeDisplay(self.m_StartX+self.m_Width*0.2, self.m_StartY, self.m_Width*0.1, self.m_Height, category.INDEX, category.ARTIFICIAL_HORIZON)
		self:drawSpeed(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*0.1, self.m_Height, category.INDEX, category.ALTIMETER)
	end
end

function HUDAviation:drawSFD()
	if self:getSFD() then
		local category = ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.SFD
		self:drawInfoPanel(self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.5, category.INDEX, category.CAUTION_WARNING_DISPLAY)
		self:drawHeading(self.m_StartX+self.m_Width*0.3, self.m_StartY+self.m_Height*0.5, self.m_Width*0.3, self.m_Height*0.5, category.INDEX, category.HEADING_INDICATOR)
	end
end

function HUDAviation:drawECAS()
	if self:getECAS() then
		local category = ELECTRONIC_FLIGHT_INSTRUMENT_SYSTEM.ECAS
		self:drawEngineInfo(self.m_StartX+self.m_Width*0.6, self.m_StartY, self.m_Width*0.3, self.m_Height, category.INDEX, category.ENGINE_PANEL)
	end
end

function HUDAviation:checkFuelLoss( fuel ) 
	local now = getTickCount()
	if not self.m_LastCheck then self.m_LastCheck = now end
	if now - self.m_LastCheck >= 2000 then 
		if self.m_LastFuel then
			local dxfuel = self.m_LastFuel / fuel
			self.m_LastFuel = fuel
			self.m_LastCheck = now
			self.m_CurrentFuelLoss = math.floor((dxfuel*100))/100
			return self.m_CurrentFuelLoss
		else 
			self.m_LastFuel = fuel
			self.m_LastCheck = now
			self.m_CurrentFuelLoss = 0
			return self.m_CurrentFuelLoss
		end
	end
end

function HUDAviation:performCheck(b, s, aX, aY)
	local cOffsetX, cOffsetY, bX, bY, bW, bH, bOffset, pTable, clickIndex
	if getKeyState("lshift") then
		for i = 1, 3 do 
			if not clickIndex then
				pTable = self:getPanelBound(i)
				bOffset = self:getOffset(i) or {}
				if pTable then 
					for i2 = 1, #pTable do 
						if not clickIndex then
							bX, bY, bW, bH = unpack(pTable[i2])
							bX, bY = self:transformOffset(i, i2)
							if bX then
								if aX > bX and bX+bW > aX then
									if aY > bY and bY+bH > aY then 
										cOffsetX = aX - bX
										cOffsetY = aY - bY
										clickIndex = i
										break;
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if clickIndex then
		if b == "left" and s == "down" then
			self.m_ClickInfo = {clickIndex, cOffsetX, cOffsetY, bX, bY, self:getOffset(clickIndex)}
			return
		elseif b == "right" and s == "up" then
			self:setOffset(clickIndex, 0, 0)
			return
		end
	end
	self.m_ClickInfo = nil
	return
end

function HUDAviation:Event_DragAndDrop(b, s, aX, aY)
	if eventName == "onClientClick" then 
		self:performCheck(b, s, aX, aY)
	elseif eventName == "onClientKey" then 
		if b == "lshift" and s then 
			local cx, cy = getCursorPosition()
			if cx then
				self:performCheck("left", getKeyState("mouse1") and "down" or "up",  cx*screenWidth, cy*screenHeight)
			end
		end
	end
end

function HUDAviation:clickRoutine() 
	local cx, cy = getCursorPosition()
	local bX, bY, clickOffsetX, clickOffsetY, previousOffset
	if self.m_ClickInfo and cx then 
		self.m_Texture.m_Blips = {}
		self.m_Texture:anyChange()
		cx, cy = screenWidth*cx, screenHeight*cy 
		clickOffsetX, clickOffsetY, bX, bY, previousOffset = self.m_ClickInfo[2], self.m_ClickInfo[3], self.m_ClickInfo[4], self.m_ClickInfo[5], self.m_ClickInfo[6]
		self:setOffset(self.m_ClickInfo[1], previousOffset[1] + ((cx - clickOffsetX) - bX), previousOffset[2] + ((cy - clickOffsetY) - bY))
	end
end

function HUDAviation:checkAcceleration( aircraft ) 
	if not aircraft then return end
	local vx, vy, vz = getElementVelocity(aircraft)
	local speedVector = (vx^2 + vy^2 + vz^2)^(0.5)
	return speedVector -- math 101
end

function HUDAviation:radarPulse()
	if self.m_Texture then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		local px, py = 0, 0
		local vx, vy = getElementPosition(vehicle)
		self.m_Texture.m_Blips = {}
		if self.m_Texture.m_Image and self.m_Texture.m_MapX then
			for k, v in ipairs(getElementsByType("vehicle")) do 
				px, py = getElementPosition(v)
				if Vector2(Vector2(px, py) - Vector2(vx, vy)):getLength() < 100 then 
					self.m_Texture:addBlip("Marker.png", px, py)
				end
			end
		end
	end
end

function HUDAviation:setPanelBound(id, posX, posY, width, height, subid)
	if not self.m_Panels[id] then self.m_Panels[id] = {};self:setOffset(id, 0, 0) end
	self.m_Panels[id][subid] = {posX, posY, width, height}
end

function HUDAviation:getPanelBound(id)
	if self.m_Panels[id] then 
		return self.m_Panels[id]
	end
end

function HUDAviation:setOffset(id, oX, oY)
	if not self.m_PanelsOffset[id] then self.m_PanelsOffset[id] = {} end
	self.m_PanelsOffset[id] = {oX, oY} 
end

function HUDAviation:getOffset(id)
	return self.m_PanelsOffset[id]
end

function HUDAviation:transformOffset(id, subid)
	local offset = self:getOffset(id)
	local bound = self:getPanelBound(id)[subid]
	if not bound then bound = {} end
	if offset then
		local ox, oy = offset[1], offset[2]
		if ox then return bound[1] + ox, bound[2] + oy end
	end
	return bound[1], bound[2]
end


function HUDAviation:drawStartUpDisplay( posX, posY, width, height, id, subid)
	posX, posY = self:transformOffset(id, subid)
	if posX and posY and width and height then 
		self:drawBorder(posX, posY, width, height)
		local now = getTickCount() 
		dxDrawRectangle(posX, posY, width, height, tocolor(0, 0, 0, 255))
		if now % 1000 >= 500 then
			local setupWidth = dxGetTextWidth("SETUP", 1, "clear")
			local setupHeight = dxGetFontHeight(1, "clears")
			dxDrawBoxText("SETUP", posX, posY, width, height, tocolor(10, 97, 34, 255), 1, "clear", "center", "center")
			dxDrawBoxShape((posX+width*0.5)-(setupWidth*0.6), (posY+height*0.5)-(setupHeight*0.5), setupWidth*1.1, setupHeight, tocolor(10, 97, 34, 255))
		end
	end
	self:drawOverlay(posX, posY, width, height)
end


function HUDAviation:drawPitchDisplay(posX, posY, width, height, id, subid) 
	posX, posY = self:transformOffset(id, subid)
	if self.m_Started then
		self:drawBorder(posX, posY, width, height)
		local aircraft = getPedOccupiedVehicle(localPlayer) 
		if not aircraft then return end
		local pitch, yaw = getElementRotation( aircraft )
		self:drawArtificialHorizon(posX, posY, width, height, pitch, yaw)
		dxSetRenderTarget(self.m_PitchRenderTarget)
			dxDrawImage(-width*0.25, 0, width*1.5, height, self.m_PitchRenderHorizon, -yaw)
		dxSetRenderTarget()
		dxDrawImage(posX, posY, width, height, self.m_PitchRenderTarget)

		dxDrawLine(posX, posY+height*0.5, posX+width, posY+height*0.5, tocolor(255,255,50,150), 2)
		dxDrawImage(posX+width*0.4, posY+height*0.5, width*0.2, height*0.05, self.m_NeedleTex, yaw, 0 ,0, tocolor(0, 0, 0, 255))
		dxDrawImage(posX, posY, width, height, "files/images/Speedo/aviation_pitch_overlay.png")
		self:drawOverlay(posX, posY, width, height)
	else 
		self:drawStartUpDisplay(posX, posY, width, height, id, subid)
	end
end	

function HUDAviation:drawArtificialHorizon(posX, posY, width, height, pitch, yaw)
	local drawHeightCorrection = 0
	if pitch >= 180 and pitch < 270  then pitch = 268-360 end
	if pitch > 180  then pitch = pitch-360 end
	local amount = pitch / 90
	local horizonPosY = 0
	amount = amount * 2
	local _amount = amount
	dxSetRenderTarget(self.m_PitchRenderHorizon)
		local indexHeight
		if amount >= 0 then
			amount = amount*0.25 + 0.5 -- math 101
			drawHeightCorrection = height*amount
			if drawHeightCorrection > height then drawHeightCorrection = height end
			amount = _amount+0.5
			horizonPosY = height*amount
			dxDrawRectangle(0, 0, width, height, tocolor(147, 69, 21,255))
			dxDrawRectangle(0, 0, width, drawHeightCorrection, tocolor(0, 126, 183,255))
			dxDrawLine(0, drawHeightCorrection, width, drawHeightCorrection, tocolor(0, 0, 0, 255))
			indexHeight = drawHeightCorrection
		else 
			amount = amount * 0.25 - 0.5 -- math 101
			drawHeightCorrection = height*amount
			if drawHeightCorrection < -1*height then drawHeightCorrection = -1*height end
			amount = _amount-0.5
			horizonPosY = height+height*amount
			dxDrawRectangle(0, 0, width, height, tocolor(0, 126, 183,255))
			dxDrawRectangle(0, height, width, drawHeightCorrection, tocolor(147, 69, 21,255))
			dxDrawLine(0, height+drawHeightCorrection, width, height+drawHeightCorrection, tocolor(0, 0, 0, 255))
			indexHeight = height+drawHeightCorrection
		end

		dxDrawLine(0, horizonPosY, width*0.3, horizonPosY)
		dxDrawLine(width, horizonPosY, width*0.7, horizonPosY)
		dxDrawLine(width*0.45, horizonPosY, width*0.55, horizonPosY)

		local degreeLine = 0
		local degreeString = ""
		local fontWidth

		dxDrawLine(0, indexHeight, 100, indexHeight, tocolor(200, 220, 0, 255))
		for i = 1, 8 do 
			degreeLine = indexHeight+height*(i/(37/2))
			if i % 2 == 0 then	
				degreeString = (math.abs(i)*10)	
				fontWidth = dxGetTextWidth(degreeString, 1,"default")
				dxDrawLine(width*0.35, degreeLine, width*0.65, degreeLine)
				dxDrawText(degreeString, width*0.3-fontWidth, degreeLine-self.m_DisplayFontHeight*0.5, width*0.3, degreeLine+self.m_DisplayFontHeight*0.5)
				dxDrawText(degreeString, width*0.7, degreeLine-self.m_DisplayFontHeight*0.5, width*0.9, degreeLine+self.m_DisplayFontHeight*0.5)
			else 
				dxDrawLine(width*0.4, degreeLine, width*0.6, degreeLine, tocolor(150, 150, 150, 255))
			end
		end
		for i = 1, 8 do 
			degreeLine = indexHeight-height*(i/(37/2))
			if i % 2 == 0 then	
				degreeString = (math.abs(i)*10)	
				fontWidth = dxGetTextWidth(degreeString, 1,"default")
				dxDrawLine(width*0.35, degreeLine, width*0.65, degreeLine)
				dxDrawText(degreeString, width*0.3-fontWidth, degreeLine-self.m_DisplayFontHeight*0.5, width*0.3, degreeLine+self.m_DisplayFontHeight*0.5)
				dxDrawText(degreeString, width*0.7, degreeLine-self.m_DisplayFontHeight*0.5, width*0.9, degreeLine+self.m_DisplayFontHeight*0.5)
			else 
				dxDrawLine(width*0.4, degreeLine, width*0.6, degreeLine, tocolor(150, 150, 150, 255))
			end
		end
	dxSetRenderTarget()
end	

function HUDAviation:drawAltitudeDisplay(posX, posY, width, height, id, subid) 
	posX, posY = self:transformOffset(id, subid)
	if self.m_Started then
		self:drawBorder(posX, posY, width, height)
		local aircraft = getPedOccupiedVehicle(localPlayer) 
		if not aircraft then return end
		local _, _, alt = getElementPosition(aircraft) 
		alt = alt*METER_TO_FEET
		local altitudeString = string.format("%04d", math.floor(alt))
		local centerY = (posY+height*0.5)
		dxDrawRectangle(posX, posY, width, height, tocolor(0,0,0,255))
		dxDrawBoxText("ALT", posX, posY, width, height, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
		dxDrawBoxShape(posX+1, centerY-height*0.05, width-2, height*0.1)
		dxDrawBoxText(altitudeString, posX, centerY-height*0.05, width, height*0.1, tocolor(20, 107, 44), 2, "default", "center", "center")
		local lineY, lineAlt
		for i = -5, 5 do 
			if i ~= 0 then
				lineAlt = (alt - i*100)
				lineAlt = string.format("%04d",math.floor(lineAlt /100)*100)
				lineY = centerY+height*(i/10)
				if lineY < posY+height and lineY > posY then
					if tonumber(lineAlt) > 0 then
						dxDrawLine(posX, lineY,posX+width*0.2, lineY)
						dxDrawBoxText(lineAlt, posX+width*0.2, lineY, width, lineY+height*0.1, tocolor(255/math.abs(i), 255/math.abs(i), 255/math.abs(i), 255))
					end
				end
			end
		end
		self:drawOverlay(posX, posY, width, height)
	else 
		self:drawStartUpDisplay(posX, posY, width, height, id, subid)
	end
end

function HUDAviation:drawSpeed( posX, posY, width, height, id, subid) 
	posX, posY = self:transformOffset(id, subid)
	if self.m_Started then
		self:drawBorder(posX, posY, width, height)
		local aircraft = getPedOccupiedVehicle( localPlayer ) 
		if not aircraft then return end 
		local vx, vy, vz = getElementVelocity(aircraft)
		local speedVector = (vx^2 + vy^2 + vz^2)^(0.5)
		local kmh = speedVector * 180
		local knots = math.floor(kmh * KMH_TO_KNOTS)*1.8
		local knotsString = string.format("%03d", math.floor(knots))
		local centerY = (posY+height*0.5)
		dxDrawRectangle(posX, posY, width, height, tocolor(0,0,0,255))
		dxDrawBoxText("GS", posX, posY, width, height, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
		dxDrawBoxShape(posX+1, centerY-height*0.05, width-2, height*0.1)
		dxDrawBoxText(knotsString, posX, centerY-height*0.05, width, height*0.1, tocolor(20, 107, 44), 2, "default", "center", "center")
		local lineY, lineKnots
		for i = -5, 5 do 
			if i ~= 0 then
				lineKnots = (knots - i*10)
				lineKnots = string.format("%03d",math.floor(lineKnots /10)*10)
				lineY = centerY+height*(i/10)
				if lineY < posY+height and lineY > posY then
					if tonumber(lineKnots) > 0 then
						dxDrawLine(posX, lineY,posX+width*0.2, lineY)
						dxDrawBoxText(lineKnots, posX+width*0.2, lineY, width, lineY+height*0.1, tocolor(255/math.abs(i), 255/math.abs(i), 255/math.abs(i), 255))
					end
				end
			end
		end
		self:drawOverlay(posX, posY, width, height)
	else 
		self:drawStartUpDisplay(posX, posY, width, height, id, subid)
	end
end

function HUDAviation:drawHeading( posX, posY, width, height, id, subid) 
	posX, posY = self:transformOffset(id, subid)
	if self.m_Started then
		self:drawBorder(posX, posY, width, height)
		local aircraft = getPedOccupiedVehicle( localPlayer ) 
		if not aircraft then return end 
		local _, _, rz = getElementRotation(aircraft) 
		local headingString = string.format("%03d", math.floor(rz))
		dxDrawRectangle(posX, posY, width, height, tocolor( 0, 0, 0, 255)) 
		dxDrawImage(posX+width*0.2, posY+height*0.1, width*0.4, width*0.4, "files/images/Speedo/heading.png", rz+180, 0, 0, tocolor(10, 97, 34, 255) )
		dxDrawLine(posX+width*0.4, posY+height*0.1+width*0.2, posX+width*0.4, posY+height*0.1+width*0.1, tocolor(200, 0,  0, 255), 2)
		dxDrawRectangle((posX+width*0.4)-2, (posY+height*0.1+width*0.2)-4, 4, 4, tocolor(10, 97, 34, 255))
		dxDrawBoxText(headingString, posX+width*0.72,posY+height*0.1, width*0.15, height*0.15, tocolor(10, 97, 34, 255), 1, "sans", "center", "top")
		dxDrawBoxShape(posX+width*0.72,posY+height*0.1, width*0.15, height*0.15, tocolor(10, 97, 34, 255))
		local isGearDown = getVehicleLandingGearDown ( aircraft )
		
		if isGearDown then
			dxDrawBoxText("GEAR", posX+width*0.72, posY+height*0.3, width*0.15, height*0.15, tocolor(10, 97, 34, 255), 0.75, "sans", "center", "center")
		else 
			dxDrawBoxText("GEAR",posX+width*0.72,posY+height*0.3, width*0.15, height*0.15, tocolor(200, 0, 0, 255), 0.75, "sans", "center", "center")
		end
		dxDrawBoxShape(posX+width*0.72,posY+height*0.3, width*0.15, height*0.15, tocolor(10, 97, 34, 255), 1)
		self:drawOverlay(posX, posY, width, height)
	else 
		self:drawStartUpDisplay(posX, posY, width, height, id, subid)
	end
end

function HUDAviation:drawInfoPanel( posX, posY, width, height, id, subid) 
	posX, posY = self:transformOffset(id, subid)
	if self.m_Started then
		self:drawBorder(posX, posY, width, height)
		local aircraft = getPedOccupiedVehicle( localPlayer ) 
		if not aircraft then return end 

		dxDrawRectangle(posX, posY, width, height, tocolor(0, 0, 0, 255)) 
		local nx = math.cos(math.rad(self.m_InternalCount)) * height*0.5
		local ny = math.sin(math.rad(self.m_InternalCount)) * height*0.5
		

		dxDrawLine(posX+width*0.5+nx, posY+(height*0.5)+ny, posX+width*0.5, posY+height*0.5, tocolor(10, 97, 34, 255), 2)
		self.m_Texture:setPosition(posX, posY)
		self.m_Texture:setAbsolutePosition(posX, posY)
		dxDrawLine(posX, posY+height*0.5, posX+width, posY+height*0.5, tocolor(0, 200, 0, 255))
		dxDrawLine(posX+width*0.5, posY, posX+width*0.5, posY+height, tocolor(0, 200, 0, 255))

		dxDrawRectangle((posX+width*0.5)-height*0.5, (posY+height*0.5)-height*0.5, height, height, tocolor(140, 0, 0, 100))
		local x, y = getElementPosition(localPlayer)
		self.m_Texture:setMapPosition(x or 0, y or 0)
		self:drawOverlay(posX, posY, width, height)
		dxDrawText("GARMIN GPS", posX, posY, width, posY, tocolor(200, 0, 0, 255), 1, "clear")
	else 
		self:drawStartUpDisplay(posX, posY, width, height, id, subid)
	end
end

function HUDAviation:drawBorder(posX, posY, width, height)
	dxDrawBoxShape(posX+4, posY+4, width, height, tocolor(0, 0, 0, 255), 6)
	dxDrawBoxShape(posX, posY, width, height, tocolor(255, 255, 255, 255), 4)
end

function HUDAviation:drawOverlay(posX, posY, width, height)
	dxDrawImageSection(posX, posY, width, height, 0, 0, 1280, 720, "files/images/Speedo/overlay_glass.png")
end

function HUDAviation:drawStartInfo( posX, posY, width, height ) 
	dxDrawBoxText("START ENGINE!", posX+width*0.05, posY, width, height, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
end

function HUDAviation:drawEngineInfo(posX, posY, width, height, id, subid) 
	posX, posY = self:transformOffset(id, subid)
	if self.m_Started then
		self:drawBorder(posX, posY, width, height)
		local aircraft = getPedOccupiedVehicle( localPlayer ) 
		if not aircraft then return end 
		dxDrawRectangle(posX, posY, width, height, tocolor(0, 0, 0, 255))
		dxDrawImage(posX+width*0.3, posY+height*0.1, width*0.4, width*0.4, self.m_EngineCircle)
		local startAngle = -28
		local maxExtendAngle = 200
		local fuel = aircraft:getData("fuel") or 0
		local degFuel = maxExtendAngle * (math.floor(fuel)/100) 
		local sx,sy = getLineAngle( posX+width*0.5, posY+height*0.1+width*0.2, width*0.2, startAngle-30)
		local ex,ey = getLineAngle( posX+width*0.5, posY+height*0.1+width*0.2, width*0.2, startAngle-120)
		local x,y = getLineAngle( posX+width*0.5, posY+height*0.1+width*0.2, width*0.2, startAngle+degFuel)
		dxDrawLine(posX+width*0.5, posY+height*0.1+width*0.2, x, y, tocolor(10, 97, 34, 255), 2)
		dxDrawBoxText(math.floor(fuel), sx, sy, width*0.1, height*0.07, tocolor(10, 97, 34, 255), 0.9, "sans", "center", "center")
		dxDrawBoxShape(sx, sy, width*0.1, height*0.07,  tocolor(10, 97, 34, 255))
	
		local fuelLoss = self:checkFuelLoss(fuel)
		local fuelString = string.format("%.1f", self.m_CurrentFuelLoss or 1)
		dxDrawBoxText(fuelString or "0.0", ex, ey, width*0.1, height*0.07, tocolor(10, 97, 34, 255), 0.9, "sans", "center", "center")
		dxDrawBoxShape(ex, ey, width*0.1, height*0.07,  tocolor(10, 97, 34, 255))
		dxDrawBoxText("FUEL", posX+width*0.3, posY+height*0.1, width*0.4, width*0.4, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
	
		local engineWork = self:checkAcceleration( aircraft ) or 0
		local e1x, e1y = getLineAngle( posX+width*0.4, posY+height*0.1+width*0.6, width*0.1, startAngle+(engineWork*maxExtendAngle))
		local eN1x,eN1y = getLineAngle( posX+width*0.4, posY+height*0.1+width*0.6, width*0.1, startAngle-120)
		local eN2x,eN2y = getLineAngle( posX+width*0.65, posY+height*0.1+width*0.6, width*0.1, startAngle-120)
		dxDrawImage(posX+width*0.3, posY+height*0.1+width*0.5, width*0.2, width*0.2, self.m_EngineCircle)
		dxDrawLine(posX+width*0.4, posY+height*0.1+width*0.6, e1x, e1y, tocolor(10, 97, 34, 255), 2)
		dxDrawBoxText("N1", eN1x, eN1y, width*0.1, height*0.07, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
		dxDrawBoxText("N2", eN2x, eN2y, width*0.1, height*0.07, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
		local e2x, e2y
		if self.m_AviationType > 1 then
			e2x, e2y = getLineAngle( posX+width*0.65, posY+height*0.1+width*0.6, width*0.1, startAngle+(engineWork*maxExtendAngle))
			dxDrawImage(posX+width*0.55, posY+height*0.1+width*0.5, width*0.2, width*0.2, self.m_EngineCircle)
			dxDrawLine(posX+width*0.65, posY+height*0.1+width*0.6, e2x, e2y, tocolor(10, 97, 34, 255), 2)
		else 
			e2x, e2y = getLineAngle( posX+width*0.65, posY+height*0.1+width*0.6, width*0.1, startAngle)
			dxDrawImage(posX+width*0.55, posY+height*0.1+width*0.5, width*0.2, width*0.2, self.m_EngineCircle, 0, 0, 0, tocolor(40, 40, 40, 255))
			dxDrawLine(posX+width*0.65, posY+height*0.1+width*0.6, e2x, e2y, tocolor(40, 40, 40, 255), 2)
		end
		self:drawOverlay(posX, posY, width, height)
	else 
		self:drawStartUpDisplay(posX, posY, width, height, id, subid)
	end
end

function HUDAviation:checkDoors( aircraft ) 
	local doorState
	for i = 2,5 do 
		doorState = getVehicleDoorState(aircraft, i)
		if doorState > 0 then 
			return false 
		end
	end
	return true
end

