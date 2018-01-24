-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDAviation.lua
-- *  PURPOSE:     HUD aviation class
-- *
-- ****************************************************************************
HUDAviation = inherit(Singleton)
local displayFontHeight = dxGetFontHeight(1,"default")
local needleTex
local engineCirlce
local METER_TO_FEET = 3.28084
local KMH_TO_KNOTS = 0.539957
function HUDAviation:constructor()
	self.m_Draw = bind(self.draw, self)
	self.m_Width = screenWidth*0.4
	engineCirlce = dxCreateTexture("files/images/Speedo/aviation_engine_circle.png", "argb", true, "clamp")
	needleTex = dxCreateTexture("files/images/Speedo/needle.png", "argb", true, "clamp")
	self.m_Height = screenHeight*0.2 
	self.m_StartX = screenWidth*0.5 - ((self.m_Width*0.9)/2 )
	self.m_StartY = screenHeight - self.m_Height*1.2
	self.m_PitchRenderTarget = dxCreateRenderTarget(self.m_Width*0.2, self.m_Height)
	dxSetTextureEdge(self.m_PitchRenderTarget, "clamp")
	self.m_PitchRenderHorizon = dxCreateRenderTarget(self.m_Width*0.2, self.m_Height)
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
	else 
		self.m_AviationType = 0
	end
	if self.m_AviationType and  self.m_AviationType > 0 then 
		addEventHandler("onClientRender", root, self.m_Draw, true, "high+10")
	end
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
				self:drawBorder(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width, self.m_Height)
				self:drawPitchDisplay(self.m_StartX, self.m_StartY, self.m_Width*0.2, self.m_Height)
				self:drawAltitudeDisplay(self.m_StartX+self.m_Width*0.2, self.m_StartY, self.m_Width*0.1, self.m_Height)
				self:drawSpeed(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*0.1, self.m_Height)
				self:drawInfoPanel(self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.2)
				self:drawHeading(self.m_StartX+self.m_Width*0.3, self.m_StartY+self.m_Height*0.2, self.m_Width*0.3, self.m_Height*0.8)
				self:drawEngineInfo(self.m_StartX+self.m_Width*0.6, self.m_StartY, self.m_Width*0.3, self.m_Height)
			else
				if not self.m_StartTime then
					self.m_StartTime = getTickCount() + 3000 
				else 
					if getTickCount() >= self.m_StartTime then 
						self.m_Started = true 
					else 
						self:drawBorder(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*1, self.m_Height)
						self:drawStartUpDisplay(self.m_StartX, self.m_StartY, self.m_Width*0.2, self.m_Height)
						self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.2, self.m_StartY, self.m_Width*0.1, self.m_Height)
						self:drawStartUpDisplay(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*0.1, self.m_Height)
						self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.3, self.m_StartY+self.m_Height*0.2, self.m_Width*0.3, self.m_Height*0.8)
						self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.2)
						self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.6, self.m_StartY, self.m_Width*0.3, self.m_Height)
					end
				end
			end
		else 
			self:drawBorder(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*1, self.m_Height)
			self:drawStartUpDisplay(self.m_StartX, self.m_StartY, self.m_Width*0.2, self.m_Height)
			self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.2, self.m_StartY, self.m_Width*0.1, self.m_Height)
			self:drawStartUpDisplay(self.m_StartX-self.m_Width*0.1, self.m_StartY, self.m_Width*0.1, self.m_Height)
			self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.3, self.m_StartY+self.m_Height*0.2, self.m_Width*0.3, self.m_Height*0.8)
			self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.3, self.m_StartY, self.m_Width*0.3, self.m_Height*0.2)
			self:drawStartUpDisplay(self.m_StartX+self.m_Width*0.6, self.m_StartY, self.m_Width*0.3, self.m_Height)
			self:drawStartInfo(self.m_StartX-self.m_Width*0.1, self.m_StartY+self.m_Height*0.02, self.m_Width*1, self.m_Height ) 
		end
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/Speedo", 1, 1) end
end

