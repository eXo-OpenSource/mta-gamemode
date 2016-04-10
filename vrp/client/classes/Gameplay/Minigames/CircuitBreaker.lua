-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/CircuitBreaker.lua
-- *  PURPOSE:     Hacking Minigame for Bank Robbery
-- *
-- ****************************************************************************
CircuitBreaker = inherit(Singleton)

function CircuitBreaker:constructor()
	self.WIDTH, self.HEIGHT = 1080, 650

	--Render targets
	self.m_RT_background = DxRenderTarget(screenWidth, screenHeight, false)	-- background
	self.m_RT_PCB = DxRenderTarget(self.WIDTH, self.HEIGHT, true)			-- PCB - MCUs, resistors, capacitors
	--self.m_Blockades = DxRenderTarget(self.WIDTH, self.HEIGHT, true)		-- MCUs, resistors, capacitor
	self.m_RT_lineBG = DxRenderTarget(self.WIDTH, self.HEIGHT, true)		-- First Line Background
	self.m_RT_lineBG2 = DxRenderTarget(self.WIDTH, self.HEIGHT, true)		-- Seccond Line Background
	self.m_RT_line = DxRenderTarget(self.WIDTH, self.HEIGHT, true)			-- Main Line


	self:loadImages()
	self:createGameplay()
	self:updateRenderTarget()

	self:bindKeys()

	self.m_fnRender = bind(CircuitBreaker.onClientRender, self)
	addEventHandler("onClientRender", root, self.m_fnRender)
end

function CircuitBreaker:loadImages()
	self.m_Images = {
		"bg",
		"input",
		"output",
		"pcb",
		"mcu",
	}

	for _, img in pairs(self.m_Images) do
		self[img] = DxTexture(("files/images/CircuitBreaker/%s.png"):format(img))
	end
end

