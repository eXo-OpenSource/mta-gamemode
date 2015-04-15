-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Tasks/TaskGuard.lua
-- *  PURPOSE:     Guard task class
-- *
-- ****************************************************************************
TaskGuard = inherit(Task)

function TaskGuard:constructor(actor)
    self.m_DamageFunc = bind(self.Actor_Damage, self)

    addEventHandler("onClientPedDamage", actor, self.m_DamageFunc)
end

function TaskGuard:getId()
    return Tasks.TASK_GUARD
end

function TaskGuard:Actor_Damage(attacker, weapon, bodypart, loss)
    if attacker and isElement(attacker) and getElementType(attacker) == "player" then
        -- Tell server that we've been damaged
        triggerServerEvent("taskGuardDamage", self.m_Actor, attacker)
    end
end
