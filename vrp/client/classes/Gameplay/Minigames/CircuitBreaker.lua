-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/CircuitBreaker.lua
-- *  PURPOSE:     Hacking Minigame for Bank Robbery
-- *
-- ****************************************************************************
CircuitBreaker = inherit(Singleton)
addRemoteEvents{"startCircuitBreaker", "forceCircuitBreakerClose"}

function CircuitBreaker:constructor(callbackEvent)
	self.WIDTH, self.HEIGHT = 1080, 650
	self.m_Textures = {}
	self.m_HeaderHeight = screenHeight/10
	self.m_CallBackEvent = callbackEvent

	--Render targets
	self.m_RT_background = DxRenderTarget(screenWidth, screenHeight, false)	-- background
	self.m_RT_PCB = DxRenderTarget(self.WIDTH, self.HEIGHT, true)			-- PCB - MCUs, resistors, capacitors
	self.m_RT_lineBG = DxRenderTarget(self.WIDTH, self.HEIGHT, true)		-- First Line Background
	self.m_RT_lineBG2 = DxRenderTarget(self.WIDTH, self.HEIGHT, true)		-- Seccond Line Background
	self.m_RT_line = DxRenderTarget(self.WIDTH, self.HEIGHT, true)			-- Main Line

	self.m_HelpFontHeight = dxGetFontHeight(2,"default-bold")
	self:loadImages()
	self:createGameplay()
	self:updateRenderTarget()
	self:bindKeys()

	self.m_fnRender = bind(CircuitBreaker.onClientRender, self)
	self.m_fnRestore = bind(CircuitBreaker.onClientRestore, self)
	removeEventHandler("onClientRender", root, self.m_fnRender)
	removeEventHandler("onClientRestore", root, self.m_fnRestore)
	addEventHandler("onClientRender", root, self.m_fnRender)
	addEventHandler("onClientRestore", root, self.m_fnRestore)
	localPlayer:setFrozen(true)
	toggleControl("left",false)
	toggleControl("right",false)
	toggleControl("forwards",false)
	toggleControl("backwards",false)
	showChat(false)
end

function CircuitBreaker:destructor()
	unbindKey("arrow_l", "down", self.fn_changeDirection)			unbindKey("a", "down", self.fn_changeDirection)
	unbindKey("arrow_r", "down", self.fn_changeDirection)			unbindKey("d", "down", self.fn_changeDirection)
	unbindKey("arrow_u", "down", self.fn_changeDirection)			unbindKey("w", "down", self.fn_changeDirection)
	unbindKey("arrow_d", "down", self.fn_changeDirection)			unbindKey("s", "down", self.fn_changeDirection)
	unbindKey("space", "down", self.fn_StopGame)
	unbindKey("enter", "down", self.fn_StartGame)
	removeEventHandler("onClientRender", root, self.m_fnRender)
	removeEventHandler("onClientRestore", root, self.m_fnRestore)
	localPlayer:setFrozen(false)
	toggleControl("left",true)
	toggleControl("right",true)
	toggleControl("forwards",true)
	toggleControl("backwards",true)
	showChat(true)

	for _, texture in pairs(self.m_Textures) do
		texture:destroy()
	end

	for level, groups in pairs(self.m_Levels) do
		for group, v in pairs(groups) do
			self.m_Levels[level][group][5]:destroy()
		end
	end

	for _, line in pairs(self.m_Lines) do
		for _, renderTarget in pairs(line) do
			renderTarget:destroy()
		end
	end

	if self.m_RT_endscreen then self.m_RT_endscreen:destroy() end
end

function CircuitBreaker:loadImages()
	self.m_Images = {
		"input",
		"output",
		"pcb",
		"qfp44",
		"sop8",
		"LD1117",
		"diode",
		"smdcapacitor",
		"smdresistor",
	}

	for _, img in pairs(self.m_Images) do
		self.m_Textures[img] = DxTexture(("files/images/CircuitBreaker/%s.png"):format(img))
	end
end

