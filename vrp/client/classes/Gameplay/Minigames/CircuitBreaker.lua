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
	self.m_rt_background = DxRenderTarget(screenWidth, screenHeight, false)	-- background
	self.m_rt_PCB = DxRenderTarget(self.WIDTH, self.HEIGHT, false)			-- PCB
	self.m_rt_line = DxRenderTarget(self.WIDTH, self.HEIGHT, true)			-- Line		(may an extra render target for smooth line bg..)

	self:loadImages()
	self:createGameplay()
	self:updateRenderTarget()

	self:bindKeys()

	self.m_fnRender = bind(CircuitBreaker.onClientRender, self)
	addEventHandler("onClientRender", root, self.m_fnRender)
end

function CircuitBreaker:loadImages()
	self.m_images = {
		"bg",
		"input",
		"output",
	}

	for _, img in ipairs(self.m_images) do
		self[img] = DxTexture(("files/images/CircuitBreaker/%s.png"):format(img))
	end
end

function CircuitBreaker:createGameplay()
	-- Some definitions
	self.m_level = 1
	self.m_state = "idle"
	self.m_moveDirection = "r"											--r = right | l = left | u = up | d = down

	-- Set D-Sub9 start pos
	self.m_levelStartPosX = 0
	self.m_levelStartPosY = math.random(0, self.HEIGHT - 82)

	-- Set D-Sub9 end pos
	self.m_levelEndPosX = self.WIDTH - 56 								--56 is the with of the d-sub 9 connector
	self.m_levelEndPosY = math.random(0, self.HEIGHT - 82)

	-- Set line pos
	self.m_linePosX = 56 - 5
	self.m_linePosY = self.m_levelStartPosY + 82/2 - 5/2

	self.m_moveSpeed = self.m_level + 2
	self.m_lineWidth = 0

	self.m_lineColor = tocolor(50, 140, 100)

	self.m_lines = {}													-- Storage for "old" render targets
end

function CircuitBreaker:createNextLevel()
	self.m_moveDirection = "r"

	-- Set D-Sub9 start pos
	self.m_levelStartPosX = 0
	self.m_levelStartPosY = self.m_levelEndPosY 						-- Start where the last level has ended

	-- Set D-Sub9 end pos
	self.m_levelEndPosX = self.WIDTH - 56 								--56 is the with of the d-sub 9 connector
	self.m_levelEndPosY = math.random(0, self.HEIGHT - 82)

	-- Set line pos
	self.m_linePosX = 56 - 5
	self.m_linePosY = self.m_levelStartPosY + 82/2 - 5/2

	self.m_moveSpeed = self.m_level + 2
	self.m_lineWidth = 0

	self.m_lineColor = tocolor(50, 140, 100)
end

function CircuitBreaker:setState(state)		--Todo: freaky function.. need improvements lel
	if state == "play" then
		self.m_state = "play"
		self.m_lineWidth = 5
	end

	if state == "done" then
		self.m_state = "done"
		outputChatBox("all levels done")
		--Todo: Show completed PCB (end screen)
		--Todo: Trigger ?!
	end

	if state == "tryPlay" then
		if self.m_state == "idle" then
			self:setState("play")
		end

		if self.m_state == "failed" then
			self.m_rt_line:setAsTarget(true) dxSetRenderTarget()		--Clear render target

			self.m_moveDirection = "r"

			self.m_linePosX = 56 - 5
			self.m_linePosY = self.m_levelStartPosY + 82/2 - 5/2
			self.m_lineColor = tocolor(50, 140, 100)

			self:setState("play")
		end

		if self.m_state == "complete" then
			self.m_rt_line = DxRenderTarget(self.WIDTH, self.HEIGHT, true)
			self:createNextLevel()
			self:updateRenderTarget()

			self:setState("play")
		end
	end


	if state == "complete" then	--Todo: Call next level via 5 sec. timer
		self.m_state = "complete"
		outputChatBox("level complete")
		self.m_lineColor = tocolor(50, 200, 130)
		self:updateRenderTarget()

		self.m_lines[self.m_level] = {line = self.m_rt_line, ICs = nil}
		self.m_level = self.m_level + 1

		if self.m_level > 3 then
			self:setState("done")
		end
	end

	if state == "failed" then
		self.m_state = "failed"
		self.m_lineColor = tocolor(220, 0, 0)
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
	if not self.m_state == "play" then return end

	-- normalise key names
	key = key == "arrow_l" and "l" or key == "a" and "l" or key
	key = key == "arrow_r" and "r" or key == "d" and "r" or key
	key = key == "arrow_u" and "u" or key == "w" and "u" or key
	key = key == "arrow_d" and "d" or key == "s" and "d" or key

	-- disable opposite movements
	if self.m_moveDirection == "l" and key == "r" then return end
	if self.m_moveDirection == "r" and key == "l" then return end
	if self.m_moveDirection == "u" and key == "d" then return end
	if self.m_moveDirection == "d" and key == "u" then return end

	self.m_moveDirection = key
