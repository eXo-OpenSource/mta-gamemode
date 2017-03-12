-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
local screenWidth, screenHeight = guiGetScreenSize()
FishingRod = inherit(Singleton)

function FishingRod:constructor()
	toggleControl("fire", false)
	self.m_FishingMap = FishingLocation:new()
	self.m_minFishingBiteTime = 600
	self.m_maxFishingBiteTime = 4000--30000
	self.m_minTimeToNibble = 340
	self.m_maxTimeToNibble = 800
	self.m_isCasting = true
	self.m_isFishing = false
	self.m_isNibbling = false
	self.m_Hit = false
	self.m_MouseDown = false

	self:initAnimations()

	self.m_Bobber = createObject(1337,0,0,0)
	self.m_Bobber:setAlpha(0)
	self.m_FishingRod = createObject(1826, localPlayer.position)
	exports.bone_attach:attachElementToBone(self.m_FishingRod, localPlayer, 12, 0, 0, 0.1, 180, 120, 0)
	--self.m_FishingRod:attach(localPlayer, .25, 0, -.1, 0, 225, 90) --todo bone attach?

	self.m_fishBite = bind(FishingRod.fishBite, self)
	self.m_HandleClick = bind(FishingRod.handleClick, self)
	self.m_Render = bind(FishingRod.render, self)

	bindKey("mouse1", "both", self.m_HandleClick)
	addEventHandler("onClientRender", root, self.m_Render)
end

function FishingRod:destructor()
	toggleControl("fire", true)
	self.m_FishingMap:delete()
	self.m_Bobber:delete()
	self.m_FishingRod:delete()
end

function FishingRod:initAnimations()
	self.m_PowerProgress = 0
	self.m_PowerDirection = 1
	self.m_PowerAnimationDuration = 800

	self.m_PowerAnimationDone =
		function()
			self.m_PowerDirection = self.m_PowerDirection == 1 and 0 or 1
			self.m_PowerAnimation:startAnimation(self.m_PowerAnimationDuration, "Linear", self.m_PowerDirection)
		end

	self.m_PowerAnimation = CAnimation:new(self, self.m_PowerAnimationDone, "m_PowerProgress")
end

function FishingRod:reset()
	self.m_isCasting = true
	self.m_isFishing = false
	self.m_isNibbling = false
	self.m_Hit = false
	self.m_MouseDown = false
	self.m_Bobber:setPosition(0,0,0)
end

function FishingRod:handleClick(_, state)
	self.m_MouseDown = state == "down"

	if self.m_isCasting and self.m_MouseDown then
		self.m_PowerProgress = 0
		self.m_PowerDirection = 1
		self.m_PowerAnimation:startAnimation(self.m_PowerAnimationDuration, "Linear", self.m_PowerDirection)
	elseif self.m_isCasting and not self.m_MouseDown then
		self.m_isCasting = false
		self.m_PowerAnimation:stopAnimation()
		self:cast()
	elseif self.m_isFishing and not self.m_MouseDown then
		if isTimer(self.m_nibblingTimer) then killTimer(self.m_nibblingTimer) end
		toggleAllControls(true)
		self.m_isFishing = false
		self.m_isCasting = true
	elseif self.m_isNibbling and self.m_MouseDown then
		if getTickCount() - self.m_nibblingTime <= self.m_maxTimeToNibble then
			if isTimer(self.m_fishBiteMissedTimer) then killTimer(self.m_fishBiteMissedTimer) end
			outputChatBox("HIT")
			self.m_isNibbling = false
			self.m_Hit = true

			triggerServerEvent("clientFishHit", localPlayer, self.m_Location)
			--self:reset()--todo: remove until server isnt added
		else
			outputChatBox("Failed ._.")
		end
	end
end

function FishingRod:fishBite()
	self.m_isFishing = false
	self.m_isNibbling = true
	self.m_nibblingTime = getTickCount()
	outputChatBox("NIBBLING!")

	self.m_fishBiteMissedTimer = setTimer(
		function()
			self.m_isFishing = true
			self.m_isNibbling = false
			self.m_timeUntilFishingBite = math.random(self.m_minFishingBiteTime, self.m_maxFishingBiteTime)
			self.m_nibblingTimer = setTimer(self.m_fishBite, self.m_timeUntilFishingBite, 1)
			outputChatBox("missed, start next " .. self.m_timeUntilFishingBite)
		end, self.m_maxTimeToNibble, 1)
	-- Do nibbling sound,  anim or renderinfo
end

function FishingRod:cast()
	local distance = 10*self.m_PowerProgress

	if self:checkWater(distance) then
		outputChatBox("Cast power: " .. tostring(self.m_PowerProgress))
		local targetPosition = localPlayer.matrix:transformPosition(Vector3(0, distance, 0))
		targetPosition.z = 0
		self.m_Bobber:setPosition(targetPosition)
		self.m_Location = self.m_FishingMap:getLocation(self.m_Bobber)
		toggleAllControls(false)
		self.m_isFishing = true
		self.m_timeUntilFishingBite = math.random(self.m_minFishingBiteTime, self.m_maxFishingBiteTime)
		self.m_nibblingTimer = setTimer(self.m_fishBite, self.m_timeUntilFishingBite, 1)
		outputChatBox(self.m_timeUntilFishingBite)
		--do cast animation (max. 600ms duration)
	else
		self.m_isCasting = true
		--InfoBox:new(_("Hier ist kein Wasser!"))--todo
	end
end

function FishingRod:checkWater(distance)
	local startPosition = localPlayer.position + localPlayer.matrix.up
	local targetPosition = localPlayer.matrix:transformPosition(Vector3(0, distance, -1))
	targetPosition.z = -0.2

	local result = {processLineOfSight(startPosition, targetPosition)}
	if not result[9] and (testLineAgainstWater(startPosition, targetPosition) or getGroundPosition(targetPosition) == 0) then
		return true
	end
	return false
end

function FishingRod:render()
	local startPosition = self.m_FishingRod.matrix:transformPosition(Vector3(0.05, 0, -1.3))
	local targetPosition = localPlayer.matrix:transformPosition(Vector3(0, 10*self.m_PowerProgress, 0))
	targetPosition.z = -0.2

	dxDrawLine3D(startPosition, targetPosition, tocolor(255, 255, 255, 255), .3)

	local left = screenWidth-300
	local top = screenHeight/2

	if self.m_isCasting and self.m_MouseDown then
		dxDrawRectangle(left, top, 125, 20, tocolor(30, 30, 30))
		dxDrawRectangle(left+1, top+1, 125-2, 20-2, tocolor(80, 80, 80))
		dxDrawImageSection(left+1, top+1, 123*self.m_PowerProgress, 20-2, 0, 0, 123*self.m_PowerProgress, 20-2, "files/images/Fishing/RedGreen.png")
	end
end

addCommandHandler("f",
	function()
		FishingRod:new()
	end
)
