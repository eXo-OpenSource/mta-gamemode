-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************

FerrisWheel = inherit(Object)

function FerrisWheel:constructor(pos, rotz)
    self.m_BaseObj = createObject(FERRIS_IDS.Base, pos, Vector3(0, 0, rotz))
    self.m_WheelObj = createObject(FERRIS_IDS.Wheel, pos + Vector3(0, 0, 2.2), Vector3(0, 0, rotz+90))
    self.m_AntiAFKCol = createColSphere(pos + Vector3(0, 0, 14.5), 3)
    addEventHandler("onColShapeHit", self.m_AntiAFKCol, function(hit)
        if isElement(hit) and getElementType(hit) == "player" then
            self:setPlayerToExitPosition(hit, 1)
        end
    end)
    
    self.m_BaseObj:setDoubleSided(true)
    self.m_WheelObj:setDoubleSided(true)
    self.m_RotSinceLastStop = 0
    
    self:addGonds()
end

function FerrisWheel:addGonds()
    self.m_Gonds = {}
    for i = 1, FerrisWheelManager.GondAmount do
        self.m_Gonds[i] = FerrisGond:new(self, i)
    end
end

function FerrisWheel:update()
    local rot = FerrisWheelManager.UpdateInterval/1000*FerrisWheelManager.DegreesPerSecond

    if self.m_MovingState == "OutQuad" then
        return self:setPaused()
    end

    if self.m_RotSinceLastStop == 0 then
        self.m_MovingState = "InQuad"
    elseif self.m_RotSinceLastStop >= FerrisWheelManager.RotationPerRound then
        self.m_MovingState = "OutQuad"
    else
        local prev = self.m_MovingState
        self.m_MovingState = "Linear"
        if prev == "InQuad" then return false end -- jump over to compensate double time on startup
    end

    self.m_RotSinceLastStop = self.m_RotSinceLastStop + rot
    local time = FerrisWheelManager.UpdateInterval * (self.m_MovingState == "Linear" and 1 or 2)
    self.m_WheelObj:move(time, self.m_WheelObj.position, Vector3(rot, 0, 0), self.m_MovingState)
    for i, v in pairs(self.m_Gonds) do
        v:update(rot, time, self.m_MovingState)
    end
end

function FerrisWheel:setPlayerToExitPosition(player, gondId)
    player:setPosition(self.m_BaseObj.position + self.m_BaseObj.matrix.right*(gondId % 2 == 0 and -3.5 or 3.5) + self.m_BaseObj.matrix.forward*(5) + self.m_BaseObj.matrix.up*(-13))
    player:setRotation(self.m_BaseObj.rotation)
end

function FerrisWheel:setPaused()
    self.m_MovingState = false
    self.m_RotSinceLastStop = 0
    FerrisWheelManager:getSingleton():unregisterUpdate(self)
    local rot = self.m_WheelObj.rotation.x
    for i,v in pairs(self.m_Gonds) do
        if isRotationEqual(v.m_Offset, 180, 20) then
            v:forceRemovePlayers()
        end
    end
    if self:isWheelInUse() then
        self:startMoving()
    end
end

function FerrisWheel:startMoving()
    self.m_PauseTimer = setTimer(function()
        FerrisWheelManager:getSingleton():registerUpdate(self)
    end, FerrisWheelManager.PauseInterval, 1)
end

function FerrisWheel:abortMovingStart()
    if isTimer(self.m_PauseTimer) then
        killTimer(self.m_PauseTimer)
    end
end

function FerrisWheel:isWheelInUse()
    local isWheelInUse = false
    for k, gond in ipairs(self.m_Gonds) do
        for k, v in pairs(gond.m_Occupants) do
            isWheelInUse = true
        end
    end
    return isWheelInUse
end