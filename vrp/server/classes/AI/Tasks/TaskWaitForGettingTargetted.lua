-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/Tasks/TaskWaitForGettingTargetted.lua
-- *  PURPOSE:     Task that waits for getting targetted by a potential attacker
-- *
-- ****************************************************************************
TaskWaitForGettingTargetted = inherit(Task)

function TaskWaitForGettingTargetted:constructor(actor)
	self.m_onPlayerTarget = bind(self.Event_OnPlayerTarget, self)
	addEventHandler("onPlayerTarget", actor, self.m_onPlayerTarget)
end

function TaskWaitForGettingTargetted:destructor()
	removeEventHandler("onPlayerTarget", self.m_Actor, self.m_onPlayerTarget)
    setPedAnimation(self.m_Actor, nil)
end

function TaskWaitForGettingTargetted.Event_OnPlayerTarget()
	if targetElement and getElementType(targetElement) == "ped" and getPedWeapon(source) ~= 0 and instanceof(targetElement, Actor) then
		local task = targetElement:getTaskById(TaskWaitForGettingTargetted.getId())
		if task then
			setPedAnimation(targetElement, "ped", "handsup", -1, false)
		end
	end
end

function TaskWaitForGettingTargetted:getId()
    return Tasks.TASK_GETTING_TARGETTED
end

function TaskWaitForGettingTargetted:hasClientScript()
    return false
end
