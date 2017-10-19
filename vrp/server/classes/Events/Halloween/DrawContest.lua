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
	addRemoteEvents{"onDrawContestSave", "drawContestRequestPlayers", "drawContestRequestImage", "drawContestRateImage"}


	addEventHandler("onDrawContestSave", root, bind(self.saveImage, self))
	addEventHandler("drawContestRequestPlayers", root, bind(self.requestPlayers, self))
	addEventHandler("drawContestRequestImage", root, bind(self.requestImage, self))
	addEventHandler("drawContestRateImage", root, bind(self.rateImage, self))
end

function DrawContest:saveImage(data)
	sql:queryExec("INSERT ??_drawContest (UserId, DrawData, Datetime) VALUES (?, ?, NOW())", sql:getPrefix(), client:getId(), data)
	client:sendInfo("Bild gespeichert!")
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
	return "none", "none"
end

function DrawContest:requestPlayers()
	local players = {}
	local result = sql:queryFetch("SELECT UserId FROM ??_drawContest", sql:getPrefix())
    for i, row in pairs(result) do
		players[row.UserId] = Account.getNameFromId(row.UserId)
	end
	local contestName, contestType = self:getCurrentEvent()
	client:triggerEvent("drawContestReceivePlayers", contestName, contestType, players)
end

function DrawContest:requestImage(userId)
	local row = sql:queryFetchSingle("SELECT DrawData FROM ??_drawContest WHERE UserId = ?", sql:getPrefix(), userId)
	triggerLatentClientEvent(client, "drawContestReceiveImage", 50000, false, client, row.DrawData)
end

function DrawContest:rateImage(userId)
	local row = sql:queryFetchSingle("SELECT Ratings FROM ??_drawContest WHERE UserId = ?", sql:getPrefix(), userId)
	triggerLatentClientEvent(client, "drawContestReceiveImage", 50000, false, client, row.DrawData)
end




