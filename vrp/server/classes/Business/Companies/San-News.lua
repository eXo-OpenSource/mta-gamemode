SanNews = inherit(Company)

function SanNews:constructor()
	self.m_isInterview = false
	self.m_InterviewPlayer = {}
	self.m_NextAd = getRealTime().timestamp
	self.m_onInterviewColshapeLeaveFunc = bind(self.onInterviewColshapeLeave, self)
	self.m_onPlayerChatFunc = bind(self.Event_onPlayerChat, self)
	self.m_SanNewsMessageEnabled = false

	local safe = createObject(2332, 732.40, -1339.90, 15.30, 0, 0, 90)
 	self:setSafe(safe)

	local id = self:getId()
	local blip = Blip:new("House.png", 732.40, -1339.90, {company = id}, 400, {companyColors[id].r, companyColors[id].g, companyColors[id].b})
	blip:setDisplayText(self:getName(), BLIP_CATEGORY.Company)

    VehicleBarrier:new(Vector3(781.40, -1384.60, 13.50), Vector3(0, 90, 180), 0).onBarrierHit = bind(self.onBarrierHit, self)
    VehicleBarrier:new(Vector3(781.30, -1330.30, 13.40), Vector3(0, 90, 180), 0).onBarrierHit = bind(self.onBarrierHit, self)

	-- Register in Player Hooks
	Player.getQuitHook():register(bind(self.Event_onPlayerQuit, self))
	Player.getChatHook():register(bind(self.Event_onPlayerChat, self))

	addRemoteEvents{"sanNewsStartInterview", "sanNewsStopInterview", "sanNewsAdvertisement", "sanNewsToggleMessage", "sanNewsStartStreetrace"}
	addEventHandler("sanNewsStartInterview", root, bind(self.Event_startInterview, self))
	addEventHandler("sanNewsStopInterview", root, bind(self.Event_stopInterview, self))
	addEventHandler("sanNewsAdvertisement", root, bind(self.Event_advertisement, self))
	addEventHandler("sanNewsToggleMessage", root, bind(self.Event_toggleMessage, self))
	addEventHandler("sanNewsStartStreetrace", root, bind(self.Event_startStreetrace, self))

	addCommandHandler("news", bind(self.Event_news, self))
	addCommandHandler("sannews", bind(self.Event_sanNewsMessage, self), false, false)

end

function SanNews:destuctor()

end

function SanNews:onBarrierHit(player)
    if player:getCompany() ~= self then
        return false
    end
    return true
end

