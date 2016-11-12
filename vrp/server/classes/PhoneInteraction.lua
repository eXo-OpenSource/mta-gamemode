-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PhoneInteraction.lua
-- *  PURPOSE:     Phone interaction class
-- *
-- ****************************************************************************
PhoneInteraction = inherit(Singleton)

function PhoneInteraction:constructor()
	addRemoteEvents{"callStart", "callBusy", "callAnswer", "callReplace", "callStartSpecial", "callAbbortSpecial"}

	addEventHandler("callStart", root, bind(self.callStart, self))
	addEventHandler("callBusy", root, bind(self.callBusy, self))
	addEventHandler("callAnswer", root, bind(self.callAnswer, self))
	addEventHandler("callReplace", root, bind(self.callReplace, self))
	addEventHandler("callStartSpecial", root, bind(self.callStartSpecial, self))
	addEventHandler("callAbbortSpecial", root, bind(self.callAbbortSpecial, self))

	self.m_LastSpecialCallNumber = {}
end

function PhoneInteraction:callStart(player, voiceEnabled)
	if not player then return end
	if player:isPhoneEnabled() == true then
		player:triggerEvent("callIncoming", client, voiceEnabled)
	else
		client:sendError(_("Das Handy von '%s' ist ausgeschaltet!",client, player.name))
	end
end

function PhoneInteraction:callBusy(caller)
	if not caller or not isElement(caller) then return end
	caller:triggerEvent("callBusy", client)
	client:triggerEvent("callBusy", caller)
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
	--if client:getPhonePartner() ~= callee then return end

	client:setPhonePartner(nil)
	callee:setPhonePartner(nil)
	setPlayerVoiceBroadcastTo(client, nil) -- Todo: Check if a voice call was active
	setPlayerVoiceBroadcastTo(callee, nil)

	-- Todo: Notify the callee
	callee:triggerEvent("callReplace", client)
	client:triggerEvent("callReplace", callee)

end

function PhoneInteraction:callStartSpecial(number)
	for index, instance in pairs(PhoneNumber.Map) do
		if instance:getNumber() == number then
			self.m_LastSpecialCallNumber[client] = number
			instance:getOwner(instance):phoneCall(client)
		end
	end
end

function PhoneInteraction:callAbbortSpecial()
	if self.m_LastSpecialCallNumber[client] then
		for index, instance in pairs(PhoneNumber.Map) do
			if instance:getNumber() == self.m_LastSpecialCallNumber[client] then
				self.m_LastSpecialCallNumber[client] = false
				instance:getOwner(instance):phoneCallAbbort(client)
				client:triggerEvent("callReplace")
			end
		end
	end
end
