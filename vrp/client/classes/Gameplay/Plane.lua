-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Plane.lua
-- *  PURPOSE:     Plane Client Class
-- *
-- ****************************************************************************

addEvent("triggerClientPlaneDestroySmoke", true)
addEventHandler("triggerClientPlaneDestroySmoke", root, 
    function (plane)
        local smokeTable = {}
        local smokeIndex = 0
        local planePos = plane:getPosition()
        local forwardVector = plane.matrix.forward
        local rightVector = plane.matrix.right
        local width = PlaneSizeTable[plane:getModel()][1]
        local height = PlaneSizeTable[plane:getModel()][2]
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
)