function HUDAviation:drawStartInfo( posX, posY, width, height ) 
	dxDrawBoxText("START ENGINE!", posX+width*0.05, posY, width, height, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
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
	local _amount = amount
	dxSetRenderTarget(self.m_PitchRenderHorizon)
	local _posX, _posY = posX, posY 
	posX = 0
	posY = 0 
	if amount >= 0 then
		amount = amount *0.25
		amount = amount + 0.5
		drawHeightCorrection = height*amount
		if drawHeightCorrection > height then drawHeightCorrection = height end
		amount = _amount+0.5
		horizonPosY = height*amount
		dxDrawRectangle(posX, posY, width, height, tocolor(147, 69, 21,255))
		dxDrawRectangle(posX, posY, width, drawHeightCorrection, tocolor(0, 126, 183,255))
		dxDrawLine(0, drawHeightCorrection, width, drawHeightCorrection, tocolor(0, 0, 0, 255))
	else 
		amount = amount * 0.25
		amount = amount - 0.5
		drawHeightCorrection = height*amount
		if drawHeightCorrection < -1*height then drawHeightCorrection = -1*height end
		amount = _amount-0.5
		horizonPosY = height+height*amount
		dxDrawRectangle(posX, posY, width, height, tocolor(0, 126, 183,255))
		dxDrawRectangle(posX, posY+height, width, drawHeightCorrection, tocolor(147, 69, 21,255))
		dxDrawLine(0, height+drawHeightCorrection, width, height+drawHeightCorrection, tocolor(0, 0, 0, 255))
	end
	posX = _posX 
	posY = _posY
	--//>> Horizon-Line <<//
	if posY+horizonPosY > posY and posY+horizonPosY < posY+height then
		dxDrawLine(posX, posY+horizonPosY, posX+width*0.3, posY+horizonPosY)
		dxDrawLine(posX+width, posY+horizonPosY, posX+width*0.7, posY+horizonPosY)
		dxDrawLine(posX+width*0.45, posY+horizonPosY, posX+width*0.55, posY+horizonPosY)
	end
	dxSetRenderTarget()
	dxSetRenderTarget(self.m_PitchRenderTarget)
		dxDrawImage(-width*0.25, 0, width*1.5, height, self.m_PitchRenderHorizon, yaw)
	dxSetRenderTarget()
	dxDrawImage(posX, posY, width, height, self.m_PitchRenderTarget)
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
	dxDrawImage(posX+width*0.2, posY+height*0.1, width*0.6, width*0.6, "files/images/Speedo/heading.png", rz+180, 0, 0, tocolor(10, 97, 34, 255) )
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
	local isBrakeApplied = getElementData( aircraft, "Handbrake" ) or getControlState("handbrake") or isElementFrozen(aircraft)
	if not isBrakeApplied then 
		dxDrawBoxText("BRAKE", posX+width*0.4, posY+height*0.55, width*0.2, height*0.4, tocolor(10, 97, 34, 255), 0.9, "sans", "center", "center")
	else 
		dxDrawBoxText("BRAKE", posX+width*0.4, posY+height*0.55, width*0.2, height*0.4, tocolor(200, 0, 0, 255), 0.9, "sans", "center", "center")
	end
	dxDrawBoxShape(posX+width*0.4, posY+height*0.55, width*0.2, height*0.4, tocolor(10, 97, 34, 255), 1)
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

function HUDAviation:drawBorder(posX, posY, width, height)
	dxDrawRectangle((posX-width*0.01), (posY-width*0.01), (width*1.02), (height+width*0.02), tocolor(186, 184, 169, 255))
	dxDrawBoxShape((posX-width*0.01)-2, (posY-width*0.01)-2, (width*1.02)+4, (height+width*0.02)+4, tocolor(0, 0, 0, 255), 4)
end

function HUDAviation:drawEngineInfo(posX, posY, width, height) 
	local aircraft = getPedOccupiedVehicle( localPlayer ) 
	if not aircraft then return end 
	dxDrawRectangle(posX, posY, width, height, tocolor(0, 0, 0, 255))
	dxDrawImage(posX+width*0.3, posY+height*0.1, width*0.4, width*0.4, engineCirlce)
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
	dxDrawImage(posX+width*0.3, posY+height*0.1+width*0.5, width*0.2, width*0.2, engineCirlce)
	dxDrawLine(posX+width*0.4, posY+height*0.1+width*0.6, e1x, e1y, tocolor(10, 97, 34, 255), 2)
	dxDrawBoxText("N1", eN1x, eN1y, width*0.1, height*0.07, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
	dxDrawBoxText("N2", eN2x, eN2y, width*0.1, height*0.07, tocolor(10, 97, 34, 255), 1, "sans", "left", "top")
	local e2x, e2y
	if self.m_AviationType > 1 then
		e2x, e2y = getLineAngle( posX+width*0.65, posY+height*0.1+width*0.6, width*0.1, startAngle+(engineWork*maxExtendAngle))
		dxDrawImage(posX+width*0.55, posY+height*0.1+width*0.5, width*0.2, width*0.2, engineCirlce)
		dxDrawLine(posX+width*0.65, posY+height*0.1+width*0.6, e2x, e2y, tocolor(10, 97, 34, 255), 2)
	else 
		e2x, e2y = getLineAngle( posX+width*0.65, posY+height*0.1+width*0.6, width*0.1, startAngle)
		dxDrawImage(posX+width*0.55, posY+height*0.1+width*0.5, width*0.2, width*0.2, engineCirlce, 0, 0, 0, tocolor(40, 40, 40, 255))
		dxDrawLine(posX+width*0.65, posY+height*0.1+width*0.6, e2x, e2y, tocolor(40, 40, 40, 255), 2)
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

function HUDAviation:checkAcceleration( aircraft ) 
	if not aircraft then return end
	local vx, vy, vz = getElementVelocity(aircraft)
	local speedVector = (vx^2 + vy^2 + vz^2)^(0.5)
	return (speedVector*180)/180
end

function HUDAviation:drawStartUpDisplay( posX, posY, width, height)
	if posX and posY and width and height then 
		local now = getTickCount() 
		dxDrawRectangle(posX, posY, width, height, tocolor(0, 0, 0, 255))
		if now % 1000 >= 500 then
			local setupWidth = dxGetTextWidth("SETUP", 1, "clear")
			local setupHeight = dxGetFontHeight(1, "clears")
			dxDrawBoxText("SETUP", posX, posY, width, height, tocolor(10, 97, 34, 255), 1, "clear", "center", "center")
			dxDrawBoxShape((posX+width*0.5)-(setupWidth*0.6), (posY+height*0.5)-(setupHeight*0.5), setupWidth*1.1, setupHeight, tocolor(10, 97, 34, 255))
		end
	end
end
