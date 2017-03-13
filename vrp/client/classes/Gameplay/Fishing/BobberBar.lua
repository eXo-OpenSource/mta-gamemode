-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
BobberBar = inherit(Singleton)
addRemoteEvents{"fishingBobberBar"}

local screenWidth, screenHeight = guiGetScreenSize()
local playerFishingLevel = 1

function BobberBar:constructor(difficulty, behavior)
	self.m_Size = Vector2(100, screenHeight/2)
	self.m_RenderTarget = DxRenderTarget(self.m_Size, true)

	self.Random = Randomizer:new()

	self.m_BobberBarHeight = 96 + playerFishingLevel*8	--this.bobberBarHeight = Game1.tileSize * 3 / 2 + Game1.player.FishingLevel * 8;
	self.m_BobberBarPosition = self.m_Size.y - self.m_BobberBarHeight - 5
	self.m_BobberBarSpeed = 0

	self.POSITION_UP = 5
	self.POSITION_DOWN = self.m_Size.y - 5
	self.HEIGHT = self.POSITION_DOWN - self.POSITION_UP
	self.MAX_PUSHBACK_SPEED = 8

	self.m_Difficulty = difficulty
	self.m_MotionType = self:getMotionType(behavior)

	self.m_BobberPosition = self.HEIGHT
	self.m_BobberSpeed = 0
	self.m_BobberTargetPosition = (100 - self.m_Difficulty) / 100 * self.HEIGHT
	self.m_FloaterSkinerAccceleration = 0
	self.m_BobberInBar = false

	self.m_FishSizeReductionTimer = 800
	self.m_Progress = 40
	self.m_ProgressDuration = 2500

	self:initAnimations()
	self:updateRenderTarget()

	self.m_Render = bind(BobberBar.render, self)
	self.m_HandleClick = bind(BobberBar.handleClick, self)

	toggleControl("fire", false)
	bindKey("mouse1", "both", self.m_HandleClick)
	addEventHandler("onClientRender", root, self.m_Render)
end

function BobberBar:destructor()
	removeEventHandler("onClientRender", root, self.m_Render)
	unbindKey("mouse1", "both", self.m_HandleClick)
end

function BobberBar:initAnimations()
	local onProgressDone =
		function()
			if self.m_Progress == 100 then
				outputChatBox("Fish caught!")
				-- Todo: Stop animations and fadeout
			else
				-- Todo: Fish escape
			end
		end

	self.m_BobberAnimation = CAnimation:new(self, bind(BobberBar.setBobberPosition, self), "m_BobberPosition")
	self.m_ProgressAnimation = CAnimation:new(self, onProgressDone, "m_Progress")
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
	self.m_MouseDown = state == "down"

	if not self.m_BobberAnimation:isAnimationRendered() then
		self:setBobberPosition()
	end
end

