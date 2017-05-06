-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Fishing/BobberBar.lua
-- *  PURPOSE:     BobberBar class
-- *
-- ****************************************************************************
BobberBar = inherit(Singleton)
addRemoteEvents{"fishingBobberBar"}

local screenWidth, screenHeight = guiGetScreenSize()

function BobberBar:constructor(difficulty, behavior)
	local fisherLevel = localPlayer:getPrivateSync("FishingLevel") + 1

	self.m_Size = Vector2(58, screenHeight/2)
	self.m_RenderTarget = DxRenderTarget(self.m_Size, true)
	self.m_AnimationMultiplicator = 0

	self.Sound = SoundManager:new("files/audio/Fishing")
	self.Random = Randomizer:new()

	self.m_BobberBarHeight = 64 + fisherLevel*4
	self.m_BobberBarPosition = self.m_Size.y - self.m_BobberBarHeight - 5
	self.m_BobberBarSpeed = 0

	self.POSITION_UP = 5
	self.POSITION_DOWN = self.m_Size.y - 5
	self.HEIGHT = self.POSITION_DOWN - self.POSITION_UP
	self.MAX_PUSHBACK_SPEED = 8

	self.m_Difficulty = difficulty
	self.m_MotionType = self:getMotionType(behavior)

	self.m_BobberPosition = (100 - self.m_Difficulty) / 100 * self.HEIGHT
	self.m_BobberSpeed = 0
	self.m_BobberTargetPosition = 0
	self.m_BobberInBar = nil

	self.m_Progress = math.max(40, self.m_Difficulty)/2
	self.m_ProgressDuration = 10000

	self:initAnimations()
	self:updateRenderTarget()

	self.m_Render = bind(BobberBar.render, self)
	self.m_HandleClick = bind(BobberBar.handleClick, self)

	toggleControl("fire", false)
	bindKey("mouse1", "both", self.m_HandleClick)
	addEventHandler("onClientRender", root, self.m_Render)

	self:setBobberPosition()
	self.m_FadeAnimation:startAnimation(500, "OutQuad", 1)
end

function BobberBar:destructor()
	removeEventHandler("onClientRender", root, self.m_Render)
	unbindKey("mouse1", "both", self.m_HandleClick)
	self.Sound:stopAll()

	if self.m_FadeAnimation:isAnimationRendered() then delete(self.m_FadeAnimation) end
	if self.m_BobberAnimation:isAnimationRendered() then delete(self.m_BobberAnimation) end
	if self.m_ProgressAnimation:isAnimationRendered() then delete(self.m_ProgressAnimation) end

	if isTimer(self.m_ResetFishingRodTimer) then killTimer(self.m_ResetFishingRodTimer) end
end

function BobberBar:initAnimations()
	local onProgressDone =
		function()
			if self.m_Progress%100 == 0 then
				self.m_ProgressDuration = 0
				self.m_BobberAnimation:stopAnimation()
				self.m_ProgressAnimation:stopAnimation()
				self.Sound:stop("slowReel")

				if self.m_Progress == 100 then
					self.Sound:play("caught")
					self.Sound:play("woap")
					triggerServerEvent("clientFishCaught", localPlayer)
				else
					self.Sound:play("escape")
				end

				self.m_FadeAnimation:startAnimation(500, "OutQuad", 0)

				self.m_ResetFishingRodTimer = setTimer(
					function()
						delete(self)

						if FishingRod:isInstantiated() then
							FishingRod:getSingleton():reset()
						end
					end, 2000, 1
				)
			end
		end

	self.m_FadeAnimation = CAnimation:new(self, "m_AnimationMultiplicator")
	self.m_BobberAnimation = CAnimation:new(self, bind(BobberBar.setBobberPosition, self), "m_BobberPosition")
	self.m_ProgressAnimation = CAnimation:new(self, onProgressDone, "m_Progress")

	self.m_BobberAnimation:callRenderTarget(false)
	self.m_ProgressAnimation:callRenderTarget(false)
	self.m_FadeAnimation:callRenderTarget(false)
