-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Warn.lua
-- *  PURPOSE:     Warn class
-- *
-- ****************************************************************************
Warn = {}
function Warn.addWarn(who, author, reason, duration)
	local authorId = 0
	if type(author) == "userdata" and getElementType(author) == "player" then
		authorId = author:getId()
	elseif author == nil then
		author = "System"
	end

	if not duration then return end

	local player = false
	if type(who) == "userdata" and getElementType(who) == "player" then
		player = who
		who = player:getId()
	end

	local expires = duration + getRealTime().timestamp

	sql:queryExec("INSERT INTO ??_warns(userId, adminId, reason, expires, created) VALUES (?, ?, ?, ?, ?)", sql:getPrefix(), who, authorId, reason, expires, getRealTime().timestamp)

	if isElement(player) then
		player:setWarns()
	end

	if Warn.getAmount(who) >= 3 then
		if not player then
			player = DatabasePlayer.Map[id]
		end

		if player then
			kickPlayer(player, _("Du wurdest aufgrund von 3 Warns gebannt!", player))
		end
	end
end

function Warn.getAmount(who)
	if type(who) == "userdata" and getElementType(who) == "player" then
		player = who
		who = player:getId()
	end
	local rows = sql:queryFetch("SELECT reason, expires FROM ??_warns WHERE userId = ?;", sql:getPrefix(), who)
	return #rows
end

function Warn.removeWarn(who, warnId)
	if type(who) == "userdata" and getElementType(who) == "player" then
		player = who
		who = player.m_Id
	end
	sql:queryExec("DELETE FROM ??_warns WHERE userId = ? AND Id = ?;", sql:getPrefix(), who, warnId)
	if isElement(player) then
		player:setWarns()
	end
end

function Warn.checkWarn(player, id, doNotSave)
	sql:queryExec("DELETE FROM ??_warns WHERE userId = ? AND expires < ?;", sql:getPrefix(), id, getRealTime().timestamp)

	if Warn.getAmount(id) >= 3 then
		sql:queryFetchSingle(Async.waitFor(), "SELECT expires FROM ??_warns WHERE userId = ? ORDER BY expires;", sql:getPrefix(), id)
		local row = Async.wait()
		if row then
			local days = math.floor((row.expires - getRealTime().timestamp)/60/60/24)
			if doNotSave then player.m_DoNotSave = true end
			kickPlayer(player, _("Du hast 3 Warns! Der nächste läuft in %d Tagen ab!", player, days+1))
			return false
		end
		return true
	elseif Warn.getAmount(id) > 0 then
		outputChatBox(_("Vorsicht du hast bereits %d Verwarnung/en!", player, Warn.getAmount(id)),player, 255,0,0)
	end
	return true
end
