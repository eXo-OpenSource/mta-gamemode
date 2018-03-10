-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Tasks/TaskShootTarget.lua
-- *  PURPOSE:     Shoot target task class
-- *
-- ****************************************************************************
TaskShootTarget = inherit(Task)
local MAX_SHOOT_DISTANCE = 30
local MAX_SHOOT_DISTANCE_SNIPER = MAX_SHOOT_DISTANCE*3

function TaskShootTarget:constructor(actor, target)
	outputDebug("TaskShootTarget:constructor - target: "..tostring(target))
	self.m_Target = target
	self.m_ShootTimer = false

	self:startShooting()
end

function TaskShootTarget:destructor()
	self:stopShooting()
end

function TaskShootTarget:getId()
	return Tasks.TASK_SHOOT_TARGET
end

function TaskShootTarget:checkActor()
	if self.m_Actor and isElement(self.m_Actor) and not isPedDead(self.m_Actor) then
		return true
	end
	return false
end

function TaskShootTarget:checkTarget()
	if self.m_Target and isElement(self.m_Target) then
		if self.m_Target:getType() == "player" or self.m_Target:getType() == "ped" then
			if not isPedDead(self.m_Target) then
				return true
			end
		else
			return true
		end
	end
	return false
end

function TaskShootTarget:shootSingleBullet()
	if self:checkActor() then
		if self:checkTarget() then
			-- Update target
			self.m_Actor:setAimTarget(self.m_Target:getBonePosition(3))

			-- Activate fire control for a bit to simulate key presses
			self.m_Actor:setControlState("aim_weapon", true)
			self.m_Actor:setControlState("fire", true)
		else
			self:stopShooting()
		end
	else
		delete(self)
	end
end

function TaskShootTarget:startShooting()
	if not self.m_ShootTimer then
		-- Shoot single bullets every 200ms (==> 5 bullets/second)
		self:shootSingleBullet()
		self.m_ShootTimer = setTimer(bind(self.shootSingleBullet, self), 200, 0)
	end
end

function TaskShootTarget:stopShooting()
	if self.m_ShootTimer then
		killTimer(self.m_ShootTimer)
		self.m_ShootTimer = false
	end

	self.m_Actor:setControlState("fire", false)
	self.m_Actor:setControlState("aim_weapon", false)
end

function TaskShootTarget:update()
	if not isElementStreamedIn(self.m_Actor) then
		return self:stopUpdating()
	end
	if self:checkTarget() and self:checkActor() then
		local actorPosition = self.m_Actor:getPosition()
		local targetPosition = self.m_Target:getPosition()
		self.m_Actor:setRotation(0, 0, findRotation(actorPosition.x, actorPosition.y, targetPosition.x, targetPosition.y))

		-- Stop if target is too far away
		if self.m_Actor:getWeapon() ~= 34 then
			if (actorPosition-targetPosition).length > MAX_SHOOT_DISTANCE then
				triggerServerEvent("taskShootTargetTooFarAway", self.m_Actor)
				return self:stopUpdating()
			end
		else
			if (actorPosition-targetPosition).length > MAX_SHOOT_DISTANCE_SNIPER then
				triggerServerEvent("taskShootTargetTooFarAway", self.m_Actor)
				return self:stopUpdating()
			end
		end
	else
		triggerServerEvent("taskShootTargetTooFarAway", self.m_Actor)
		return self:stopUpdating()
	end
end