end



function CircuitBreaker:updateRenderTarget()
	-- Update background render target
	self.m_rt_background:setAsTarget()

	local headerWidth = screenHeight/6

	dxDrawImage(0, 0, screenWidth, screenHeight, self.bg)
	dxDrawRectangle(0, 0, screenWidth, headerWidth, tocolor(0, 0, 0, 170))
	dxDrawText("VLSI Circuit Breaker 2.0", 0, 0, screenWidth, headerWidth, tocolor(50, 140, 100), 3, "default-bold", "center", "center")
	dxDrawText("- WE DGAF ABOUT YOUR PCB -", 0, 0, screenWidth, headerWidth - headerWidth/4, tocolor(50, 140, 100), 1, "default-bold", "center", "bottom")
	dxDrawText("RELAUNCHING: Failed\nERROR CODE: 0x53686974\n\nERROR CODE: 0x54697473\nfx42756c6c73686974\nfx42756c6c73686974\nRELAUNCHING: Proxy\nWARNING: Protocol Changed\nCall: Override_F\nERROR CODE:0x54697473\nDETECTED: Lag\nWARNING: Memory Leak\nCALL: Override_E\n\nWARNING: Protocol Changed\nWARNING: Port 69 Unavailable\nERROR CODE: 0x41727365",
		50, 0, screenWidth, screenHeight, tocolor(255, 255, 255, 220), 1, "default", "left", "center")

	dxSetRenderTarget()

	-- Update PCB render target
	self.m_rt_PCB:setAsTarget()

	dxDrawRectangle(0, 0, self.WIDTH, self.HEIGHT, tocolor(9, 35, 30))
	dxDrawImage(self.m_levelStartPosX, self.m_levelStartPosY, 56, 82, self.input)
	dxDrawImage(self.m_levelEndPosX, self.m_levelEndPosY, 56, 82, self.output)

	dxSetRenderTarget()

	-- Update line render target

	self.m_rt_line:setAsTarget()
	dxSetBlendMode("overwrite")

	if self.m_moveDirection == "r" or self.m_moveDirection == "l" then
		dxDrawRectangle(self.m_linePosX, self.m_linePosY - 2, self.m_lineWidth, self.m_lineWidth + 4, tocolor(255, 255, 255, 50))
		dxDrawRectangle(self.m_linePosX, self.m_linePosY - 1, self.m_lineWidth, self.m_lineWidth + 2, tocolor(255, 255, 255, 150))
	else
		dxDrawRectangle(self.m_linePosX - 2, self.m_linePosY, self.m_lineWidth + 4, self.m_lineWidth, tocolor(255, 255, 255, 50))
		dxDrawRectangle(self.m_linePosX - 1, self.m_linePosY, self.m_lineWidth + 2, self.m_lineWidth, tocolor(255, 255, 255, 150))
	end

	dxDrawRectangle(self.m_linePosX, self.m_linePosY, self.m_lineWidth, self.m_lineWidth, tocolor(255, 255, 255))

	dxSetBlendMode("blend")
	dxSetRenderTarget()
end

function CircuitBreaker:onClientRender()
	-- idk how to title that
	if self.m_state == "play" then
		if self.m_moveDirection == "r" then
			self.m_linePosX = self.m_linePosX + self.m_moveSpeed
		elseif self.m_moveDirection == "l" then
			self.m_linePosX = self.m_linePosX - self.m_moveSpeed
		elseif self.m_moveDirection == "u" then
			self.m_linePosY = self.m_linePosY - self.m_moveSpeed
		elseif self.m_moveDirection == "d" then
			self.m_linePosY = self.m_linePosY + self.m_moveSpeed
		end

		self:updateRenderTarget()

		-- Out of screen detection
		if not CircuitBreaker:collision(0, 0, self.WIDTH, self.HEIGHT, self.m_linePosX, self.m_linePosY, self.m_lineWidth, self.m_lineWidth) then
			self:setState("failed")
		end

		-- Collision detection
		if CircuitBreaker:collision(self.m_levelEndPosX, self.m_levelEndPosY, 56, 82, self.m_linePosX, self.m_linePosY, self.m_lineWidth, self.m_lineWidth) then
			self:setState("complete")
		end
	end

	-- Draw render targets
	local headerWidth = screenHeight/6

	dxDrawImage(0, 0, screenWidth, screenHeight, self.m_rt_background)
	dxDrawImage(screenWidth/2 - self.WIDTH/2, headerWidth, self.WIDTH, self.HEIGHT, self.m_rt_PCB)
	dxDrawImage(screenWidth/2 - self.WIDTH/2, headerWidth, self.WIDTH, self.HEIGHT, self.m_rt_line, 0, 0, 0, self.m_lineColor)
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
