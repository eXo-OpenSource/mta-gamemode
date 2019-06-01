-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Minigames/2Cars.lua
-- *  PURPOSE:     Minigame 2Cars
-- *
-- ****************************************************************************
TCars = inherit(Singleton)

function TCars:constructor()
	localPlayer:setFrozen(true)
	--toggleAllControls(false)

	self.font_JosefinSans13 = VRPFont(21, Fonts.JosefinSansThin) -- dxCreateFont("files/fonts/JosefinSans-Thin.ttf", 13)
	self.font_Vanadine36 = VRPFont(58, Fonts.VanadineBold) --dxCreateFont("files/fonts/vanadine-bold.ttf", 36)
	self.font_Gobold16 = VRPFont(26, Fonts.Gobold) -- dxCreateFont("files/fonts/gobold-light.ttf", 16)

	self.m_Width, self.m_Height = 400, 600
	self.m_RenderTarget = DxRenderTarget(self.m_Width, self.m_Height, false)

	self.m_State = "Home"
	self.m_Points = 0
	self.m_Highscore = 0
	self.m_Sounds = true
	self.m_Music = true

	self.m_CarSize = Vector2(40, 76)
	self.m_BlockSize = Vector2(45, 45)
	self.m_Tile = self.m_Width/4
	self.m_CarLines = {
		[1] = self.m_Tile - self.m_Tile/2,
		[2] = self.m_Tile*2 - self.m_Tile/2,
		[3] = self.m_Tile*3 - self.m_Tile/2,
		[4] = self.m_Tile*4 - self.m_Tile/2,
	}
	self.m_ActiveRedCarLine = 1
	self.m_ActiveBlueCarLine = 4
	self.m_RedCarPosition = self.m_CarLines[self.m_ActiveRedCarLine]
	self.m_BlueCarPosition = self.m_CarLines[self.m_ActiveBlueCarLine]
	self.m_RedCarRotation = 0
	self.m_BlueCarRotation = 0

	self.m_CarParticleCount = 30
	self.m_CarAnimationSpeed = 200
	self.m_CarRotation = 40

	self.m_BlockExplodingParticleCount = 150
	self.m_BlocksAnimationSpeed = 2000
	self.m_RedBlockCounter = 0
	self.m_BlueBlockCounter = 0
	self.m_RedBlocks = {}
	self.m_BlueBlocks = {}

	self.m_FailedAlpha = 0

	self:loadHighscore()
	self:loadImages()
	self:createAnimations()
	self:updateRenderTarget()

	self:bindKeys()

	if self.m_Music then
		self.m_BackgroundMusic = playSound("files/audio/2Cars/music.mp3", true)
		self.m_BackgroundMusic:setVolume(.5)
	end

	self.m_Render = bind(TCars.Render, self)
	self.m_BlockAnimationDone = bind(TCars.blockAnimationDone, self)
	self.m_CollisionDetection = bind(TCars.collisionDetection, self)
	self.m_Restore = bind(TCars.onClientRestore, self)

	addEventHandler("onClientRender", root, self.m_Render)
	addEventHandler("onClientRestore", root, self.m_Restore)
	addEventHandler("onClientResourceStop", root, self.m_CloseFunc)
end

function TCars:destructor()
	localPlayer:setFrozen(false)
	toggleAllControls(true, true, false)
	self:saveHighscore()

	if self.m_BackgroundMusic then self.m_BackgroundMusic:destroy() end
	if self.m_BlueBlockTimer and self.m_BlueBlockTimer:isValid() then self.m_BlueBlockTimer:destroy() end
	if self.m_RedBlockTimer and self.m_RedBlockTimer:isValid() then self.m_RedBlockTimer:destroy() end
	if self.m_AlphaTimer and self.m_AlphaTimer:isValid() then self.m_AlphaTimer:destroy() end

	unbindKey("backspace", "down", self.m_CloseFunc)
	unbindKey("a", "down", self.m_ToggleCar)
	unbindKey("d", "down", self.m_ToggleCar)
	unbindKey("arrow_l", "down", self.m_ToggleCar)
	unbindKey("arrow_r", "down", self.m_ToggleCar)
	unbindKey("s", "down", self.m_bindKeySoundsFunc)
	unbindKey("m", "down", self.m_bindKeyMusicFunc)
	removeEventHandler("onClientRender", root, self.m_Render)
	removeEventHandler("onClientPreRender", root, self.m_CollisionDetection)
	removeEventHandler("onClientRestore", root, self.m_Restore)
	removeEventHandler("onClientResourceStop", root, self.m_CloseFunc)

	self:virtual_destructor()
