-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/PlayerManager.lua
-- *  PURPOSE:     Player manager class
-- *
-- ****************************************************************************
PlayerManager = inherit(Singleton)
addRemoteEvents{"playerReady", "playerSendMoney", "requestPointsToKarma", "requestWeaponLevelUp", "requestVehicleLevelUp",
"requestSkinLevelUp", "requestJobLevelUp", "setPhoneStatus", "toggleAFK", "startAnimation", "passwordChange",
"requestGunBoxData", "gunBoxAddWeapon", "gunBoxTakeWeapon","Event_ClientNotifyWasted", "Event_getIDCardData",
"startWeaponLevelTraining","switchSpawnWithFactionSkin","Event_setPlayerWasted", "Event_moveToJail", "onClientRequestTime", "playerDecreaseAlcoholLevel",
"premiumOpenVehiclesList", "premiumTakeVehicle","destroyPlayerWastedPed","onDeathPedWasted", "toggleSeatBelt", "onPlayerTryGateOpen", "onPlayerUpdateSpawnLocation", "attachPlayerToVehicle"}

function PlayerManager:constructor()
	self.m_WastedHook = Hook:new()
	self.m_QuitHook = Hook:new()
	self.m_AFKHook = Hook:new()
	self.m_ReadyPlayers = {}
	self.m_QuitPlayers = {}

	-- Register events
	addEventHandler("onPlayerConnect", root, bind(self.playerConnect, self))
	addEventHandler("onPlayerJoin", root, bind(self.playerJoin, self))
	addEventHandler("onPlayerQuit", root, bind(self.playerQuit, self))
	addEventHandler("onPlayerCommand", root,  bind(self.playerCommand, self))
	addEventHandler("Event_ClientNotifyWasted", root, bind(self.playerWasted, self))
	addEventHandler("onPlayerChat", root, bind(self.playerChat, self))
	addEventHandler("onPlayerChangeNick", root, function() cancelEvent() end)
	addEventHandler("playerReady", root, bind(self.Event_playerReady, self))
	addEventHandler("playerSendMoney", root, bind(self.Event_playerSendMoney, self))
	addEventHandler("requestPointsToKarma", root, bind(self.Event_requestPointsToKarma, self))
	addEventHandler("requestWeaponLevelUp", root, bind(self.Event_requestWeaponLevelUp, self))
	addEventHandler("requestVehicleLevelUp", root, bind(self.Event_requestVehicleLevelUp, self))
	addEventHandler("requestSkinLevelUp", root, bind(self.Event_requestSkinLevelUp, self))
	addEventHandler("requestJobLevelUp", root, bind(self.Event_requestJobLevelUp, self))
	addEventHandler("playerRequestTrading", root, bind(self.Event_playerRequestTrading, self))
	addEventHandler("setPhoneStatus", root, bind(self.Event_setPhoneStatus, self))
	addEventHandler("toggleAFK", root, bind(self.Event_toggleAFK, self))
	addEventHandler("startAnimation", root, bind(self.Event_startAnimation, self))
	addEventHandler("passwordChange", root, bind(self.Event_passwordChange, self))
	addEventHandler("requestGunBoxData", root, bind(self.Event_requestGunBoxData, self))
	addEventHandler("gunBoxAddWeapon", root, bind(self.Event_gunBoxAddWeapon, self))
	addEventHandler("gunBoxTakeWeapon", root, bind(self.Event_gunBoxTakeWeapon, self))
	addEventHandler("Event_getIDCardData", root, bind(self.Event_getIDCardData, self))
	addEventHandler("startWeaponLevelTraining", root, bind(self.Event_weaponLevelTraining, self))
	addEventHandler("switchSpawnWithFactionSkin", root, bind(self.Event_switchSpawnWithFaction, self))
	addEventHandler("Event_setPlayerWasted", root, bind(self.Event_setPlayerWasted, self))
	addEventHandler("Event_moveToJail", root, bind(self.Event_moveToJail, self))
	addEventHandler("onClientRequestTime",root, bind(self.Event_ClientRequestTime, self))
	addEventHandler("playerDecreaseAlcoholLevel",root, bind(self.Event_DecreaseAlcoholLevel, self))
	addEventHandler("premiumOpenVehiclesList",root, bind(self.Event_PremiumOpenVehiclesList, self))
	addEventHandler("premiumTakeVehicle",root, bind(self.Event_PremiumTakeVehicle, self))
	addEventHandler("destroyPlayerWastedPed",root,bind(self.Event_OnDeadDoubleDestroy, self))
	addEventHandler("onDeathPedWasted", root, bind(self.Event_OnDeathPedWasted, self))
	addEventHandler("onPlayerWeaponFire", root, bind(self.Event_OnWeaponFire, self))
	addEventHandler("onPlayerUpdateSpawnLocation", root, bind(self.Event_OnUpdateSpawnLocation, self))
	addEventHandler("attachPlayerToVehicle", root, bind(self.Event_AttachToVehicle, self))

	addEventHandler("onPlayerPrivateMessage", root, function()
		cancelEvent()
	end)

	addEventHandler("toggleSeatBelt", root, bind(self.Event_onToggleSeatBelt, self))
	addEventHandler("onPlayerTryGateOpen",root, bind(self.Event_onRequestGateOpen, self))
	addCommandHandler("s",bind(self.Command_playerScream, self))
	addCommandHandler("l",bind(self.Command_playerWhisper, self))
	addCommandHandler("ooc",bind(self.Command_playerOOC, self))
	addCommandHandler("shrug",bind(self.Command_playerShrug, self))
	addCommandHandler("BeamtenChat", Player.staticStateFactionChatHandler)
	addCommandHandler("g", Player.staticStateFactionChatHandler)
	addCommandHandler("Fraktion", Player.staticFactionChatHandler,false)
	addCommandHandler("t", Player.staticFactionChatHandler)
	addCommandHandler("Unternehmen", Player.staticCompanyChatHandler,false)
	addCommandHandler("u", Player.staticCompanyChatHandler)
	addCommandHandler("Gruppe", Player.staticGroupChatHandler,false)
	addCommandHandler("f", Player.staticGroupChatHandler)
	addCommandHandler("b", Player.staticFactionAllianceChatHandler)
	addCommandHandler("BündnisChat", Player.staticFactionAllianceChatHandler)

	self.m_PaydayPulse = TimedPulse:new(60000)
	self.m_PaydayPulse:registerHandler(bind(self.checkPayday, self))

	self.m_SyncPulse = TimedPulse:new(500)
	self.m_SyncPulse:registerHandler(bind(PlayerManager.updatePlayerSync, self))

	self.m_AnimationStopFunc = bind(self.stopAnimation, self)
