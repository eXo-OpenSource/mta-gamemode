-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Plane/PlaneManager.lua
-- *  PURPOSE:     Plane Manager Class
-- *
-- ****************************************************************************

PlaneManager = inherit(Singleton)

function PlaneManager:constructor()
    Timer(
        function()
            PlaneManager:createRoute(false)
        end
    , 600000, 0)
    addRemoteEvents{"warpPilotIntoPlane"}
    addEventHandler("warpPilotIntoPlane", root, bind(self.warpPilotIntoPlane, self))
end

function PlaneManager:destructor()
    
end

function PlaneManager:createRoute(Accident)
    if Accident == true then
        if self.m_PlaneAccidentInstance then
            self:endAccident()
        end
        local accidentRandom = math.random(1, #PlaneFlightRoutes[true])
        local table = PlaneFlightRoutes[true][accidentRandom]
        self.m_PlaneAccidentInstance = PlaneAccident:new(unpack(table))
        self.m_PlaneAccidentInstance:setAccidentPlane(table[8], table[9], table[10], table[11], table[12], table[13], table[14], table[15], table[16], table[17], table[18], table[19], table[20])
        triggerClientEvent(root, "instanciatePlane", root, self.m_PlaneAccidentInstance.m_Plane, self.m_PlaneAccidentInstance.m_Pilot, true)
    else
        local flightRandom = math.random(1, #PlaneFlightRoutes[false])
        self.m_PlaneInstance = AmbientPlane:new(unpack(PlaneFlightRoutes[false][flightRandom]))
        triggerClientEvent(root, "instanciatePlane", root, self.m_PlaneInstance.m_Plane, self.m_PlaneInstance.m_Pilot, false)
        Timer(
            function()
                self.m_PlaneInstance:delete()
                triggerClientEvent(root, "deletePlaneInstance", root, false)
            end
        , PlaneFlightRoutes[false][flightRandom][8], 1)
    end
end

function PlaneManager:endAccident()
    if self.m_PlaneAccidentInstance then
        self.m_PlaneAccidentInstance:delete()
    end
end

function PlaneManager:warpPilotIntoPlane(accident)
    if accident then
        if isElement(self.m_PlaneAccidentInstance.m_Plane) and isElement(self.m_PlaneAccidentInstance.m_Pilot) then
            self.m_PlaneAccidentInstance.m_Pilot:warpIntoVehicle(self.m_PlaneAccidentInstance.m_Plane)
        end
    else
        if isElement(self.m_PlaneInstance.m_Plane) and isElement(self.m_PlaneInstance.m_Pilot) then
            self.m_PlaneInstance.m_Pilot:warpIntoVehicle(self.m_PlaneInstance.m_Plane)
        end
    end
end