-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/RobableShop.lua
-- *  PURPOSE:     Robable shop class (client)
-- *
-- ****************************************************************************
--RobableShop = inherit(Object)

addEvent("shopRobbed", true)
addEventHandler("shopRobbed", root,
    function(x, y, z)
        -- Play an alarm for 5min
        local sound = Sound3D.create("files/audio/Siren.ogg", x, y, z)

        setTimer(function() sound:destroy() end, 5*60*1000, 1)
    end
)
