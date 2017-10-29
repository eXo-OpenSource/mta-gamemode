DrawContest = inherit(Singleton)
DrawContest.Events = {
	["Male einen Kürbis"] = {
		["Draw"] = {["Start"] = 1508882400, ["Duration"] = 86400}, 	--25.10 - 26.10
		["Vote"] = {["Start"] = 1509404400, ["Duration"] = 86400}  	--26.10 - 27.10
	},
	["Male Süßigkeiten"]= {
		["Draw"] = {["Start"] = 1509490800, ["Duration"] = 86400}, 	--27.10 - 28.10
		["Vote"] = {["Start"] = 1509577200, ["Duration"] = 86400} 	--28.10 - 29.10
	},
	["Male ein Halloween-Kostüm"]= {
		["Draw"] = {["Start"] = 1509663600, ["Duration"] = 86400}, 	--29.10 - 30.10
		["Vote"] = {["Start"] = 1509750000, ["Duration"] = 86400}	--30.10 - 31.10
	},
	["Male eine Hexe"]= {
		["Draw"] = {["Start"] = 1509836400, ["Duration"] = 86400},	--31.10 - 01.11
		["Vote"] = {["Start"] = 1509922800, ["Duration"] = 86400}	--01.11 - 02.11
	},
	["Male eine Halloweenparty"]= {
		["Draw"] = {["Start"] = 1510009200, ["Duration"] = 86400},	--02.11 - 03.11
		["Vote"] = {["Start"] = 1510095600, ["Duration"] = 86400}	--03.11 - 04.11
	}
}

function DrawContest:constructor()
	addRemoteEvents{"drawContestRequestPlayers", "drawContestRateImage", "drawContestRequestRating"}


	addEventHandler("drawContestRequestPlayers", root, bind(self.requestPlayers, self))
	addEventHandler("drawContestRateImage", root, bind(self.rateImage, self))
	addEventHandler("drawContestRequestRating", root, bind(self.requestRating, self))
end

function DrawContest:getCurrentEvent()
	local now = getRealTime().timestamp
	for name, data in pairs(DrawContest.Events) do
		local drawStart = data["Draw"]["Start"]
		local drawEnd =  data["Draw"]["Start"] + data["Draw"]["Duration"]
		if now > drawStart and now < drawEnd then
			return name, "draw"
		end
		if now > voteStart and now < voteEnd then
			return name, "vote"
		end
	end
	return false, false
end

function DrawContest:requestPlayers()
	local contestName, contestType = self:getCurrentEvent()
	if not contestName then client:sendError("Aktuell läuft kein Zeichen-Wettbewerb!") return end

	local players = {}
	local result = sql:queryFetch("SELECT UserId FROM ??_drawContest WHERE Contest = ?", sql:getPrefix(), contestName)
    if not result then return end
	for i, row in pairs(result) do
		players[row.UserId] = Account.getNameFromId(row.UserId)
	end
	client:triggerEvent("drawContestReceivePlayers", contestName, contestType, players)
end

function DrawContest:getVotes(ownerId, contestName)
	local row = sql:queryFetchSingle("SELECT VoteData FROM ??_drawContest WHERE UserId = ? AND Contest = ?", sql:getPrefix(), ownerId, contestName)
	if row.VoteData and row.VoteData:len() > 0 then
		return fromJSON(row.VoteData)
	end
	return {}
end

function DrawContest:saveVotes(ownerId, contestName, votes)
	return sql:queryExec("UPDATE ??_drawContest SET VoteData = ? WHERE UserId = ? AND Contest = ?", sql:getPrefix(), toJSON(votes), ownerId, contestName)
end

function DrawContest:rateImage(userId, rating)
	local contestName, contestType = self:getCurrentEvent()
	if not contestName then client:sendError("Aktuell läuft kein Zeichen-Wettbewerb!") return end
	if not contestType == "vote" then client:sendError("Aktuell kann nicht Abgestimmt werden!") return end

	local votes = self:getVotes(userId, contestName)
	if votes[client:getId()] then
		client:sendError("Du hast bereits für dieses Bild abgestimmt!")
		return
	end

	votes[client:getId()] = rating
	self:saveVotes(userId, contestName, votes)

	client:sendSuccess("Du hast das Bild erfolgreich bewertet!")
end

function DrawContest:requestRating(userId)
	local contestName, contestType = self:getCurrentEvent()
	if not contestName then return end
	if not contestType == "vote" then return end
	local admin = false
	local votes = self:getVotes(userId, contestName)

	if client:getRank() >= RANK.Moderator then
		local votesCount = table.size(votes)
		local votesSum = 0
		for id, rating in pairs(votes) do votesSum = votesSum + rating end
		admin = ("%d Abstimmung/en | %d Sterne"):format(votesCount, math.round(votesSum/votesCount, 2))
	end

	if votes[client:getId()] then
		client:triggerEvent("drawingContestReceiveVote", votes[client:getId()], admin)
	end
end



