addRemoteEvents{"onDrawContestSave"}

addEventHandler("onDrawContestSave", root, function(data)
	sql:queryExec("INSERT ??_drawContest (UserId, DrawData, Datetime) VALUES (?, ?, NOW())", sql:getPrefix(), client:getId(), data)
	client:sendInfo("Bild gespeichert!")
end)

