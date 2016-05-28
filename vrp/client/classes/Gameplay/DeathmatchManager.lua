-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Deathmatch/DeathmatchManager.lua
-- *  PURPOSE:     DeathmatchManager
-- *
-- ****************************************************************************

DeathmatchManager = inherit(Singleton)

function DeathmatchManager:constructor()
	-- Zombie Survival
	local market = createObject ( 3863, -32.4, 1377.8, 9.3, 0, 0, 274 )
	local sign = createObject ( 3264, -33.5, 1374.9, 8.2, 0, 0, 274 )
	local shader = dxCreateShader("files/shader/texreplace.fx" )

	local texture = dxCreateTexture("files/images/Textures/ZombieSurvival.png" )
	dxSetShaderValue(shader,"gTexture",texture)
	engineApplyShaderToWorldTexture(shader, "sign_tresspass1", sign)

	-- Sniper Game
	local market = createObject ( 3863, -531.09998, 1972.7, 60.8, 0, 0, 156 )
	local sign = createObject ( 3264, -534.09998, 1975.4, 59.5, 0, 0, 142 )
	local texture = dxCreateTexture("files/images/Textures/SniperGame.png" )
	dxSetShaderValue(shader,"gTexture",texture)
	engineApplyShaderToWorldTexture(shader, "sign_tresspass1", sign)

end

addEvent("addPedDamageHandler", true)
addEventHandler("addPedDamageHandler", root, function(ped)
	addEventHandler("onClientPedDamage", ped,
	function(attacker, weapon, bodypart)
		if attacker == localPlayer and weapon == 34 then
			triggerServerEvent("SniperGame:onPedDamage", localPlayer, ped, bodypart)
		end
		cancelEvent()
	end)
end)
