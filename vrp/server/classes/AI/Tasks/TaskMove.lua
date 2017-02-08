-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/Tasks/TaskMove.lua
-- *  PURPOSE:     Shoot target task class
-- *
-- ****************************************************************************
TaskMove = inherit(Task)

function TaskMove:constructor(actor, actorSyncer, targetPosition)
	self.m_Syncer = actorSyncer
	self.m_TargetPosition = targetPosition
end

function TaskMove:destructor()

end

function TaskMove:getId()
    return Tasks.TASK_MOVE
end

function TaskMove:hasClientScript()
    return true
end

function TaskMove:getClientParameter()
    return {self.m_Syncer, serialiseVector(self.m_TargetPosition)}
end


addEvent("someEVENT", true)
addEventHandler("someEVENT", root,
    function()
        if not instanceof(source, Actor) then
            return
        end
    end
)
