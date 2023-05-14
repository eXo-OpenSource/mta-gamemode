-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:
-- *  PURPOSE:
-- *
-- ****************************************************************************

AchievementBox = inherit(Object)
AchievementBox.queue = {}
AchievementBox.active = false

function AchievementBox:constructor (text, xp)
	if AchievementBox.active then
		table.insert(AchievementBox.queue, {text, xp})
		return
	end

	AchievementBox.active = true

	self.m_XP = xp or "0"
	self.m_Text = text or "An error occured"

	self.ms_startPosition = Vector3((screenWidth)/2, (screenHeight - 75) - 20, 0)
	self.ms_endPosition = Vector3((screenWidth - 400)/2, (screenHeight - 75) - 20, 0)
	self.ms_startSize = Vector3(0, 75, 0)
	self.ms_endSize = Vector3(400, 75, 0)
	self.m_Position = nil;
	self.m_Size = nil;

	self.m_Font = VRPFont(25, Fonts.Gasalt)

	self.ms_renderTarget = dxCreateRenderTarget(self.ms_endSize, true)
	dxSetRenderTarget(self.ms_renderTarget, true)
		dxSetBlendMode("modulate_add")

		dxDrawRectangle(0, 0, self.ms_endSize, tocolor(0, 0, 0, 150))
		dxDrawRectangle(0, 0, self.ms_endSize.x, 5, Color.DarkLightBlue)
		dxDrawImage(5, 5, 65, 65, "files/images/Logo.png")
		dxDrawText("Achievement unlocked:", 80, 10, 360, 35, Color.White, 1.3, "default", "center", "center")
		dxDrawText(_("%s", self.m_Text), 80, 35, 360, self.ms_endSize.y - 15, Color.White, 1, getVRPFont(self.m_Font), "center", "center", true)

		dxSetBlendMode("blend")
	dxSetRenderTarget()

	self.ms_inEasing = "OutBack"
	self.ms_outEasing = "InBack"
	self.m_Progress = 0;
	self.ms_startTime = getTickCount();
	self.ms_endTime = self.ms_startTime + 1000;
	self.m_RenderType = 1
	self.ms_renderFunc = bind(self.render, self)

	addEventHandler("onClientRender", root, self.ms_renderFunc)

	setTimer(function ()
		self:runBackwards()
	end, 7000, 1) -- 6s visible

	--[[
	self.m_boxSize = Vector2(400, 120)
	self.m_boxPosition = Vector2((screenWidth - self.ms_boxSize.x)/2, (screenHeight - self.ms_boxSize.y) - 20)
	self.m_imageSize = Vector2(self.ms_boxSize.y - 10, self.ms_boxSize.y - 10)
	self.m_imagePosition = self.ms_boxPosition + Vector2(5, 5)
	self.m_boxTarget = dxCreateRenderTarget(self.ms_boxSize, true)
	--]]
end

function AchievementBox:destructor ()
	destroyElement(self.ms_renderTarget)
	removeEventHandler("onClientRender", root, self.ms_renderFunc)

	AchievementBox.active = false
	if #AchievementBox.queue > 0 then
		setTimer(function ()
			AchievementBox:new(unpack(AchievementBox.queue[1]))
			table.remove(AchievementBox.queue, 1)
		end, 1000, 1)
	end
end

function AchievementBox:runBackwards ()
	self.ms_startTime = getTickCount();
	self.ms_endTime = self.ms_startTime + 500;
	self.m_RenderType = 2

	setTimer(function ()
		delete(self)
	end, 500, 1)
end

function AchievementBox:render ()
	if getTickCount() <= self.ms_endTime then
		if self.m_RenderType == 1 then
			self.m_Progress = (getTickCount() - self.ms_startTime)/(self.ms_endTime - self.ms_startTime)
			self.m_Position = Vector3(interpolateBetween(self.ms_startPosition, self.ms_endPosition, self.m_Progress, self.ms_inEasing))
			self.m_Size = Vector3(interpolateBetween(self.ms_startSize, self.ms_endSize, self.m_Progress, self.ms_inEasing))
		elseif self.m_RenderType == 2 then
			self.m_Progress = (getTickCount() - self.ms_startTime)/(self.ms_endTime - self.ms_startTime)
			self.m_Position = Vector3(interpolateBetween(self.ms_endPosition, self.ms_startPosition, self.m_Progress, self.ms_outEasing))
			self.m_Size = Vector3(interpolateBetween(self.ms_endSize, self.ms_startSize, self.m_Progress, self.ms_outEasing))
		end
	end

	dxDrawImage(self.m_Position, self.m_Size, self.ms_renderTarget)
end


