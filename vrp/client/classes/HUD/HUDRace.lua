-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDRace.lua
-- *  PURPOSE:     Race HUD class
-- *
-- ****************************************************************************
HUDRace = inherit(Singleton)
addRemoteEvents{"showRaceHUD", "HUDRaceUpdate", "HUDRaceUpdateDelta", "HUDRaceUpdateTimes"}

function HUDRace:constructor(showPersonalTrackStats)
	self.m_Width, self.m_Height = 250*screenWidth/1920, 52*screenHeight/1080
	self.m_PosX, self.m_PosY = screenWidth/2-self.m_Width/2, 0
	self.m_RenderTarget = DxRenderTarget(self.m_Width, self.m_Height, true)

	if showPersonalTrackStats then
		self.m_TS_Size = Vector2(300, 100)
		self.m_TrackStats = DxRenderTarget(self.m_TS_Size, true)
	end

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

function HUDRace:setStartTick(startTick)
	self.m_StartTick = startTick and getTickCount() or false
end

function HUDRace:setLaps(laps)
	self.m_Laps = laps and laps or self.m_Laps
end

function HUDRace:setSelectedLaps(laps)
	self.m_SelectedLaps = laps and laps or self.m_SelectedLaps
end

function HUDRace:setDelta(delta)
	if delta then
		self.m_DeltaTime = (delta > 0 and "+%s" or "-%s"):format(timeMsToTimeText(math.abs(delta), true))
		self.m_DeltaColor = delta > 0 and Color.Red or Color.Green

		if isTimer(self.m_DeltaTimer) then self.m_DeltaTimer:destroy() end
		self.m_DeltaTimer = setTimer(function() self.m_DeltaTime = false end, 5000, 1)
	end
end

function HUDRace:update(startTick, laps, delta)
	--self.m_StartTick = startTick and getTickCount() or false
	--self.m_Laps = laps and laps or self.m_Laps

	--[[if delta then
		self.m_DeltaTime = (delta > 0 and "+%s" or "-%s"):format(timeMsToTimeText(math.abs(delta), true))
		self.m_DeltaColor = delta > 0 and Color.Red or Color.Green

		if isTimer(self.m_DeltaTimer) then self.m_DeltaTimer:destroy() end
		self.m_DeltaTimer = setTimer(function() self.m_DeltaTime = false end, 5000, 1)
	end]]
end

function HUDRace:updateTimes(toptimes, playerID)
	self.m_BestTime = toptimes[1]

	for k, v in pairs(toptimes) do
		if v.PlayerID == playerID then
			self.m_PersonalBestTime = v.time
			return
		end
	end
end

function HUDRace:updateRenderTarget()
	self.m_RenderTarget:setAsTarget(true)
	dxDrawRectangle(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 200))
	dxDrawRectangle(0, 0, self.m_Width, 5, Color.LightBlue)

	dxDrawText("Aktuell", 0, 5, self.m_Width/2, self.m_Height/2 + 5, Color.White, 1, VRPFont(self.m_Height*0.6), "center", "center")
	dxDrawText("Beste", self.m_Width/2, 5, self.m_Width, self.m_Height/2 + 5, Color.White, 1, VRPFont(self.m_Height*0.6), "center", "center")

	dxDrawText(self.m_Time and timeMsToTimeText(self.m_Time) or "--.---", 0, self.m_Height/2, self.m_Width/2, self.m_Height, Color.White, 1, VRPFont(self.m_Height*0.6), "center", "center")
	dxDrawText(self.m_BestTime and timeMsToTimeText(self.m_BestTime.time) or "--.---", self.m_Width/2, self.m_Height/2, self.m_Width, self.m_Height, Color.White, 1, VRPFont(self.m_Height*0.6), "center", "center")

	dxSetRenderTarget()

	if not self.m_TrackStats then return end
	self.m_TrackStats:setAsTarget(true)
	dxDrawRectangle(0, self.m_TS_Size.y-28*2-5, self.m_TS_Size.x, 28, tocolor(0, 0, 0, 200))
	dxDrawText("Deine Bestzeit", 0, self.m_TS_Size.y-28*2-5, self.m_TS_Size.x - 5, 28, Color.White, 1, VRPFont(28), "right")
	dxDrawText(self.m_PersonalBestTime and timeMsToTimeText(self.m_PersonalBestTime) or "--.---", 5, self.m_TS_Size.y-28*2-5, self.m_TS_Size.x - 5, 28, Color.White, 1, VRPFont(28))

	if self.m_DeltaTime then
		dxDrawRectangle(0, self.m_TS_Size.y-28, self.m_TS_Size.x, 28, self.m_DeltaColor)
		dxDrawText("Delta", 0, self.m_TS_Size.y-28, self.m_TS_Size.x - 5, 28, Color.White, 1, VRPFont(28), "right")
		dxDrawText(self.m_DeltaTime and self.m_DeltaTime or "--.---", 5, self.m_TS_Size.y-28, self.m_TS_Size.x - 5, 28, Color.White, 1, VRPFont(28))
	end

	dxDrawText(self.m_Laps and ("R %d | %d"):format(self.m_Laps, self.m_SelectedLaps) or "--", 0, 0, self.m_TS_Size.x, self.m_TS_Size.y, Color.White, 1, VRPFont(39), "right")

	dxSetRenderTarget()
end

function HUDRace:render()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/Race") end
	if self.m_StartTick then
		self.m_Time = getTickCount() - self.m_StartTick
	end

	self:updateRenderTarget()
	dxDrawImage(self.m_PosX, self.m_PosY, self.m_Width, self.m_Height, self.m_RenderTarget)

	if self.m_TrackStats then
		dxDrawImage(screenWidth - self.m_TS_Size.x - 10, 10, self.m_TS_Size, self.m_TrackStats)
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/Race", 1, 1) end
end

addEventHandler("HUDRaceUpdateTimes", root,
	function(...)
		HUDRace:getSingleton():updateTimes(...)
	end
)

addEventHandler("HUDRaceUpdate", root,
	function(...)
		HUDRace:getSingleton():update(...)
	end
)

addEventHandler("HUDRaceUpdateDelta", root,
	function(delta)
		HUDRace:getSingleton():setDelta(delta)
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
