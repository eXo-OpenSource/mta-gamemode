DrawContest = inherit(Singleton)

function DrawContest:constructor()
	addRemoteEvents{"onDrawContestSave", "drawContestRequestPlayers", "drawContestRequestImage"}


	addEventHandler("onDrawContestSave", root, bind(self.saveImage, self))
	addEventHandler("drawContestRequestPlayers", root, bind(self.requestPlayers, self))
	addEventHandler("drawContestRequestImage", root, bind(self.requestImage, self))
end

function DrawContest:saveImage(data)
	sql:queryExec("INSERT ??_drawContest (UserId, DrawData, Datetime) VALUES (?, ?, NOW())", sql:getPrefix(), client:getId(), data)
	client:sendInfo("Bild gespeichert!")
end

function DrawContest:requestPlayers()
	local players = {}
	local result = sql:queryFetch("SELECT UserId FROM ??_drawContest", sql:getPrefix())
    for i, row in pairs(result) do
		players[row.UserId] = Account.getNameFromId(row.UserId)
	end
	client:triggerEvent("drawContestReceivePlayers", players)
end

function DrawContest:requestImage(userId)
	local row = sql:queryFetchSingle("SELECT DrawData FROM ??_drawContest WHERE UserId = ?", sql:getPrefix(), userId)
	triggerLatentClientEvent(client, "drawContestReceiveImage", 50000, false, client, row.DrawData)
end




