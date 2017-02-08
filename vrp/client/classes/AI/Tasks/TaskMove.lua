-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Tasks/TaskMove.lua
-- *  PURPOSE:     Shoot target task class
-- *
-- ****************************************************************************
TaskMove = inherit(Task)

function TaskMove:constructor(actor, actorSyncer, targetPosition)
	self.m_Syncer = actorSyncer
	self.m_TargetPosition = normaliseVector(targetPosition)

	outputDebug(("MoveActor:constructor - target: %s - syncer: %s (%s) (isSyncer: %s)"):format(tostring(self.m_TargetPosition), tostring(self.m_Syncer), self.m_Syncer:getName(), tostring(self:isSyncer())))
end

function TaskMove:destructor()

end

function TaskMove:getId()
	return Tasks.TASK_MOVE
end

function TaskMove:update()

end

function TaskMove:isSyncer()
	return self.m_Syncer == localPlayer
end