function CircuitBreaker:createGameplay()
	-- Level patterns - {startX, startY, sizeX, sizeY, material}
	self.m_Levels = {
        --Leveldesign 1
		[1] = {
				{10, 10, 255, 410, self:createStructurGroup(255, 410)},
				{190, 550, 170, 90, self:createStructurGroup(170, 90)},
				{265, 320, 350, 160, self:createStructurGroup(350, 160)},
				{615, 390, 235, 90, self:createStructurGroup(235, 90)},
				{420, 480, 195, 115, self:createStructurGroup(195, 115)},
				{240, 420, 25, 60, self:createStructurGroup(25, 60)},
				{670, 535, 400, 105, self:createStructurGroup(400, 105)},
				{925, 315, 145, 220, self:createStructurGroup(145, 220)},
				{670, 210, 300, 105, self:createStructurGroup(300, 105)},
				{970, 235, 100, 80, self:createStructurGroup(100, 80)},
				{775, 80, 75, 130, self:createStructurGroup(75, 130)},
				{340, 70, 85, 205, self:createStructurGroup(85, 205)},
				{425, 160, 245, 90, self:createStructurGroup(245, 90)},
				{670, 160, 75, 50, self:createStructurGroup(75, 50)},
				{310, 70, 30, 75, self:createStructurGroup(30, 75)},
				{485, 10, 220, 105, self:createStructurGroup(220, 105)},
				{905, 10, 90, 105, self:createStructurGroup(90, 105)},
			},

        --Leveldesign 2
		[2] = {
				{60, 275, 95, 75, self:createStructurGroup(95, 75)},
				{155, 10, 120, 355, self:createStructurGroup(120, 355)},
				{155, 365, 190, 160, self:createStructurGroup(190, 160)},
				{10, 410, 90, 50, self:createStructurGroup(90, 50)},
				{120, 575, 120, 65, self:createStructurGroup(120, 65)},
				{345, 365, 445, 95, self:createStructurGroup(445, 95)},
				{290, 525, 55, 80, self:createStructurGroup(55, 80)},
				{390, 460, 115, 40, self:createStructurGroup(115, 40)},
				{540, 315, 250, 50, self:createStructurGroup(250, 50)},
				{715, 460, 75, 50, self:createStructurGroup(75, 50)},
				{275, 10, 180, 100, self:createStructurGroup(180, 100)},
				{405, 110, 50, 95, self:createStructurGroup(50, 95)},
				{455, 10, 265, 85, self:createStructurGroup(265, 85)},
				{600, 95, 75, 60, self:createStructurGroup(75, 60)},
				{360, 250, 130, 80, self:createStructurGroup(130, 80)},
				{415, 560, 380, 80, self:createStructurGroup(380, 80)},
				{540, 525, 90, 35, self:createStructurGroup(90, 35)},
				{520, 210, 130, 60, self:createStructurGroup(130, 60)},
				{520, 150, 45, 60, self:createStructurGroup(45, 60)},
				{675, 210, 335, 60, self:createStructurGroup(335, 60)},
				{800, 50, 80, 160, self:createStructurGroup(80, 160)},
				{950, 270, 85, 115, self:createStructurGroup(85, 115)},
				{855, 330, 95, 55, self:createStructurGroup(95, 55)},
				{855, 385, 115, 85, self:createStructurGroup(115, 85)},
				{855, 470, 85, 170, self:createStructurGroup(85, 170)},
				{950, 10, 40, 65, self:createStructurGroup(40, 65)},
				{1030, 105, 40, 70, self:createStructurGroup(40, 70)},
				{1020, 440, 50, 90, self:createStructurGroup(50, 90)},
			},

        --Leveldesign 3
		[3] = {
				{10, 10, 485, 95, self:createStructurGroup(485, 95)},
				{10, 150, 90, 75, self:createStructurGroup(90, 75)},
				{10, 420, 95, 80, self:createStructurGroup(95, 80)},
				{135, 105, 170, 45, self:createStructurGroup(170, 45)},
				{75, 280, 80, 95, self:createStructurGroup(80, 95)},
				{155, 210, 80, 430, self:createStructurGroup(80, 430)},
				{235, 210, 30, 50, self:createStructurGroup(30, 50)},
				{405, 105, 90, 215, self:createStructurGroup(90, 215)},
				{495, 135, 180, 60, self:createStructurGroup(180, 60)},
				{310, 240, 95, 235, self:createStructurGroup(95, 235)},
				{285, 475, 60, 120, self:createStructurGroup(60, 120)},
				{405, 400, 265, 75, self:createStructurGroup(265, 75)},
				{405, 525, 130, 110, self:createStructurGroup(130, 110)},
				{585, 475, 40, 60, self:createStructurGroup(40, 60)},
				{585, 585, 40, 55, self:createStructurGroup(40, 55)},
				{715, 415, 40, 65, self:createStructurGroup(40, 65)},
				{570, 225, 40, 130, self:createStructurGroup(40, 130)},
				{550, 45, 280, 50, self:createStructurGroup(280, 50)},
				{745, 95, 85, 275, self:createStructurGroup(85, 275)},
				{670, 240, 75, 55, self:createStructurGroup(75, 55)},
				{830, 150, 45, 85, self:createStructurGroup(45, 85)},
				{785, 370, 85, 270, self:createStructurGroup(85, 270)},
				{870, 490, 25, 75, self:createStructurGroup(25, 75)},
				{870, 270, 80, 100, self:createStructurGroup(80, 100)},
				{720, 560, 65, 80, self:createStructurGroup(65, 80)},
				{830, 295, 40, 75, self:createStructurGroup(40, 75)},
				{930, 130, 35, 70, self:createStructurGroup(35, 70)},
				{910, 10, 160, 85, self:createStructurGroup(160, 85)},
				{1020, 95, 50, 175, self:createStructurGroup(50, 175)},
				{1000, 220, 20, 50, self:createStructurGroup(20, 50)},
				{1005, 315, 65, 175, self:createStructurGroup(65, 175)},
				{950, 400, 55, 135, self:createStructurGroup(55, 135)},
				{940, 590, 40, 50, self:createStructurGroup(40, 50)},
		}
	}

	-- Some definitions
	self.m_DefaultLineColor = tocolor(70, 160, 255)
	self.m_Level = 1
	self.m_State = "idle"
	self.m_MoveDirection = "r"											--r = right | l = left | u = up | d = down

	-- Set D-Sub9 start pos
	self.m_LevelStartPosX = 0
	self.m_LevelStartPosY = 500

	-- Set D-Sub9 end pos
	self.m_LevelEndPosX = self.WIDTH - 56 								--56 is the with of the d-sub 9 connector
	self.m_LevelEndPosY = {100, 545, 530}

	-- Set line pos
	self.m_LinePosX = 56 - 5
	self.m_LinePosY = self.m_LevelStartPosY + 82/2 - 5/2

	self.m_MoveSpeed = self.m_Level + 1
	self.m_LineWidth = 0

	self.m_LineColor = self.m_DefaultLineColor

	self.m_Lines = {}													-- Storage for "old" render targets
