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
end

function PlaneManager:destructor()
    
end

function PlaneManager:createRoute(Accident)
    if Accident == true then
        local accidentRandom = math.random(1, #PlaneFlightRoutes[true])
        local table = PlaneFlightRoutes[true][accidentRandom]
        self.m_PlaneAccidentInstance = PlaneAccident:new(unpack(table)):setAccidentPlane(table[8], table[9], table[10], table[11], table[12], table[13], table[14], table[15], table[16], table[17], table[18], table[19], table[20])
    else
        local flightRandom = math.random(1, #PlaneFlightRoutes[false])
        self.m_PlaneInstance = AmbientPlane:new(unpack(PlaneFlightRoutes[false][flightRandom]))
        Timer(
            function()
                self.m_PlaneInstance:delete()
            end
        , PlaneFlightRoutes[false][flightRandom][8], 1)
    end
end

function PlaneManager:endAccident()
    if self.m_PlaneAccidentInstance then
        self.m_PlaneAccidentInstance:delete()
    end
end