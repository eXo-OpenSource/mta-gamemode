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
		if type(author) == "number" then
			author = DatabasePlayer.getFromId(author)
		end
		if duration > 0 then
			reasonstr = ("+Timeban: %s von %s (Grund: %s)"):format( string.duration(duration), author.name, reason)
		else
			reasonstr = ("+Permanenter Bann von %s (Grund: %s)"):format(author.name, reason)
		end
		kickPlayer(player, author, reasonstr)
	end
end

function Ban.checkBan(player, id, doNotSave)
	if player and isElement(player) then
		local serial = getPlayerSerial(player)
		return Ban.checkSerial(serial, player, id, nil, doNotSave)
	end
	return false
end

function Ban.checkSerial(serial, player, id, cancel, doNotSave)
	-- Note: true = not banned
	if not id then id = player and player:getId() or "false" end

	sql:queryFetchSingle(Async.waitFor(), "SELECT reason, expires FROM ??_bans WHERE serial = ? OR player_id = ?;", sql:getPrefix(), serial, id)
	local row = Async.wait()
	if row then
		local duration = row.expires
		if duration == 0 then
			reasonstr = ("Du wurdest permanent gebannt (Grund: %s)"):format(row.reason)
		elseif duration - getRealTime().timestamp < 0 then
			sql:queryExec("DELETE FROM ??_bans WHERE expires > 0 AND (serial = ? OR player_id = ?);", sql:getPrefix(), serial, id)
			return true
		elseif duration > 0 then
			reasonstr = ("Du bist noch %s gebannt! (Grund: %s)"):format(string.duration(duration - getRealTime().timestamp), row.reason)
		end
		if doNotSave then player.m_DoNotSave = true end
		if cancel then
			if player and isElement(player) then cancelEvent(true, reasonstr) end
		else
			if player and isElement(player) then kickPlayer(player, reasonstr) end
		end
		return false
	end
	return true
end

function Ban.checkOfflineBan(playerId)
	local serial = Account.getLastSerialFromId(playerId)
	if Ban.checkSerial(serial, nil, playerId) == true then
		return false
	else
		return true
	end
end

addEventHandler("onPlayerConnect", root, function(nick, ip, username, serial)
	Async.create(function()
		Ban.checkSerial(serial, source, nil, true, true)
	end)()
end)
