-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PlayerManager.lua
-- *  PURPOSE:     Player manager class
-- *
-- ****************************************************************************
PlayerManager = inherit(Singleton)
addEvent("playerSendMoney", true)

function PlayerManager:constructor()
	addEventHandler("onPlayerConnect", root, bind(self.playerConnect, self))
	addEventHandler("onPlayerJoin", root, bind(self.playerJoin, self))
	addEventHandler("onPlayerWasted", root, bind(self.playerWasted, self))
	addEventHandler("onPlayerChat", root, bind(self.playerChat, self))
	
	addEventHandler("playerSendMoney", root, bind(self.playerSendMoney, self))
end

function PlayerManager:destructor()
	for k, v in ipairs(getElementsByType("player")) do
		delete(v)
	end
end

function PlayerManager:playerConnect(name)
	local player = getPlayerFromName(name)
	Async.create(Player.connect)(player)
end

function PlayerManager:playerJoin()
	source:join()
end

function PlayerManager:playerWasted()
	source:sendMessage("Pass lieber auf, was du machst!")
	setTimer(function(player) if player then player:respawnAfterDeath() end end, 5*1000, 1, source)
end

function PlayerManager:playerChat(message, messageType)
	if messageType == 0 then
		local phonePartner = source:getPhonePartner()
		if not phonePartner then
			outputChatBox(getPlayerName(source)..": "..message, root, 255, 255, 0)
		else
			-- Send handy message
			outputChatBox(_("%s from phone: %s", phonePartner, getPlayerName(source), message), phonePartner, 0, 255, 0)
			outputChatBox(_("%s from phone: %s", source, getPlayerName(source), message), source, 0, 255, 0)
		end
		cancelEvent()
	end
end

function PlayerManager:playerSendMoney(amount)
	if not client then return end
	if client:getMoney() >= amount then
		client:takeMoney(amount)
		source:giveMoney(amount)
	end
end
