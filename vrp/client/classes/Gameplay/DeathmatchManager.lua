-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Deathmatch/DeathmatchManager.lua
-- *  PURPOSE:     DeathmatchManager
-- *
-- ****************************************************************************

DeathmatchManager = inherit(Singleton)

function DeathmatchManager:constructor()
	local market = createObject ( 3863, -32.4, 1377.8, 9.3, 0, 0, 274 )
	local sign = createObject ( 3264, -33.5, 1374.9, 8.2, 0, 0, 274 )

	local shader = dxCreateShader("files/shader/texreplace.fx" )
	local texture = dxCreateTexture("files/images/Textures/ZombieSurvival.png" )
	dxSetShaderValue(shader,"gTexture",texture)
	engineApplyShaderToWorldTexture(shader, "sign_tresspass1", sign)


end
