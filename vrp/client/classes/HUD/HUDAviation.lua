-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDAviation.lua
-- *  PURPOSE:     HUD aviation class
-- *
-- ****************************************************************************
HUDAviation = inherit(Singleton)
local displayFontHeight = dxGetFontHeight(1,"default")
local needleTex = dxCreateTexture("files/images/Speedo/needle.png", "argb", true, "clamp")
local METER_TO_FEET = 3.28084
local KMH_TO_KNOTS = 0.539957
function HUDAviation:constructor()
	self.m_Draw = bind(self.draw, self)
	self.m_Width = screenWidth*0.4
	self.m_Height = screenHeight*0.2 
	self.m_StartX = screenWidth*0.5 - self.m_Width/2 
	self.m_StartY = screenHeight - self.m_Height*1.2
	addEventHandler("onClientPlayerVehicleEnter", localPlayer,
		function(vehicle, seat)
			if seat == 0 or seat == 1 then
				local model = getElementModel(vehicle)
				local isSER = PLANES_SINGLE_ENGINE[model] 
				local isTE = PLANES_TWIN_ENGINE[model] 
				local isJET = PLANES_JET[model] 
				local isJumboJET = PLANES_JUMBO_JET[model] 
				self:show( isSER, isTE, isJET, isJumboJET)
			end
		end
	)
	addEventHandler("onClientPlayerVehicleExit", localPlayer,
		function(vehicle, seat)
			if seat == 0 or seat == 1 then
				if self.m_AviationType then 
					self:hide()
				end
			end
		end
	)
end

function HUDAviation:show( isSER, isTE, isJET, isJumboJET)
	if isSER then 
		self.m_AviationType = 1
	elseif isTE then 
		self.m_AviationType = 2 
	elseif isJET then 
		self.m_AviationType = 3 
	elseif isJumboJET then 
		self.m_AviationType = 4
	end
	addEventHandler("onClientRender", root, self.m_Draw, true, "high+10")
end

function HUDAviation:hide()
	removeEventHandler("onClientRender", root, self.m_Draw)
	self.m_AviationType = false
	self.m_Started = false
	self.m_StartTime = false
end

function HUDAviation:draw()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/Aviation") end
	if not isPedInVehicle(localPlayer) or localPlayer.vehicleSeat > 1 then
		self:hide()
		return
	end
	if not self.m_AviationType then 
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
			if self.m_Started then 
				self:drawPitchDisplay(self.m_StartX, self.m_StartY, self.m_Width*0.2, self.m_Height)
				self:drawAltitudeDisplay(self.m_StartX+self.m_Width*0.2, self.m_StartY, self.m_Width*0.1, self.m_Height)
				self:drawSpeed(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*0.1, self.m_Height)
				self:drawInfoPanel(self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.2)
				self:drawHeading(self.m_StartX+self.m_Width*0.3, self.m_StartY+self.m_Height*0.2, self.m_Width*0.3, self.m_Height*0.8)
			else
				if not self.m_StartTime then
					self.m_StartTime = getTickCount() + 3000 
				else 
					if getTickCount() >= self.m_StartTime then 
						self.m_Started = true 
					else 
						self:drawStartUpDisplay(self.m_StartX, self.m_StartY, self.m_Width*0.2, self.m_Height)
						self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.2, self.m_StartY, self.m_Width*0.1, self.m_Height)
						self:drawStartUpDisplay(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*0.1, self.m_Height)
						self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.3, self.m_StartY+self.m_Height*0.2, self.m_Width*0.3, self.m_Height*0.8)
						self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.2)
					end
				end
			end
		else 
			self.m_Started = false
			self.m_StartTime = false
		end
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/Speedo", 1, 1) end
end

function HUDAviation:drawPitchDisplay(posX, posY, width, height) 
	local aircraft = getPedOccupiedVehicle(localPlayer) 
	if not aircraft then return end
	local pitch, yaw = getElementRotation( aircraft )
	local drawHeightCorrection = 0
	if pitch >= 180 and pitch < 270  then
			pitch = 268-360
	end
	if pitch > 180  then
		pitch = pitch-360
	end
	local amount = pitch / 90
	local horizonPosY = 0
	amount = amount * 2
	if amount >= 0 then
		amount = amount + 0.5
		drawHeightCorrection = height*amount
		if drawHeightCorrection > height then drawHeightCorrection = height end
		horizonPosY = height*amount
		dxDrawRectangle(posX, posY, width, height, tocolor(147, 69, 21,255))
		dxDrawRectangle(posX, posY, width, drawHeightCorrection, tocolor(0, 126, 183,255))
	else 
		amount = amount - 0.5
		drawHeightCorrection = height*amount
		if drawHeightCorrection < -1*height then drawHeightCorrection = -1*height end
		horizonPosY = height+height*amount
		dxDrawRectangle(posX, posY, width, height, tocolor(0, 126, 183,255))
		dxDrawRectangle(posX, posY+height, width, drawHeightCorrection, tocolor(147, 69, 21,255))
	end
	--//>> Horizon-Line <<//
	if posY+horizonPosY > posY and posY+horizonPosY < posY+height then
		dxDrawLine(posX, posY+horizonPosY, posX+width*0.3, posY+horizonPosY)
		dxDrawLine(posX+width, posY+horizonPosY, posX+width*0.7, posY+horizonPosY)
		dxDrawLine(posX+width*0.45, posY+horizonPosY, posX+width*0.55, posY+horizonPosY)
	end
	--//>> Degree-Lines <<//
	local degreeLine = 0
	local degreeCount = -9
	local degreeString = ""
	local fontWidth
	for i = -19, 19 do 
		degreeLine = horizonPosY+height*(i/10)
		if i ~= 0 then
			if i % 2 == 0 then	
				degreeString = (math.abs(degreeCount)*10)	
				fontWidth = dxGetTextWidth(degreeString,1,"default")
				if degreeLine <= height and degreeLine > 0 then
					dxDrawLine(posX+width*0.3, posY+degreeLine, posX+width*0.7, posY+degreeLine)
					if degreeLine+displayFontHeight <= height and degreeLine+displayFontHeight > 0 then
						dxDrawText(degreeString, posX+width*0.3-fontWidth, posY+degreeLine, posX+width*0.3, posY+degreeLine)
						dxDrawText(degreeString, posX+width*0.7, posY+degreeLine, posX+width*0.9, posY+degreeLine)
					end
				end	
				degreeCount = degreeCount + 1 
			else 
				if degreeLine <= height and degreeLine > 0 then
					dxDrawLine(posX+width*0.4, posY+degreeLine, posX+width*0.6, posY+degreeLine)
				end
			end
		else 
			degreeCount = 1
		end
	end
	--//>>Center-Line<<//
	dxDrawLine(posX, posY+height*0.5, posX+width, posY+height*0.5, tocolor(255,255,50,150), 2)
	dxDrawImage(posX+width*0.4, posY+height*0.5, width*0.2, height*0.05, needleTex, yaw, 0 ,0, tocolor(0, 0, 0, 255))
	--//>>Overlay<<//
	dxDrawImage(posX, posY, width, height, "files/images/Speedo/aviation_pitch_overlay.png")
