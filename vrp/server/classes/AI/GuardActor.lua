-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/GuardActor.lua
-- *  PURPOSE:     Guard actor class
-- *
-- ****************************************************************************
GuardActor = inherit(Actor)

function GuardActor:constructor()
    self:setModel(71)
    self:giveWeapon(24, 999999999, true)

    -- Start tasks
    self:startIdleTask()
end

function GuardActor:getIdleTask()
    return TaskGuard
end