end

function TCars:loadImages()
	self.images = {
		"circle_play",
		"circle_sound",
		"circle_sound_off",
		"circle_music",
		"circle_music_off",
		"arrow_down",
		"titlescreen",
		"car_red",
		"car_blue",
		"point_red",
		"point_blue",
		"block_red",
		"block_blue",
		"particleExplode",
	}

	for _, img in ipairs(self.images) do
		self[img] = DxTexture(("files/images/2Cars/%s.png"):format(img))
	end

	self.background = math.random(1, 6)
end

function TCars:loadHighscore()
	if fileExists("2Cars.stats") then
		local file = fileOpen("2Cars.stats", true)
		local fileContent = file:read(file:getSize())
		file:close()

		if fileContent then
			local decryptedContent = teaDecode(fileContent, getPlayerSerial())

			if fromJSON(decryptedContent) then
				local read = fromJSON(decryptedContent)

				self.m_Highscore = read
				return
			end
		end
	end
end

function TCars:saveHighscore()
	local fileContent = toJSON(self.m_Highscore)
	local encryptedContent = teaEncode(fileContent, getPlayerSerial())
	local file = fileCreate("2Cars.stats")
	file:write(encryptedContent)
	file:close()
end

function TCars:createParticleAnimations()
	self.m_CarParticles = {}
	self.m_CarParticleAnimationDone =
	function()
		for i = 1, self.m_CarParticleCount do
			if not self.m_CarParticles[i]:isAnimationRendered() then
				self[("m_CarParticleX%s"):format(i)] = (i%2 == 0 and self.m_RedCarPosition or self.m_BlueCarPosition) + math.random(-5, 5)
				self[("m_CarParticleY%s"):format(i)] = self.m_Height - 150 + self.m_CarSize.y
				self[("m_CarParticleS%s"):format(i)] = 16
				self[("m_CarParticleC%s"):format(i)] = i%2 == 0 and tocolor(242, 0, 86, 100) or tocolor(50, 200, 255, 100)

				self.m_CarParticles[i]:startAnimation(math.random(500, 1500), "OutQuad", (i%2 == 0 and self.m_RedCarPosition or self.m_BlueCarPosition) + math.random(-20, 20), self.m_Height, 0)
			end
		end
	end

	for i = 1, self.m_CarParticleCount do
		self[("m_CarParticleX%s"):format(i)] = (i%2 == 0 and self.m_RedCarPosition or self.m_BlueCarPosition) + math.random(-5, 5)
		self[("m_CarParticleY%s"):format(i)] = self.m_Height - 150 + self.m_CarSize.y
		self[("m_CarParticleS%s"):format(i)] = 16
		self[("m_CarParticleC%s"):format(i)] = tocolor(250, 170, 50)--i%2 == 0 and tocolor(242, 0, 86, 100) or tocolor(50, 200, 255, 100)

		self.m_CarParticles[i] = CAnimation:new(self, self.m_CarParticleAnimationDone, ("m_CarParticleX%s"):format(i), ("m_CarParticleY%s"):format(i), ("m_CarParticleS%s"):format(i))
		self.m_CarParticles[i]:callRenderTarget(false)
	end
end

