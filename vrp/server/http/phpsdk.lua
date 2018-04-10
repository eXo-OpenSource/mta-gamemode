--WEB (PHP mtasdk)

function phpSDKGetPlayers()
	local name
	local players = {}
	local i = 1
	for index, player in pairs(getElementsByType("player")) do
		players[i]={}
		players[i]["pname"] = player:getName()
		i = i+1
	end
	return players
end

function phpSDKSendChatBox(type, target, message, r, g, b)
	if type == "admin" then
		Admin:getSingleton():sendMessage(message, r, g, b)
	elseif type == "player" then
		local target = getPlayerFromName(target)
		if isElement(target) then
			target:outputChat(message, r, g, b)
		end
	end
	return
end

function phpSDKLoadCharacterInfo(targetName) -- Cause of Migrator
	local target = getPlayerFromName(targetName)
	if isElement(target) then
		target:loadMigratorData()
	end
end

function phpSDKSendActivationMailCallback(answer)
	outputChatBox("phpSDKSendActivationMailCallback: "..answer)
end

function phpSDKSendActivationMail(userID, username)
	callRemote(INGAME_WEB_PATH .. "/ingame/boardActivation.php", phpSDKSendActivationMailCallback, userID, username)
end

function phpSDKSendOnlinePlayers()
	local players = {}
	local i = 1

	for index, player in pairs(getElementsByType("player")) do
		if player.isActive and player:isActive() then
			players[i]= {
				["Name"] = player:getName(),
				["Id"] = player:getId() or 0,
				["Faction"] = player:getFaction() and player:getFaction():getId() or 0,
				["Company"] = player:getCompany() and player:getCompany():getId() or 0,
				["GroupId"] = player:getGroup() and player:getGroup():getId() or 0,
			}
			i = i+1
		end
	end
	outputDebugString("PHP-Request Playerlist")
	return players
end

function phpSDKGiveQRAchievement(playerId)
	Async.create(
		function()
			local player, isOffline = DatabasePlayer.get(playerId)
			if isOffline then
				player:load()
				delete(player)
				return false
			else
				player:giveAchievement(78)
				return true
			end
		end
	)()
end
