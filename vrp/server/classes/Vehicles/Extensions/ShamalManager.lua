-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/ShamalManager.lua
-- *  PURPOSE:     Vehicle Shamal Manager class
-- *
-- ****************************************************************************
ShamalManager = inherit(Singleton)

ShamalManager.Map = {}
ShamalManager.InteriorPositions = {
 [0] = {Vector3(0.81, 35.85, 1199.6), 0},
 [1] = {Vector3(2.57, 35.87, 1199.59), 0},
 [2] = {Vector3(2.86, 29.80, 1199.59), 180},
 [3] = {Vector3(0.61, 28.76, 1199.59), 180},
 [4] = {Vector3(2.84, 28.64, 1199.59), 0},
 [5] = {Vector3(0.61, 27.60, 1199.59), 0},
 [6] = {Vector3(2.88, 26.37, 1199.59), 0},
 [7] = {Vector3(0.57, 25.30, 1199.59), 0},
}

addRemoteEvents{"toggleShamalInterior"}
function ShamalManager:constructor()

    addEventHandler("toggleShamalInterior", root, bind(self.toggleShamalInterior, self))

    Player.getQuitHook():register(
        function(player)
            if player.shamalInterior then
                player.shamalInterior:enterExitInterior(player, "quit")
            end
        end
    )
    core:getStopHook():register(
        function()
            for i, shamal in pairs(ShamalManager.Map) do
                for i, passenger in pairs(shamal.m_Passengers) do
                    shamal:enterExitInterior(passenger, "quit")
                end
            end
        end
    )
end

function ShamalManager:toggleShamalInterior()
    enter = client:getInterior() == 0 and true or false
    source.m_Shamal:enterExitInterior(client, enter)
end