-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        server/classes/PlayerManager.lua
-- *  PURPOSE:     Player manager class
-- *
-- ****************************************************************************
PlayerManager = inherit(Singleton)

function PlayerManager:constructor()
	addEventHandler("onPlayerChat", root, bind(self.playerChat, self))
end

function PlayerManager:playerChat(message, messageType)
	if messageType == 0 then
		local phonePartner = source:getPhonePartner()
		if not phonePartner then
			outputChatBox(getPlayerName(source)..": "..message, root, 255, 255, 0)
		else
			-- Send handy message
			outputChatBox(_("%s from phone: %s", phonePartner):format(getPlayerName(source), message), phonePartner, 0, 255, 0)
			outputChatBox(_("%s from phone: %s", source):format(getPlayerName(source), message), source, 0, 255, 0)
		end
		cancelEvent()
	end
end
