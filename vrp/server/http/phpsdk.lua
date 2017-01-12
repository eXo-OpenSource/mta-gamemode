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
	callRemote("http://exo-reallife.de/ingame/boardActivation.php", phpSDKSendActivationMailCallback, userID, username)
end

function phpSDKSendOnlinePlayers()
	local players = {}
	local i = 1

	for index, player in pairs(getElementsByType("player")) do
		if player:isActive() then
			players[i]= {
				["Name"] = player:getName(),
				["Id"] = player:getId() or 0,
				["Faction"] = player:getFaction() and player:getFaction():getId() or 0,
				["Company"] = player:getCompany() and player:getCompany():getId() or 0,
				["GroupId"] = player:getGroup() and player:getGroup():getId() or 0,
				["GroupName"] = player:getGroup() and player:getGroup():getName() or "-keine-",
			}
			i = i+1
		end
	end
	outputDebugString("PHP-Request Playerlist")
	return players
end
