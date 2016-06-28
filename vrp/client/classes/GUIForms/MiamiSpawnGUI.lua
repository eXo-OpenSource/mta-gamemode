-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MiamiSpawnGUI.lua
-- *  PURPOSE:     Artistic Miami Spawn GUI class
-- *
-- ****************************************************************************
MiamiSpawnGUI = inherit(GUIForm)
inherit( Singleton, MiamiSpawnGUI)

local month_abr = {"JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"}
addRemoteEvents{"Event_StartScreen"}
function MiamiSpawnGUI:constructor()
	addEventHandler("Event_StartScreen", localPlayer, bind( MiamiSpawnGUI.Event_InitScreen, self))
end

function MiamiSpawnGUI:Event_InitScreen()
	local bstate = 	core:get("HUD", "startScreen" )
	setElementFrozen(localPlayer,true)
	if not bstate then return end
	self.m_RadarEnabled = HUDRadar:getSingleton().m_Enabled
	if self.m_RadarEnabled then 
		HUDRadar:getSingleton():setEnabled(false)
	end
	showChat(false)
	GUIForm.constructor(self, 0,0,screenWidth, screenHeight)
	fadeCamera(false,0.5,0,0,0)
	self.m_StartTick = getTickCount()
	self.m_EndTick = self.m_StartTick + 1000
	local time = getRealTime()
	local hour = string.format("%.2d",time.hour)
	local minute = string.format("%.2d",time.minute)
	local x,y,z = getElementPosition( localPlayer )
	self.m_Font = dxCreateFont("files/fonts/digital-7.ttf", 40, false, "antialiased") or "default-bold"
	self.m_Font2 = dxCreateFont("files/fonts/bit_font.ttf", 30, false, "antialiased") or "default-bold"
	self.m_FontHeight = math.floor(screenWidth*0.002)*ASPECT_RATIO_MULTIPLIER
	self.m_FontHeight2 = math.floor(screenWidth*0.001)*ASPECT_RATIO_MULTIPLIER
	if self.m_FontHeight2 <= 0.5 then 
		self.m_FontHeight2 = 0.5
	end
	self.m_Font3 = dxCreateFont("files/fonts/bit_font.ttf", 20, false, "antialiased") or "default-bold"
	self.m_ClockText = hour..":"..minute
	self.m_LocText = string.upper(getZoneName(x, y, z, true))..", SAN ANDREAS"
	self.m_DateText = month_abr[time.month].." "..time.monthday..", "..time.year + 1900
	self.m_ClockTextScale = {dxGetTextWidth( self.m_ClockText,self.m_FontHeight,self.m_Font ),dxGetFontHeight( self.m_FontHeight,self.m_Font )}
	self.m_DateTextScale = {dxGetTextWidth( self.m_DateText,self.m_FontHeight2,self.m_Font2 ),dxGetFontHeight( self.m_FontHeight2,self.m_Font2 )}
	self.m_LocTextScale = {dxGetTextWidth( self.m_LocText,self.m_FontHeight2,self.m_Font3 ),dxGetFontHeight( self.m_FontHeight2,self.m_Font3 )}
	self.m_Duration = self.m_EndTick - self.m_StartTick 
	self.m_Bind = bind( MiamiSpawnGUI._Render, self)
	addEventHandler("onClientRender", root, self.m_Bind )
end

function MiamiSpawnGUI:_Render()
	setCameraMatrix(0,0,0,0,0,0)
	local now = getTickCount()
	local elap = now - self.m_StartTick
	local prog = elap / self.m_Duration
	local alpha = interpolateBetween( 0,0,0,255,0,0,prog,"Linear")
	local height, height2, width = interpolateBetween( -1*screenHeight - self.m_ClockTextScale[2],screenHeight*1+self.m_DateTextScale[2], 0, screenHeight*0.5-self.m_ClockTextScale[2],screenHeight*0.5+self.m_DateTextScale[2]/2,1, prog, "Linear")
	dxDrawText(self.m_ClockText,screenWidth*0.5- (self.m_ClockTextScale[1]/2),height,screenWidth*0.5+ (self.m_ClockTextScale[1]/2), screenHeight, tocolor(176, 33, 33, alpha), self.m_FontHeight, self.m_Font, "left", "top")
	dxDrawLine(screenWidth*0.5- (((self.m_ClockTextScale[1])/2)*width), screenHeight*0.5, screenWidth*0.5+ ((self.m_ClockTextScale[1]/2)*width), screenHeight*0.5 ,tocolor(255,255,255,alpha))
	dxDrawText(self.m_DateText,screenWidth*0.5- (self.m_DateTextScale[1]/2),height2,screenWidth*0.5+ (self.m_DateTextScale[1]/2), screenHeight, tocolor(255, 255, 255, alpha), self.m_FontHeight2, self.m_Font2, "left", "top")
	dxDrawText(self.m_LocText,screenWidth*0.5- (self.m_LocTextScale[1]/2),height2+(self.m_DateTextScale[2]*1.2),screenWidth*0.5+ (self.m_LocTextScale[1]/2), screenHeight, tocolor(255, 255, 255, alpha), self.m_FontHeight2, self.m_Font3, "left", "top")
	if prog >= 1 then 
		if not self.m_FadeOut then 
			self.m_FadeOut = now + 2000
		elseif now >= self.m_FadeOut then 
			removeEventHandler("onClientRender", root, self.m_Bind)
			fadeCamera(true,0.5)
			if self.m_RadarEnabled then 
				HUDRadar:getSingleton():setEnabled(true)
				showChat(true)
				setCameraTarget(localPlayer)
				setElementFrozen(localPlayer,false)
			end
		end
	end
end