end

function CircuitBreaker:createNextLevel()
	self.m_MoveDirection = "r"

	-- Set D-Sub9 start pos
	self.m_LevelStartPosX = 0
	self.m_LevelStartPosY = self.m_LevelEndPosY[self.m_Level - 1] 		-- Start where the last level has ended

	-- Set line pos
	self.m_LinePosX = 56 - 5											--56 is the with of the d-sub 9 connector
	self.m_LinePosY = self.m_LevelStartPosY + 82/2 - 5/2

	self.m_MoveSpeed = self.m_Level + 1
	self.m_LineWidth = 0
end

function CircuitBreaker:setState(state)
	if state == "play" then
		self.m_State = "play"
		self.m_LineWidth = 5
	end

	if state == "done" then
		self.m_RT_endscreen = DxRenderTarget(self.WIDTH*3, self.HEIGHT, true)
		self.m_State = "done"
		outputDebug("all levels done")

		--Todo: Show completed PCB (end screen)
	end

	if state == "tryPlay" then
		if self.m_State == "idle" then
			self:setState("play")
		end

		-- If the user failed, try to play the level again
		if self.m_State == "failed" then
			self.m_RT_line:setAsTarget(true) dxSetRenderTarget()		--Clear render targets
			self.m_RT_lineBG:setAsTarget(true) dxSetRenderTarget()
			self.m_RT_lineBG2:setAsTarget(true) dxSetRenderTarget()

			self.m_MoveDirection = "r"

			self.m_LinePosX = 56 - 5
			self.m_LinePosY = self.m_LevelStartPosY + 82/2 - 5/2
			self.m_LineColor = self.m_DefaultLineColor

			self:setState("play")
		end

		if self.m_State == "complete" then
			self.m_RT_PCB = DxRenderTarget(self.WIDTH, self.HEIGHT, true)		--Create new render targets
			self.m_RT_line = DxRenderTarget(self.WIDTH, self.HEIGHT, true)
			self.m_RT_lineBG = DxRenderTarget(self.WIDTH, self.HEIGHT, true)
			self.m_RT_lineBG2 = DxRenderTarget(self.WIDTH, self.HEIGHT, true)

			self.m_LineColor = self.m_DefaultLineColor
			self:createNextLevel()
			self:updateRenderTarget()

			self.m_State = "idle"
		end
	end

	if state == "complete" then	--Todo: Call next level via 5 sec. timer?
		self.m_State = "complete"
		outputDebug("level complete")
		self.m_LineColor = tocolor(0, 220, 0)
		self:updateRenderTarget()

		self.m_Lines[self.m_Level] = {pcb = self.m_RT_PCB, line = self.m_RT_line, lineBG = self.m_RT_lineBG, lineBG2 = self.m_RT_lineBG2}
		self.m_Level = self.m_Level + 1

		if self.m_Level > 3 then
			self:setState("done")
		end
	end

	if state == "failed" then
		self.m_State = "failed"
		self.m_LineColor = tocolor(220, 0, 0)
		self:updateRenderTarget()
	end
