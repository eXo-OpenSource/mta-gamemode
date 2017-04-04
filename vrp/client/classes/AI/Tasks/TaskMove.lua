-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Tasks/TaskMove.lua
-- *  PURPOSE:     Shoot target task class
-- *
-- ****************************************************************************
TaskMove = inherit(Task)
local CHECK_FACTOR = 1.2
local TARGET_MIN_DIST = 0.2

function TaskMove:constructor(actor, actorSyncer, targetPosition)
	self.m_Syncer = actorSyncer
	self.m_TargetPosition = normaliseVector(targetPosition)
	self.m_Actor:setControlState("forwards", true)

	outputDebug(("MoveActor:constructor - target: %s - syncer: %s (%s) (isSyncer: %s)"):format(tostring(self.m_TargetPosition), tostring(self.m_Syncer), self.m_Syncer:getName(), tostring(self:isSyncer())))
end

function TaskMove:destructor()

end

function TaskMove:getId()
	return Tasks.TASK_MOVE
end

function TaskMove:isSyncer()
	return self.m_Syncer == localPlayer
end

function TaskMove:update()
	if self:isSyncer() then
		local actorPosition = self.m_Actor:getPosition()
		local hit, hitX, hitY, hitZ = self:testLine()
		local hitPosition = Vector3(hitX, hitY, hitZ)

		if hitX then
			if self.m_Actor:getControlState("forwards") then
				self.m_Actor:setControlState("forwards", false)
				self.m_Actor:setControlState("jump", true)

				self.m_LastJump = getTickCount()
			elseif getTickCount() - self.m_LastJump > 2500 then -- if we tried to jump but didn work
				self.m_Actor:setControlState("jump", false)

				local startLeft = actorPosition + self.m_Actor.matrix.right*-CHECK_FACTOR
				local startRight = actorPosition + self.m_Actor.matrix.right*CHECK_FACTOR
				local bestLine = self:getBestLine(startLeft, startRight)
				if bestLine then
					outputDebug(bestLine)
					self:setTemporaryTarget(bestLine)
				else
					return
				end

				if DEBUG then
					if bestLine then
						dxDrawLine3D(bestLine, self.m_TargetPosition, Color.Yellow, 2)
					end

					dxDrawLine3D(startLeft, startLeft + self.m_Actor.matrix.forward*(CHECK_FACTOR/2), leftLine and Color.Green or Color.Red)
					dxDrawLine3D(startRight, startRight + self.m_Actor.matrix.forward*(CHECK_FACTOR/2), rightLine and Color.Green or Color.Red)
				end
			end
		else
			if (self.m_Actor:getPosition() - self.m_TargetPosition).length > TARGET_MIN_DIST then
				self.m_Actor:setControlState("forwards", true)
				self.m_Actor:setControlState("jump", false)

				self.m_Actor:setRotation(Vector3(0, 0, findRotation(actorPosition.x, actorPosition.y, self.m_TargetPosition.x, self.m_TargetPosition.y)))
			else
				-- Target reached
				self.m_Actor:setControlState("forwards", false)

				if self.m_IsTemporaryTarget then
					self:resetTarget()
				end
			end
		end

		if DEBUG then
			if hitX then
				dxDrawLine3D(self.m_Actor:getPosition(), Vector3(hitX, hitY, hitZ), Color.Red, 3)
			end
			dxDrawLine3D(self.m_Actor:getPosition(), self.m_Actor:getPosition() + self.m_Actor.matrix.forward*CHECK_FACTOR, hit and Color.Red or Color.Green, 1)
		end
	end

	if DEBUG then
		dxDrawLine3D(Vector3(self.m_TargetPosition.x, self.m_TargetPosition.y, self.m_TargetPosition.z - 10), Vector3(self.m_TargetPosition.x, self.m_TargetPosition.y, self.m_TargetPosition.z + 10), Color.Blue, 3)
	end
end

function TaskMove:setTemporaryTarget(target)
	if not self.m_IsTemporaryTarget then
		self.m_OriginalTargetPosition = self.m_TargetPosition
		self.m_TargetPosition = target
		self.m_IsTemporaryTarget = true

		local actorPosition = self.m_Actor:getPosition()
		self.m_Actor:setRotation(Vector3(0, 0, findRotation(actorPosition.x, actorPosition.y, target.x, target.y)))
	end
end

function TaskMove:resetTarget()
	if self.m_IsTemporaryTarget then
		self.m_TargetPosition = self.m_OriginalTargetPosition
		self.m_IsTemporaryTarget = false

		local actorPosition = self.m_Actor:getPosition()
		self.m_Actor:setRotation(Vector3(0, 0, findRotation(actorPosition.x, actorPosition.y, self.m_TargetPosition.x, self.m_TargetPosition.y)))
	end
end

function TaskMove:testLine(lineStart, lineEnd)
	return processLineOfSight(lineStart or self.m_Actor:getPosition(), lineEnd or self.m_Actor:getPosition() + self.m_Actor.matrix.forward*CHECK_FACTOR, true, true, false, true, true, true, false, false, self.m_Actor)
end

function TaskMove:getLineScore(pos)
	return (self.m_TargetPosition - pos).length
end

function TaskMove:testHit(pos)
	return false
end

function TaskMove:getBestLine(posA, posB) -- lightweight heuristic
	local leftHit  = self:testLine(posA, posA + self.m_Actor.matrix.forward*CHECK_FACTOR)
	local rightHit = self:testLine(posB, posB + self.m_Actor.matrix.forward*CHECK_FACTOR)
	local scoreLeft = self:getLineScore(posA)
	local scoreRight = self:getLineScore(posB)

	if (leftHit and self:testHit(leftHit) == false) and (rightHit and self:testHit(rightHit) == false) then
		return self:getBestLine(posA + self.m_Actor.matrix.right*-(CHECK_FACTOR/2), posB + self.m_Actor.matrix.right*(CHECK_FACTOR/2))
	elseif leftHit == true and scoreRight < scoreLeft then
		outputDebug("using right path")
		return posB
	elseif rightHit == true and scoreLeft < scoreRight then
		outputDebug("using left path")
		return posA
	end

	if leftHit == true and (scoreRight - scoreLeft) <= 5 then
		outputDebug("using right path")
		return posB
	else
		return posA
	end
	if rightHit == true and (scoreRight - scoreLeft) <= 5 then
		outputDebug("using right path")
		return posB
	else
		return posA
	end

	--[[
	if scoreA == scoreB then -- should never happen => RANDOM! :>
		if chance(50) then
			return posA
		else
			return posB
		end
	elseif scoreA < scoreB then -- lineA is better
		return posA
	elseif scoreA > scoreB then -- lineB is better
		return posB
	end
	--]]
end

function TaskMove:updateByRemote(package)

end
