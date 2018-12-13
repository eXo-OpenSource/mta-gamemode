-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Plane/Plane.lua
-- *  PURPOSE:     Plane Class
-- *
-- ****************************************************************************

Plane = inherit(Object)

Plane.constructor = pure_virtual
function Plane:virtual_constructor(id, startX, startY, startZ, endX, endY, endZ, flyingTime, ambient)
    local rotation = findRotation(startX, startY, endX, endY)

    self.m_Plane = TemporaryVehicle.create(id, startX, startY, startZ, rotation)
    self.m_Plane:setDamageProof(true)

    self.m_Object = createObject(2710, startX, startY, startZ, 0, 0, rotation)
    self.m_Object:setAlpha(0)
    self.m_Plane:attach(self.m_Object, 0, 0, 0, 0, 0, 0)
    self.m_Object:move(flyingTime, endX, endY, endZ)

    self.m_Pilot = Ped(61, Vector3(startX, startY, startZ+3))
    self.m_Pilot:warpIntoVehicle(self.m_Plane)
end

function Plane:virtual_destructor()
    if isElement(self.m_Plane) then
        self.m_Plane:destroy()
    end
    if isElement(self.m_Object) then
        self.m_Object:destroy()
    end
    if isElement(self.m_Pilot) then
        self.m_Pilot:destroy()
    end
end
