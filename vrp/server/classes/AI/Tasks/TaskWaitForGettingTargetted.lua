-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/Tasks/TaskWaitForGettingTargetted.lua
-- *  PURPOSE:     Task that waits for getting targetted by a potential attacker
-- *
-- ****************************************************************************
TaskWaitForGettingTargetted = inherit(Task)

function TaskWaitForGettingTargetted:constructor(actor)

end

function TaskWaitForGettingTargetted:destructor()
    setPedAnimation(self.m_Actor, nil)
end

function TaskWaitForGettingTargetted:getId()
    return Tasks.TASK_GETTING_TARGETTED
end

function TaskWaitForGettingTargetted:hasClientScript()
    return false
end

function TaskWaitForGettingTargetted:Actor_GettingTargetted(attacker)
    setPedAnimation(self.m_Actor, "ped", "handsup", -1, false)
end

addEventHandler("onPlayerTarget", root,
    function(targetElement)
        if targetElement and getElementType(targetElement) == "ped" and getPedWeapon(source) ~= 0 and instanceof(targetElement, Actor) then -- Todo: Sometimes Error: classlib.lua:139 - Cannot get the superclass of this element
            local task = targetElement:getTaskById(TaskWaitForGettingTargetted.getId())
            if task then
                task:Actor_GettingTargetted(source)
            end
        end
    end
)
