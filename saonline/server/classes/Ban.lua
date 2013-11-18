Ban = {}
function Ban.addBan(who, author, reason, duration)
	if type(author) == "userdata" and getElementType(author) == "player" then
		author = getPlayerName(author)
	elseif author == nil then
		author = "System"
	end
	
	if not duration then duration = 0 end
	
	local player = false
	if type(who) == "userdata" and getElementType(who) == "player" then
		who = getPlayerSerial(who)
		player = who
	end
	
	sql:queryExec("INSERT INTO ??_bans(serial, author, reason, expires) VALUES (?, ?, ?, ?)", sql:getPrefix(), serial, author, reason, duration + getRealTime().timestamp)
	
	if not player then
		for k, v in pairs(getElementsByType("player")) do
			if getPlayerSerial(v) == serial then
				player = v
				break
			end
		end
	end
	
	if player then
		local reasonstr 
		if duration > 0 then
			reasonstr = ("You were banned by %s for %s (Reason: %s"):format(author, string.duration(duration), reason)
		else
			reasonstr = ("You were permanently banned by %s (Reason: %s"):format(author, reason)
		end
		outputDebug(player)
		kickPlayer(player, reasonstr)
	end
end

function Ban.checkBan(player)
	local serial = getPlayerSerial(player)
	sql:queryFetchSingle(Async.waitFor(), "SELECT reason, expires FROM ??_bans WHERE serial = ?;", sql:getPrefix(), serial)
	local row = Async.wait()
	if #row > 0 then
		local duration = row.expires
		if duration > 0 then
			reasonstr = ("You are banned for %s (Reason: %s"):format(string.duration(duration - getRealTime().timestamp), reason)
		else
			reasonstr = ("You are permanently banned (Reason: %s"):format(reason)
		end
		kickPlayer(player, reasonstr)
		return false
	end
	return true
end