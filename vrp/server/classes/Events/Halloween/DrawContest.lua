DrawContest = inherit(Singleton)
DrawContest.Events = {
	["Male einen Kürbis"] = {
		["Draw"] = {["Start"] = 1509317599, ["Duration"] = 86400},
		["Vote"] = {["Start"] = 1509404400, ["Duration"] = 86400}
	},
	["Male Süßigkeiten"]= {
		["Draw"] = {["Start"] = 1509490800, ["Duration"] = 86400}, 	--27.10 - 28.10
		["Vote"] = {["Start"] = 1509577200, ["Duration"] = 86400} 	--28.10 - 29.10
	},
	["Male ein Geisterhaus"]= {
		["Draw"] = {["Start"] = 1509663600, ["Duration"] = 86400}, 	--29.10 - 30.10
		["Vote"] = {["Start"] = 1509750000, ["Duration"] = 86400}	--30.10 - 31.10
	},
	["Male Halloween auf eXo"]= {
		["Draw"] = {["Start"] = 1509836400, ["Duration"] = 86400},	--31.10 - 01.11
		["Vote"] = {["Start"] = 1509922800, ["Duration"] = 86400}	--01.11 - 02.11
	},
}

function DrawContest:constructor()
	addRemoteEvents{"drawContestRequestPlayers", "drawContestRateImage", "drawContestRequestRating", "drawContestHideImage"}

	addEventHandler("drawContestRequestPlayers", root, bind(self.requestPlayers, self))
	addEventHandler("drawContestRateImage", root, bind(self.rateImage, self))
	addEventHandler("drawContestRequestRating", root, bind(self.requestRating, self))
	addEventHandler("drawContestHideImage", root, bind(self.hideImage, self))
end

function DrawContest:getCurrentEvent()
	local now = getRealTime().timestamp
	for name, data in pairs(DrawContest.Events) do
		local drawStart = data["Draw"]["Start"]
		local drawEnd =  data["Draw"]["Start"] + data["Draw"]["Duration"]
		if now > drawStart and now < drawEnd then
			return name, "draw"
		end
		local voteStart = data["Vote"]["Start"]
		local voteEnd =  data["Vote"]["Start"] + data["Vote"]["Duration"]
		if now > voteStart and now < voteEnd then
			return name, "vote"
		end
	end
	return false, false
end

function DrawContest:requestPlayers()
	local contestName, contestType = self:getCurrentEvent()
	if not contestName then client:sendError("Aktuell läuft kein Zeichen-Wettbewerb!") return end

	self:sendToClient(client)
end

function DrawContest:sendToClient(player)
	local contestName, contestType = self:getCurrentEvent()
	local players = {}
	local result = sql:queryFetch("SELECT Id, UserId FROM ??_drawContest WHERE Contest = ? AND Hidden = 0", sql:getPrefix(), contestName)
    if not result then return end

	for i, row in pairs(result) do
		local playersVote = self:getVotes(row.Id, player:getId())
		players[row.UserId] = {drawId = row.Id, name = Account.getNameFromId(row.UserId), vote = playersVote and playersVote.Vote}
	end

	player:triggerEvent("drawContestReceivePlayers", contestName, contestType, players)
end

function DrawContest:getVotes(drawId, userId)
	if not userId then
		return sql:queryFetch("SELECT Vote FROM ??_drawcontest_votes WHERE DrawId = ?", sql:getPrefix(), drawId)
	else
		return sql:queryFetchSingle("SELECT Vote FROM ??_drawcontest_votes WHERE DrawId = ? AND UserId = ?", sql:getPrefix(), drawId, userId)
	end
end

function DrawContest:rateImage(drawId, rating)
	local contestName, contestType = self:getCurrentEvent()
	if not contestName then client:sendError("Aktuell läuft kein Zeichen-Wettbewerb!") return end
	if not contestType == "vote" then client:sendError("Aktuell kann nicht Abgestimmt werden!") return end

	local hasVoted = self:getVotes(drawId, client:getId())
	if hasVoted then
		client:sendError("Du hast bereits für dieses Bild abgestimmt!")
		return
	end

	sql:queryExec("INSERT INTO ??_drawcontest_votes (DrawId, UserId, Vote) VALUES (?, ?, ?)", sql:getPrefix(), drawId, client:getId(), rating)
	client:sendSuccess("Du hast das Bild erfolgreich bewertet!")
end

function DrawContest:hideImage(drawId)
	if client:getRank() < RANK.Moderator then
		return
	end
	local contestName, contestType = self:getCurrentEvent()
	if not contestName then client:sendError("Aktuell läuft kein Zeichen-Wettbewerb!") return end

	sql:queryExec("UPDATE ??_drawContest SET Hidden = 1 WHERE Id = ?", sql:getPrefix(), drawId)
	client:sendSuccess("Du hast das Bild erfolgreich deaktiviert!")

	self:sendToClient(client)
end

function DrawContest:requestRating(drawId)
	if client:getRank() < RANK.Moderator then return end
	if not drawId then return end

	local contestName, contestType = self:getCurrentEvent()
	if not contestName then return end
	if not contestType == "vote" then return end

	local admin = "0 Abstimmungen"
	local votes = self:getVotes(drawId)
	local votesCount = table.size(votes)

	if votesCount > 0 then
		local votesSum = 0

		for id, vote in pairs(votes) do
			votesSum = votesSum + vote.Vote
		end

		admin = ("%d Abstimmung%s | %s Sterne"):format(votesCount, votesCount == 1 and "" or "en", math.round(votesSum/votesCount, 2))
	end

	client:triggerEvent("drawingContestReceiveVote", admin)
end



