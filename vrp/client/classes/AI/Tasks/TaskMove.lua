-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Tasks/TaskMove.lua
-- *  PURPOSE:     Shoot target task class
-- *
-- ****************************************************************************
TaskMove = inherit(Task)
local CHECK_FACTOR = 1.2
local TARGET_MIN_DIST = 0.8

function TaskMove:constructor(actor, actorSyncer, targetPosition)
	self.m_Syncer = actorSyncer
	self.m_TargetPosition = normaliseVector(targetPosition)
	self.m_Actor:setControlState("forwards", true)
	--self.m_Actor:setControlState("sprint", true)
	self.m_State = "moving"

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
	if isElementStreamedIn(self.m_Actor) then
		if self:isSyncer() then
			local actorPosition = self.m_Actor:getPosition()
			local hit, hitX, hitY, hitZ = self:testLine()
			local hit2 = self:testLine(self.m_Actor:getPosition() + self.m_Actor.matrix.up*-0.7, self.m_Actor:getPosition() + self.m_Actor.matrix.up*-0.7 + self.m_Actor.matrix.forward*CHECK_FACTOR)
			local hit3 = self:testLine(self.m_Actor:getPosition() + self.m_Actor.matrix.up*1,  self.m_Actor:getPosition() + self.m_Actor.matrix.up*1  + self.m_Actor.matrix.forward*CHECK_FACTOR)
			local hitPosition = Vector3(hitX, hitY, hitZ)

			if hit or hit2 or hit3 then
				local isJumpAble = self:isJumpAble()
				if isJumpAble == true and self.m_State == "moving" then
					self.m_Actor:setControlState("forwards", false)
					self.m_Actor:setControlState("jump", true)
					self.m_State = "jumping"

					self.m_LastJump = getTickCount()
				elseif (isJumpAble == false and self.m_State == "moving") or (self.m_State == "jumping" and getTickCount() - self.m_LastJump > 3000) then -- if we tried to jump but didn work
					self.m_Actor:setControlState("jump", false)

					local startLeft = actorPosition + self.m_Actor.matrix.right*-CHECK_FACTOR
					local startRight = actorPosition + self.m_Actor.matrix.right*CHECK_FACTOR
					local bestLine = self:getBestLine(startLeft, startRight)
					self:setTemporaryTarget(bestLine)

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
					if self.m_State == "jumping" then
						self.m_Actor:setControlState("jump", false)
					end
					self.m_Actor:setControlState("forwards", true)
					self.m_State = "moving"

					self.m_Actor:setRotation(Vector3(0, 0, findRotation(actorPosition.x, actorPosition.y, self.m_TargetPosition.x, self.m_TargetPosition.y)))
				else
					-- Target reached
					self.m_Actor:setControlState("forwards", false)
					--self.m_State = "idle"

					if self.m_IsTemporaryTarget then
						self:resetTarget()
					end
				end
			end

			if DEBUG then
				dxDrawLine3D(self.m_Actor:getPosition() + self.m_Actor.matrix.up*1, self.m_Actor:getPosition() + self.m_Actor.matrix.up*1.2, self.m_State == "moving" and Color.Green or self.m_State == "jumping" and Color.LightBlue or self.m_State == "idle" and Color.Red)

				dxDrawLine3D(self.m_Actor:getPosition(), self.m_Actor:getPosition() + self.m_Actor.matrix.forward*CHECK_FACTOR, hit and Color.Red or Color.Green, 1)
				dxDrawLine3D(self.m_Actor:getPosition() + self.m_Actor.matrix.up*-0.7, self.m_Actor:getPosition() + self.m_Actor.matrix.up*-0.7 + self.m_Actor.matrix.forward*CHECK_FACTOR, hit2 and Color.Red or Color.Green, 1)
				dxDrawLine3D(self.m_Actor:getPosition() + self.m_Actor.matrix.up*0.7,  self.m_Actor:getPosition() + self.m_Actor.matrix.up*0.7  + self.m_Actor.matrix.forward*CHECK_FACTOR, hit3 and Color.Red or Color.Green, 1)
			end
		end

		if DEBUG then
			dxDrawLine3D(Vector3(self.m_TargetPosition.x, self.m_TargetPosition.y, self.m_TargetPosition.z - 10), Vector3(self.m_TargetPosition.x, self.m_TargetPosition.y, self.m_TargetPosition.z + 10), Color.Blue, 3)
		end
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

function TaskMove:isJumpAble()
	local matrix = self.m_Actor.matrix
	local topHit = self:testLine(self.m_Actor:getPosition() + matrix.up*2, self.m_Actor:getPosition() + matrix.forward*(CHECK_FACTOR+0.2) + matrix.up*2)
	if DEBUG then
		dxDrawLine3D(self.m_Actor:getPosition() + matrix.up*2, self.m_Actor:getPosition() + matrix.forward*(CHECK_FACTOR+0.2) + matrix.up*2, topHit and Color.Red or Color.Green)
	end
	return not topHit
end

function TaskMove:getBestLine(posA, posB) -- lightweight heuristic
	local leftHit  = self:testLine(posA, posA + self.m_Actor.matrix.forward*CHECK_FACTOR)
	local rightHit = self:testLine(posB, posB + self.m_Actor.matrix.forward*CHECK_FACTOR)
	local scoreLeft = self:getLineScore(posA)
	local scoreRight = self:getLineScore(posB)

	if (leftHit and self:isJumpAble(posA) == false) and (rightHit and self:isJumpAble(posB) == false) then
		return self:getBestLine(posA + self.m_Actor.matrix.right*-(CHECK_FACTOR/2), posB + self.m_Actor.matrix.right*(CHECK_FACTOR/2))
	elseif (leftHit and self:isJumpAble(posA) == true) and scoreLeft < scoreRight then
		outputDebug("using left path")
		return posA
	elseif (rightHit and self:isJumpAble(posB) == true) and scoreRight < scoreLeft then
		outputDebug("using right path")
		return posB
	elseif (leftHit and self:isJumpAble(posA) == false) and scoreRight < scoreLeft then
		outputDebug("using right path")
		return posB
	elseif (rightHit and self:isJumpAble(posB) == false) and scoreLeft < scoreRight then
		outputDebug("using left path")
		return posA
	end

	if leftHit == true and (scoreRight - scoreLeft) <= 2.5 then
		outputDebug("using right path")
		return posB
	else
		return posA
	end
	if rightHit == true and (scoreRight - scoreLeft) <= 2.5 then
		outputDebug("using right path")
		return posB
	else
		return posA
	end
end

function TaskMove:updateByRemote(package)

end
