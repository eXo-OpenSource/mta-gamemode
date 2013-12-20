-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
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

function PhoneInteraction:callStart(player, voiceEnabled)
	if not player then return end
	
	player:triggerEvent("callIncoming", client, voiceEnabled)
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
		setPlayerVoiceBroadcastTo(client, caller)
	end
end

function PhoneInteraction:callReplace(callee)
	if not callee then return end
	if client:getPhonePartner() ~= callee then return end
	
	client:setPhonePartner(nil)
	callee:setPhonePartner(nil)
	setPlayerVoiceBroadcastTo(client, nil) -- Todo: Check if a voice call was active
	setPlayerVoiceBroadcastTo(callee, nil)
	
	-- Todo: Notify the callee
	callee:triggerEvent("callReplace", client)
end