end

function CircuitBreaker:bindKeys()
	if self.fn_changeDirection then
		unbindKey("arrow_l", "down", self.fn_changeDirection)			unbindKey("a", "down", self.fn_changeDirection)
		unbindKey("arrow_r", "down", self.fn_changeDirection)			unbindKey("d", "down", self.fn_changeDirection)
		unbindKey("arrow_u", "down", self.fn_changeDirection)			unbindKey("w", "down", self.fn_changeDirection)
		unbindKey("arrow_d", "down", self.fn_changeDirection)			unbindKey("s", "down", self.fn_changeDirection)
	end
	if self.fn_StartGame then
		unbindKey("enter", "down", self.fn_StartGame)
	end
	if self.fn_StopGame then
		unbindKey("space", "down", self.fn_StopGame)
	end

	self.fn_changeDirection = bind(CircuitBreaker.changeDirection, self)

	self.fn_StartGame =
		function()
			if self.m_State == "done" then
				if self.m_CallBackEvent then
					triggerServerEvent(self.m_CallBackEvent, localPlayer)
				end
				delete(self)
			else
				self:setState("tryPlay")
			end
		end

	self.fn_StopGame =
		function()
			if self.m_State == "done" then
				if self.m_CallBackEvent then
					triggerServerEvent(self.m_CallBackEvent, localPlayer)
				end
			end

			delete(self)
		end

	bindKey("arrow_l", "down", self.fn_changeDirection)			bindKey("a", "down", self.fn_changeDirection)
	bindKey("arrow_r", "down", self.fn_changeDirection)			bindKey("d", "down", self.fn_changeDirection)
	bindKey("arrow_u", "down", self.fn_changeDirection)			bindKey("w", "down", self.fn_changeDirection)
	bindKey("arrow_d", "down", self.fn_changeDirection)			bindKey("s", "down", self.fn_changeDirection)

	bindKey("enter", "down", self.fn_StartGame)
	bindKey("space", "down", self.fn_StopGame)
end

function CircuitBreaker:changeDirection(key)
	if self.m_State ~= "play" then return end

	-- normalise key names
	key = key == "arrow_l" and "l" or key == "a" and "l" or key
	key = key == "arrow_r" and "r" or key == "d" and "r" or key
	key = key == "arrow_u" and "u" or key == "w" and "u" or key
	key = key == "arrow_d" and "d" or key == "s" and "d" or key

	-- disable opposite movements
	if self.m_MoveDirection == "l" and key == "r" then return end
	if self.m_MoveDirection == "r" and key == "l" then return end
	if self.m_MoveDirection == "u" and key == "d" then return end
	if self.m_MoveDirection == "d" and key == "u" then return end

	self.m_MoveDirection = key
end

