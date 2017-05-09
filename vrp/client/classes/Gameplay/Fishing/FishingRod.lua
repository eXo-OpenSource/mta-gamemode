-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Fishing/FishingRod.lua
-- *  PURPOSE:     FishingRod class
-- *
-- ****************************************************************************
FishingRod = inherit(Singleton)

function FishingRod:constructor(fishingRod)
	self.FishingMap = FishingLocation:new()
	self.Sound = SoundManager:new("files/audio/Fishing")
	self.Random = Randomizer:new()

	self.m_minFishingBiteTime = 600
	self.m_maxFishingBiteTime = 30000
	self.m_minTimeToNibble = 340
	self.m_maxTimeToNibble = 800
	self.m_isCasting = true
	self.m_isFishing = false
	self.m_isNibbling = false
	self.m_Hit = false
	self.m_MouseDown = false

	self:initAnimations()

	self.m_FishingRod = fishingRod--createObject(1826, localPlayer.position)
	--exports.bone_attach:attachElementToBone(self.m_FishingRod, localPlayer, 12, -0.03, 0.02, 0.05, 180, 120, 0)

	self.m_fishBite = bind(FishingRod.fishBite, self)
	self.m_HandleClick = bind(FishingRod.handleClick, self)
	self.m_Render = bind(FishingRod.render, self)

	toggleControl("fire", false)
	bindKey("mouse1", "both", self.m_HandleClick)
	addEventHandler("onClientRender", root, self.m_Render)
end

function FishingRod:destructor()
	toggleAllControls(true)
	unbindKey("mouse1", "both", self.m_HandleClick)
	removeEventHandler("onClientRender", root, self.m_Render)
	if isTimer(self.m_nibblingTimer) then killTimer(self.m_nibblingTimer) end
	self.Sound:stopAll()

	delete(self.FishingMap)
end

function FishingRod:initAnimations()
	self.m_PowerProgress = 0
	self.m_PowerDirection = 1
	self.m_PowerAnimationDuration = 800

	self.m_PowerAnimationDone =
		function()
			self.m_PowerDirection = self.m_PowerDirection == 1 and 0 or 1
			self.m_PowerAnimation:startAnimation(self.m_PowerAnimationDuration, "Linear", self.m_PowerDirection)

			self.Sound:stopAll()
			self.Sound:play(self.m_PowerDirection == 1 and "chirp_cast" or "chirp_cast_back")

			--localPlayer:setAnimation() --reset
			--localPlayer:setAnimation("camera", self.m_PowerDirection == 1 and "picstnd_in" or "picstnd_out", -1, false, false, false, true)
		end

	self.m_PowerAnimation = CAnimation:new(self, self.m_PowerAnimationDone, "m_PowerProgress")
end

function FishingRod:reset()
	localPlayer:setAnimation()
	toggleAllControls(true)
	toggleControl("fire", false)

	self.m_isCasting = true
	self.m_isFishing = false
	self.m_isNibbling = false
	self.m_Hit = false
	self.m_MouseDown = false
	self.m_PowerProgress = 0
end

function FishingRod:handleClick(_, state)
	if isCursorShowing() then return end
	setControlState("fire", false)
	toggleControl("fire", false)

	self.m_MouseDown = state == "down"

	if self.m_isCasting and self.m_MouseDown then
		self.m_PowerProgress = 0
		self.m_PowerDirection = 1
		self.m_PowerAnimation:startAnimation(self.m_PowerAnimationDuration, "Linear", self.m_PowerDirection)
		self.Sound:play("chirp_cast")

		--localPlayer:setAnimation("camera", "picstnd_in", -1, false, false, false, true)
	elseif self.m_isCasting and not self.m_MouseDown then
		self.m_isCasting = false
		self.m_PowerAnimation:stopAnimation()
		self.Sound:stopAll()
		self:cast()
	elseif self.m_isFishing and not self.m_MouseDown then
		if isTimer(self.m_nibblingTimer) then killTimer(self.m_nibblingTimer) end
		self.m_PowerProgress = 0
		self.m_isFishing = false
		self.m_isCasting = true
		self.Sound:play("caught")

		toggleAllControls(true)
		toggleControl("fire", false)
	elseif self.m_isNibbling and self.m_MouseDown then
		if getTickCount() - self.m_nibblingTime <= self.m_maxTimeToNibble then
			if isTimer(self.m_fishBiteMissedTimer) then killTimer(self.m_fishBiteMissedTimer) end
			self.Sound:play("hit")
			self.m_isNibbling = false
			self.m_Hit = true

			triggerServerEvent("clientFishHit", localPlayer, self.m_Location, self.m_PowerProgress)
		end
	end
