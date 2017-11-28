-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDAviation.lua
-- *  PURPOSE:     HUD aviation class
-- *
-- ****************************************************************************
HUDAviation = inherit(Singleton)
local displayFontHeight = dxGetFontHeight(1,"default")

function HUDAviation:constructor()
	self.m_Draw = bind(self.draw, self)
	self.m_Width = screenWidth*0.4
	self.m_Height = screenHeight*0.2 
	self.m_StartX = screenWidth*0.5 - self.m_Width/2 
	self.m_StartY = screenHeight - self.m_Height*1.2
	-- Add event handlers
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
	if not vehicle then  -- death in veh fix
		self:hide()
		return
	end
	
	self:drawPitch()

	
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/Speedo", 1, 1) end
end

function HUDAviation:drawPitch() 
	local pitch = getElementRotation( getPedOccupiedVehicle(localPlayer) )
	if pitch >= 180 and pitch < 315  then
			pitch = 313-360
	end
	if pitch > 180 then
		pitch = pitch-360
	end
	local amount = pitch / 90
	outputChatBox(amount)
	local posX = self.m_StartX 
	local posY = self.m_StartY 
	local width = self.m_Width*0.2
	local height = self.m_Height
	local horizonPosY = 0
	if amount >= 0 then
		amount = amount + 0.5
		if amount >= 1 then amount = 1 end
		horizonPosY = height*amount
		dxDrawRectangle(posX, posY, width, height, tocolor(189, 132, 8,255))
		dxDrawRectangle(posX, posY, width, height*amount, tocolor(0, 197, 255,255))
	else 
		amount = amount - 0.5
		if amount >= 1 then amount = 1 end
		horizonPosY = height+height*amount
		dxDrawRectangle(posX, posY, width, height, tocolor(0, 197, 255,255))
		dxDrawRectangle(posX, posY+height, width, height*amount, tocolor(189, 132, 8,255))
	end
	--//>> Horizon-Line <<//
	dxDrawLine(posX, posY+horizonPosY, posX+width*0.3, posY+horizonPosY)
	dxDrawLine(posX+width, posY+horizonPosY, posX+width*0.7, posY+horizonPosY)
	dxDrawLine(posX+width*0.45, posY+horizonPosY, posX+width*0.55, posY+horizonPosY)
	--//>> Degree-Lines <<//
	local degreeLine = 0
	local degreeCount = -4
	local degreeString = ""
	local fontWidth
	for i = -9, 9 do 
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
	dxDrawLine( posX-width*0.06, (posY+height*0.5)+2, posX, (posY+height*0.5)+2, tocolor(255,255,50,150), 2)
	dxDrawLine( posX+width, (posY+height*0.5)+2, posX+width+(width*0.06), (posY+height*0.5)+2, tocolor(255,255,50,150), 2)
	--//>>Overlay<<//
	dxDrawImage(posX, posY, width, height, "files/images/Speedo/aviation_pitch_overlay.png")
end