function CircuitBreaker:updateRenderTarget()
	---
	-- Update background render target
	---
	self.m_RT_background:setAsTarget()

	dxDrawRectangle(0, 0, screenWidth, screenHeight, tocolor(0, 0, 0,100)) -- 323232
	dxDrawRectangle(0, 0, screenWidth, self.m_HeaderHeight, tocolor(0, 0, 0, 170))

	dxSetRenderTarget()

	---
	-- Update PCB render target
	---

	self.m_RT_PCB:setAsTarget()
	dxDrawImage(0, 0, self.WIDTH, self.HEIGHT, self.m_Textures.pcb)
	dxDrawImage(self.m_LevelStartPosX, self.m_LevelStartPosY, 56, 82, self.m_Textures.input)
	dxDrawImage(self.m_LevelEndPosX, self.m_LevelEndPosY[self.m_Level], 56, 82, self.m_Textures.output)

	for _, v in pairs(self.m_Levels[self.m_Level]) do
		dxDrawImage(unpack(v))
	end

	dxSetRenderTarget()

	---
	-- Update line render targets
	---

	self.m_RT_lineBG:setAsTarget()
	dxSetBlendMode("overwrite")
	dxDrawRectangle(self.m_LinePosX - 1, self.m_LinePosY - 1, self.m_LineWidth + 2, self.m_LineWidth + 2, tocolor(255, 255, 255, 100))
	dxSetBlendMode("blend")
	dxSetRenderTarget()

	self.m_RT_lineBG2:setAsTarget()
	dxSetBlendMode("overwrite")
	dxDrawRectangle(self.m_LinePosX - 2, self.m_LinePosY - 2, self.m_LineWidth + 4, self.m_LineWidth + 4, tocolor(255, 255, 255, 50))
	dxSetBlendMode("blend")
	dxSetRenderTarget()

	self.m_RT_line:setAsTarget()
	dxDrawRectangle(self.m_LinePosX, self.m_LinePosY, self.m_LineWidth, self.m_LineWidth, tocolor(255, 255, 255))
	dxSetRenderTarget()
end

