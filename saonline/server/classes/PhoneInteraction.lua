-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        server/classes/PhoneInteraction.lua
-- *  PURPOSE:     Phone interaction class
-- *
-- ****************************************************************************
PhoneInteraction = inherit(Singleton)

function PhoneInteraction:constructor()
	addEvent("voiceCallStart", true)
	addEventHandler("voiceCallStart", root, bind(self.voiceCallStart, self))
end

function PhoneInteraction:voiceCallStart(player)
	if not player then return end
	
	player:triggerEvent("voiceCallIncoming", client)
end
