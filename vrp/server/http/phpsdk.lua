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
		local target = getPlayerFomName(target)
		if isElement(target) then
			target:outputChat(message, r, g, b)
		end
	end
end
