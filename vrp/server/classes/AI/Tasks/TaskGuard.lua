-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/Tasks/TaskGuard.lua
-- *  PURPOSE:     Guard task class
-- *
-- ****************************************************************************
TaskGuard = inherit(Task)

function TaskGuard:constructor(actor)

end

function TaskGuard:getId()
    return Tasks.TASK_GUARD
end

function TaskGuard:hasClientScript()
    return true
end

addEvent("taskGuardDamage", true)
addEventHandler("taskGuardDamage", root,
    function(attacker)
        if not instanceof(source, Actor) then
            return
        end

        local actor = source
        if actor:getPrimaryTaskClass() == TaskGuard then
            actor:startPrimaryTask(TaskShootTarget, attacker)
        end
    end
)