function TCars:createExplosionParticles(x, y, blockColor, lostPoint)
	self.m_BlockParticles = {}

	for i = 1, self.m_BlockExplodingParticleCount do
		self[("m_BlockParticleX%s"):format(i)] = x
		self[("m_BlockParticleY%s"):format(i)] = y
		self[("m_BlockParticleSize%s"):format(i)] = lostPoint and 8 or 32
		self[("m_BlockParticleColor%s"):format(i)] = blockColor == "red" and tocolor(242, 0, 86, 150) or tocolor(50, 200, 255, 150)

		local radius = lostPoint and nil or 360/self.m_BlockExplodingParticleCount*i
		local targetParticleX = lostPoint and x + math.random(-self.m_Tile/2, self.m_Tile/2) or x + math.cos(radius)*math.random(5, 200)
		local targetParticleY = lostPoint and math.random(0, self.m_Height) or y + math.sin(radius)*math.random(5, 200)
		local targetParticleSize = lostPoint and 32 or 0

		self.m_BlockParticles[i] = CAnimation:new(self, ("m_BlockParticleX%s"):format(i), ("m_BlockParticleY%s"):format(i), ("m_BlockParticleSize%s"):format(i))
		self.m_BlockParticles[i]:startAnimation(i == 1 and 2200 or math.random(300, 2200), "OutQuad", targetParticleX, targetParticleY, targetParticleSize)
		self.m_BlockParticles[i]:callRenderTarget(false)
	end

	self.m_BlockParticles[1]:callRenderTarget(true)
end

function TCars:createAnimations()
	self:createParticleAnimations()

	self.m_AlphaAnimation = CAnimation:new(self, "m_FailedAlpha")

	self.m_RedCarAnimation = CAnimation:new(self, "m_RedCarPosition")
	self.m_RedCarRotAnimation = CAnimation:new(self, "m_RedCarRotation")
	self.m_BlueCarAnimation = CAnimation:new(self, "m_BlueCarPosition")
	self.m_BlueCarRotAnimation = CAnimation:new(self, "m_BlueCarRotation")

	self.m_CarAnimations = {
		self.m_RedCarAnimation,
		self.m_RedCarRotAnimation,
		self.m_BlueCarAnimation,
		self.m_BlueCarRotAnimation
	}

	for _, v in pairs(self.m_CarAnimations) do
		v:callRenderTarget(false)
	end
end

function TCars:createRedBlock()
	self.m_RedBlockCounter = self.m_RedBlockCounter + 1
	local ID = self.m_RedBlockCounter
	self.m_RedBlocks[ID] = {}
	self.m_RedBlocks[ID].posX = self.m_CarLines[math.random(1,2)]
	self.m_RedBlocks[ID].type = math.random(1,4) == 1 and self.point_red or self.block_red
	self.m_RedBlocks[ID].animation = CAnimation:new(self, ("m_RedBlock%s"):format(ID))
	self[("m_RedBlock%s"):format(ID)] = -55

	self.m_RedBlocks[ID].animation:startAnimation(self.m_BlocksAnimationSpeed-(self.m_Points*10), "Linear", self.m_Height)
	self.m_RedBlocks[ID].animation:updateCallbackFunction(self.m_BlockAnimationDone, "red", ID)

	self.m_RedBlockTimer = setTimer(bind(TCars.createRedBlock, self), math.random(500, 700), 1)
end

function TCars:createBlueBlock()
	self.m_BlueBlockCounter = self.m_BlueBlockCounter + 1
	local ID = self.m_BlueBlockCounter
	self.m_BlueBlocks[ID] = {}
	self.m_BlueBlocks[ID].posX = self.m_CarLines[math.random(3,4)]
	self.m_BlueBlocks[ID].type = math.random(1,4) == 1 and self.point_blue or self.block_blue
	self.m_BlueBlocks[ID].animation = CAnimation:new(self, ("m_BlueBlock%s"):format(ID))
	self[("m_BlueBlock%s"):format(ID)] = -55

	self.m_BlueBlocks[ID].animation:startAnimation(self.m_BlocksAnimationSpeed-(self.m_Points*10), "Linear", self.m_Height)
	self.m_BlueBlocks[ID].animation:updateCallbackFunction(self.m_BlockAnimationDone, "blue", ID)

	self.m_BlueBlockTimer = setTimer(bind(TCars.createBlueBlock, self), math.random(500, 700), 1)
end

