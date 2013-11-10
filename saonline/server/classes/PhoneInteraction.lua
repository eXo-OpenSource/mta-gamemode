-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        server/classes/PhoneInteraction.lua
-- *  PURPOSE:     Phone interaction class
-- *
-- ****************************************************************************
PhoneInteraction = inherit(Singleton)

function PhoneInteraction:constructor()
	addEvent("callStart", true)
	addEvent("callBusy", true)
	addEvent("callAnswer", true)
	addEvent("callReplace", true)
	addEventHandler("callStart", root, bind(self.callStart, self))
	addEventHandler("callBusy", root, bind(self.callBusy, self))
	addEventHandler("callAnswer", root, bind(self.callAnswer, self))
	addEventHandler("callReplace", root, bind(self.callReplace, self))
end

function PhoneInteraction:callStart(player)
	if not player then return end
	
	player:triggerEvent("callIncoming", client)
end

function PhoneInteraction:callBusy(caller)
	if not caller or not isElement(caller) then return end
	caller:triggerEvent("callBusy", client)
end

function PhoneInteraction:callAnswer(caller, voiceCall)
	if not caller or not isElement(caller) then return end
	caller:triggerEvent("callAnswer", client, voiceCall)
	
	-- Set phone partner
	caller:setPhonePartner(client)
	client:setPhonePartner(caller)
	
	-- Start voice broadcasting
	if voiceCall and isVoiceEnabled() then
		setPlayerVoiceBroadcastTo(caller, client)
	end
end

function PhoneInteraction:callReplace(callee)
	if not callee then return end
	if client:getPhonePartner() ~= callee then return end
	
	client:setPhonePartner(nil)
	callee:setPhonePartner(nil)
	
	-- Todo: Notify the callee
end
