-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/PlayHouse.lua
-- *  PURPOSE:     PlayHouse class
-- *
-- ****************************************************************************

PlayHouse = inherit(Singleton)

addRemoteEvents{"PlayHouse:requestTimeWeather"}
function PlayHouse:constructor() 
    addEventHandler("PlayHouse:requestTimeWeather", root, bind(self.Event_requestTimeWeather, self))
    
    self.m_EnterCasino = InteriorEnterExit:new(Vector3(-1431.87, -952.25, 200.96), Vector3(467.85, 498.00, 1055.82), 0, 180, 12, 0, 0, 0)

    local antifall = createColCuboid(452.46, 476.06, 1045.81,  120, 60, 40)
    InstantTeleportArea:new(antifall, 12, 0, Vector3(467.85, 498.00, 1055.82))
    

end


function PlayHouse:destructor() 

end

function PlayHouse:Event_requestTimeWeather() 
    local weather = getWeather() 
    local hour, time  = getTime()
    client:triggerEvent("PlayHouse:resetWeatherTime", hour, time, weather)
end

