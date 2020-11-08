--WEB (PHP mtasdk)

function phpSDKGetPlayers()
	local name
	local players = {}
	local i = 1
	for index, player in pairs(getElementsByType("player")) do
		players[i]={}
		players[i]["pname"] = player:getName()
		i = i+1
	end
	return players
end

function phpSDKSendChatBox(messageType, target, message, r, g, b)
	if messageType == "admin" then
		Admin:getSingleton():sendMessage(message, r, g, b, type(target) == "number" and target or 1)
	elseif messageType == "player" then
		local target = getPlayerFromName(target)
		if isElement(target) then
			target:outputChat(message, r, g, b)
		end
	end
	return
end

function phpSDKSendMessage(targetType, targetId, message, options)
	local options = options or {}
	local color = {r = options.r or nil, g = options.g or nil, b = options.b or nil}
	local title = options.title or nil
	local offline = options.offline or false
	local messageType = options.messageType or "chat"
	local timeout = options.timeout or nil
	local minRank = options.minRank or nil
	local withPrefix = options.withPrefix or false

	if targetType == "admin" then
		if messageType == "shortMessage" then
			Admin:getSingleton():sendShortMessageWithRank(message, minRank or 1, title, color, timeout)
		else
			Admin:getSingleton():sendMessage(message, color.r, color.g, color.b, minRank or 1)
		end

		local data = toJSON({status = "SUCCESS"}, true)
		return data:sub(2, #data-1)
	elseif targetType == "faction" then
		if targetId == "state" then
			if messageType == "shortMessage" then
				FactionState:getSingleton():sendShortMessageWithRank(message, minRank or 0, title, color, timeout)
			else
				FactionState:getSingleton():sendMessageWithRank(message, color.r, color.g, color.b, minRank or 0, withPrefix)
			end

			local data = toJSON({status = "SUCCESS"}, true)
			return data:sub(2, #data-1)
		else
			local faction = FactionManager.Map[targetId]

			if not faction then
				local data = toJSON({status = "FAILED"}, true)
				return data:sub(2, #data-1)
			end

			if messageType == "shortMessage" then
				faction:sendShortMessageWithRank(message, minRank or 0, title, color, timeout)
			else
				faction:sendMessageWithRank(message, color.r, color.g, color.b, minRank or 0, withPrefix)
			end

			local data = toJSON({status = "SUCCESS"}, true)
			return data:sub(2, #data-1)
		end
	elseif targetType == "company" then
		local company = CompanyManager.Map[targetId]

		if not company then
			local data = toJSON({status = "FAILED"}, true)
			return data:sub(2, #data-1)
		end

		if messageType == "shortMessage" then
			company:sendShortMessageWithRank(message, minRank or 0, title, color, timeout)
		else
			company:sendMessageWithRank(message, color.r, color.g, color.b, minRank or 0, withPrefix)
		end

		local data = toJSON({status = "SUCCESS"}, true)
		return data:sub(2, #data-1)
	elseif targetType == "group" then
		local group = GroupManager.Map[targetId]

		if not group then
			local data = toJSON({status = "FAILED"}, true)
			return data:sub(2, #data-1)
		end

		if messageType == "shortMessage" then
			group:sendShortMessageWithRank(message, minRank or 0, title, color, timeout)
		else
			group:sendMessageWithRank(message, color.r, color.g, color.b, minRank or 0, withPrefix)
		end

		local data = toJSON({status = "SUCCESS"}, true)
		return data:sub(2, #data-1)
	elseif targetType == "player" then
		local target, isOffline = DatabasePlayer.get(targetId)
		if target then
			if isOffline then
				local data = toJSON({status = "SUCCESS", online = false}, true)
				if offline then
					target:addOfflineMessage(message, 1)
				else
					data = toJSON({status = "FAILED", online = false}, true)
				end

				target.m_DoNotSave = true
				delete(target)

				return data:sub(2, #data-1)
			else
				if messageType == "infoBox" then
					target:sendInfo(message, timeout, title)
				elseif messageType == "successBox" then
					target:sendSuccess(message, timeout, title)
				elseif messageType == "warningBox" then
					target:sendWarning(message, timeout, title)
				elseif messageType == "errorBox" then
					target:sendError(message, timeout, title)
				elseif messageType == "shortMessage" then
					target:sendShortMessage(message, title, color, timeout)
				else
					target:sendMessage(message, color.r, color.g, color.b, true)
				end
				local data = toJSON({status = "SUCCESS", online = true}, true)
				return data:sub(2, #data-1)
			end
		end
	end
	return
end

function phpSDKLoadCharacterInfo(targetName) -- Cause of Migrator
	local target = getPlayerFromName(targetName)
	if isElement(target) then
		target:loadMigratorData()
	end
end

function phpSDKSendActivationMailCallback(answer)
	outputChatBox("phpSDKSendActivationMailCallback: "..answer)
end

function phpSDKSendActivationMail(userID, username)
	callRemote(INGAME_WEB_PATH .. "/ingame/boardActivation.php", phpSDKSendActivationMailCallback, userID, username)
end

function phpSDKSendOnlinePlayers()
	local players = {}
	local i = 1

	for index, player in pairs(getElementsByType("player")) do
		if player.isActive and player:isActive() then
			players[i]= {
				["Name"] = player:getName(),
				["Id"] = player:getId() or 0,
				["Faction"] = player:getFaction() and player:getFaction():getId() or 0,
				["Company"] = player:getCompany() and player:getCompany():getId() or 0,
				["GroupId"] = player:getGroup() and player:getGroup():getId() or 0,
				["PlayTime"] = player:getPlayTime() or 0,
			}
			i = i+1
		end
	end
	return players
end

function phpSDKGiveQRAchievement(playerId)
	Async.create(
		function()
			local player, isOffline = DatabasePlayer.get(playerId)
			if isOffline then
				player:load()
				delete(player)
				return false
			else
				player:giveAchievement(78)
				return true
			end
		end
	)()
end

function phpSDKKickPlayer(adminId, targetId, reason)
	local target = DatabasePlayer.Map[targetId]

	if not isElement(target) or target:getType() ~= "player" then
		local data = toJSON({status = "ERROR", error = "TARGET_OFFLINE"}, true)
		outputServerLog(data:sub(2, #data-1))
		return data:sub(2, #data-1)
	end

	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		outputServerLog(data:sub(2, #data-1))
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	Admin:getSingleton():sendShortMessage(_("%s hat %s gekickt! Grund: %s", nil, adminName, targetName, reason))
	outputChatBox("Der Spieler "..targetName.." wurde von "..adminName.." gekickt!",root, 200, 0, 0)
	outputChatBox("Grund: "..reason,root, 200, 0, 0)

	if isElement(admin) then
		kickPlayer(target, admin, reason)
	else
		kickPlayer(target, reason)
	end

	if aCreated then delete(admin) end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKPrisonPlayer(adminId, targetId, duration, reason)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	if not duration then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "DURATION_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local duration = tonumber(duration)

	if not duration or duration <= 0 then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "DURATION_INVALID"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	if tCreated then
		target:load(true)
	end

	Admin:getSingleton():sendShortMessage(_("%s hat %s für %d Minuten ins Prison gesteckt! Grund: %s", nil, adminName, targetName, duration, reason))
	Admin:getSingleton():addPunishLog(adminId, targetId, "prisonCP", reason, duration * 60)
	outputChatBox(_("%s hat %s für %s Minuten ins Prison gesteckt!!", nil, adminName, targetName, duration), root, 200, 0, 0)
	outputChatBox(_("Grund: %s", nil, reason), root, 200, 0, 0)
	target:setPrison(duration * 60)

	if tCreated then delete(target) end
	if aCreated then delete(admin) end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKUnprisonPlayer(adminId, targetId, reason)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	if tCreated then
		target:load(true)
	end

	local prisonTime = target:getRemainingPrisonTime()

	if prisonTime == 0 then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "PLAYER_NOT_IN_PRISON"}, true)
		return data:sub(2, #data-1)
	end

	Admin:getSingleton():sendShortMessage(_("%s hat %s aus dem Prison gelassen! Grund: %s", nil, adminName, targetName, reason))
	Admin:getSingleton():addPunishLog(adminId, targetId, "unPrisonCP", reason, 0)

	if tCreated then
		target:setPrison(0, true)
	else
		target:endPrison()
	end

	if tCreated then delete(target) end
	if aCreated then delete(admin) end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKBanPlayer(adminId, targetId, duration, reason)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	if not duration then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "DURATION_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local duration = tonumber(duration)

	if not duration or duration < 0 then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "DURATION_INVALID"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	if duration == 0 then -- perma
		Admin:getSingleton():sendShortMessage(_("%s hat %s permanent gebannt! Grund: %s", nil, adminName,targetName, reason))
		Admin:getSingleton():addPunishLog(adminId, targetId, "permabanCP", reason, 0)
		outputChatBox(_("Der Spieler %s  wurde von %s gebannt!", nil, targetName, adminName), root, 200, 0, 0)
		outputChatBox(_("Grund: %s", nil, reason), root, 200, 0, 0)
		Ban.addBan(targetId, adminId, reason, 0, adminName)
	else -- time
		Admin:getSingleton():sendShortMessage(_("%s hat %s für %d Stunden gebannt! Grund: %s", nil, adminName, targetName, duration, reason))
		Admin:getSingleton():addPunishLog(adminId, targetId, "timebanCP", reason, duration * 60 * 60)
		outputChatBox(_("Der Spieler %s  wurde von %s für %d Stunden gebannt!", nil, targetName, adminName, duration), root, 200, 0, 0)
		outputChatBox(_("Grund: %s", nil, reason), root, 200, 0, 0)
		Ban.addBan(targetId, adminId, reason, duration * 60 * 60, adminName)
	end

	if tCreated then delete(target) end
	if aCreated then delete(admin) end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKUnbanPlayer(adminId, targetId, reason)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	Admin:getSingleton():sendShortMessage(_("%s hat %s offline entbannt!", nil, adminName, targetName))
	Admin:getSingleton():addPunishLog(adminId, targetId, "unbanCP", reason, 0)
	sql:queryExec("DELETE FROM ??_bans WHERE serial = ? OR player_id = ?;", sql:getPrefix(), Account.getLastSerialFromId(targetId), targetId)
	outputChatBox(_("Der Spieler %s wurde von %s entbannt!", nil, targetName, adminName), root, 200, 0, 0)

	if tCreated then delete(target) end
	if aCreated then delete(admin) end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKAddWarn(adminId, targetId, duration, reason)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	if not duration then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "DURATION_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local duration = tonumber(duration)

	if not duration or duration < 0 then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "DURATION_INVALID"}, true)
		return data:sub(2, #data-1)
	end

	if not reason or reason == "" then
		if tCreated then delete(target) end
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "REASON_MISSING"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	Warn.addWarn(targetId, adminId, reason, duration*60*60*24)
	Admin:getSingleton():addPunishLog(adminId, targetId, "warnCP", reason, duration*60*60*24)
	Admin:getSingleton():sendShortMessage(_("%s hat %s verwarnt! Ablauf in %d Tagen, Grund: %s", nil, adminName, targetName, duration, reason))

	if target and isElement(target) then
		target:sendMessage(_("Du wurdest von %s verwarnt! Ablauf in %s Tagen, Grund: %s", target, adminName, duration, reason), 255, 0, 0)
	end

	if tCreated then delete(target) end
	if aCreated then delete(admin) end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKRemoveWarn(adminId, targetId, warnId)
	local admin, aCreated = DatabasePlayer.get(adminId)
	if not admin then
		local data = toJSON({status = "ERROR", error = "UNKNOWN_ADMIN_ID"}, true)
		return data:sub(2, #data-1)
	end

	local target, tCreated = DatabasePlayer.get(targetId)
	if not target then
		if aCreated then delete(admin) end
		local data = toJSON({status = "ERROR", error = "UNKNOWN_PLAYER_ID"}, true)
		return data:sub(2, #data-1)
	end

	local adminName = Account.getNameFromId(adminId)
	local targetName = Account.getNameFromId(targetId)

	Warn.removeWarn(targetId, warnId)
	Admin:getSingleton():addPunishLog(adminId, targetId, "removeWarnCP", nil, 0)
	Admin:getSingleton():sendShortMessage(_("%s hat einen Warn von %s entfernt!", nil, adminName, targetName))

	if tCreated then delete(target) end
	if aCreated then delete(admin) end

	local data = toJSON({status = "SUCCESS"}, true)
	return data:sub(2, #data-1)
end

function phpSDKTakeScreenShot(userId)
	local player = DatabasePlayer.Map[userId]

	if player and isElement(player) then
		local tag = string.random(128)
		local status = player:takeScreenShot(800, 600, "cp:" .. tag, 30, 1024 * 512, 500)
		if status then
			local data = toJSON({status = "SUCCESS", tag = tag}, true)
			return data:sub(2, #data-1)
		else
			local data = toJSON({status = "ERROR", error = "FAILED"}, true)
			return data:sub(2, #data-1)
		end
	else
		local data = toJSON({status = "ERROR", error = "PLAYER_IS_OFFLINE"}, true)
		return data:sub(2, #data-1)
	end
end

function phpSDKStartScreenCapture(userId, width, height, frameLimit, time, forceResample)
	local player = DatabasePlayer.Map[userId]

	if player and isElement(player) then
		local tag = string.random(128)
		local status = player:triggerEvent("onScreenCaptureStart", tag, width, height, frameLimit, time, forceResample)
		if status then
			local data = toJSON({status = "SUCCESS", tag = tag}, true)
			return data:sub(2, #data-1)
		else
			local data = toJSON({status = "ERROR", error = "FAILED"}, true)
			return data:sub(2, #data-1)
		end
	else
		local data = toJSON({status = "ERROR", error = "PLAYER_IS_OFFLINE"}, true)
		return data:sub(2, #data-1)
	end
end

function phpSDKStopScreenCapture(userId)
	local player = DatabasePlayer.Map[userId]

	if player and isElement(player) then
		local status = player:triggerEvent("onScreenCaptureStop")
		if status then
			local data = toJSON({status = "SUCCESS", tag = tag}, true)
			return data:sub(2, #data-1)
		else
			local data = toJSON({status = "ERROR", error = "FAILED"}, true)
			return data:sub(2, #data-1)
		end
	else
		local data = toJSON({status = "ERROR", error = "PLAYER_IS_OFFLINE"}, true)
		return data:sub(2, #data-1)
	end
end


addEventHandler("onPlayerScreenShot", root, function(resource, status, pixels, timestamp, tag)
	if resource == getThisResource() then
		if tag:sub(0, 3) == "cp:" then
			local tag = tag:sub(4, #tag)
			if status == "ok" then
				fetchRemote("https://cp.exo-reallife.de/api/admin/screenshots", {
					method = "POST",
					formFields = {
						status = "SUCCESS",
						data = pixels,
						tag = tag
					}
				}, function() end)
			elseif status == "minimized" then
				fetchRemote("https://cp.exo-reallife.de/api/admin/screenshots", {
					method = "POST",
					formFields = {
						status = "ERROR",
						error = "MINIMIZED",
						tag = tag
					}
				}, function() end)
			elseif status == "disabled" then
				fetchRemote("https://cp.exo-reallife.de/api/admin/screenshots", {
					method = "POST",
					formFields = {
						status = "ERROR",
						error = "DISABLED",
						tag = tag
					}
				}, function() end)
			end
		end
	end
end)
