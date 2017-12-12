QuestDraw = inherit(Quest)

QuestDraw.Targets = {
	[4] = "SantaClaus",
	[10] = "SnowMan",
	[17] = "ChristmasTree"
}

function QuestDraw:constructor(id)
	Quest.constructor(self, id)

	self.m_Target = QuestPhotography.Targets[id]

	self.m_RequestPlayersBind = bind(self.requestPlayers, self)
	self.m_AcceptImageBind = bind(self.acceptImage, self)
	self.m_DeclineImageBind = bind(self.declineImage, self)
	self.m_PictureSavedImageBind = bind(self.savedImage, self)



	addCommandHandler("drawquest", function(player)
		if player:getRank() >= RANK.Moderator then
			player:triggerEvent("questDrawShowAdminGUI")
		end
	end)

	addRemoteEvents{"questDrawRequestPlayers", "questDrawReceiveAcceptImage", "questDrawReceiveDeclineImage", "questDrawPictureSaved"}
	addEventHandler("questDrawRequestPlayers", root, self.m_RequestPlayersBind)
	addEventHandler("questDrawReceiveAcceptImage", root, self.m_AcceptImageBind)
	addEventHandler("questDrawReceiveDeclineImage", root, self.m_DeclineImageBind)
	addEventHandler("questDrawPictureSaved", root, self.m_PictureSavedImageBind)

end

function QuestDraw:destructor(id)
	Quest.destructor(self)

	removeEventHandler("questDrawRequestPlayers", root, self.m_RequestPlayersBind)
	removeEventHandler("questDrawReceiveAcceptImage", root, self.m_AcceptImageBind)
	removeEventHandler("questDrawReceiveDeclineImage", root, self.m_DeclineImageBind)
	removeEventHandler("questDrawPictureSaved", root, self.m_PictureSavedImageBind)

end

function QuestDraw:requestPlayers()
	self:sendToClient(client)
end

function QuestDraw:addPlayer(player)
	Quest.addPlayer(self, player)
	local contestName = self.m_Name
	local result = sql:queryFetchSingle("SELECT Accepted FROM ??_drawContest WHERE Contest = ? AND UserId = ?", sql:getPrefix(), contestName, player:getId())
	if result then
		if not result["Accepted"] or result["Accepted"] == 0 then -- Picture Pending
			player:sendWarning("Deine eingesendete Zeichnung wurde noch nicht von einem Admin bestätigt!")
			self:removePlayer(player)
		elseif result["Accepted"] == 1 then
			player:sendSuccess("Glückwunsch! Deine Zeichnung wurde von einem Admin bestätigt! Hier deine Belohnung!")
			sql:queryExec("UPDATE ??_drawContest SET Accepted = 2 WHERE Contest = ? AND UserId = ?", sql:getPrefix(), contestName, player:getId())
			self:success(client)

		elseif result["Accepted"] == 2 then
			player:sendError("Du hast deine Belohnung für diesen Quest bereits erhalten!")
			self:removePlayer(player)
		elseif result["Accepted"] == 3 then
			player:sendError("Deine Zeichnung wurde abgelehnt! Du hast nicht schön genug gezeichnet!")
			self:removePlayer(player)
		end
	else
		player:triggerEvent("questDrawShowSkribble")
	end
end

function QuestDraw:sendToClient(player)
	local contestName = self.m_Name
	local players = {}
	local result = sql:queryFetch("SELECT Id, UserId FROM ??_drawContest WHERE Contest = ? AND (Accepted IS NULL OR Accepted = 0)", sql:getPrefix(), contestName)
    if not result then return end

	for i, row in pairs(result) do
		players[row.UserId] = {drawId = row.Id, name = Account.getNameFromId(row.UserId)}
	end

	player:triggerEvent("questDrawReceivePlayers", contestName, players)
end

function QuestDraw:acceptImage(drawId)
	if client:getRank() < RANK.Moderator then
		return
	end

	local contestName = self.m_Name
	if not contestName then client:sendError("Aktuell läuft kein Zeichen-Wettbewerb!") return end

	sql:queryExec("UPDATE ??_drawContest SET Accepted = 1 WHERE Id = ?", sql:getPrefix(), drawId)
	client:sendSuccess("Du hast die Zeichnung erfolgreich akzeptiert!")
	self:sendToClient(client)
end

function QuestDraw:declineImage(drawId)
	if client:getRank() < RANK.Moderator then
		return
	end

	local contestName = self.m_Name
	if not contestName then client:sendError("Aktuell läuft kein Zeichen-Wettbewerb!") return end

	sql:queryExec("UPDATE ??_drawContest SET Accepted = 3 WHERE Id = ?", sql:getPrefix(), drawId)
	client:sendSuccess("Du hast die Zeichnung abgelehnt!")
	self:sendToClient(client)
end

function QuestDraw:savedImage()
	client:sendShortMessage("Deine Zeichnung muss bestätigt werden!\nKomm später wieder und starte nochmal den Quest!")
	self:removePlayer(client)
end
