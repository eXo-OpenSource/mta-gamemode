-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Ban.lua
-- *  PURPOSE:     Ban class
-- *
-- ****************************************************************************
Ban = {}
function Ban.addBan(who, author, reason, duration)
	local authorId = 0
	if type(author) == "userdata" and getElementType(author) == "player" then
		authorId = author:getId()
	elseif author == nil then
		author = "System"
	end

	if not duration then duration = 0 end

	local player = false
	local playerId = 0
	local serial = ""
	if type(who) == "userdata" and getElementType(who) == "player" then
		player = who
		serial = getPlayerSerial(who)
		playerId = player:getId()
	else
		playerId = who
		serial = Account.getLastSerialFromId(playerId)
	end

	local expires = duration + getRealTime().timestamp
	if duration == 0 then expires = 0 end

	sql:queryExec("INSERT INTO ??_bans(serial, author, reason, expires, player_id) VALUES (?, ?, ?, ?, ?)", sql:getPrefix(), serial, authorId, reason, expires, playerId)

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
			reasonstr = ("You were banned by %s for %s (Reason: %s"):format(author.name, string.duration(duration), reason)
		else
			reasonstr = ("You were permanently banned by %s (Reason: %s"):format(author.name, reason)
		end
		outputDebug(player)
		kickPlayer(player, reasonstr)
	end
end

function Ban.checkBan(player)
	local serial = getPlayerSerial(player)
	return Ban.checkSerial(serial, player)
end

function Ban.checkSerial(serial, player)
	-- Note: true = not banned
	local row = sql:queryFetchSingle("SELECT reason, expires FROM ??_bans WHERE serial = ?;", sql:getPrefix(), serial)
	if row then
		local duration = row.expires
		if duration == 0 then
			reasonstr = ("You are permanently banned (Reason: %s"):format(row.reason)
		elseif duration - getRealTime().timestamp < 0 then
			sql:queryExec("DELETE FROM ??_bans WHERE serial = ?;", sql:getPrefix(), serial)
			return true
		elseif duration > 0 then
			reasonstr = ("You are banned for %s (Reason: %s"):format(string.duration(duration - getRealTime().timestamp), row.reason)
		end

		if player and isElement(player) then kickPlayer(player, reasonstr) end
		return false
	end
	return true
end

function Ban.checkOfflineBan(playerId)
	local serial = Account.getLastSerialFromId(playerId)
	if Ban.checkSerial(serial) == true then
		return false
	else
		return true
	end
end