function TCars:blockAnimationDone(blockType, ID)
	if blockType == "red" then
		if self.m_RedBlocks[ID].type == self.point_red then
			if not self.m_RedBlocks[ID].gotPoint then
				local posX = self.m_RedBlocks[ID].posX
				local posY = self[("m_RedBlock%s"):format(ID)]
				self:createExplosionParticles(posX, posY, "red", true)
				self:setState("Failed")
				self:playSound("die2")
			end
		end

		self[("m_RedBlock%s"):format(ID)] = nil
		self.m_RedBlocks[ID].animation:delete()
		self.m_RedBlocks[ID] = nil
	else
		if self.m_BlueBlocks[ID].type == self.point_blue then
			if not self.m_BlueBlocks[ID].gotPoint then
				local posX = self.m_BlueBlocks[ID].posX
				local posY = self[("m_BlueBlock%s"):format(ID)]
				self:createExplosionParticles(posX, posY, "blue", true)
				self:setState("Failed")
				self:playSound("die2")
			end
		end

		self[("m_BlueBlock%s"):format(ID)] = nil
		self.m_BlueBlocks[ID].animation:delete()
		self.m_BlueBlocks[ID] = nil
	end
end

function TCars:setState(newState)
	if newState == "Play" then
		self.m_State = "Play"
		self:createRedBlock()
		self:createBlueBlock()

		for i, v in pairs(self.m_CarParticles) do
			v:startAnimation(1, "Linear", 0, 0, 0)	--Just start, animation will shown continuously with callback function
		end

		addEventHandler("onClientPreRender", root, self.m_CollisionDetection)
		return
	end

	if newState == "TryPlay" then
		if getTickCount() - self.m_FailedTick < 2000 then return end
		self.m_Points = 0

		self.m_ActiveRedCarLine = 1
		self.m_ActiveBlueCarLine = 4
		self.m_RedCarPosition = self.m_CarLines[self.m_ActiveRedCarLine]
		self.m_BlueCarPosition = self.m_CarLines[self.m_ActiveBlueCarLine]
		self.m_RedCarRotation = 0
		self.m_BlueCarRotation = 0

		self.m_RedBlockCounter = 0
		self.m_BlueBlockCounter = 0
		self.m_RedBlocks = {}
		self.m_BlueBlocks = {}

		self.m_FailedAlpha = 0

		self:setState("Play")
	end

	if newState == "Failed" then
		self.m_State = "Failed"
		removeEventHandler("onClientPreRender", root, self.m_CollisionDetection)

		for i, v in pairs(self.m_CarParticles) do
			v:stopAnimation()
		end

		for i, v in pairs(self.m_CarAnimations) do
			v:stopAnimation()
		end

		for i, v in pairs(self.m_RedBlocks) do
			v.animation:stopAnimation()--delete()
		end

		for i, v in pairs(self.m_BlueBlocks) do
			v.animation:stopAnimation()
		end

		if isTimer(self.m_BlueBlockTimer) then self.m_BlueBlockTimer:destroy() end
		if isTimer(self.m_RedBlockTimer) then self.m_RedBlockTimer:destroy() end
		if isTimer(self.m_AlphaTimer) then self.m_AlphaTimer:destroy() end

		triggerServerEvent("MinigameSendHighscore", resourceRoot, "2Cars", self.m_Points)
		if self.m_Points > self.m_Highscore then
			self.m_Highscore = self.m_Points
		end

		self.m_FailedAlpha = 0
		self.m_AlphaTimer = setTimer(
			function()
				self.m_AlphaAnimation:startAnimation(1200, "OutQuad", 230)
			end, 800, 1
		)

		self.m_FailedTick = getTickCount()
		return
	end
end

function TCars:bindKeys()
	self.m_ToggleCar = bind(TCars.toggleCar, self)
	self.m_CloseFunc = bind(TCars.destructor, self)

	self.m_bindKeySoundsFunc =
	function()
		self.m_Sounds = not self.m_Sounds
		self:updateRenderTarget()
	end

	self.m_bindKeyMusicFunc =
	function()
		self.m_Music = not self.m_Music
		self:updateRenderTarget()

		if self.m_Music then
			self.m_BackgroundMusic = playSound("files/audio/2Cars/music.mp3", true)
			self.m_BackgroundMusic:setVolume(.5)
		else
			stopSound(self.m_BackgroundMusic)
			self.m_BackgroundMusic = nil
		end

	end

	bindKey("backspace", "down", self.m_CloseFunc)
	bindKey("a", "down", self.m_ToggleCar)
	bindKey("d", "down", self.m_ToggleCar)
	bindKey("arrow_l", "down", self.m_ToggleCar)
	bindKey("arrow_r", "down", self.m_ToggleCar)
	bindKey("s", "down", self.m_bindKeySoundsFunc)
	bindKey("m", "down", self.m_bindKeyMusicFunc)
