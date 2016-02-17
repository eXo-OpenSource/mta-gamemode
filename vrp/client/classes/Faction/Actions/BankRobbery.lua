-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Factions/BankRobbery.lua
-- *  PURPOSE:     Bank class (client)
-- *
-- ****************************************************************************
--RobableShop = inherit(Object)

addEvent("bankAlarm", true)
addEventHandler("bankAlarm", root,
    function(x, y, z)
        -- Play an alarm for 5min
        local sound = Sound3D.create("files/audio/Alarm.mp3", x, y, z, true)
		Sound3D.setMaxDistance(sound, 300)

        setTimer(function() sound:destroy() end, 5*60*1000, 1)
    end
)
