-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/RobableShop.lua
-- *  PURPOSE:     Robable shop class (client)
-- *
-- ****************************************************************************
RobableShop = inherit(Object)
RobableShop.CrashBreak = false

function RobableShop.onVehicleCrash(veh)
    if source == localPlayer:getOccupiedVehicle() then
		if isElement(veh) and veh:getType() == "vehicle" and veh:getOccupant() then
            local driver = veh:getOccupant()
            if isElement(driver) then
                if RobableShop.CrashBreak == false then
                    triggerServerEvent("robableShopGiveBagFromCrash", localPlayer, driver)
    				RobableShop.CrashBreak = true
    				setTimer(function()
    					RobableShop.CrashBreak = false
    				end,7500,1)
    			end
            end
        end
    end
end

addEvent("shopRobbed", true)
addEventHandler("shopRobbed", root,
    function(x, y, z, dimension)
        -- Play an alarm for 5min
        local sound = Sound3D.create("files/audio/Alarm.mp3", x, y, z, true)
		setSoundVolume(sound, 0.5)
        sound:setDimension(dimension)

        setTimer(function() sound:destroy() end, 5*60*1000, 1)
    end
)

addEvent("robableShopEnableVehicleCollision", true)
addEventHandler("robableShopEnableVehicleCollision", root, function(vehicle)
	removeEventHandler ( "onClientVehicleCollision", vehicle, RobableShop.onVehicleCrash)
    addEventHandler ( "onClientVehicleCollision", vehicle, RobableShop.onVehicleCrash)
end)

addEvent("robableShopDisableVehicleCollision", true)
addEventHandler("robableShopDisableVehicleCollision", root, function(vehicle)
    removeEventHandler ( "onClientVehicleCollision", vehicle, RobableShop.onVehicleCrash)
end)
