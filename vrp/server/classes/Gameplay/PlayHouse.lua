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
end


function PlayHouse:destructor() 

end

function PlayHouse:Event_requestTimeWeather() 
    local weather = getWeather() 
    local hour, time  = getTime()
    client:triggerEvent("PlayHouse:resetWeatherTime", hour, time, weather)
end

