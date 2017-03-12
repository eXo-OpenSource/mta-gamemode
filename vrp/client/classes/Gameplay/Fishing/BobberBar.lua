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
	toggleControl("fire", false) --todo dev
	self.m_Size = Vector2(100, screenHeight/2)
	self.m_RenderTarget = DxRenderTarget(self.m_Size, true)

	self.m_BobberBarHeight = 96 + playerFishingLevel*8	--this.bobberBarHeight = Game1.tileSize * 3 / 2 + Game1.player.FishingLevel * 8;
	self.m_BobberPosition = self.m_Size.y - self.m_BobberBarHeight - 5
	self.m_BobberSpeed = 0
	self.m_BobberTargetPosition = 0
	self.m_BobberInBar = false

	self.m_Difficulty = difficulty
	self.m_MotionType = self:getMotionType(behavior)

	self.m_FishSizeReductionTimer = 800
	self.m_Progress = 40

	self:initAnimations()
	self:updateRenderTarget()

	self.m_Render = bind(BobberBar.render, self)
	self.m_HandleClick = bind(BobberBar.handleClick, self)

	bindKey("mouse1", "both", self.m_HandleClick)
	addEventHandler("onClientRender", root, self.m_Render)
end

function BobberBar:destructor()
	removeEventHandler("onClientRender", root, self.m_fnRender)
end

function BobberBar:initAnimations()
	self.m_BobberBarUpDownDuration = 1000

	self.m_BobberBarPushBack =
		function()
			if self.m_BobberPosition == 5 then
				--todo oush back animation
			elseif self.m_BobberPosition == self.m_Size.y-self.m_BobberBarHeight-5 then
				--todo push back animation
			end
		end

	self.m_BobberBarAnimation = CAnimation:new(self, self.m_BobberBarPushBack, "m_BobberPosition")
end

function BobberBar:getMotionType(behavior)
	if behavior == "mixed" then
		return 0
	elseif behavior == "dart" then
		return 1
	elseif behavior == "smooth" then
		return 2
	elseif behavior == "floater" then
		return 3
	elseif behavior == "sinker" then
		return 4
	end
end

function BobberBar:handleClick(_, state)
	self.m_MouseDown = state == "down"

	if self.m_MouseDown then
		local duration = self.m_BobberPosition/(self.m_Size.y-self.m_BobberBarHeight-5)*self.m_BobberBarUpDownDuration

		self.m_BobberBarAnimation:startAnimation(duration, "InQuad", 5)
	elseif not self.m_MouseDown then
		local duration = self.m_BobberBarUpDownDuration - (self.m_BobberPosition/(self.m_Size.y-self.m_BobberBarHeight-5)*self.m_BobberBarUpDownDuration)

		self.m_BobberBarAnimation:startAnimation(duration, "InQuad", self.m_Size.y-self.m_BobberBarHeight - 5)
	end
end

function BobberBar:updateRenderTarget()
	self.m_RenderTarget:setAsTarget()

	dxDrawRectangle(0, 0, self.m_Size, tocolor(40, 40, 40, 150))	--full bg
	dxDrawImage(50, 5, 30, self.m_Size.y-10, "files/images/Fishing/BobberBarBG.png")	--todo BobberBarBG (maybe framed?)
	dxDrawRectangle(49, self.m_BobberPosition, 32, self.m_BobberBarHeight, tocolor(0, 225, 50))	--todo BobberBar
	dxDrawRectangle(60, 75, 10, 10, tocolor(0, 140, 255))		--todo: fish

	dxDrawRectangle(82, 5, 13, self.m_Size.y-10, tocolor(200, 80, 80))	--progress bg
	dxDrawRectangle(82, self.m_Size.y-self.m_Progress - 5, 13, self.m_Progress, tocolor(255, 200, 0)) --progressbar

	dxSetRenderTarget()
end

function BobberBar:render()
	dxDrawImage(screenWidth*0.66 - self.m_Size.x/2, screenHeight/2 - self.m_Size.y/2, self.m_Size, self.m_RenderTarget)
end

addEventHandler("fishingBobberBar", root,
	function(data)
		BobberBar:new(data.difficulty, data.behavior)
	end
)

--BobberBar:new(90, "mixed")
