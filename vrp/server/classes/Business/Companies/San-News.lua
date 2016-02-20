SanNews = inherit(Company)

function SanNews:constructor()
	outputDebug(("[%s] Extra-class successfully loaded! (Id: %d)"):format(self:getName(), self:getId()))

	self.m_isInterview = false
	self.m_InterviewPlayer = {}

	self.m_onInterviewColshapeLeaveFunc = bind(self.onInterviewColshapeLeave, self)
	self.m_onPlayerChatFunc = bind(self.Event_onPlayerChat, self)
	self.m_onPlayerQuitFunc = bind(self.Event_onPlayerQuit, self)

	addRemoteEvents{"sanNewsStartInterview", "sanNewsStopInterview"}
	addEventHandler("sanNewsStartInterview", root, bind(self.Event_startInterview, self))
	addEventHandler("sanNewsStopInterview", root, bind(self.Event_stopInterview, self))

	addCommandHandler("news", bind(self.Event_news, self))
end

function SanNews:destuctor()

end

function SanNews:Event_news(player, cmd, ...)
	if player:getCompany() == self then
		if player:isCompanyDuty() then
			local argTable = { ... }
			local text = table.concat ( argTable , " " )
			outputChatBox(_("#FE8D14Reporter %s:#FEDD42 %s", player, player.name, text), root, 255, 200, 20, true)
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
				target:sendShortMessage(_("Interview: Alles was du im Chat schreibst ist nun öffentlich!", client))
				self:addInterviewPlayer(client)
				self:addInterviewPlayer(target)
			else
				client:sendError(_("Es findet bereits ein Interview statt!", player))
			end
		else
			client:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function SanNews:addInterviewPlayer(player)
	table.insert(self.m_InterviewPlayer, player)
	player:setPublicSync("inInterview", true)
	addEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)
	addEventHandler("onPlayerChat", player, self.m_onPlayerChatFunc, true, "high")
end


function SanNews:Event_stopInterview(target)
	if client:getCompany() == self then
		if client:isCompanyDuty() then
			client:sendInfo(_("Du hast das Interview mit %s beendet!", client, target.name))
			target:sendInfo(_("Reporter %s hat das Interview mit dir beendet!", target, client.name))
			self:stopInterview()
		else
			client:sendError(_("Du bist nicht im Dienst!", player))
		end
	end
end

function SanNews:Event_onPlayerQuit()
	if table.find(self.m_InterviewPlayer, source) then
		for index, player in pairs(self.m_InterviewPlayer) do
			player:sendInfo(_("Interview beendet! Ein Spieler ist offline gegangen!", client))
		end
		self:stopInterview()
	end
end

function SanNews:onInterviewColshapeLeave(leaveElement)
	if table.find(self.m_InterviewPlayer, leaveElement) then
		for index, player in pairs(self.m_InterviewPlayer) do
			player:sendInfo(_("Interview beendet! Ihr habt euch zuweit entfernt!", client))
		end
		self:stopInterview()
	end
end

function SanNews:stopInterview()
	for index, player in pairs(self.m_InterviewPlayer) do
		player:setPublicSync("inInterview", false)
		removeEventHandler("onPlayerQuit", player, self.m_onPlayerQuitFunc)
		removeEventHandler("onPlayerChat", player, self.m_onPlayerChatFunc, true, "high")
	end
	self.m_isInterview = false
	self.m_InterviewPlayer = {}
	self.m_InterviewColshape:destroy()
end

function SanNews:Event_onPlayerChat(text, type)
	if type == 0 then
		if table.find(self.m_InterviewPlayer, source) then
			if source:getCompany() == self and source:isCompanyDuty() then
				outputChatBox(_("#FE8D14Reporter %s:#FEDD42 %s", source, source.name, text), root, 255, 200, 20, true)
			else
				outputChatBox(_("#FE8D14[Interview] %s:#FEDD42 %s", source, source.name, text), root, 255, 200, 20, true)
			end
			cancelEvent()
		end
	end
end
