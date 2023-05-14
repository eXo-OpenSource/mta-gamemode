-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/PlaneManager.lua
-- *  PURPOSE:     Plane Manager Client Class
-- *
-- ****************************************************************************

PlaneManager = inherit(Singleton)

function PlaneManager:constructor()
    addRemoteEvents{"instanciatePlane", "deletePlaneInstance"}
    addEventHandler("instanciatePlane", root, bind(self.instanciatePlane, self))
    addEventHandler("deletePlaneInstance", root, bind(self.deletePlaneInstance, self)) 
    self.m_PlaneTable = {}
end

function PlaneManager:instanciatePlane(plane, pilot, accident)
    if accident == true then
        self.m_PlaneAccidentInstance = PlaneClient:new(plane, pilot, true)
    else
        self.m_PlaneInstance = PlaneClient:new(plane, pilot, false)
    end
end

function PlaneManager:deletePlaneInstance(accident)
    if accident then
        if self.m_PlaneAccidentInstance then
            delete(self.m_PlaneAccidentInstance)
            self.m_PlaneAccidentInstance = nil
        end
    else
        if self.m_PlaneInstance then
            delete(self.m_PlaneInstance)
            self.m_PlaneInstance = nil
        end
    end
end