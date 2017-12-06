-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************

FerrisGond = inherit(Object)
FerrisGond.Map = {}
FerrisGond.DistToWheel = 11.75
addRemoteEvents{"onFerrisWheelGondClicked"}

function FerrisGond:constructor(wheel, id)
    if not FerrisGond.Map[wheel] then
        FerrisGond.Map[wheel] = {}
    end
    self.m_Wheel = wheel
    self.m_Id = id
    self.m_Offset = (360/FerrisWheelManager.GondAmount * id) + 18
    self.m_ClientEnterHandler = bind(FerrisGond.clientEnterTry, self)
    self:createObject()
end

function FerrisGond:createObject()
    if not self.m_Object then
        local wheel = self.m_Wheel.m_WheelObj
        self.m_Object = createObject(FERRIS_IDS.Gond, self:getAttachedPositionVertical(), wheel.rotation)
        addEventHandler("onFerrisWheelGondClicked", self.m_Object, self.m_ClientEnterHandler)
    end
end

function FerrisGond:update(rot, time, movingState)
    local wheel = self.m_Wheel.m_WheelObj
    self.m_Offset = self.m_Offset - rot
    self.m_Object:move(time, self:getAttachedPositionVertical(), Vector3(0,0,0), movingState)
end

function FerrisGond:clientEnterTry()
    outputDebug(client, self.m_Id)
    if self.m_Wheel.m_MovingState then
        return  client:sendWarning(_("Warte, bis die Gondel anhält!",client))
    end
end


function FerrisGond:getAttachedPositionVertical()
    local wheel = self.m_Wheel.m_WheelObj
    local rot = wheel.rotation
    local angleAttached = rot.x + self.m_Offset
  
    local dx = math.sin(math.rad(angleAttached))* FerrisGond.DistToWheel
    local dy = math.cos(math.rad(angleAttached))* FerrisGond.DistToWheel

    return wheel.matrix:transformPosition(Vector3(0, dx, dy))
end