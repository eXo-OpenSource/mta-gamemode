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
	outputDebugString("PHP-Request Playerlist")
	return players;
end