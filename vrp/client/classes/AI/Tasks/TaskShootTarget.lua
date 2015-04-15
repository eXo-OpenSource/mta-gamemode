-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AI/Tasks/TaskShootTarget.lua
-- *  PURPOSE:     Shoot target task class
-- *
-- ****************************************************************************
TaskShootTarget = inherit(Task)
local MAX_SHOOT_DISTANCE = 30

function TaskShootTarget:constructor(actor, target)
    self.m_Target = target
    self.m_ShootTimer = false

    self:startShooting()
end

function TaskShootTarget:destructor()
    self:stopShooting()
end

function TaskShootTarget:getId()
    return Tasks.TASK_SHOOT_TARGET
end

function TaskShootTarget:shootSingleBullet()
    -- Update target
    self.m_Actor:setAimTarget(self.m_Target:getPosition())

    -- Activate fire control for a bit to simulate key presses
    self.m_Actor:setControlState("fire", true)
end

function TaskShootTarget:startShooting()
    if not self.m_ShootTimer then
        -- Shoot single bullets every 200ms (==> 5 bullets/second)
        self:shootSingleBullet()
        self.m_ShootTimer = setTimer(bind(self.shootSingleBullet, self), 200, 0)
    end
end

function TaskShootTarget:stopShooting()
    if self.m_ShootTimer then
        killTimer(self.m_ShootTimer)
        self.m_ShootTimer = false
    end

    self.m_Actor:setControlState("fire", false)
end

function TaskShootTarget:update()
    local actorPosition = self.m_Actor:getPosition()
    local targetPosition = self.m_Target:getPosition()
    self.m_Actor:setRotation(0, 0, findRotation(actorPosition.x, actorPosition.y, targetPosition.x, targetPosition.y))

    -- Stop if target is too far away
    if (actorPosition-targetPosition).length > MAX_SHOOT_DISTANCE then
        triggerServerEvent("taskShootTargetTooFarAway", self.m_Actor)
        self:stopUpdating()
    end
end