end

function HUDAviation:drawAltitudeDisplay(posX, posY, width, height) 
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
end

function HUDAviation:drawSpeed( posX, posY, width, height) 
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
end

function HUDAviation:drawHeading( posX, posY, width, height) 
	local aircraft = getPedOccupiedVehicle( localPlayer ) 
	if not aircraft then return end 
	local _, _, rz = getElementRotation(aircraft) 
	local headingString = string.format("%03d", math.floor(rz))
	dxDrawRectangle(posX, posY, width, height, tocolor( 0, 0, 0, 255)) 
	dxDrawImage(posX+width*0.2, posY+height*0.1, width*0.6, width*0.6, "files/images/Speedo/heading.png", rz, 0, 0, tocolor(10, 97, 34, 255) )
	dxDrawLine(posX+width*0.5, posY+height*0.1+width*0.3, posX+width*0.5, posY+height*0.1+width*0.1, tocolor(10, 97, 34, 255), 2)
	dxDrawBoxText(headingString, posX+width*0.72,posY+height*0.1, width*0.15, height*0.1, tocolor(10, 97, 34, 255), 1, "sans", "center", "top")
	dxDrawBoxShape(posX+width*0.72,posY+height*0.1, width*0.15, height*0.1, tocolor(10, 97, 34, 255))
end

function HUDAviation:drawInfoPanel( posX, posY, width, height) 
	local aircraft = getPedOccupiedVehicle( localPlayer ) 
	if not aircraft then return end 
	dxDrawRectangle(posX, posY, width, height, tocolor(0, 0, 0, 255)) 
	local isGearDown = getVehicleLandingGearDown ( aircraft )
	if isGearDown then
		dxDrawBoxText("GEAR", posX+width*0.1, posY+height*0.1, width*0.2, height*0.4, tocolor(10, 97, 34, 255), 1, "sans", "center", "center")
	else 
		dxDrawBoxText("GEAR", posX+width*0.1, posY+height*0.1, width*0.2, height*0.4, tocolor(200, 0, 0, 255), 1, "sans", "center", "center")
	end
	dxDrawBoxShape(posX+width*0.1, posY+height*0.1, width*0.2, height*0.4, tocolor(10, 97, 34, 255), 1)
	local isDoorChecked = self:checkDoors(aircraft) 
	if isDoorChecked then 
		dxDrawBoxText("DOOR", posX+width*0.4, posY+height*0.1, width*0.2, height*0.4, tocolor(10, 97, 34, 255), 1, "sans", "center", "center")
	else 
		dxDrawBoxText("DOOR", posX+width*0.4, posY+height*0.1, width*0.2, height*0.4, tocolor(200, 0, 0, 255), 1, "sans", "center", "center")
	end
	dxDrawBoxShape(posX+width*0.4, posY+height*0.1, width*0.2, height*0.4, tocolor(10, 97, 34, 255), 1)
	local isFireDamage = getElementHealth(aircraft) <= 250
	if not isFireDamage then 
		dxDrawBoxText("FIRE", posX+width*0.7, posY+height*0.1, width*0.2, height*0.4, tocolor(10, 97, 34, 255), 1, "sans", "center", "center")
	else 
		dxDrawBoxText("FIRE", posX+width*0.7, posY+height*0.1, width*0.2, height*0.4, tocolor(200, 0, 0, 255), 1, "sans", "center", "center")
	end
	dxDrawBoxShape(posX+width*0.7, posY+height*0.1, width*0.2, height*0.4, tocolor(10, 97, 34, 255), 1)
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

function HUDAviation:drawStartUpDisplay( posX, posY, width, height)
	if posX and posY and width and height then 
		local now = getTickCount() 
		dxDrawRectangle(posX, posY, width, height, tocolor(0, 0, 0, 255))
		if now % 1000 >= 500 then
			dxDrawBoxText("SETUP", posX, posY, width, height, tocolor(10, 97, 34, 255), 1, "clear", "center", "center")
		end
	end
end