function CircuitBreaker:createGameplay()
	-- Level patterns - {startX, startY, sizeX, sizeY, material}
	self.m_Levels = {
		--Levels for level 1

		[1] = {
			{
				{125, 25, 256, 256, self.mcu},
				{500, 330, 256, 256, self.mcu},
				{220, 350, 128, 128, self.mcu},
				{660, 90, 128, 128, self.mcu},
				{870, 470, 128, 128, self.mcu},
			},
			{
				{140, 360, 256, 256, self.mcu},
				{650, 20, 256, 256, self.mcu},
				{170, 50, 128, 128, self.mcu},
				{420, 100, 128, 128, self.mcu},
				{590, 450, 128, 128, self.mcu},
			},
			{
				{360, 25, 256, 256, self.mcu},
				{660, 370, 256, 256, self.mcu},
				{140, 150, 128, 128, self.mcu},
				{330, 400, 128, 128, self.mcu},
				{740, 70, 128, 128, self.mcu},
			},
		},

		--Levels for level 2
		[2] = {
			{
				{300, 15, 256, 256, self.mcu},
				{500, 365, 256, 256, self.mcu},
				{140, 155, 128, 128, self.mcu},
				{140, 283, 128, 128, self.mcu},
				{250, 460, 128, 128, self.mcu},
				{590, 210, 128, 128, self.mcu},
				{780, 110, 128, 128, self.mcu},
				{800, 490, 128, 128, self.mcu},
			},
			{
				{130, 330, 256, 256, self.mcu},
				{690, 345, 256, 256, self.mcu},
				{460, 100, 128, 128, self.mcu},
				{460, 280, 128, 128, self.mcu},
				{460, 408, 128, 128, self.mcu},
				{300, 25, 128, 128, self.mcu},
				{610, 180, 128, 128, self.mcu},
				{700, 25, 128, 128, self.mcu},
			},
			{
				{350, 95, 256, 256, self.mcu},
				{225, 350, 256, 256, self.mcu},
				{100, 90, 128, 128, self.mcu},
				{525, 400, 128, 128, self.mcu},
				{655, 155, 128, 128, self.mcu},
				{700, 10, 128, 128, self.mcu},
				{700, 475, 128, 128, self.mcu},
				{765, 310, 128, 128, self.mcu},
			}
		},

		--Levels for level 3
		[3] = {
				{
					{320, 170, 256, 256, self.mcu},
					{150, 375, 128, 128, self.mcu},
					{150, 503, 128, 128, self.mcu},
					{190, 160, 64, 64, self.mcu},
					{300, 10, 128, 128, self.mcu},
					{480, 90, 64, 64, self.mcu},
					{380, 460, 128, 128, self.mcu},
					{510, 580, 64, 64, self.mcu},
					{625, 150, 64, 64, self.mcu},
					{625, 240, 128, 128, self.mcu},
					{650, 10, 64, 64, self.mcu},
					{690, 400, 128, 128, self.mcu},
					{740, 30, 128, 128, self.mcu},
					{630, 540, 64, 64, self.mcu},
					{550, 450, 64, 64, self.mcu},
				}
		}
	}

	-- Some definitions
	self.m_DefaultLineColor = tocolor(70, 160, 255)
	self.m_Level = 1
	self.m_RandomPattern = math.random(1, #self.m_Levels[self.m_Level])
	self.m_State = "idle"
	self.m_MoveDirection = "r"											--r = right | l = left | u = up | d = down

	-- Set D-Sub9 start pos
	self.m_LevelStartPosX = 0
	self.m_LevelStartPosY = math.random(0, self.HEIGHT - 82)

	-- Set D-Sub9 end pos
	self.m_LevelEndPosX = self.WIDTH - 56 								--56 is the with of the d-sub 9 connector
	self.m_LevelEndPosY = math.random(0, self.HEIGHT - 82)

	-- Set line pos
	self.m_LinePosX = 56 - 5
	self.m_LinePosY = self.m_LevelStartPosY + 82/2 - 5/2

	self.m_MoveSpeed = self.m_Level + 2
	self.m_LineWidth = 0

	self.m_LineColor = self.m_DefaultLineColor

	self.m_Lines = {}													-- Storage for "old" render targets
end

function CircuitBreaker:createNextLevel()
	self.m_MoveDirection = "r"
	self.m_RandomPattern = math.random(1, #self.m_Levels[self.m_Level])

	-- Set D-Sub9 start pos
	self.m_LevelStartPosX = 0
	self.m_LevelStartPosY = self.m_LevelEndPosY 						-- Start where the last level has ended

	-- Set D-Sub9 end pos
	self.m_LevelEndPosX = self.WIDTH - 56 								--56 is the with of the d-sub 9 connector
	self.m_LevelEndPosY = math.random(0, self.HEIGHT - 82)

	-- Set line pos
	self.m_LinePosX = 56 - 5
	self.m_LinePosY = self.m_LevelStartPosY + 82/2 - 5/2

	self.m_MoveSpeed = self.m_Level + 2
	self.m_LineWidth = 0
end

function CircuitBreaker:setState(state)		--Todo: freaky function.. need improvements lel
	if state == "play" then
		self.m_State = "play"
		self.m_LineWidth = 5
	end

	if state == "done" then
		self.m_State = "done"
		outputChatBox("all levels done")
		--Todo: Show completed PCB (end screen)

		--Todo: Trigger ?!
	end

	if state == "tryPlay" then
		if self.m_State == "idle" then
			self:setState("play")
		end

		-- If the user failed, try to play  the level again
		if self.m_State == "failed" then
			self.m_RT_line:setAsTarget(true) dxSetRenderTarget()		--Clear render targets
			self.m_RT_lineBG:setAsTarget(true) dxSetRenderTarget()		--Clear render targets
			self.m_RT_lineBG2:setAsTarget(true) dxSetRenderTarget()		--Clear render targets

			self.m_MoveDirection = "r"

			self.m_LinePosX = 56 - 5
			self.m_LinePosY = self.m_LevelStartPosY + 82/2 - 5/2
			self.m_LineColor = self.m_DefaultLineColor

			self:setState("play")
		end

		if self.m_State == "complete" then
			self.m_RT_PCB = DxRenderTarget(self.WIDTH, self.HEIGHT, true)		--Create new render targets
			self.m_RT_line = DxRenderTarget(self.WIDTH, self.HEIGHT, true)		--Create new render targets
			self.m_RT_lineBG = DxRenderTarget(self.WIDTH, self.HEIGHT, true)
			self.m_RT_lineBG2 = DxRenderTarget(self.WIDTH, self.HEIGHT, true)

			self:createNextLevel()
			self:updateRenderTarget()

			self:setState("play")
		end
	end


	if state == "complete" then	--Todo: Call next level via 5 sec. timer?
		self.m_State = "complete"
		outputChatBox("level complete")
		self.m_LineColor = self.m_DefaultLineColor
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
	self.fn_changeDirection = bind(CircuitBreaker.changeDirection, self)

	self.fn_StartGame =
		function()
			self:setState("tryPlay")
		end

	bindKey("arrow_l", "down", self.fn_changeDirection)			bindKey("a", "down", self.fn_changeDirection)
	bindKey("arrow_r", "down", self.fn_changeDirection)			bindKey("d", "down", self.fn_changeDirection)
	bindKey("arrow_u", "down", self.fn_changeDirection)			bindKey("w", "down", self.fn_changeDirection)
	bindKey("arrow_d", "down", self.fn_changeDirection)			bindKey("s", "down", self.fn_changeDirection)

	bindKey("enter", "down", self.fn_StartGame)
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

	local headerWidth = screenHeight/7

	--dxDrawImage(0, 0, screenWidth, screenHeight, self.bg)
	dxDrawRectangle(0, 0, screenWidth, screenHeight, tocolor(50, 50, 50)) -- 323232
	dxDrawRectangle(0, 0, screenWidth, headerWidth, tocolor(0, 0, 0, 170))
	dxDrawText("VLSI Circuit Breaker 2.0", 0, 0, screenWidth, headerWidth, self.m_DefaultLineColor, 3, "default-bold", "center", "center")
	dxDrawText("- WE DGAF ABOUT YOUR PCB -", 0, 0, screenWidth, headerWidth - headerWidth/4, self.m_DefaultLineColor, 1, "default-bold", "center", "bottom")
	dxDrawText("RELAUNCHING: Failed\nERROR CODE: 0x53686974\n\nERROR CODE: 0x54697473\nfx42756c6c73686974\nfx42756c6c73686974\nRELAUNCHING: Proxy\nWARNING: Protocol Changed\nCall: Override_F\nERROR CODE:0x54697473\nDETECTED: Lag\nWARNING: Memory Leak\nCALL: Override_E\n\nWARNING: Protocol Changed\nWARNING: Port 69 Unavailable\nERROR CODE: 0x41727365",
		50, 0, screenWidth, screenHeight, tocolor(255, 255, 255, 220), 1, "default", "left", "center")

	dxSetRenderTarget()

	---
	-- Update PCB render target
	---

	self.m_RT_PCB:setAsTarget()

	--dxDrawRectangle(0, 0, self.WIDTH, self.HEIGHT, tocolor(9, 35, 30))
	dxDrawImage(0, 0, self.WIDTH, self.HEIGHT, self.pcb)
	dxDrawImage(self.m_LevelStartPosX, self.m_LevelStartPosY, 56, 82, self.input)
	dxDrawImage(self.m_LevelEndPosX, self.m_LevelEndPosY, 56, 82, self.output)

	for _, v in pairs(self.m_Levels[self.m_Level][self.m_RandomPattern]) do
		--dxDrawRectangle(v[1], v[2], v[3], v[4], tocolor(255, 0, 0, 100))
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

		-- Out of screen detection
		if not self:collision(8, 8, self.WIDTH-24, self.HEIGHT-24, self.m_LinePosX, self.m_LinePosY, self.m_LineWidth, self.m_LineWidth) then
			self:setState("failed")
		end

		for _, v in pairs(self.m_Levels[self.m_Level][self.m_RandomPattern]) do
			if self:collision(v[1], v[2], v[3], v[4], self.m_LinePosX, self.m_LinePosY, self.m_LineWidth, self.m_LineWidth) then
				self:setState("failed")
			end
		end

		-- Collision detection
		if self:collision(self.m_LevelEndPosX, self.m_LevelEndPosY, 56, 82, self.m_LinePosX, self.m_LinePosY, self.m_LineWidth, self.m_LineWidth) then
			self:setState("complete")
		end
	end

	-- Draw render targets
	local headerWidth = screenHeight/6

	-- Render endscreen
	if self.m_State == "done" then
		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_RT_background)

		for i = 1, 3 do
			dxDrawImage(screenWidth/2 - self.WIDTH/2 + (self.WIDTH/3*(i-1)), headerWidth, self.WIDTH/3, self.HEIGHT/3, self.m_Lines[i].pcb)
			dxDrawImage(screenWidth/2 - self.WIDTH/2 + (self.WIDTH/3*(i-1)), headerWidth, self.WIDTH/3, self.HEIGHT/3, self.m_Lines[i].lineBG2)
			dxDrawImage(screenWidth/2 - self.WIDTH/2 + (self.WIDTH/3*(i-1)), headerWidth, self.WIDTH/3, self.HEIGHT/3, self.m_Lines[i].lineBG)
			dxDrawImage(screenWidth/2 - self.WIDTH/2 + (self.WIDTH/3*(i-1)), headerWidth, self.WIDTH/3, self.HEIGHT/3, self.m_Lines[i].line, 0, 0, 0, self.m_LineColor)
		end

		return
	end

	-- Render game
	dxDrawImage(0, 0, screenWidth, screenHeight, self.m_RT_background)
	dxDrawImage(screenWidth/2 - self.WIDTH/2, headerWidth, self.WIDTH, self.HEIGHT, self.m_RT_PCB)
	dxDrawImage(screenWidth/2 - self.WIDTH/2, headerWidth, self.WIDTH, self.HEIGHT, self.m_RT_lineBG2)
	dxDrawImage(screenWidth/2 - self.WIDTH/2, headerWidth, self.WIDTH, self.HEIGHT, self.m_RT_lineBG)
	dxDrawImage(screenWidth/2 - self.WIDTH/2, headerWidth, self.WIDTH, self.HEIGHT, self.m_RT_line, 0, 0, 0, self.m_LineColor)
end

function CircuitBreaker:collision(sx, sy, sw, sh, px, py, pw, ph)
	local focusX, focusY = px - pw/2, py - ph/2

	if focusX >= sx and focusY >= sy and focusX < sx + sw and focusY < sy + sh then
		return true
	end
end


-- dev.. todo: remove when its done
addCommandHandler("g",
	function()
		CircuitBreaker:new()
	end
)
