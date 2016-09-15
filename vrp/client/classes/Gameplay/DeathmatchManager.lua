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

	self:addSign(Vector3(-33.5, 1374.9, 8.2), 274, "files/images/Textures/ZombieSurvival.png")

	-- Sniper Game
	local market = createObject ( 3863, -531.09998, 1972.7, 60.8, 0, 0, 156 )
	self:addSign(Vector3(-534.09998, 1975.4, 59.5), 142, "files/images/Textures/SniperGame.png")

end

function DeathmatchManager:addSign(pos, rotZ, image)
	local sign = createObject ( 3264, pos, 0, 0, rotZ )
	local shader = dxCreateShader("files/shader/texreplace.fx")
	dxSetShaderValue(shader,"gTexture", dxCreateTexture(image))
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

addEvent("playZombieCutscene", true)
addEventHandler("playZombieCutscene", root, function()
	if not core:get("Gameplay", "playedZombieCutscene", false) then
		CutscenePlayer:getSingleton():playCutscene("ZombieSurvivalCutscene", function()
			core:set("Gameplay", "playedZombieCutscene", true)
			triggerServerEvent("startZombieSurvival", localPlayer)
			fadeCamera(true)
		end)
	end
end)