end

function BobberBar:getMotionType(behavior)
	if behavior == "mixed" then
		return 0
	elseif behavior == "dart" then
		return 1
	elseif behavior == "smooth" then
		return 2
	elseif behavior == "sinker" then
		return 3
	elseif behavior == "floater" then
		return 4
	end
end

function BobberBar:handleClick(_, state)
	if self.m_ProgressDuration ~= 0 then
		self.m_MouseDown = state == "down"
		self.Sound:play(("fishingRodBend%s"):format(self.m_MouseDown and "" or 2)):setVolume(.2)
	end
end

function BobberBar:setBobberPosition()
	local bobberAnimation = "InOutQuad"
	self.m_BobberSpeed = (2000 - math.min(1000, self.m_Difficulty*5)) + self.Random:get(-self.m_Difficulty*3, self.m_Difficulty*3)

	if self.m_MotionType == 1 or self.m_MotionType == 4 or (self.m_MotionType == 0 and self.Random:nextDouble() < self.m_Difficulty/150) then
		if self.m_MotionType == 4 then
			bobberAnimation = "InOutBack"
			self.m_BobberSpeed = self.m_BobberSpeed * 3
		end

		local newTargetPosition = self.m_BobberTargetPosition

		while math.abs(newTargetPosition - self.m_BobberTargetPosition) < self.m_Difficulty do
			newTargetPosition = self.Random:get(math.max(self.POSITION_UP + 10, self.m_BobberPosition - self.m_Difficulty*5), math.min(self.POSITION_DOWN - 20, self.m_BobberPosition + self.m_Difficulty*5))
		end

		self.m_BobberTargetPosition = newTargetPosition

	elseif self.m_MotionType == 2 or (self.m_MotionType == 0 and self.Random:nextDouble() < self.m_Difficulty / 200) then
		self.m_BobberTargetPosition = self.Random:get(math.max(self.POSITION_UP + 10, self.m_BobberPosition - self.m_Difficulty*3),
			math.min(self.POSITION_DOWN - 20, self.m_BobberPosition + self.m_Difficulty*3))

	elseif self.m_MotionType == 3 or (self.m_MotionType == 0 and self.Random:nextDouble() < self.m_Difficulty/100) then
		if self.m_BobberPosition < 50 then
			self.m_BobberTargetPosition = self.Random:get(self.POSITION_DOWN - self.HEIGHT/2, self.POSITION_DOWN)
		else
			self.m_BobberTargetPosition = self.m_BobberPosition - self.Random:get(-30, 100)
			self.m_BobberSpeed = self.m_BobberTargetPosition > self.m_BobberTargetPosition and 500 or self.m_BobberSpeed/2
		end
	else
		-- call again if motionType == 0 and no condition was true
		return self:setBobberPosition()
	end

	-- Probably we don't need this
	if self.m_BobberTargetPosition > self.POSITION_DOWN - 20 then
		self.m_BobberTargetPosition = self.POSITION_DOWN - 20
	elseif self.m_BobberTargetPosition < self.POSITION_UP + 10 then
		self.m_BobberTargetPosition = self.POSITION_UP + 10
	end

	self.m_BobberAnimation:startAnimation(self.m_BobberSpeed, bobberAnimation, self.m_BobberTargetPosition)
end

function BobberBar:updateRenderTarget()
	self.m_RenderTarget:setAsTarget()

	-- Draw Background
	dxDrawRectangle(0, 0, self.m_Size, tocolor(80, 80, 80, 150))

	-- Draw BobberBar
	dxSetBlendMode("modulate_add")
	dxDrawImage(5, 5, 30, self.m_Size.y-10, "files/images/Fishing/BobberBarBG.png")
	dxDrawRectangle(4, self.m_BobberBarPosition, 32, self.m_BobberBarHeight, tocolor(0, 225, 50, self.m_BobberInBar and 255 or 200))
	dxSetBlendMode("blend")

	-- Draw Bobber (Fish)
	dxDrawImage(6, self.m_BobberPosition, 28, 28, "files/images/Fishing/Fish.png", 0, 0, 0, tocolor(115, 200, 230))

	-- Draw Progressbar
	local progress_height = self.HEIGHT*(self.m_Progress/100)
	local progress_color = tocolor(255*(1-self.m_Progress/100), 255*self.m_Progress/100, 0)
	dxDrawRectangle(40, 5, 13, self.m_Size.y-10, tocolor(210, 125, 30))	--progress bg
	dxDrawRectangle(40, self.POSITION_DOWN - progress_height, 13, progress_height, progress_color) --progressbar

	dxSetRenderTarget()