function SanNews:Event_news(player, cmd, ...)
	if player:getCompany() == self then
		if player:isCompanyDuty() then
			local argTable = { ... }
			local text = table.concat ( argTable , " " )
			outputChatBox(_("#FE8D14Reporter %s:#FEDD42 %s", player, player.name, text), root, 255, 200, 20, true)

    		local receivedPlayers = {}
			for k, targetPlayer in ipairs(getElementsByType("player")) do
				if targetPlayer ~= player then
					receivedPlayers[#receivedPlayers+1] = targetPlayer
				end
			end
			StatisticsLogger:getSingleton():addChatLog(player, "news", text, receivedPlayers)
		else
			player:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function SanNews:Event_startInterview(target)
	if client:getCompany() == self then
		if client:isCompanyDuty() then
			if not self.m_isInterview then
				self.m_isInterview = true
				self.m_InterviewColshape = createColSphere(client.position, 4)
				self.m_InterviewColshape:attach(client)

				client:sendInfo(_("Du hast ein Interview mit %s gestartet!", client, target.name))
				target:sendInfo(_("Reporter %s hat ein Interview mit dir gestartet!", target, client.name))
				target:sendShortMessage(_("Interview: Alles was du im Chat schreibst ist nun öffentlich! (Außnahme: @l [text])", target))
				self:addInterviewPlayer(client)
				self:addInterviewPlayer(target)
			else
				client:sendError(_("Es findet bereits ein Interview statt!", client))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function SanNews:addInterviewPlayer(player)
	table.insert(self.m_InterviewPlayer, player)
	player:setPublicSync("inInterview", true)
end

function SanNews:Event_stopInterview(target)
	if client:getCompany() == self then
		if client:isCompanyDuty() then
			client:sendInfo(_("Du hast das Interview mit %s beendet!", client, target.name))
			target:sendInfo(_("Reporter %s hat das Interview mit dir beendet!", target, client.name))
			self:stopInterview()
		else
			client:sendError(_("Du bist nicht im Dienst!", client))
		end
	end
end

function SanNews:Event_onPlayerQuit()
	if table.find(self.m_InterviewPlayer, source) then
		for index, player in pairs(self.m_InterviewPlayer) do
			player:sendInfo(_("Interview beendet! Ein Spieler ist offline gegangen!", player))
		end
		self:stopInterview()
	end
end

function SanNews:onInterviewColshapeLeave(leaveElement)
	if table.find(self.m_InterviewPlayer, leaveElement) then
		for index, player in pairs(self.m_InterviewPlayer) do
			player:sendInfo(_("Interview beendet! Ihr habt euch zu weit entfernt!", player))
		end
		self:stopInterview()
	end
end

function SanNews:stopInterview()
	for index, player in pairs(self.m_InterviewPlayer) do
		player:setPublicSync("inInterview", false)
	end
	self.m_isInterview = false
	self.m_InterviewPlayer = {}
	self.m_InterviewColshape:destroy()
end

function SanNews:Event_onPlayerChat(player, text, type)
	if type == 0 then
		if table.find(self.m_InterviewPlayer, player) then
			if text:sub(1, 2):lower() ~= "@l" then
				if player:getCompany() == self and player:isCompanyDuty() then
					outputChatBox(_("#FE8D14Reporter %s:#FEDD42 %s", player, player.name, text), root, 255, 200, 20, true)
				else
					outputChatBox(_("#FE8D14[Interview] %s:#FEDD42 %s", player, player.name, text), root, 255, 200, 20, true)
				end

				local receivedPlayers = {}
				for k, targetPlayer in ipairs(getElementsByType("player")) do
					if targetPlayer ~= player then
						receivedPlayers[#receivedPlayers+1] = targetPlayer
					end
				end
				StatisticsLogger:getSingleton():addChatLog(player, "interview", text, receivedPlayers)
				return true
			end
		end
	end
end

function SanNews:Event_advertisement(senderIndex, text, color, duration)
	local length = text:len()
	if length <= 50 and length >= 5 then
		local durationExtra = (AD_DURATIONS[duration] - 20) * 2
		local colorMultiplicator = 1
		if color ~= "Schwarz" then
			colorMultiplicator = 2
		end

		local costs = (length*AD_COST_PER_CHAR + AD_COST + durationExtra) * colorMultiplicator

		if client:getMoney() >= costs then
			if self.m_NextAd < getRealTime().timestamp then
				client:takeMoney(costs, "San News Ad")
				self:giveMoney(costs, "San News Ad")
				client:triggerEvent("closeAdvertisementBox")
				self.m_NextAd = getRealTime().timestamp + AD_DURATIONS[duration] + AD_BREAK_TIME
				StatisticsLogger:getSingleton():addAdvert(client, text)

				local sender = {referenz = "player", name = client:getName()}
				if senderIndex == 2 and client:getGroup() and client:getGroup():getName() then
					sender = {referenz = "group", name = client:getGroup():getName(), number = client:getGroup():getPhoneNumber()}
				end

				triggerClientEvent("showAd", client, sender, text, color, duration)
			else
				local next = self.m_NextAd - getRealTime().timestamp
				client:sendError(_("Die nächste Werbung kann erst in %d Sekunden gesendet werden!", client, next))
			end
		else
			client:sendError(_("Du hast zu wenig Geld dabei! (%s$)", client, costs))
		end
	end
end

function SanNews:Event_toggleMessage()
	if self.m_SanNewsMessageEnabled then
		self.m_SanNewsMessageEnabled = false
		self:sendShortMessage(("%s hat /sannews deaktiviert!"):format(client:getName()))
	else
		self.m_SanNewsMessageEnabled = true
		self:sendShortMessage(("%s hat /sannews aktiviert!"):format(client:getName()))
	end
end

function SanNews:Event_startStreetrace()
	EventManager:getSingleton():openRandomEvent()
end

function SanNews:Event_sanNewsMessage(player, cmd, ...)
	if self.m_SanNewsMessageEnabled then
		local argTable = {...}
		local msg = table.concat(argTable, " ")
		self:sendMessage(("#9cff00[SanNews-Nachricht] %s: #FFFFFF%s"):format(player:getName(), msg), 255, 255 ,0, true)
		player:sendMessage(("#9cff00[Msg an Sannews]: #FFFFFF%s"):format(msg), 255, 255 ,0, true)
	else
		player:sendError(_("Die SanNews hat /sannews derzeit deaktiviert!", player))
	end
end
