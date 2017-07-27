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
	createObject ( 3863, -32.4, 1377.8, 9.3, 0, 0, 274 )
	self:addSign(Vector3(-33.5, 1374.9, 8.2), 274, "files/images/Textures/ZombieSurvival.png")

	-- Sniper Game
	createObject ( 3863, -531.09998, 1972.7, 60.8, 0, 0, 156 )
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


local deathScreen = {}

function deathScreen.onDeath(killer, gui)
	if not deathScreen.state then
		deathScreen.state = true
		setGameSpeed(0.3)
		playSound("files/audio/wasted.mp3")
		deathScreen.sCount = getTickCount()
		deathScreen.eCount = deathScreen.sCount + 1000
		if killer and killer ~= localPlayer and killer ~= "Zombie" then
			deathScreen.killerName = getPlayerName(killer).." pulverized you"
		elseif killer == "Zombie" then
			deathScreen.killerName = "Zombie-Kill"
		else
			deathScreen.killerName = "Suicide..."
		end

		addEventHandler("onClientRender",root,deathScreen.runDeathAnim)

		-- Hide HUD, Chat, ...
		HUDUI:getSingleton():hide()
		if gui then
			DeathmatchGUI:getSingleton():hide()
		end
		showChat(false)

		setTimer(function()
			removeEventHandler("onClientRender",root,deathScreen.runDeathAnim)
			setGameSpeed(1)
			deathScreen.state = false

			HUDUI:getSingleton():show()
			if gui then
				DeathmatchGUI:getSingleton():show()
			end
			showChat(true)
		end,9000,1)
	else
		setTimer(function() deathScreen.onDeath(killer) end, 5000, 1)
	end
end

function deathScreen.runDeathAnim()
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD/deathScreen") end
	local now = getTickCount()
	local elapsedTime = now - deathScreen.sCount
	local duration = deathScreen.eCount  - deathScreen.sCount
	local prog = elapsedTime / duration

	deathScreen["line_width"] = interpolateBetween(0,0,0,screenWidth*1,0,0,prog,"Linear")
	deathScreen["line_height"] = interpolateBetween(screenHeight*0.3,0,0,screenHeight*0.14,0,0,prog,"Linear")

	deathScreen["line_alpha"] = interpolateBetween(0,0,0,150,0,0,prog,"Linear")
	deathScreen["rec_alpha"] = interpolateBetween(0,0,0,255,0,0,prog,"OutQuad",10000)

	deathScreen["line_r"],deathScreen["line_b"],deathScreen["line_g"] = interpolateBetween(255,255,255,255,255,255,prog,"Linear")

	dxDrawImage(0, 0, screenWidth, screenHeight, "files/images/Deathmatch/death_round.png", 0, 0, 0, tocolor(255,255,255,deathScreen["rec_alpha"]))
	dxDrawImage(0, screenHeight*0.4, screenWidth, screenHeight*0.3, "files/images/Deathmatch/death_img.png", 0, 0, 0, tocolor(deathScreen["line_r"], deathScreen["line_b"], deathScreen["line_g"], deathScreen["line_alpha"]))

	dxDrawText("Wasted",screenWidth*0,screenHeight*0.4,screenWidth*1,screenHeight*0.7,tocolor(255,0,0,255),screenWidth/screenHeight*2,"pricedown","center","center")
	dxDrawText(deathScreen.killerName,screenWidth*0,screenHeight*0.525,screenWidth*1,screenHeight*0.7,tocolor(255,255,255,255),screenWidth/screenHeight*1,"pricedown","center","center")
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD/deathScreen", 1, 1) end
end
addEvent("deathmatchStartDeathScreen", true)
addEventHandler("deathmatchStartDeathScreen", root, deathScreen.onDeath)