function BobberBar:setBobberPosition()
	if self.Random:nextDouble() < self.m_Difficulty * (self.m_MotionType == 2 and 20 or 1) / 4000 and (self.m_MotionType ~= 2 or self.m_BobberTargetPosition == -1) then
		local num1 = self.HEIGHT - self.m_BobberPosition
		local bobberPosition = self.m_BobberPosition
		local num2 = math.min(99, self.m_Difficulty + self.Random:get(10, 45)) / 100
		self.m_BobberTargetPosition = bobberPosition + self.Random:get(-bobberPosition, num1) * num2
	end

	if self.m_MotionType == 4 then			-- floater
		self.m_FloaterSkinerAccceleration = math.max(self.m_FloaterSkinerAccceleration - 0.01, -1.5)
	elseif self.m_MotionType == 3 then		-- sinker
		self.m_FloaterSkinerAccceleration = math.max(self.m_FloaterSkinerAccceleration + 0.01, -1.5)
	end

	if math.abs(self.m_BobberPosition - self.m_BobberTargetPosition) > 3 and self.m_BobberTargetPosition ~= -1 then
		local bobberAcceleration = self.m_BobberTargetPosition - self.m_BobberPosition / self.Random:get(10, 30) + (100 - math.min(100, self.m_Difficulty))
		self.m_BobberSpeed = self.m_BobberSpeed + ((bobberAcceleration - self.m_BobberSpeed) / 5)
	else
		self.m_BobberTargetPosition = self.m_MotionType == 2 or self.Random:nextDouble() >= self.m_Difficulty / 2000 and -1 or self.m_BobberPosition + (self.Random:nextDouble() < 0.5 and self.Random:get(-100, -51) or self.Random:get(50, 101))
	end

	if self.m_MotionType == 1 and self.Random:nextDouble() < self.m_Difficulty / 1000 then
		self.m_BobberTargetPosition = self.m_BobberPosition + (self.Random:nextDouble() < 0.5 and self.Random:get(-100 - self.m_Difficulty * 2, -51) or self.Random:get(50, 101 + self.m_Difficulty * 2))
	end

	self.m_BobberTargetPosition = math.max(-1, math.min(self.m_BobberTargetPosition, self.HEIGHT))

	if self.m_BobberPosition > self.POSITION_DOWN then
		self.m_BobberPosition = self.POSITION_DOWN
	elseif self.m_BobberPosition < self.POSITION_UP then
		self.m_BobberPosition = self.POSITION_UP
	end

	self.m_BobberAnimation:startAnimation(self.m_BobberSpeed*100, "OutQuad", self.m_BobberTargetPosition)
end

function BobberBar:updateRenderTarget()
	self.m_RenderTarget:setAsTarget()

	-- Draw Background
	dxDrawRectangle(0, 0, self.m_Size, tocolor(40, 40, 40, 150))

	-- Draw BobberBar
	dxDrawImage(50, 5, 30, self.m_Size.y-10, "files/images/Fishing/BobberBarBG.png")
	dxDrawRectangle(49, self.m_BobberBarPosition, 32, self.m_BobberBarHeight, tocolor(0, 225, 50))

	-- Draw Bobber (Fish) (Todo: Change to fish image)
	dxDrawRectangle(60, self.m_BobberPosition, 10, 10, tocolor(0, 140, 255))

	-- Draw Progressbar
	local progress_height = self.HEIGHT*(self.m_Progress/100)
	dxDrawRectangle(82, 5, 13, self.m_Size.y-10, tocolor(200, 80, 80))	--progress bg
	dxDrawRectangle(82, self.POSITION_DOWN - progress_height, 13, progress_height, tocolor(255, 200, 0)) --progressbar

	dxSetRenderTarget()
end

function BobberBar:render()
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

	-- Check progress (only check Y position/height)
	if self.m_BobberInBar and not rectangleCollision2D(0, self.m_BobberBarPosition, 0, self.m_BobberBarHeight, 0, self.m_BobberPosition, 0, 10) then
		self.m_BobberInBar = false

		local duration = (self.m_ProgressDuration + 2000) * (self.m_Progress/100)
		self.m_ProgressAnimation:startAnimation(duration, "Linear", 0)
	elseif not self.m_BobberInBar and rectangleCollision2D(0, self.m_BobberBarPosition, 0, self.m_BobberBarHeight, 0, self.m_BobberPosition, 0, 10) then
		self.m_BobberInBar = true

		local duration = self.m_ProgressDuration * (1 - self.m_Progress/100)
		self.m_ProgressAnimation:startAnimation(duration, "Linear", 100)
	end

	-- Update and draw
	self:updateRenderTarget()
	dxDrawText(self.m_BobberSpeed, 500, 20)
	dxDrawText(self.m_BobberTargetPosition, 500, 30)
	dxDrawImage(screenWidth*0.66 - self.m_Size.x/2, screenHeight/2 - self.m_Size.y/2, self.m_Size, self.m_RenderTarget)
end

addEventHandler("fishingBobberBar", root,
	function(data)
		BobberBar:new(data.difficulty, data.behavior)
	end
)

--BobberBar:new(90, "mixed")
