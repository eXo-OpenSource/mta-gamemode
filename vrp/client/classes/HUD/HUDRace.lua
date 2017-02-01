-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDRace.lua
-- *  PURPOSE:     Race HUD class
-- *
-- ****************************************************************************
HUDRace = inherit(Singleton)
addRemoteEvents{"showRaceHUD", "HUDRaceUpdateTimes"}

function HUDRace:constructor()
	self.m_Width, self.m_Height = 250*screenWidth/1920, 52*screenHeight/1080
	self.m_PosX, self.m_PosY = screenWidth/2-self.m_Width/2, 0
	self.m_RenderTarget = dxCreateRenderTarget(self.m_Width, self.m_Height, true)

	self.m_StartTick = false
	self.m_Time = false
	self.m_BestTime = false

	self:updateRenderTarget()

	HUDRadar:getSingleton():hide()
	HUDUI:getSingleton():hide()

	self.m_Render = bind(HUDRace.render, self)
	addEventHandler("onClientRender", root, self.m_Render)
end

function HUDRace:destructor()
	HUDRadar:getSingleton():show()
	HUDUI:getSingleton():show()
	removeEventHandler("onClientRender", root, self.m_Render)
end

function HUDRace:updateTimes(startTick, bestTime)
	self.m_StartTick = startTick and getTickCount() or false
	self.m_BestTime = bestTime
end

function HUDRace:updateRenderTarget()
	self.m_RenderTarget:setAsTarget(true)
	dxDrawRectangle(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 200))
	dxDrawRectangle(0, 0, self.m_Width, 5, Color.LightBlue)

	dxDrawText("Aktuell", 0, 5, self.m_Width/2, self.m_Height/2 + 5, Color.White, 1, VRPFont(self.m_Height*0.6), "center", "center")
	dxDrawText("Beste", self.m_Width/2, 5, self.m_Width, self.m_Height/2 + 5, Color.White, 1, VRPFont(self.m_Height*0.6), "center", "center")

	dxDrawText(self.m_Time and timeMsToTimeText(self.m_Time) or "--:--:---", 0, self.m_Height/2, self.m_Width/2, self.m_Height, Color.White, 1, VRPFont(self.m_Height*0.6), "center", "center")
	dxDrawText(self.m_BestTime and timeMsToTimeText(self.m_BestTime) or "--:--:---", self.m_Width/2, self.m_Height/2, self.m_Width, self.m_Height, Color.White, 1, VRPFont(self.m_Height*0.6), "center", "center")

	dxSetRenderTarget()
end

function HUDRace:render()
	if self.m_StartTick then
		self.m_Time = getTickCount() - self.m_StartTick
	end

	self:updateRenderTarget()
	dxDrawImage(self.m_PosX, self.m_PosY, self.m_Width, self.m_Height, self.m_RenderTarget)
end

addEventHandler("HUDRaceUpdateTimes", root,
	function(startTick, bestTime)
		HUDRace:getSingleton():updateTimes(startTick, bestTime)
	end
)

addEventHandler("showRaceHUD", root,
	function(show, ...)
		if show then
			HUDRace:new(...)
		else
			delete(HUDRace:getSingleton())
		end
	end
)




addCommandHandler("race", function()
	HUDRace:getSingleton()
end)

addCommandHandler("racedel", function()
	delete(HUDRace:getSingleton())
end)

