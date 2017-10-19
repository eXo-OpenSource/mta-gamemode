DrawContest = inherit(Singleton)
DrawContest.Events = {
	["Male PewX"] = {
		["Draw"] = {["Start"] = 1508450400, ["End"] = 1508709600}, 	--25.10 - 26.10
		["Vote"] = {["Start"] = 1508709600, ["End"] = 1508882400}  	--26.10 - 27.10
	},
	["Male einen Kürbis"] = {
		["Draw"] = {["Start"] = 1508882400, ["End"] = 1508968800}, 	--25.10 - 26.10
		["Vote"] = {["Start"] = 1508968800, ["End"] = 1509055200}  	--26.10 - 27.10
	},
	["Male Süßigkeiten"]= {
		["Draw"] = {["Start"] = 1509055200, ["End"] = 1509141600}, 	--27.10 - 28.10
		["Vote"] = {["Start"] = 1509141600, ["End"] = 1509228000} 	--28.10 - 29.10
	},
	["Male ein Halloween-Kostüm"]= {
		["Draw"] = {["Start"] = 1509228000, ["End"] = 1509318000}, 	--29.10 - 30.10
		["Vote"] = {["Start"] = 1509318000, ["End"] = 1509404400}	--30.10 - 31.10
	},
	["Male eine Hexe"]= {
		["Draw"] = {["Start"] = 1509404400, ["End"] = 1509490800},	--31.10 - 01.11
		["Vote"] = {["Start"] = 1509490800, ["End"] = 1509577200}	--01.11 - 02.11
	},
	["Male eine Halloweenparty"]= {
		["Draw"] = {["Start"] = 1509577200, ["End"] = 1509663600},	--02.11 - 03.11
		["Vote"] = {["Start"] = 1509663600, ["End"] = 1509750000}	--03.11 - 04.11
	}
}

function DrawContest:constructor()
	addRemoteEvents{"drawContestRequestPlayers", "drawContestRateImage"}


	addEventHandler("drawContestRequestPlayers", root, bind(self.requestPlayers, self))
	addEventHandler("drawContestRateImage", root, bind(self.rateImage, self))
end

function DrawContest:getCurrentEvent()
	local now = getRealTime().timestamp
	for name, data in pairs(DrawContest.Events) do
		if now > data["Draw"]["Start"] and now < data["Draw"]["End"] then
			return name, "draw"
		end
		if now > data["Vote"]["Start"] and now < data["Vote"]["End"] then
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
    for i, row in pairs(result) do
		players[row.UserId] = Account.getNameFromId(row.UserId)
	end
	client:triggerEvent("drawContestReceivePlayers", contestName, contestType, players)
end

function DrawContest:rateImage(userId)
	local contestName, contestType = self:getCurrentEvent()
	if not contestName then client:sendError("Aktuell läuft kein Zeichen-Wettbewerb!") return end
	if not contestType == "vote" then client:sendError("Aktuell kann nicht Abgestimmt werden!") return end

	--Todo

end