function CircuitBreaker:onClientRender()
	-- idk how to title that
	if self.m_State == "play" then
		if self.m_MoveDirection == "r" then
			self.m_LinePosX = self.m_LinePosX + self.m_MoveSpeed
		elseif self.m_MoveDirection == "l" then
			self.m_LinePosX = self.m_LinePosX - self.m_MoveSpeed
		elseif self.m_MoveDirection == "u" then
			self.m_LinePosY = self.m_LinePosY - self.m_MoveSpeed
		elseif self.m_MoveDirection == "d" then
			self.m_LinePosY = self.m_LinePosY + self.m_MoveSpeed
		end

		self:updateRenderTarget()

		-- Out of pcb detection
		if not rectangleCollision2D(10, 10, self.WIDTH-20, self.HEIGHT-20, self.m_LinePosX, self.m_LinePosY, self.m_LineWidth, self.m_LineWidth) then
			self:setState("failed")
		end

		for _, v in pairs(self.m_Levels[self.m_Level]) do
			if rectangleCollision2D(v[1], v[2], v[3], v[4], self.m_LinePosX, self.m_LinePosY, self.m_LineWidth, self.m_LineWidth) then
				self:setState("failed")
			end
		end

		-- Collision detection
		if self:collision(self.m_LevelEndPosX, self.m_LevelEndPosY[self.m_Level], 56, 82, self.m_LinePosX, self.m_LinePosY, self.m_LineWidth, self.m_LineWidth) then
			self:setState("complete")
		end
	end

	-- Render endscreen
	if self.m_State == "done" then
		dxDrawRectangle(0, 0, screenWidth, screenHeight, tocolor(0,0,0,150))

		for i = 1, 3 do
			dxDrawImage(screenWidth/2 - self.WIDTH/2 + (self.WIDTH/3*(i-1)), (screenHeight/2 - self.HEIGHT/2), self.WIDTH/3, self.HEIGHT/3, self.m_Lines[i].pcb)
			dxDrawImage(screenWidth/2 - self.WIDTH/2 + (self.WIDTH/3*(i-1)),(screenHeight/2 - self.HEIGHT/2), self.WIDTH/3, self.HEIGHT/3, self.m_Lines[i].lineBG2)
			dxDrawImage(screenWidth/2 - self.WIDTH/2 + (self.WIDTH/3*(i-1)), (screenHeight/2 - self.HEIGHT/2), self.WIDTH/3, self.HEIGHT/3, self.m_Lines[i].lineBG)
			dxDrawImage(screenWidth/2 - self.WIDTH/2 + (self.WIDTH/3*(i-1)), (screenHeight/2 - self.HEIGHT/2), self.WIDTH/3, self.HEIGHT/3, self.m_Lines[i].line, 0, 0, 0, self.m_LineColor)
		end

		return
	end

	-- Render game
	local scale = 0.8
	local origWidth, origHeight = self.WIDTH, self.HEIGHT
	local origHeader = self.m_HeaderHeight
	local origSWidth, origSHeight = screenWidth, screenHeight
	self.WIDTH = self.WIDTH *scale
	local screenWidth = screenWidth *scale
	local screenHeight = screenHeight * scale
	self.HEIGHT = self.HEIGHT *scale
	self.m_HeaderHeight = self.m_HeaderHeight *scale

	dxDrawImage(0, 0, origSWidth, origSHeight, "files/images/Other/focus.png")
	dxDrawImage((screenWidth/2 - self.WIDTH/4) ,(screenHeight*0.6 - self.HEIGHT/2), self.WIDTH, self.HEIGHT, self.m_RT_PCB)
	dxDrawImage((screenWidth/2 - self.WIDTH/4),(screenHeight*0.6 - self.HEIGHT/2), self.WIDTH, self.HEIGHT, self.m_RT_lineBG2)
	dxDrawImage((screenWidth/2 - self.WIDTH/4), (screenHeight*0.6 - self.HEIGHT/2), self.WIDTH, self.HEIGHT, self.m_RT_lineBG)
	dxDrawImage((screenWidth/2 - self.WIDTH/4), (screenHeight*0.6 - self.HEIGHT/2), self.WIDTH, self.HEIGHT, self.m_RT_line, 0, 0, 0, self.m_LineColor)
	dxDrawRectangle((screenWidth/2 - self.WIDTH/4), (screenHeight*0.6 - self.HEIGHT/2)+self.HEIGHT, self.WIDTH, self.m_HelpFontHeight, self.m_DefaultLineColor)
	dxDrawText("ENTER = START       SPACE = ZURÜCK",(screenWidth/2 - self.WIDTH/4), (screenHeight*0.6 - self.HEIGHT/2)+self.HEIGHT, (screenWidth/2 - self.WIDTH/4)+self.WIDTH, screenHeight, tocolor(255,255,255,255),2,"default-bold","center","top")

	self.WIDTH = origWidth
	self.HEIGHT = origHeight
	self.m_HeaderHeight = origHeader
	screenWidth = origSWidth
	screenHeight = origSHeight
end

function CircuitBreaker:onClientRestore(didClearRenderTargets)
	if didClearRenderTargets then
		outputDebug("Recreate structur groups")
		for level, groups in pairs(self.m_Levels) do
			for group, v in pairs(groups) do
				self.m_Levels[level][group][5] = self:createStructurGroup(v[3], v[4])
			end
		end

		self:updateRenderTarget()
	end
end

function CircuitBreaker:collision(sx, sy, sw, sh, px, py, pw, ph)
	return (sx <= px and sy <= py and sx + sw > px and sy + sh > py)
end

local STRUCTUR_TYPES = {
		{"qfp44", 296, 296, true, {1, 2, 3, 4}, {0, 90, 180, 270}},
		{"smdresistor", 46, 22, false, {1}, {0}},
		{"smdcapacitor", 46, 22, true, {1, 1, 1, 1, 2}, {0, 0, 90}},
		{"sop8", 82, 100, true, {1, 1, 2, 2, 2, 3}, {0, 90, 180}},
		--{"LD1117", 81, 88, true, {2, 3}, {0, 90, 180}},
		--{"diode", 72, 33, true, {3}, {0, 90, 180}},
		}

