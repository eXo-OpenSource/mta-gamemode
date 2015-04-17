-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/AI/ShopActor.lua
-- *  PURPOSE:     Shop actor class
-- *
-- ****************************************************************************
ShopActor = inherit(Actor)

function ShopActor:constructor()
    self:setModel(155)
    self:giveWeapon(23, 999999999, true)

    -- Start tasks
    self:startPrimaryTask(TaskGuard)
    self:startSecondaryTask(TaskWaitForGettingTargetted)
end

function ShopActor:getIdleTask()
    return TaskWaitForGettingTargetted
end

--[[
Behavior:
This actor behaves similar to GuardActor, but is less agressive and tends to escape after shooting a few times

]]
