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
    self.m_Actor = actor

    addEventHandler("onClientPedDamage", actor, self.m_DamageFunc)
end

function TaskGuard:getId()
    return Tasks.TASK_GUARD
end

function TaskGuard:Actor_Damage(attacker, weapon, bodypart, loss)
    -- Tell server that we've been damaged
    triggerServerEvent("taskGuardDamage", self.m_Actor, attacker)
end