function CircuitBreaker:createStructurGroup(width, height, count)
	if not count then count = 0 end
	if count > 3 then
		return outputConsole("Zu wenig Videospeicher in MTA-Memory!")
	end

	local WIDTH, HEIGHT = width, height
	local collideImage = DxRenderTarget(WIDTH, HEIGHT, true)
	local line = 5
	local structures = {}
	if collideImage then
		collideImage:setAsTarget()
		dxDrawRectangle(0, 0, WIDTH, HEIGHT, tocolor(120, 160, 200, 170))
		for posY = 0, HEIGHT, 4 do
			for posX = 0, WIDTH, 4 do
				local rnd_structur = STRUCTUR_TYPES[math.random(1, #STRUCTUR_TYPES)]
				local sizeDivider = rnd_structur[5][math.random(1,#rnd_structur[5])]
				local rotation = rnd_structur[6][math.random(1,#rnd_structur[6])]
				local struct_width, struct_height = rnd_structur[2]/sizeDivider, rnd_structur[3]/sizeDivider
				local rotationOffsetX, rotationOffsetY = 0, 0

				local drawWidth, drawHeight = struct_width, struct_height
				local rotFix_X, rotFix_Y = posX, posY

				if rotation == 90 then
					rotationOffsetX = -(struct_width/2)
					rotationOffsetY = struct_height/2

					rotFix_Y = rotFix_Y - struct_height

					struct_width = drawHeight
					struct_height = drawWidth
				end

				if (posX + struct_width < WIDTH) and (posY + struct_height < HEIGHT) then
					if not self:rectangleCollision(structures, posX, posY, struct_width, struct_height) then
						if math.random(1, 3) == 1 then
							if rnd_structur[1] == "smdresistor" then
								self:createRandomResistor(rotFix_X, rotFix_Y, struct_width, struct_height)
							else
								dxDrawImage(rotFix_X, rotFix_Y, drawWidth, drawHeight, self.m_Textures[rnd_structur[1]], rotation, rotationOffsetX, rotationOffsetY)
							end
							table.insert(structures, {posX, posY, struct_width + math.random(2, 10), struct_height + math.random(2, 10)})
						end
					end
				end
			end
		end
	else
		return self:createStructurGroup(width, height, count + 1)
	end

	dxSetRenderTarget()
	return collideImage
end

local E24 = {"1.0", "1.1", "1.2", "1.3", "1.5", "1.6", "1.8", "2.0", "2.2", "2.4", "2.7", "3.0", "3.3", "3.6", "3.9", "4.3", "4.7",	"5.1", "5.6", "6.2", "6.8", "7.5", "8.2", "9.1"}
local eToChar = {[0] = "R", [1] = "R", [2] = "R", [3] = "K", [4] = "K", [5] = "K", [6] = "M"}
function CircuitBreaker:createRandomResistor(posX, posY, width, height, labelType)
	if not labelType then labelType = "SI" end --SI = Internationales Einheitensystem
	local e = math.random(0, 6)
	local value = E24[math.random(1, 24)]

	if labelType == "SI" then
		if e == 0 or e == 3 or e == 6 then
			value = value:gsub("[.]", eToChar[e])
		else
			value = ("%s%s%s"):format(value:gsub("[.]", ""), ("0"):rep(e - (e < 3 and 1 or 4)), eToChar[e])
		end
	elseif labelType == "COMPACT" then
		value = ("%s%s"):format(value:gsub("[.]", ""), e)
	end

	dxDrawImage(posX, posY, width, height, self.m_Textures.smdresistor)
	dxDrawText(value, posX, posY, posX + width, posY + height, tocolor(255, 255, 255), .5/14*height, "clear", "center", "center")
end

function CircuitBreaker:rectangleCollision(structTable, posX, posY, width, height)
	for _, v in pairs(structTable) do
		if rectangleCollision2D(posX, posY, width, height, v[1], v[2], v[3], v[4]) then
			return true
		end
	end
end

addEventHandler("startCircuitBreaker", root,
    function(callbackEvent)
		if CircuitBreaker:isInstantiated() then
			outputChatBox("instantiated")
			delete(CircuitBreaker:getSingleton())
		end

   		CircuitBreaker:new(callbackEvent)
    end
)

addEventHandler("forceCircuitBreakerClose", root,
	function()
		if CircuitBreaker:isInstantiated() then
			outputChatBox("instantiated")
			delete(CircuitBreaker:getSingleton())
		end
	end
)
