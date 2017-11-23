QuestDraw = inherit(Quest)

QuestDraw.Targets = {
	[4] = "SantaClaus",
	[10] = "SnowMan"
}

function QuestDraw:constructor(id)
	Quest.constructor(self, id)

	self.m_Target = QuestPhotography.Targets[id]

	self.m_ReceivePlayersBind = bind(self.requestPlayers, self)
	self.m_AcceptImageBind = bind(self.acceptImage, self)

	addRemoteEvents{"questDrawReceivePlayers", "questDrawReceiveAcceptImage"}
	addEventHandler("questDrawReceivePlayers", root, self.m_ReceivePlayersBind)
	addEventHandler("questDrawReceiveAcceptImage", root, self.m_AcceptImageBind)
end

function QuestDraw:destructor(id)
	Quest.destructor(self)

	removeEventHandler("questDrawReceivePlayers", root, self.m_ReceivePlayersBind)
	removeEventHandler("questDrawReceiveAcceptImage", root, self.m_AcceptImageBind)
end

function QuestDraw:requestPlayers()
	self:sendToClient(client)
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

	sql:queryExec("UPDATE ??_drawContest SET Accepted = 1 WHERE DrawId = ?", sql:getPrefix(), drawId)
	client:sendSuccess("Du hast das Bild erfolgreich akzeptiert!")
end

