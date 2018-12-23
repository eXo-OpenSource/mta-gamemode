-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Plane.lua
-- *  PURPOSE:     Plane Client Class
-- *
-- ****************************************************************************

PlaneClient = inherit(Object)
addRemoteEvents{"triggerClientPlaneDestroySmoke", "addClientPlaneStreamInHandler"}

function PlaneClient:constructor(plane, pilot, accident)
    self.m_Plane = plane
    self.m_Pilot = pilot
    self.m_Accident = accident

    self.m_StreamInBind = bind(self.onStreamIn, self)
    self.m_SmokeBind = bind(self.createDestroySmoke, self)

    addEventHandler("onClientElementStreamIn", plane, self.m_StreamInBind)
    addEventHandler("triggerClientPlaneDestroySmoke", root, self.m_SmokeBind)
end

function PlaneClient:destructor()
    removeEventHandler("onClientElementStreamIn", plane, self.m_StreamInBind)
    removeEventHandler("triggerClientPlaneDestroySmoke", root, self.m_SmokeBind)
end

function PlaneClient:onStreamIn()
    if self.m_Plane and self.m_Pilot then
        triggerServerEvent("warpPilotIntoPlane", localPlayer, self.m_Accident)
    end
end

function PlaneClient:createDestroySmoke()
    local smokeTable = {}
    local smokeIndex = 0
    local planePos = self.m_Plane:getPosition()
    local forwardVector = self.m_Plane.matrix.forward
    local rightVector = self.m_Plane.matrix.right
    local width = PlaneSizeTable[self.m_Plane:getModel()][1]
    local height = PlaneSizeTable[self.m_Plane:getModel()][2]
    for i = -width, width, 5 do
        for j = -height, height, 5 do
            smokeIndex = smokeIndex + 1
            smokeTable[smokeIndex] = Effect("prt_smoke_huge", planePos.x + (rightVector.x * i) + (forwardVector.x * j), planePos.y + (rightVector.y * i) + (forwardVector.y * j), planePos.z, 0, 0, 0, 200)
        end
    end
    Timer(
        function()
            for i = 1, #smokeTable do
                smokeTable[i]:setDensity(0)
            end
        end
    , 10000, 1)
    Timer(
        function()
            for i = 1, #smokeTable do
                smokeTable[i]:destroy()
            end
        end
    , 30000, 1)
end