end

function PlayerManager:Event_onRequestGateOpen()
	if client then
		if Gate.Map then
			local obj
			for i = 1,#Gate.Map do
				obj = Gate.Map[i]
				local int, dim = obj:getInterior(), obj:getDimension()
				if int == client:getInterior() and dim == client:getDimension() then
					if obj:getPosition() and client:getPosition() then
						if getDistanceBetweenPoints3D(obj:getPosition(), client:getPosition() ) <= 15 then
							local instance = obj.m_Super
							if instance and obj.m_Id == 1 then
								instance:Event_onColShapeHit(client, true)
							end
						end
					end
				end
			end
		end
	end
end

function PlayerManager:Event_OnWeaponFire(weapon, ex, ey, ez, hE, sx, sy, sz)
	if getElementDimension(source) > 0 or getElementInterior(source) > 0 then return end
	local slot = getSlotFromWeapon(weapon)
	if slot > 2 and slot <= 6 and weapon ~= 23 then
		local area = getZoneName(ex, ey, ez)
		if area then
			if not self.m_AreaDistrictShoots then
				self.m_AreaDistrictShoots = {}
			end
			local lastoutput = self.m_AreaDistrictShoots[area] or 0
			local tick = getTickCount()
			if lastoutput+50000 <=  tick then
				self.m_AreaDistrictShoots[area] = tick
				source:districtChat("Schüsse ertönen durch die Gegend! (("..area.."))")
			end
		end
	end
end

function PlayerManager:Event_OnDeadDoubleDestroy()
	source:dropReviveWeapons()
	source:clearReviveWeapons()
	if source:getExecutionPed() then delete(source:getExecutionPed()) end
end

function PlayerManager:Event_onToggleSeatBelt( )
	if client then
		local vehicle = getPedOccupiedVehicle(client)
		if vehicle and vehicle:getVehicleType() == VehicleType.Automobile then
			client:buckleSeatBelt(vehicle)
		end
	end
end

function PlayerManager:Event_OnDeathPedWasted( pPed )
	if client then
		if pPed and isElement(pPed) then
			local owner = pPed.m_ExecutedPlayer
			if owner then
				client:meChat(true, "setzte "..getPlayerName(owner).." ein Ende!")
				setElementData(pPed, "NPC:isDyingPed", false)
				owner:dropReviveWeapons()
				owner:clearReviveWeapons()
			end
		end
	end
end

function PlayerManager:Event_ClientRequestTime()
	client:Event_requestTime()
end

function PlayerManager:Event_DecreaseAlcoholLevel()
	client:decreaseAlcoholLevel(ALCOHOL_LOSS)
end

function PlayerManager:Event_PremiumOpenVehiclesList()
	client.m_Premium:openVehicleList()
end

function PlayerManager:Event_PremiumTakeVehicle(model)
	client.m_Premium:takeVehicle(model)
end


function PlayerManager:Event_switchSpawnWithFaction( state )
	client.m_SpawnWithFactionSkin = state
end

function PlayerManager:destructor()
	for k, v in pairs(getElementsByType("player")) do
		delete(v)
	end
end