end

function FishingRod:fishBite()
	self.m_isFishing = false
	self.m_isNibbling = true
	self.m_nibblingTime = getTickCount()
	self.Sound:play("bit")

	local targetPosition = localPlayer.matrix:transformPosition(Vector3(0, 10*self.m_PowerProgress, -1))
	targetPosition.z = 0
	createEffect("water_swim", targetPosition)

	self.m_fishBiteMissedTimer = setTimer(
		function()
			self.m_isFishing = true
			self.m_isNibbling = false
			self.m_timeUntilFishingBite = self.Random:get(self.m_minFishingBiteTime, self.m_maxFishingBiteTime)
			self.m_nibblingTimer = setTimer(self.m_fishBite, self.m_timeUntilFishingBite, 1)
			self.Sound:play("dwop")
		end, self.m_maxTimeToNibble, 1
	)
end

function FishingRod:cast()
	if localPlayer:isInWater() then
		ErrorBox:new(_("Du kannst im Wasser nicht angeln!"))
		return
	end

	local distance = 10*self.m_PowerProgress

	if self:checkWater(distance) then
		toggleAllControls(false)

		local targetPosition = localPlayer.matrix:transformPosition(Vector3(0, distance, 0))
		targetPosition.z = 0
		self.m_Location = self.FishingMap:getLocation(targetPosition)
		self.m_isFishing = true
		self.m_timeUntilFishingBite = self.Random:get(self.m_minFishingBiteTime, self.m_maxFishingBiteTime)
		self.m_nibblingTimer = setTimer(self.m_fishBite, self.m_timeUntilFishingBite, 1)

		createEffect("water_swim", targetPosition)
		self.Sound:play("cast")
		self.Sound:play("waterplop")
	else
		self.m_isCasting = true
		self.Sound:play("dwop")
		self.m_PowerProgress = 0
		WarningBox:new(_("Hier ist kein Wasser!"))
	end
end

function FishingRod:checkWater(distance)
	local startPosition = self.m_FishingRod.matrix:transformPosition(Vector3(0.05, 0, -1.3))
	local targetPosition = localPlayer.matrix:transformPosition(Vector3(0, distance, 0))
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

	if self.m_isCasting and not self.m_MouseDown then
		targetPosition = self.m_FishingRod.matrix:transformPosition(Vector3(0.05, 0, -1.3))
		targetPosition.z = targetPosition.z - .7
	else
		targetPosition.z = 0
	end

	exports.bone_attach:setElementBoneRotationOffset(self.m_FishingRod, 180, 120 + 60*self.m_PowerProgress, 0)
	dxDrawLine3D(startPosition, targetPosition, tocolor(255, 230, 190, 100), .3)

	local left = screenWidth-300
	local top = screenHeight/2

	if self.m_isCasting and self.m_MouseDown then
		dxDrawRectangle(left, top, 125, 20, tocolor(30, 30, 30))
		dxDrawRectangle(left+1, top+1, 125-2, 20-2, tocolor(80, 80, 80))
		dxDrawImageSection(left+1, top+1, 123*self.m_PowerProgress, 20-2, 0, 0, 123*self.m_PowerProgress, 20-2, "files/images/Fishing/RedGreen.png")
	end
end
