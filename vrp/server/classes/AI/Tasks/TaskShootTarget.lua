-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/Tasks/TaskShootTarget.lua
-- *  PURPOSE:     Shoot target task class
-- *
-- ****************************************************************************
TaskShootTarget = inherit(Task)

function TaskShootTarget:constructor(actor, target)
    self.m_Target = target
end

function TaskShootTarget:destructor()

end

function TaskShootTarget:getId()
    return Tasks.TASK_SHOOT_TARGET
end

function TaskShootTarget:hasClientScript()
    return true
end

function TaskShootTarget:getClientParameter()
    return {self.m_Target}
end

function TaskShootTarget:startShooting()
    -- TODO
end

function TaskShootTarget:stopShooting()
    -- TODO
end

addEvent("taskShootTargetTooFarAway", true)
addEventHandler("taskShootTargetTooFarAway", root,
    function()
        if not instanceof(source, Actor) then
            return
        end

        if source:getPrimaryTaskClass() == TaskShootTarget then
            -- Fallback to idle mode
            source:startIdleTask()
        end
    end
)