end

function BobberBar:render()
	if self.m_ProgressDuration ~= 0 then
		-- BobberBar Animation
		local num = self.m_MouseDown and -0.5 or 0.5
		self.m_BobberBarSpeed = self.m_BobberBarSpeed + num
		self.m_BobberBarPosition = self.m_BobberBarPosition + self.m_BobberBarSpeed

		if self.m_BobberBarPosition > self.POSITION_DOWN - self.m_BobberBarHeight then
			self.m_BobberBarPosition = self.POSITION_DOWN - self.m_BobberBarHeight

			if self.m_BobberBarSpeed ~= 0 then
				self.m_BobberBarSpeed = -self.m_BobberBarSpeed + 0.5
				if self.m_BobberBarSpeed < -self.MAX_PUSHBACK_SPEED then self.m_BobberBarSpeed = -self.MAX_PUSHBACK_SPEED end
			end
		elseif self.m_BobberBarPosition < self.POSITION_UP then
			self.m_BobberBarPosition = self.POSITION_UP

			if self.m_BobberBarSpeed ~= 0 then
				self.m_BobberBarSpeed = math.abs(self.m_BobberBarSpeed) - 0.5
				if self.m_BobberBarSpeed > self.MAX_PUSHBACK_SPEED then self.m_BobberBarSpeed = self.MAX_PUSHBACK_SPEED end
			end
		end

		-- Check progress (only Y position/height)
		if (self.m_BobberInBar or self.m_BobberInBar == nil) and not rectangleCollision2D(0, self.m_BobberBarPosition, 0, self.m_BobberBarHeight, 0, self.m_BobberPosition, 0, 28) then
			self.m_BobberInBar = false

			local duration = (self.m_ProgressDuration - 3000) * (self.m_Progress/100)
			self.m_ProgressAnimation:startAnimation(duration, "Linear", 0)
			self.Sound:play("woap2")
			self.Sound:stop("slowReel")
		elseif (not self.m_BobberInBar or self.m_BobberInBar == nil) and rectangleCollision2D(0, self.m_BobberBarPosition, 0, self.m_BobberBarHeight, 0, self.m_BobberPosition, 0, 28) then
			self.m_BobberInBar = true

			local duration = self.m_ProgressDuration * (1 - self.m_Progress/100)
			self.m_ProgressAnimation:startAnimation(duration, "Linear", 100)
			self.Sound:play("slowReel", true)
		end
	end

	-- Update and draw
	self:updateRenderTarget()
	dxDrawText("Speed: " .. self.m_BobberSpeed, 500, 20)
	dxDrawText("Current position: " .. self.m_BobberPosition, 500, 35)
	dxDrawText("Target position: " .. self.m_BobberTargetPosition, 500, 50)
	dxDrawText("Motion type: " .. self.m_MotionType, 500, 65)
	dxDrawText("Bobber in bar: " .. tostring(self.m_BobberInBar), 500, 80)

	dxDrawImage(screenWidth*0.66 - self.m_Size.x * self.m_AnimationMultiplicator/2, screenHeight/2 - self.m_Size.y * self.m_AnimationMultiplicator/2, self.m_Size * self.m_AnimationMultiplicator, self.m_RenderTarget, 0, 0, 0, tocolor(255, 255, 255, 255*self.m_AnimationMultiplicator))
end

addEventHandler("fishingBobberBar", root,
	function(data)
		BobberBar:new(data.Difficulty, data.Behavior)
	end
)
