-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PhoneInteraction.lua
-- *  PURPOSE:     Phone interaction class
-- *
-- ****************************************************************************
PhoneInteraction = inherit(Singleton)

function PhoneInteraction:constructor()
	addRemoteEvents{"callStart", "callBusy", "callAnswer", "callReplace", "callStartSpecial", "callAbbortSpecial", "callSendLocation", "requestEPTList"}

	addEventHandler("callStart", root, bind(self.callStart, self))
	addEventHandler("callBusy", root, bind(self.callBusy, self))
	addEventHandler("callAnswer", root, bind(self.callAnswer, self))
	addEventHandler("callReplace", root, bind(self.callReplace, self))
	addEventHandler("callStartSpecial", root, bind(self.callStartSpecial, self))
	addEventHandler("callAbbortSpecial", root, bind(self.callAbbortSpecial, self))
	addEventHandler("callSendLocation", root, bind(self.callSendLocation, self))
	addEventHandler("requestEPTList", root, bind(self.requestEPTList, self))


	self.m_LastSpecialCallNumber = {}
	self.m_LocationBlips = {}

	PlayerManager:getSingleton():getQuitHook():register(
		function(player)
			self:abortCall(player)
		end
	)

	PlayerManager:getSingleton():getWastedHook():register(
		function(player)
			self:abortCall(player)
		end
	)

end

function PhoneInteraction:callStart(player, voiceEnabled)
	if not player then return end

	if player:isPhoneEnabled() == true then
		if client:getData("isInDeathMatch") or player:getData("isInDeathMatch") then
			client:sendError(_("Besetzt... Der Spieler ist gerade nicht erreichbar!",client, player.name))
			client:triggerEvent("callReplace", player)
			return
		end

		if not player:getPhonePartner() and not player.IncomingCall then
			player:triggerEvent("callIncoming", client, voiceEnabled)
			player.IncomingCall = true
		else
			client:sendError(_("Besetzt... Der Spieler telefoniert gerade!",client, player.name))
			client:triggerEvent("callReplace", player)
		end
	else
		client:sendError(_("Das Handy von '%s' ist ausgeschaltet!",client, player.name))
		client:triggerEvent("callReplace", player)
	end
end

function PhoneInteraction:callBusy(caller)
	if not caller or not isElement(caller) then return end
	client:triggerEvent("callBusy", caller)
	caller:triggerEvent("callBusy", client)
	client:giveAchievement(4)
	client.IncomingCall = false
	caller.IncomingCall = false
end

function PhoneInteraction:callAnswer(caller, voiceCall)
	if not caller or not isElement(caller) then return end
	caller:triggerEvent("callAnswer", client, voiceCall)

	-- Set phone partner
	caller:setPhonePartner(client)
	client:setPhonePartner(caller)
	caller.IncomingCall = false
	client.IncomingCall = false

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
	client.IncomingCall = false
	callee.IncomingCall = false

	setPlayerVoiceBroadcastTo(client, nil) -- Todo: Check if a voice call was active
	setPlayerVoiceBroadcastTo(callee, nil)

	if self.m_LocationBlips[client] then delete(self.m_LocationBlips[client]) end
	if self.m_LocationBlips[callee] then delete(self.m_LocationBlips[callee]) end

	-- Todo: Notify the callee
	if callee:isPhoneEnabled() == true then
		callee:triggerEvent("callReplace", client)
	end
	if client:isPhoneEnabled() == true then
		client:triggerEvent("callReplace", callee)
	end
end

function PhoneInteraction:abortCall(player)
	if player:getPhonePartner() then
		local partner = player:getPhonePartner()
		setPlayerVoiceBroadcastTo(partner, nil)
		partner:setPhonePartner(nil)
		partner:triggerEvent("callReplace", player)
		partner:sendMessage(_("Knack... Das Telefonat wurde abgebrochen!", partner), 255, 0, 0)

		if self.m_LocationBlips[player] then delete(self.m_LocationBlips[player]) end
		if self.m_LocationBlips[partner] then delete(self.m_LocationBlips[partner]) end

		setPlayerVoiceBroadcastTo(player, nil)
		player:setPhonePartner(nil)
		player:triggerEvent("callReplace", partner)
		player.IncomingCall = false
		partner.IncomingCall = false
	end
end


function PhoneInteraction:callStartSpecial(number)
	for index, instance in pairs(PhoneNumber.Map) do
		if instance:getNumber() == number then
			if instance:getOwner(instance) ~= client then
				self.m_LastSpecialCallNumber[client] = number
				instance:getOwner(instance):phoneCall(client)
			else
				client:sendError("Du kannst dich nicht selbst anrufen!")
			end
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

function PhoneInteraction:callSendLocation()
	if client:getPhonePartner() then
		local partner = client:getPhonePartner()

		if self.m_LocationBlips[client] then
			delete(self.m_LocationBlips[client])
			partner:sendMessage(_("[HANDY] %s hat seine Position aktualisiert.", partner, client:getName()), 255, 0, 0)
			client:sendMessage(_("[HANDY] Du hast deine Position aktualisiert.", client, partner:getName()), 255, 0, 0)
		else
			partner:sendMessage(_("[HANDY] %s hat dir seine Position mitgeteilt.", partner, client:getName()), 255, 0, 0)
			client:sendMessage(_("[HANDY] Du hast %s deine Position mitgeteilt.", client, partner:getName()), 255, 0, 0)
		end

		local pos = client:getPosition()
		self.m_LocationBlips[client] = Blip:new("Marker.png", pos.x, pos.y, partner, 10000)
	end
end

function PhoneInteraction:requestEPTList()
	local eptList = {}
	for _, player in pairs(CompanyManager:getSingleton():getFromId(4):getOnlinePlayers()) do
		if player:isCompanyDuty() and player.vehicle and player.vehicle:getData("EPT_Taxi") and player.vehicleSeat == 0 then
			table.insert(eptList, player)
		end
	end

	client:triggerEvent("receivingEPTList", eptList)
end
