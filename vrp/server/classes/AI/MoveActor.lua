-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/MoveActor.lua
-- *  PURPOSE:     (Area-)Defend actor class
-- *
-- ****************************************************************************
MoveActor = inherit(Actor)

function MoveActor:constructor(actorSyncer, targetPosition)
	outputDebug(("MoveActor:constructor - target: %s - syncer: %s (%s)"):format(tostring(targetPosition), tostring(actorSyncer), actorSyncer:getName()))

	self.m_Syncer = actorSyncer
	self.m_TargetPosition = targetPosition

    -- Start task
    self:start()
end

function MoveActor:start()
	self:startPrimaryTask(TaskMove, self:getSyncer(), self:getTargetPosition())
end

function MoveActor:getTargetPosition()
	return self.m_TargetPosition
end

function MoveActor:getSyncer()
	return self.m_Syncer
end
