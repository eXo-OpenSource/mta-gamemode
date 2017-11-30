QuestNPCTransport = inherit(Quest)

QuestNPCTransport.Targets = {
	[1] = Vector3(1274.49, 294.03, 19),
	[5] = Vector3(318.71, -1819.91, 3.7)
}

function QuestNPCTransport:constructor(id)
	Quest.constructor(self, id)
	self.m_Spawn = Vector3(1476.10, -1692.99, 14.05)
	self.m_Target = QuestNPCTransport.Targets[id]
	self.m_Marker = createMarker(self.m_Target, "cylinder", 3, 255, 0, 0)
	self.m_Marker:setVisibleTo(root, false)
	self.m_Bots = {}
	self.m_Blips = {}

	self.m_checkDistanceTimer = setTimer(bind(self.checkDistance, self), 15000, 0)

	self.m_onVehicleEnterBind = bind(self.onVehicleEnter, self)
	addEventHandler("onVehicleEnter", root, self.m_onVehicleEnterBind)
	addEventHandler("onMarkerHit", self.m_Marker, bind(self.onMarkerHit, self))
end

function QuestNPCTransport:destructor(id)
	Quest.destructor(self)
	for index, bot in pairs(self.m_Bots) do
		if bot then
			if bot then
				BotManager:getSingleton():deleteNPC(bot.m_Id)
			end
		end
	end
	for index, blip in pairs(self.m_Blips) do
		if blip then delete(blip) end
	end
	if isTimer(self.m_checkDistanceTimer) then killTimer(self.m_checkDistanceTimer) end
	self.m_Marker:destroy()
	removeEventHandler("onVehicleEnter", root, self.m_onVehicleEnterBind)
end

function QuestNPCTransport:onVehicleEnter(player, seat)
	if table.find(self:getPlayers(), player) then
		player:sendWarning("Der Weihnachtsmann ist zu dick um in ein Auto einzusteigen!")
	end
end

function QuestNPCTransport:onMarkerHit(player, dim)
	if player:getType() == "player" and dim then
		if table.find(self:getPlayers(), player) then
			if self.m_Bots[player] then
				if (self.m_Bots[player]:getPosition() - player:getPosition()).length < 30 then
					player:sendSuccess("Du hast den Weihnachtsmann erfolgreich abgeliefert!")
					self:success(player)
				else
					player:sendWarning("Dein Weihnachtsmann ist zu weit entfernt, gehe nochmal in den Marker sobald er näher bei dir ist!")
				end
			end
		end
	end
end

function QuestNPCTransport:checkDistance()
	for index, player in pairs(self:getPlayers()) do
		if player and isElement(player) then
			if self.m_Bots[player] then
				if (self.m_Bots[player]:getPosition() - player:getPosition()).length > 30 then
					if not player.christmasBotWarning then
						player:sendWarning("Vorsicht, dein Weihnachtsmann ist zu weit von dir entfernt! Bleibe bei ihm, ansonsten wird der Quest abgebrochen!")
						player.christmasBotWarning = true
					else
						player:sendError("Du hast dich zu weit von deinem Weihnachtsmann entfernt!")
						self:removePlayer(player)
						player.christmasBotWarning = nil
					end
				else
					player.christmasBotWarning = nil
				end
			end
		end
	end
end

function QuestNPCTransport:addPlayer(player)
	Quest.addPlayer(self, player)

	self.m_Bots[player] = BotManager:getSingleton():addNPC(244, self.m_Spawn, nil, player)
	self.m_Bots[player]:setData("NPC:Immortal", true, true)
	self.m_Bots[player]:setData("Ped:fakeNameTag", "Santa Claus von "..player:getName(), true)
	self.m_Blips[player] = Blip:new("Marker.png", self.m_Target.x, self.m_Target.y, player, 6000, {255, 0, 0})
	self.m_Marker:setVisibleTo(player, true)
end

function QuestNPCTransport:removePlayer(player)
	Quest.removePlayer(self, player)
	if self.m_Blips[player] then delete(self.m_Blips[player]) end
	if self.m_Bots[player] then
		BotManager:getSingleton():deleteNPC(self.m_Bots[player].m_Id)
	end
	self.m_Marker:setVisibleTo(player, false)
end