end

function TCars:toggleCar(key, keyState)
	if self.m_State == "Home" then
		return self:setState("Play")
	elseif self.m_State == "Failed" then
		return self:setState("TryPlay")
	end

	if key == "arrow_l" then key = "a" end
	if key == "arrow_r" then key = "d" end

	if self.m_State == "Play" then
		if key == "a" then
			self.m_RedCarRotation = 0

			if self.m_ActiveRedCarLine == 1 then
				self.m_ActiveRedCarLine = 2
				self.m_RedCarAnimation:startAnimation(self.m_CarAnimationSpeed, "Linear", self.m_CarLines[2])
				self.m_RedCarRotAnimation:startAnimation(self.m_CarAnimationSpeed, "SineCurve", self.m_CarRotation)
			else
				self.m_ActiveRedCarLine = 1
				self.m_RedCarAnimation:startAnimation(self.m_CarAnimationSpeed, "Linear", self.m_CarLines[1])
				self.m_RedCarRotAnimation:startAnimation(self.m_CarAnimationSpeed, "SineCurve", -self.m_CarRotation)
			end
		elseif key == "d" then
			self.m_BlueCarRotation = 0

			if self.m_ActiveBlueCarLine == 3 then
				self.m_ActiveBlueCarLine = 4
				self.m_BlueCarAnimation:startAnimation(self.m_CarAnimationSpeed, "Linear", self.m_CarLines[4])
				self.m_BlueCarRotAnimation:startAnimation(self.m_CarAnimationSpeed, "SineCurve", self.m_CarRotation)
			else
				self.m_ActiveBlueCarLine = 3
				self.m_BlueCarAnimation:startAnimation(self.m_CarAnimationSpeed, "Linear", self.m_CarLines[3])
				self.m_BlueCarRotAnimation:startAnimation(self.m_CarAnimationSpeed, "SineCurve", -self.m_CarRotation)
			end
		end
	end
end

function TCars:playSound(sound)
	if self.m_Sounds then
		playSound(("files/audio/2Cars/%s.mp3"):format(sound))
	end
end

function TCars:collisionDetection()
	for i, v in pairs(self.m_RedBlocks) do
		local posX = v.posX
		local posY = self[("m_RedBlock%s"):format(i)]
		if rectangleCollision2D(posX, posY, self.m_BlockSize.x, self.m_BlockSize.y, self.m_RedCarPosition, self.m_Height - 150, self.m_CarSize.x, self.m_CarSize.y) then
			if v.type == self.point_red then
				if not v.gotPoint then
					self.m_Points = self.m_Points + 1
					v.gotPoint = true
					self:playSound("score")
				end
			else
				v.gotPoint = true		-- not shown
				self:createExplosionParticles(posX, posY, "red")
				self:setState("Failed")
				self:playSound("die1")
			end
		end
	end

	for i, v in pairs(self.m_BlueBlocks) do
		local posX = v.posX
		local posY = self[("m_BlueBlock%s"):format(i)]
		if rectangleCollision2D(posX, posY, self.m_BlockSize.x, self.m_BlockSize.y, self.m_BlueCarPosition, self.m_Height - 150, self.m_CarSize.x, self.m_CarSize.y) then
			if v.type == self.point_blue then
				if not v.gotPoint then
					self.m_Points = self.m_Points + 1
					v.gotPoint = true
					self:playSound("score")
				end
			else
				v.gotPoint = true	-- not shown
				self:createExplosionParticles(posX, posY, "blue")
				self:setState("Failed")
				self:playSound("die1")
			end
		end
	end
end

