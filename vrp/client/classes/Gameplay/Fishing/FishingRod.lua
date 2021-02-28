-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Fishing/FishingRod.lua
-- *  PURPOSE:     FishingRod class
-- *
-- ****************************************************************************
FishingRod = inherit(Singleton)

function FishingRod:constructor(fishingRod, fishingRodName, baitName, accessorieName)
	self.FishingMap = FishingLocation:new()
	self.Sound = SoundManager:new("files/audio/Fishing")
	self.Random = Randomizer:new()

	self.m_minFishingBiteTime = 600
	self.m_maxFishingBiteTime = 30000 - FISHING_RODS[fishingRodName].biteTimeReduction - FISHING_BAITS[baitName].biteTimeReduction - FISHING_ACCESSORIES[accessorieName].biteTimeReduction
	self.m_minTimeToNibble = 340
	self.m_maxTimeToNibble = 800
	self.m_isCasting = true
	self.m_isFishing = false
	self.m_isNibbling = false
	self.m_Hit = false
	self.m_MouseDown = false
	self.m_RenderBobber = FISHING_ACCESSORIES[accessorieName].renderBobber

	self:initAnimations()

	self.m_FishingRod = fishingRod
	self.m_FishingRodName = fishingRodName

	self.m_fishBite = bind(FishingRod.fishBite, self)
	self.m_HandleClick = bind(FishingRod.handleClick, self)
	self.m_Render = bind(FishingRod.render, self)

	toggleControl("fire", false)
	bindKey("mouse1", "both", self.m_HandleClick)
	addEventHandler("onClientRender", root, self.m_Render)
end

function FishingRod:destructor()
	toggleAllControls(true, true, false)
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
	toggleAllControls(true, true, false)
	toggleControl("fire", false)

	self.m_isCasting = true
	self.m_isFishing = false
	self.m_isNibbling = false
	self.m_Hit = false
	self.m_MouseDown = false
	self.m_PowerProgress = 0
end

function FishingRod:updateEquipments(baitName, accessorieName)
	self.m_maxFishingBiteTime = 30000 - FISHING_RODS[self.m_FishingRodName].biteTimeReduction - FISHING_BAITS[baitName].biteTimeReduction - FISHING_ACCESSORIES[accessorieName].biteTimeReduction
	self.m_RenderBobber = FISHING_ACCESSORIES[accessorieName].renderBobber
end

function FishingRod:handleClick(_, state)
	if isCursorShowing() then return end
	setPedControlState("fire", false)
	toggleControl("fire", false)
	if localPlayer.vehicle then return end

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

		toggleAllControls(true, true, false)
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

	local fishingHookPosition = self:getFishingHookPosition()
	createEffect("water_swim", fishingHookPosition)

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

	if self:checkWater() then
		toggleAllControls(false, true, false)

		local fishingHookPosition = self:getFishingHookPosition()

		self.m_Location = self.FishingMap:getLocation(fishingHookPosition)
		self.m_isFishing = true
		self.m_timeUntilFishingBite = self.Random:get(self.m_minFishingBiteTime, self.m_maxFishingBiteTime)
		self.m_nibblingTimer = setTimer(self.m_fishBite, self.m_timeUntilFishingBite, 1)

		createEffect("water_swim", fishingHookPosition)
		self.Sound:play("cast")
		self.Sound:play("waterplop")

		triggerServerEvent("clientFishingRodCast", localPlayer)
	else
		self.m_isCasting = true
		self.Sound:play("dwop")
		self.m_PowerProgress = 0
		WarningBox:new(_("Hier ist kein Wasser!"))
	end
end

function FishingRod:checkWater()
	local location = self.FishingMap:getLocation(localPlayer.position)
	local startPosition = self.m_FishingRod.matrix:transformPosition(Vector3(0.05, 0, -1.3))
	local targetPosition = self:getFishingHookPosition()

	local waterPosition = Vector3(targetPosition.x, targetPosition.y, targetPosition.z)
	waterPosition.z = -500

	local result = {processLineOfSight(startPosition, targetPosition)}
	if not result[9] and isLineOfSightClear(localPlayer.position, startPosition, true, true, true, true, true, false, false, localPlayer) and (testLineAgainstWater(startPosition, waterPosition) or getGroundPosition(targetPosition) == 0 or (localPlayer:getData("inSewer") and location == "sewer")) then
		return true
	end
	return false
end

function FishingRod:getFishingHookPosition()
	local waterHeight = self.FishingMap:getWaterHeight(localPlayer.matrix:transformPosition(Vector3(0, 10*self.m_PowerProgress/3, 0)))
	local multiplier = 10 + (self.m_FishingRod.position.z - waterHeight)*2

	local targetPosition = self.m_FishingRod.matrix:transformPosition(Vector3(0.05+multiplier*self.m_PowerProgress/3, 0, -1.3))
	targetPosition.z = self.FishingMap:getWaterHeight(targetPosition)

	return targetPosition
end

function FishingRod:render()
	if not isElement(self.m_FishingRod) then return end

	local startPosition = self.m_FishingRod.matrix:transformPosition(Vector3(0.05, 0, -1.3))
	local fishingHookPosition = self:getFishingHookPosition()

	if self.m_Hit or self.m_isNibbling then
		fishingHookPosition = Vector3(fishingHookPosition.x + self.Random:get(-3, 3)/100, fishingHookPosition.y + self.Random:get(-4, 4)/100, fishingHookPosition.z + self.Random:get(-5, 5)/100)
	end

	if self.m_RenderBobber and not self.m_isCasting then
		local drawn = self.m_isNibbling or self.m_Hit
		if not drawn then
			dxDrawLine3D(fishingHookPosition, Vector3(fishingHookPosition.x, fishingHookPosition.y, fishingHookPosition.z - 0.2), Color.White, 5)
		end

		dxDrawLine3D(Vector3(fishingHookPosition.x, fishingHookPosition.y, fishingHookPosition.z - (drawn and 0.1 or 0)), Vector3(fishingHookPosition.x, fishingHookPosition.y, fishingHookPosition.z - 0.1 - (drawn and 0.1 or 0)), Color.Red, 5)
	end

	if self.m_isCasting and not self.m_MouseDown then
		fishingHookPosition = Vector3(startPosition.x, startPosition.y, startPosition.z)
		fishingHookPosition.z = fishingHookPosition.z - .7
	end

	exports.bone_attach:setElementBoneRotationOffset(self.m_FishingRod, 180, 120 + 60*self.m_PowerProgress, 0)
	dxDrawLine3D(startPosition, fishingHookPosition, tocolor(255, 230, 190, 100), .3)

	local left = screenWidth-300
	local top = screenHeight/2

	if self.m_isCasting and self.m_MouseDown then
		dxDrawRectangle(left, top, 125, 20, tocolor(30, 30, 30))
		dxDrawRectangle(left+1, top+1, 125-2, 20-2, tocolor(80, 80, 80))
		dxDrawImageSection(left+1, top+1, 123*self.m_PowerProgress, 20-2, 0, 0, 123*self.m_PowerProgress, 20-2, "files/images/Fishing/RedGreen.png")
	end
end
