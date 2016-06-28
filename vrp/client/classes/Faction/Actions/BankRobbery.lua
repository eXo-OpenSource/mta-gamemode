-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Factions/BankRobbery.lua
-- *  PURPOSE:     Bank class (client)
-- *
-- ****************************************************************************

addEvent("bankAlarm", true)
addEventHandler("bankAlarm", root,
    function(x, y, z)
        -- Play an alarm for 5min
        banksound = Sound3D.create("files/audio/Alarm.mp3", x, y, z, true)
		Sound3D.setMaxDistance(banksound, 300)
    end
)

addEvent("bankAlarmStop", true)
addEventHandler("bankAlarmStop", root,
    function()
        if isElement(banksound) then banksound:destroy() end
    end
)