function PlayerManager:updatePlayerSync()
	for k, v in pairs(getElementsByType("player")) do
		if v and isElement(v) and v.updateSync then
			v:updateSync()
		end
	end
end

function PlayerManager:checkPayday()
	for k, v in pairs(getElementsByType("player")) do
		if v.m_LastPlayTime then
			if v.m_NextPayday == v:getPlayTime() then
				v:payDay()
			end
		end
	end
end

function PlayerManager:getWastedHook()
	return self.m_WastedHook
end

function PlayerManager:getQuitHook()
	return self.m_QuitHook
end

function PlayerManager:getAFKHook()
	return self.m_AFKHook
end

function PlayerManager:getReadyPlayers()
	return self.m_ReadyPlayers
end

function PlayerManager:startPaydayDebug(player)
	player:payDay()
end

function PlayerManager:breakingNews(text, ...)
	for k, v in pairs(PlayerManager:getSingleton():getReadyPlayers()) do
		local textFinish = _(text, v, ...)
		v:triggerEvent("breakingNews", textFinish, "Breaking News")
	end
end

function PlayerManager:getPlayerFromId(userId)
	if userId then
		for i, v in pairs(getElementsByType('player')) do
			if v:getId() == userId then
				return v
			end
		end
	end
	return false
end

function PlayerManager:getPlayerFromPartOfName(name, sourcePlayer,noOutput)
	if name and sourcePlayer then
		local matches = {}
		for i, v in pairs(getElementsByType('player')) do
			if getPlayerName(v) == name then
				return v
			end
			if type(getPlayerName(v)) == "string" then
				if type(name) == "string" then
					if string.find(string.lower(getPlayerName(v)), string.lower(name), 0, false) then
						table.insert(matches, v)
					end
				end
			end
		end
		if #matches == 1 then
			return matches[1]
		elseif #matches >= 2 then
			if not noOutput then
				outputChatBox('Es wurden '..#matches..' Spieler gefunden! Bitte genauer angeben!', sourcePlayer, 255, 0, 0)
			end
		else
			if not noOutput then
				outputChatBox('Es wurde kein Spieler gefunden!', sourcePlayer, 255, 0, 0)
			end
		end
	end
	return false
end

function PlayerManager:sendShortMessage(text, ...)
	for k, player in pairs(getElementsByType("player")) do
		if player:isLoggedIn() then
			player:sendShortMessage(_(text, player), ...)
		end
	end
end

-----------------------------------------
--------       Event zone       ---------
-----------------------------------------
function PlayerManager:playerConnect(name)

end

function PlayerManager:playerJoin()
	-- Set a random nick to prevent blocking nicknames
	source:setName(getRandomUniqueNick())

	source:join()
end

function PlayerManager:playerCommand(cmd)
	local blockedCmdWhileDead = {
		"say", "f", "l", "me", "g", "Fraktion", "Firma", "teamsay"
	}

	if not DEBUG then
		if not source:isLoggedIn() then
			cancelEvent()
		end
		if source:isDead() and table.find(blockedCmdWhileDead, cmd) then
			cancelEvent()
		end
	end

end

function PlayerManager:playerQuit()
	self.m_QuitPlayers[source:getId()] = getTickCount()
	self.m_QuitHook:call(source)

	if getPedWeapon(source,1) == 9 then takeWeapon(source,9) end

	local index = table.find(self.m_ReadyPlayers, source)
	if index then
		table.remove(self.m_ReadyPlayers, index)
	end
	if ItemManager.Map["Kanne"] then
		if ItemManager.Map["Kanne"].m_Cans then
			if ItemManager.Map["Kanne"].m_Cans[source] and isElement(ItemManager.Map["Kanne"].m_Cans[source]) then
				destroyElement(ItemManager.Map["Kanne"].m_Cans[source])
			end
		end
	end
	if source:getWanteds() > 0 then
		FactionState:getSingleton():checkLogout(source)
	end
	if source.elevator then
		source.elevator:forceStationPosition(source, source.elevatorStationId)
	end
	if source:isLoggedIn() then
		StatisticsLogger:addLogin(source, getPlayerName( source ) , "Logout")
	end
	if source:getExecutionPed() then delete(source:getExecutionPed()) end
	if source.m_SpeedCol then
		destroyElement(source.m_SpeedCol)
	end
	VehicleManager:getSingleton():destroyUnusedVehicles( source )
	if source.m_DeathInJail then
		FactionState:getSingleton():Event_JailPlayer(source, false, true, false, true)
	end
	if DrivingSchool.m_LessonVehicles[source] then
		if DrivingSchool.m_LessonVehicles[source].m_NPC then
			destroyElement(DrivingSchool.m_LessonVehicles[source].m_NPC)
		end
		destroyElement(DrivingSchool.m_LessonVehicles[source])
		DrivingSchool.m_LessonVehicles[source] = nil
		source:triggerEvent("DrivingLesson:endLesson")
		outputChatBox("Du hast das Fahrzeug verlassen und die Prüfung beendet!", source, 200,0,0)
	end
end

function PlayerManager:Event_playerReady()
	local player = client

	self.m_ReadyPlayers[#self.m_ReadyPlayers + 1] = player
end

function PlayerManager:playerWasted(killer, killerWeapon, bodypart)
	-- Call wasted hook
	if self.m_WastedHook:call(client, killer, killerWeapon, bodypart) then
		return
	end

	client:setAlcoholLevel(0)
	client:increaseStatistics("Deaths", 1)
	client:giveAchievement(37)

	for key, obj in ipairs(getAttachedElements(client)) do
		if obj:getData("MoneyBag") then
			detachElements(obj, client)
			client:meChat(true, "lies einen Geldbeutel fallen")
		end
	end

	if killer and killer:getType() == "player" then
		if killer ~= client then
			killer:increaseStatistics("Kills", 1)
			if killer:getFaction() and killer:getFaction():isStateFaction() then
				if killer:isFactionDuty() and not client:isFactionDuty() then
					local wantedLevel = client:getWanteds()
					if wantedLevel > 0 then
						local jailTime = wantedLevel * JAIL_TIME_PER_WANTED_KILL
						local factionBonus = JAIL_COSTS[wantedLevel]
						killer:giveAchievement(64)
						client:sendInfo(_("Du wurdest außer Gefecht gesetzt!", client))
						client.m_DeathInJail = true
						-- Pay some money to faction and karma, xp to the policeman
						local factionBonus = JAIL_COSTS[wantedLevel]
						if client:getFaction() and client:getFaction():isEvilFaction() then
							factionBonus = JAIL_COSTS[wantedLevel]/2
						end
						FactionState:getSingleton().m_BankAccountServer:transferMoney(killer:getFaction(), factionBonus, "Arrest", "Faction", "ArrestKill")
						killer:giveKarma(wantedLevel)
						killer:givePoints(wantedLevel)
						PlayerManager:getSingleton():sendShortMessage(_("%s wurde soeben von %s für %d Minuten eingesperrt! Strafe: %d$", client, client:getName(), killer:getName(), jailTime, factionBonus), "Staat")
						StatisticsLogger:getSingleton():addArrestLog(client, wantedLevel, jailTime, killer, 0)
						killer:getFaction():addLog(killer, "Knast", "hat "..client:getName().." für "..jailTime.."min. eingesperrt!")
						outputChatBox("Du hast den Spieler "..getPlayerName(client).." außer Gefecht gesetzt und er wird ins Gefängnis transportiert!",killer,0,0,190)
						-- Give Achievements
						if wantedLevel > 4 then
							killer:giveAchievement(48)
						else
							killer:giveAchievement(47)
						end
						client:triggerEvent("playerWasted")
						return
					end
				end
			end
		end
	end

	-- Start death
	client:triggerEvent("playerWasted")

	if FactionRescue:getSingleton():countPlayers() > 0 then
		if not client.m_DeathPickup and not isElement(client.m_DeathPickup) then
			FactionRescue:getSingleton():createDeathPickup(client)
			--return true
		else -- This should never never happen!
			outputDebugString("Internal Error! Player died while he is Dead. Dafuq?")
		end
	end

	return false
	--client:sendInfo(_("Du hattest Glück und hast die Verletzungen überlebt. Doch pass auf, dass es nicht wieder passiert!", client))
	--client:triggerEvent("playerSendToHospital")
	--setTimer(function(player) if player and isElement(player) then player:respawn() end end, 60000, 1, client)
end


function PlayerManager:playerChat(message, messageType)
	if source:isDead() then
		cancelEvent()
		return
	end

	if source.isTasered then
		cancelEvent()
		return
	end

	local lastMsg, msgTimeSent = source:getLastChatMessage()
	if getTickCount()-msgTimeSent < (message == lastMsg and CHAT_SAME_MSG_REPEAT_COOLDOWN or CHAT_MSG_REPEAT_COOLDOWN) then -- prevent chat spam
		cancelEvent()
		return
	end
	source:setLastChatMessage(message)

	if Player.getChatHook():call(source, message, messageType) then
		cancelEvent()
		return
	end

	-- Look for special Chars (e.g. '@l': Local Chat, at Interview)
	if message:sub(1, 2):lower() == "@l" then
		message = message:sub(3, #message)
	end

	if messageType == 0 then
		local phonePartner = source:getPhonePartner()
		local playersToSend = source:getPlayersInChatRange(1)
		if not phonePartner then
			local receivedPlayers = {}
			for index = 1, #playersToSend do
				outputChatBox(("%s sagt: %s"):format(getPlayerName(source), message), playersToSend[index], 220, 220, 220)
				if playersToSend[index] ~= source then
					receivedPlayers[#receivedPlayers+1] = playersToSend[index]
				end
			end
			StatisticsLogger:getSingleton():addChatLog(source, "chat", message, receivedPlayers)
			FactionState:getSingleton():addBugLog(source, "sagt", message)
		else
			-- Send handy message
			outputChatBox(_("%s (Handy) sagt: %s", phonePartner, getPlayerName(source), message), phonePartner, 0, 255, 0)
			outputChatBox(_("%s (Handy) sagt: %s", source, getPlayerName(source), message), source, 0, 255, 0)
			StatisticsLogger:getSingleton():addChatLog(source, "phone", message, {phonePartner})
			local receivedPlayers = {}
			for index = 1, #playersToSend do
				if playersToSend[index] ~= source then
					outputChatBox(("%s (Handy) sagt: %s"):format(getPlayerName(source), message), playersToSend[index], 220, 220, 220)
					--if not playersToSend[index] == source then
						receivedPlayers[#receivedPlayers+1] = playersToSend[index]
					--end
				end
			end
			StatisticsLogger:getSingleton():addChatLog(source, "chat", ("(Handy) %s"):format(message), receivedPlayers)
			FactionState:getSingleton():addBugLog(source, "(Handy)", message)

			if phonePartner and phonePartner:getName() == "PewX" and (message:lower():find("pewpew") or message:lower():find("pew pew")) then
				Achievements["PewPew"](source)
			end
		end

		Admin:getSingleton():outputSpectatingChat(source, "C", message, phonePartner, playersToSend)
		cancelEvent()
	elseif messageType == 1 then
		source:meChat(false, message)

		Admin:getSingleton():outputSpectatingChat(source, "M", message)
		cancelEvent()
	end
end

function PlayerManager:Command_playerScream(source , cmd, ...)
	if source:isDead() then
		return
	end

	local argTable = { ... }
	local text = table.concat ( argTable , " " )

	local lastMsg, msgTimeSent = source:getLastChatMessage()
	if getTickCount()-msgTimeSent < (text == lastMsg and CHAT_SAME_MSG_REPEAT_COOLDOWN or CHAT_MSG_REPEAT_COOLDOWN) then -- prevent chat spam
		return
	end
	source:setLastChatMessage(text)

	if Player.getScreamHook():call(source, text) then
		cancelEvent()
		return
	end

	local playersToSend = source:getPlayersInChatRange(2)
	local receivedPlayers = {}
	local faction = source:getFaction()
	if source:getOccupiedVehicle() and source:getOccupiedVehicle().isStateVehicle and source:getOccupiedVehicle():isStateVehicle() then
		local success = FactionState:getSingleton():outputMegaphone(source, ...)
		if success then return true end -- cancel screaming if megaphone succeeds
	end
	for index = 1,#playersToSend do
		outputChatBox(("%s schreit: %s"):format(getPlayerName(source), text), playersToSend[index], 240, 240, 240)
		if playersToSend[index] ~= source then
            receivedPlayers[#receivedPlayers+1] = playersToSend[index]
        end
	end
	FactionState:getSingleton():addBugLog(source, "schreit", text)
	StatisticsLogger:getSingleton():addChatLog(source, "scream", text, receivedPlayers)
	Admin:getSingleton():outputSpectatingChat(source, "S", text, nil, playersToSend)
end

function PlayerManager:Command_playerWhisper(source , cmd, ...)
	if source:isDead() then
		return
	end

	local argTable = { ... }
	local text = table.concat(argTable , " ")

	local lastMsg, msgTimeSent = source:getLastChatMessage()
	if getTickCount()-msgTimeSent < (text == lastMsg and CHAT_SAME_MSG_REPEAT_COOLDOWN or CHAT_MSG_REPEAT_COOLDOWN) then -- prevent chat spam
		return
	end
	source:setLastChatMessage(text)

	local playersToSend = source:getPlayersInChatRange(0)
	local receivedPlayers = {}
	for index = 1,#playersToSend do
		outputChatBox(("%s flüstert: %s"):format(getPlayerName(source), text), playersToSend[index], 140, 140, 140)
		if playersToSend[index] ~= source then
			receivedPlayers[#receivedPlayers+1] = playersToSend[index]
		end
	end
	FactionState:getSingleton():addBugLog(source, "flüstert", text)
	StatisticsLogger:getSingleton():addChatLog(source, "whisper", text, receivedPlayers)
	Admin:getSingleton():outputSpectatingChat(source, "W", text, nil, playersToSend)
end

function PlayerManager:Command_playerOOC(source , cmd, ...)
	local argTable = { ... }
	local text = table.concat(argTable , " ")

	local lastMsg, msgTimeSent = source:getLastChatMessage()
	if getTickCount()-msgTimeSent < (text == lastMsg and CHAT_SAME_MSG_REPEAT_COOLDOWN or CHAT_MSG_REPEAT_COOLDOWN) then -- prevent chat spam
		return
	end
	source:setLastChatMessage(text)

	local playersToSend = source:getPlayersInChatRange(1)
	local receivedPlayers = {}
	for index = 1,#playersToSend do
		outputChatBox(("(( OOC %s: %s ))"):format(getPlayerName(source), text), playersToSend[index], 220, 220, 220)
		if playersToSend[index] ~= source then
			receivedPlayers[#receivedPlayers+1] = playersToSend[index]
		end
	end
	FactionState:getSingleton():addBugLog(source, "OOC", text)
	StatisticsLogger:getSingleton():addChatLog(source, "ooc", text, receivedPlayers)
	Admin:getSingleton():outputSpectatingChat(source, "OOC", text, nil, playersToSend)
end

function PlayerManager:Command_playerShrug(source, cmd)
	local text = "zuckt mit den Schultern ¯\\_(ツ)_/¯"
	local lastMsg, msgTimeSent = source:getLastChatMessage()
	if getTickCount()-msgTimeSent < (text == lastMsg and CHAT_SAME_MSG_REPEAT_COOLDOWN or CHAT_MSG_REPEAT_COOLDOWN) then -- prevent chat spam
		return
	end
	source:setLastChatMessage(text)
	source:meChat(true, text)
	if source.isTasered then return	end
	if source.vehicle then return end
	setPedAnimation(source, "shop", "SHP_HandsUp_Scr", 400, false, false, true, false)
end

function PlayerManager:Event_playerSendMoney(amount)
	if not client then return end
	amount = math.floor(amount)
	if amount <= 0 then return end
	if client:getMoney() >= amount then
		client:transferMoney(source, amount, "Spieler-Zahlung", "Gameplay", "SendMoney")
		source:sendShortMessage(_("Du hast %d$ von %s bekommen!", source, amount, client:getName()))
	end
end

function PlayerManager:Event_requestPointsToKarma(positive)
	if client:getPoints() >= 200 then
		outputDebug(positive)

		client:giveKarma((positive and 1 or -1))
		client:givePoints(-200)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_requestWeaponLevelUp()
	if client:getWeaponLevel() >= MAX_WEAPON_LEVEL then
		client:sendError(_("Du hast das zurzeit mögliche Maximallevel erreicht!", client))
		return
	end

	local requiredPoints = calculatePointsToNextLevel(client:getWeaponLevel())
	if client:getPoints() >= requiredPoints then
		client:incrementWeaponLevel()
		client:givePoints(-requiredPoints)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_requestVehicleLevelUp()
	if client:getVehicleLevel() >= MAX_VEHICLE_LEVEL then
		client:sendError(_("Du hast das zurzeit mögliche Maximallevel erreicht!", client))
		return
	end

	local requiredPoints = calculatePointsToNextLevel(client:getVehicleLevel())
	if client:getPoints() >= requiredPoints then
		client:incrementVehicleLevel()
		client:givePoints(-requiredPoints)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_requestSkinLevelUp()
	if client:getSkinLevel() >= MAX_SKIN_LEVEL then
		client:sendError(_("Du hast das zurzeit mögliche Maximallevel erreicht!", client))
		return
	end

	local requiredPoints = calculatePointsToNextLevel(client:getSkinLevel())
	if client:getPoints() >= requiredPoints then
		client:incrementSkinLevel()
		client:givePoints(-requiredPoints)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_requestJobLevelUp()
	if client:getJobLevel() >= MAX_JOB_LEVEL then
		client:sendError(_("Du hast das zurzeit mögliche Maximallevel erreicht!", client))
		return
	end

	local requiredPoints = calculatePointsToNextLevel(client:getJobLevel())
	if client:getPoints() >= requiredPoints then
		client:incrementJobLevel()
		client:givePoints(-requiredPoints)
		client:sendInfo(_("Punkte eingetauscht!", client))
	else
		client:sendError(_("Du hast nicht genügend Punkte!", client))
	end
end

function PlayerManager:Event_playerRequestTrading()
	-- TODO: Add accept prompt box
	client:startTrading(source)
end

function PlayerManager:Event_setPhoneStatus(state)
	client:togglePhone(state)
end

function PlayerManager:Event_toggleAFK(state, teleport)
	if state == true then
		if client.m_JailTime then
			if client.m_JailTime > 0 then
				return
			end
		end

		if client.m_InCircuitBreak then
			return
		end

		if client.texturePreviewActive then
			client:triggerEvent("texturePreviewForceClose")
		end

		if client.sittingOn then
			Chair:getSingleton():trySitDown()
		end
	end
	client:setPublicSync("AFK", state)
	if state == true then
		self.m_AFKHook:call(client)
		client:startAFK()
		if client:isInVehicle() then client:removeFromVehicle() end
		setElementInterior(client, 4)
		setElementDimension(client,0)
		local afkPos = AFK_POSITIONS[math.random(1, #AFK_POSITIONS)]
		if teleport then
			client:setPosition(afkPos.x, afkPos.y, 999.5546875)
		end
	else
		client:endAFK()
	end
end

function PlayerManager:Event_startAnimation(animation)
	if client.isTasered then return	end
	if client.vehicle then return end
	if client:isOnFire() then return end
	if client.lastAnimation and getTickCount() - client.lastAnimation < 1000 then return end

	if ANIMATIONS[animation] then
		local ani = ANIMATIONS[animation]
		client:setAnimation(ani["block"], ani["animation"], -1, ani["loop"], false, ani["interruptable"], ani["freezeLastFrame"])
		if client.animationObject and isElement(client.animationObject) then client.animationObject:destroy() end
		if ani.object then
			client.animationObject = createObject(ani.object, 0, 0, 0)
			client.animationObject:setInterior(client:getInterior())
			client.animationObject:setDimension(client:getDimension())
			client.animationObject:attach(client)
		end

		bindKey(client, "space", "down", self.m_AnimationStopFunc)
		addCommandHandler("stopanim", self.m_AnimationStopFunc)
		client.lastAnimation = getTickCount()
	else
		client:sendError("Internal Error! Animation nicht gefunden!")
	end
end

function PlayerManager:stopAnimation(player)
	player:setAnimation(false)
	unbindKey(player, "space", "down", self.m_AnimationStopFunc)
	removeCommandHandler("stopanim")
	if player.animationObject and isElement(player.animationObject) then player.animationObject:destroy() end
	-- Tell the client
	player:triggerEvent("onClientAnimationStop")
end

function PlayerManager:Event_passwordChange(old, new1, new2)
	--Todo: Kurzfristig deaktiviert wegen Forum Login
	client:sendError("Funktion deaktiviert!", client)
	if true then return false end

	if new1 == new2 then
		local row = sql:queryFetchSingle("SELECT Id, Salt, Password FROM ??_account WHERE Name = ? ", sql:getPrefix(), client:getName())
		if row then
			local oldPwhash = sha256(row.Salt..old)
			if oldPwhash == row.Password then
				local newSalt = md5(math.random())
				local newPwhash = sha256(newSalt..new1)
				sql:queryExec("UPDATE ??_account SET Password = ?, Salt = ? WHERE Name = ? ", sql:getPrefix(), newPwhash, newSalt, client:getName())
				client:sendInfo("Dein neues Passwort wurde gespeichert!", client)
				client:triggerEvent("passwordChangeSuccess")
			else
				client:sendError("Dein bisheriges Passwort ist nicht korrekt!", client)
			end
		else
			client:sendError("Internal Error @Password Change!", client)
		end
	else
		client:sendError("Die beiden eingegebenen neuen Passwörter sind nicht identisch!", client)
	end
end

function PlayerManager:Event_requestGunBoxData()
	client:triggerEvent("receiveGunBoxData", client.m_GunBox)
end

function PlayerManager:Event_gunBoxAddWeapon(weaponId, muni)
	if client:getFaction() and client:isFactionDuty() then
		client:sendError(_("Du darfst im Dienst keine Waffen einlagern!", client))
		return
	end

	if client:hasTemporaryStorage() then client:sendError(_("Du kannst aktuell keine Waffen einlagern!", client)) return end

	for i= 1, 6 do
		if not client.m_GunBox[tostring(i)] then
			client.m_GunBox[tostring(i)] = {}
			client.m_GunBox[tostring(i)]["WeaponId"] = 0
			client.m_GunBox[tostring(i)]["Amount"] = 0
			if i >= 4 then
				client.m_GunBox[tostring(i)]["VIP"] = true
			else
				client.m_GunBox[tostring(i)]["VIP"] = false
			end
		end

		local slot = client.m_GunBox[tostring(i)]
		if slot["WeaponId"] == 0 then
			if not slot["VIP"] or (slot["VIP"] and client:isPremium()) then
				local weaponSlot = getSlotFromWeapon(weaponId)
				if client:getWeapon(weaponSlot) > 0 then
					if client:getTotalAmmo(weaponSlot) >= math.abs(muni) then
						takeWeapon(client, weaponId)
						slot["WeaponId"] = weaponId
						slot["Amount"] = math.abs(muni)
						client:sendInfo(_("Du hast eine/n %s mit %d Schuss in deine Waffenbox (Slot %d) gelegt!", client, WEAPON_NAMES[weaponId], math.abs(muni), i))
						client:triggerEvent("receiveGunBoxData", client.m_GunBox)
						return
					else
						client:sendInfo(_("Du hast nicht genug %s Munition!", client, WEAPON_NAMES[weaponId]))
						client:triggerEvent("receiveGunBoxData", client.m_GunBox)
						return
					end
				else
					client:sendInfo(_("Du hast keine/n %s!", client, WEAPON_NAMES[weaponId]))
					client:triggerEvent("receiveGunBoxData", client.m_GunBox)
					return
				end
			end
		end
	end

	client:sendError(_("Du hast keinen freien Waffen-Slot in deiner Waffenbox!", client))
end

function PlayerManager:Event_gunBoxTakeWeapon(slotId)
	if client:getFaction() and client:isFactionDuty() then
		client:sendError(_("Du darfst im Dienst keine privaten Waffen verwenden!", client))
		return
	end

	if client:hasTemporaryStorage() then client:sendError(_("Du kannst aktuell keine Waffen entnehmen!", client)) return end

	local slot = client.m_GunBox[tostring(slotId)]
	if slot then
		if slot["WeaponId"] > 0 then
			--if slot["Amount"] >= 0 then
				local weaponId = slot["WeaponId"]
				local amount = slot["Amount"]

				if client:getWeaponLevel() < MIN_WEAPON_LEVELS[weaponId] then
					client:sendError(_("Dein Waffenlevel ist zu niedrig! (Benötigt: %i)", client, MIN_WEAPON_LEVELS[weaponId]))
					return
				end

				if client:getWeapon(getSlotFromWeapon(weaponId)) == 0 then
					slot["WeaponId"] = 0
					slot["Amount"] = 0
					client:giveWeapon(weaponId, amount)
					client:sendInfo(_("Du hast eine/n %s mit %d Schuss aus deiner Waffenbox (Slot %d) genommen!", client, WEAPON_NAMES[weaponId], amount, slotId))
					client:triggerEvent("receiveGunBoxData", client.m_GunBox)
					return
				else
					client:sendError(_("Du hast bereits eine Waffe dieser Art dabei!", client))
					client:triggerEvent("receiveGunBoxData", client.m_GunBox)
					return
				end
			--else
			--	client:sendError("Internal Error Amount to low", client)
			--	client:triggerEvent("receiveGunBoxData", client.m_GunBox)
			--	return
			--end
		else
			client:sendError(_("Du hast keine Waffe in diesem Slot!", client))
			client:triggerEvent("receiveGunBoxData", client.m_GunBox)
			return
		end
	end
end

function PlayerManager:Event_getIDCardData(target)
	client:triggerEvent("Event_receiveIDCardData",
		target:hasDrivingLicense(), target:hasBikeLicense(), target:hasTruckLicense(), target:hasPilotsLicense(),
		target:getRegistrationDate(), target:getPaNote(), target:getSTVO(),
		target:getJobLevel(), target:getWeaponLevel(), target:getVehicleLevel(), target:getSkinLevel()
	)
end

function PlayerManager:Event_weaponLevelTraining()
	local currentLevel = client:getWeaponLevel()
	local nextLevel = currentLevel+1
	if WEAPON_LEVEL[nextLevel] then
		if client:getMoney() >= WEAPON_LEVEL[nextLevel]["costs"] then
			if math.floor(client:getPlayTime()/60) >= WEAPON_LEVEL[nextLevel]["hours"] then
				ShootingRanch:getSingleton():startTraining(client, nextLevel)
			else
				client:sendError(_("Du hast nicht genug Spielstunden!", client))
			end
		else
			client:sendError(_("Du hast nicht genug Geld dabei!", client))
		end
	else
		client:sendError(_("Du hast bereits das maximale Waffenlevel!", client))
	end
end

function PlayerManager:Event_setPlayerWasted()
	if client then
		client.m_IsDead = 1
	end
end

function PlayerManager:Event_moveToJail()
	if not client:getData("inAdminPrison") then
		client:moveToJail(false,true)
	end
end

function PlayerManager:Event_OnUpdateSpawnLocation(locationId, property)
	if locationId == SPAWN_LOCATIONS.HOUSE then
		if HouseManager:getSingleton().m_Houses[client.visitingHouse]:isValidToEnter(client) then
			client:setSpawnLocation(SPAWN_LOCATIONS.HOUSE)
			client:setSpawnLocationProperty(client.visitingHouse)
			client:sendInfo("Spawnposition geändert!")
		else
			client:sendError("Du kannst dieses Haus nicht als Spawnpunkt festlegen!")
		end
	elseif locationId == SPAWN_LOCATIONS.VEHICLE then
		if VEHICLE_MODEL_SPAWNS[source:getModel()] then
			if source:getOwner() ~= client:getId() then
				return
			end

			client:setSpawnLocation(SPAWN_LOCATIONS.VEHICLE)
			client:setSpawnLocationProperty(source:getId())
			client:sendInfo("Spawnposition geändert!")
		end
	elseif locationId ==  SPAWN_LOCATIONS.FACTION_BASE then
		if client:getFaction() then
			client:setSpawnLocation(locationId)
			client:sendInfo("Spawnpunkt wurde geändert.")
		end
	elseif locationId ==  SPAWN_LOCATIONS.COMPANY_BASE then
		if client:getCompany() then
			client:setSpawnLocation(locationId)
			client:sendInfo("Spawnpunkt wurde geändert.")
		end
	else
		client:setSpawnLocation(locationId)
		client:sendInfo("Spawnpunkt wurde geändert.")
	end
end

function PlayerManager:Event_AttachToVehicle()
	client:attachToVehicle()
end