function TCars:updateRenderTarget()
	if not self.m_RenderTarget then return end
	self.m_RenderTarget:setAsTarget(true)

	-- Draw background
	dxDrawRectangle(0, 0, self.m_Width, self.m_Height, tocolor(37, 51, 122))
	dxDrawRectangle(self.m_Tile-1, 0, 2, self.m_Height, tocolor(129, 152, 241))	-- left line
	dxDrawRectangle(self.m_Width/2-3, 0, 6, self.m_Height, tocolor(129, 152, 241))	-- middle line
	dxDrawRectangle(self.m_Tile*3-1, 0, 2, self.m_Height, tocolor(129, 152, 241))	-- right line

	-- Draw cars
	dxDrawImage(self.m_RedCarPosition - self.m_CarSize.x/2, self.m_Height - 150, self.m_CarSize, self.car_red, self.m_RedCarRotation)
	dxDrawImage(self.m_BlueCarPosition - self.m_CarSize.x/2, self.m_Height - 150, self.m_CarSize, self.car_blue, self.m_BlueCarRotation)

	-- Draw points
	dxDrawText(self.m_Points, 0, 5, self.m_Width - 5, self.m_Height, Color.White, 1, getVRPFont(self.font_Gobold16), "right", "top")

	-- Draw Car moving drops
	if self.m_State == "Play" then
		for i = 1, self.m_CarParticleCount do
			local particleX = self[("m_CarParticleX%s"):format(i)]
			local particleY = self[("m_CarParticleY%s"):format(i)]
			local particleSize = self[("m_CarParticleS%s"):format(i)]
			local particleColor = self[("m_CarParticleC%s"):format(i)]
			dxDrawRectangle(particleX-particleSize/2, particleY, particleSize, particleSize, particleColor)
		end

		for i, v in pairs(self.m_RedBlocks) do
			local posX = v.posX
			local posY = self[("m_RedBlock%s"):format(i)]
			if not v.gotPoint then
				dxDrawImage(posX-self.m_BlockSize.x/2, posY, self.m_BlockSize, v.type)
			end
		end

		for i, v in pairs(self.m_BlueBlocks) do
			local posX = v.posX
			local posY = self[("m_BlueBlock%s"):format(i)]
			if not v.gotPoint then
				dxDrawImage(posX-self.m_BlockSize.x/2, posY, self.m_BlockSize, v.type)
			end
		end
	end

	if self.m_State == "Failed" then
		for i, v in pairs(self.m_RedBlocks) do
			local posX = v.posX
			local posY = self[("m_RedBlock%s"):format(i)]
			if not v.gotPoint then
				dxDrawImage(posX-self.m_BlockSize.x/2, posY, self.m_BlockSize, v.type)
			end
		end

		for i, v in pairs(self.m_BlueBlocks) do
			local posX = v.posX
			local posY = self[("m_BlueBlock%s"):format(i)]
			if not v.gotPoint then
				dxDrawImage(posX-self.m_BlockSize.x/2, posY, self.m_BlockSize, v.type)
			end
		end

		for i, v in pairs(self.m_BlockParticles) do
			local particleX = self[("m_BlockParticleX%s"):format(i)]
			local particleY = self[("m_BlockParticleY%s"):format(i)]
			local particleSize = self[("m_BlockParticleSize%s"):format(i)]
			local particleColor = self[("m_BlockParticleColor%s"):format(i)]

			dxDrawImage(particleX-particleSize/2, particleY-particleSize/2, particleSize, particleSize, self.particleExplode, 0, 0, 0, particleColor)
		end

		dxDrawRectangle(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, self.m_FailedAlpha))

		local whiteColorFaded = tocolor(255, 255, 255, 255/230*self.m_FailedAlpha)
		dxDrawText("GAME OVER", 0, 0, self.m_Width, self.m_Height/3, whiteColorFaded, 1, getVRPFont(self.font_Vanadine36), "center", "center")
		dxDrawText("SCORE", self.m_Width/2-75, self.m_Height/3 - 50, self.m_Width, self.m_Height, whiteColorFaded, 1, getVRPFont(self.font_Gobold16))
		dxDrawText("BEST", self.m_Width/2-75, self.m_Height/3 - 20, self.m_Width, self.m_Height, whiteColorFaded, 1, getVRPFont(self.font_Gobold16))

		dxDrawText(self.m_Points, self.m_Width/2-75, self.m_Height/3 - 50, self.m_Width/2+75, self.m_Height, whiteColorFaded, 1, getVRPFont(self.font_Gobold16), "right")
		dxDrawText(self.m_Highscore, self.m_Width/2-75, self.m_Height/3 - 20, self.m_Width/2+75, self.m_Height, whiteColorFaded, 1, getVRPFont(self.font_Gobold16), "right")

		dxDrawImage(self.m_Width/2 - 48/2 - 50, self.m_Height*.7, 48, 48, self.m_Music and self.circle_music or self.circle_music_off, 0, 0, 0, whiteColorFaded)
		dxDrawImage(self.m_Width/2 - 48/2 + 50, self.m_Height*.7, 48, 48, self.m_Sounds and self.circle_sound or self.circle_sound_off, 0, 0, 0, whiteColorFaded)

		dxDrawImage(self.m_Width/2 - 48/2 - 50 + (48/2-18/2), self.m_Height*.7 + 48, 18, 18, self.arrow_down, 0, 0, 0, whiteColorFaded)
		dxDrawImage(self.m_Width/2 - 48/2 + 50 + (48/2-18/2), self.m_Height*.7 + 48, 18, 18, self.arrow_down, 0, 0, 0, whiteColorFaded)

		dxDrawText("m", self.m_Width/2 - 48/2 - 50, self.m_Height*.7 + 48 + 8, self.m_Width/2 - 48/2 - 50 + 48, 0, whiteColorFaded, 1, getVRPFont(self.font_JosefinSans13), "center")
		dxDrawText("s", self.m_Width/2 - 48/2 + 50, self.m_Height*.7 + 48 + 8, self.m_Width/2 - 48/2 + 50 + 48, 0, whiteColorFaded, 1, getVRPFont(self.font_JosefinSans13), "center")

		dxDrawText("Press a movement key to play again", 0, self.m_Height - 50, self.m_Width, self.m_Height, whiteColorFaded, 1, getVRPFont(self.font_Gobold16), "center")
	end

	if self.m_State == "Home" then
		dxDrawRectangle(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150))
		dxDrawImage(0, 0, self.m_Width, self.m_Height, self.titlescreen)

		dxDrawImage(self.m_Width/2 - 96/2, self.m_Height/2 - 96/2, 96, 96, self.circle_play)
		dxDrawImage(self.m_Width/2 - 48/2 - 120, self.m_Height/2 - 48/2, 48, 48, self.m_Music and self.circle_music or self.circle_music_off)
		dxDrawImage(self.m_Width/2 - 48/2 + 120, self.m_Height/2 - 48/2, 48, 48, self.m_Sounds and self.circle_sound or self.circle_sound_off)

		dxDrawImage(self.m_Width/2 - 48/2 - 120 + (48/2-18/2), self.m_Height/2 - 48/2 + 48, 18, 18, self.arrow_down)
		dxDrawImage(self.m_Width/2 - 48/2 + 120 + (48/2-18/2), self.m_Height/2 - 48/2 + 48, 18, 18, self.arrow_down)

		dxDrawText("m", self.m_Width/2 - 48/2 - 120, self.m_Height/2 - 48/2 + 48 + 5, self.m_Width/2 - 48/2 - 120 + 48, 0, Color.White, 1, getVRPFont(self.font_JosefinSans13), "center")
		dxDrawText("s", self.m_Width/2 - 48/2 + 120, self.m_Height/2 - 48/2 + 48 + 5, self.m_Width/2 - 48/2 + 120 + 48, 0, Color.White, 1, getVRPFont(self.font_JosefinSans13), "center")
	end

	dxSetRenderTarget()
end

function TCars:Render()
	dxDrawImage(screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, self.m_RenderTarget)
end

function TCars:onClientRestore(didClearRenderTargets)
	if didClearRenderTargets then
		self:updateRenderTarget()
	end
end
