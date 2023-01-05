-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AntiCheat.lua
-- *  PURPOSE:     Anticheat class
-- *
-- ****************************************************************************
AntiCheat = inherit(Singleton)
addRemoteEvents{"AntiCheat:ReportBlip", "AntiCheat:ReportFarmerTeleport"}

AntiCheat.AllowedDataChange = {
	["playingTime"] = true,
	["playingTimeFaction"] = true,
	["playingTimeCompany"] = true,
	["playingTimeGroup"] = true,
	["dutyTimeFaction"] = true,
	["dutyTimeCompany"] = true,
	["dutyTime"] = true,
	["writing"] = true,
	["i:left"] = true,
	["i:right"] = true,
	["i:warn"] = true,
	["Neon"] = true,
	["NeonColor"] = true,
	["heligrab.vehicle"] = true,
	["heligrab.legsUp"] = true,
	["heligrab.side"] = true,
	["heligrab.linePercent"] = true,
	["heligrab.offsets"] = true,
	["abseiling"] = true,
	["abseilped"] = true,
	["abseilspeed"] = true,
	["parachuting"] = true,
	["animation_state"] = true,
	["skydiving"] = true,
	["W_A:w0"] = true,
	["W_A:w1"] = true,
	["W_A:w2"] = true,
	["W_A:w3"] = true,
	["W_A:w4"] = true,
	["W_A:w5"] = true,
	["W_A:w6"] = true,
	["W_A:alt_w5"] = true,
	["syncer"] = true,
	["lastSync"] = true,
	["superman:flying"] = true,
	["isEquipmentGUIOpen"] = true,
	["clickable"] = true,
	["FactionChatEnabled"] = true,
	["CompanyChatEnabled"] = true,
	["AllianceChatEnabled"] = true,
	["StateChatEnabled"] = true,
	["GroupChatEnabled"] = true,
	["HeliGlue"] = true,
}
AntiCheat.Check = {
	[14] = true,
	[28] = true,
	[33] = true,
}
AntiCheat.KickMessage = {
	[14] = "Der Server erlaubt keine virtuellen Maschinen",
	[28] = "Der Server erlaubt kein Wine",
	[33] = "Der Server erlaubt keine Net Limiter",
}

function AntiCheat:constructor()
	-- Disable clientside synced element data setting entirely (even though we don't store anything important via elementdatas)
	addEventHandler("onElementDataChange", root,
		function(name, oldValue)
			if AntiCheat.AllowedDataChange[name] then return end

			-- Serverside changes are okay
			if not client then
				return
			end

			setElementData(source, name, oldValue)
		end
	)

	self.m_AntiCheatWhitelist = {}
	local result = sql:queryFetch("SELECT Serial, Bypass FROM ??_account_anticheat_whitelist w INNER JOIN ??_account_to_serial a on w.PlayerId = a.PlayerId", sql:getPrefix(), sql:getPrefix())
	if result then
		for __, info in pairs(result) do
			self.m_AntiCheatWhitelist[info.Serial] = info.Bypass ~= "" and fromJSON(info.Bypass) or {}
		end
	end

	addEventHandler("onPlayerACInfo", root, bind(self.Event_playerAcInfo, self))
	for _,plr in pairs( getElementsByType("player") ) do
		resendPlayerACInfo( plr )
	end

	addCommandHandler("reloadAntiCheatWhitelist", bind(self.reloadWhitelist, self), false, false)
	addCommandHandler("addPlayerToWhitelist", bind(self.addPlayerToWhitelist, self), false, false)
	addCommandHandler("removePlayerFromWhitelist", bind(self.removePlayerFromWhitelist, self), false, false)
end

function AntiCheat:Event_playerAcInfo(detectedACList, d3d9Size, d3d9MD5, d3d9SHA256)
	for __, acCode in pairs(detectedACList) do
		acCode = tonumber(acCode)
		if AntiCheat.Check[acCode] then
			if not self.m_AntiCheatWhitelist[source:getSerial()] or not table.find(self.m_AntiCheatWhitelist[source:getSerial()], acCode) then
				source:kick(_("%s (#%s)", source, AntiCheat.KickMessage[acCode], acCode))
			end
		end
	end
end

function AntiCheat:report(player, name, severity)
	if type(player) ~= "userdata" or type(name) ~= "string" or type(severity) ~= "number" then
		outputServerLog("Bad argument @ Anticheat.report")
		outputServerLog(debug.traceback())
		return
	end
	outputServerLog(("AntiCheat:report(%s, %s, %i)"):format(player:getName(), name, severity))

	sql:queryExec("INSERT INTO ??_cheatlog (UserId, Name, Severity, Date) VALUES(?, ?, ?, NOW())", sql:getPrefix(), player:getId(), name, severity)
end

addEventHandler("AntiCheat:ReportBlip", root,
	function(blipCount)
		AntiCheat:getSingleton():report(client, ("Invalid Blip Count: %s"):format(tostring(blipCount)), CheatSeverity.High)
	end
)

addEventHandler("AntiCheat:ReportFarmerTeleport", root,
	function(dist)
		AntiCheat:getSingleton():report(client, ("used teleport bug on farmer job (%sm)"):format(dist), CheatSeverity.High)
	end
)

function AntiCheat:reloadWhitelist(player)
	if player:getRank() >= RANK.Developer then
		self.m_AntiCheatWhitelist = {}
		local result = sql:queryFetch("SELECT Serial, Bypass FROM ??_account_anticheat_whitelist w INNER JOIN ??_account_to_serial a on w.PlayerId = a.PlayerId", sql:getPrefix(), sql:getPrefix())
		if result then
			for __, info in pairs(result) do
				self.m_AntiCheatWhitelist[info.Serial] = info.Bypass ~= "" and fromJSON(info.Bypass) or {}
			end
			player:sendSuccess("AntiCheat Whitelist aktualisiert!")
		end
	end
end

function AntiCheat:addPlayerToWhitelist(player, cmd, name, acCode, serial)
	if player:getRank() >= RANK.Developer then
		acCode = tonumber(acCode)
		if not AntiCheat.Check[acCode] then
			return player:sendError(_("Man kann Spieler für den Anticheat Code #%s nicht whitelisten.", player, acCode))
		end

		if serial then
			if not self.m_AntiCheatWhitelist[serial] then
				self.m_AntiCheatWhitelist[serial] = {acCode}
				player:sendSuccess(_("Die Serial wurde bis Server Restart erfolgreich für den Anticheat Code #%s gewhitelistet.", player, acCode))
				return
			end
			if table.find(self.m_AntiCheatWhitelist[serial], acCode) then
				return player:sendError(_("Die Serial ist bereits für den Anticheat Code #%s gewhitelistet.", player, acCode))
			end
			if not table.find(self.m_AntiCheatWhitelist[serial], acCode) then
				table.insert(self.m_AntiCheatWhitelist[serial], acCode)
				player:sendSuccess(_("Die Serial wurde bis Server Restart erfolgreich für den Anticheat Code #%s gewhitelistet.", player, acCode))
				return
			end
		end
		if name and name ~= "false" and #name > 2 then
			if not Account.getIdFromName(name) then
				return player:sendError(_("Fehler: Spieler nicht gefunden!", player))
			end

			local userId = Account.getIdFromName(name)
			local userName = Account.getNameFromId(userId)
			local result = sql:queryFetch("SELECT Serial FROM ??_account_to_serial WHERE PlayerId = ?", sql:getPrefix(),userId)
			local count = 0 
			local errorCount = 0
			if result then
				for __, value in pairs(result) do
					count = count + 1
					if self.m_AntiCheatWhitelist[value.Serial] then
						if not table.find(self.m_AntiCheatWhitelist[value.Serial], acCode) then
							table.insert(self.m_AntiCheatWhitelist[value.Serial], acCode)
						else
							errorCount = errorCount + 1
						end
					else
						self.m_AntiCheatWhitelist[value.Serial] = {acCode}
					end
				end

				if count == errorCount then
					return player:sendError(_("Der Spieler %s (Id: %d) ist für den Anticheat Code #%s bereits gewhitelistet", player, userName, userId, acCode))
				elseif errorCount > 0 then
					player:sendWarning(_("Eine oder mehrere Serials von dem Spieler %s (Id: %d) waren bereits für den Anticheat Code #%s gewhitelistet", player, userName, userId, acCode))
				end
			end

			local bypassTbl, numRows = sql:queryFetch("SELECT Bypass FROM ??_account_anticheat_whitelist WHERE PlayerId = ?", sql:getPrefix(), userId)
			if numRows > 0 then
				bypassTbl = fromJSON(bypassTbl[1].Bypass)
				if not table.find(bypassTbl, acCode) then
					table.insert(bypassTbl, acCode)
				end
			else
				bypassTbl = {acCode}
			end

			sql:queryExec("INSERT INTO ??_account_anticheat_whitelist (PlayerId, Bypass) VALUES (?, ?) ON DUPLICATE KEY UPDATE Bypass = ?", sql:getPrefix(), userId, toJSON(bypassTbl), toJSON(bypassTbl))
			player:sendSuccess(_("Der Spieler %s (Id: %d) wurde erfolgreich für den Anticheat Code #%s gewhitelistet.", player, userName, userId, acCode))
		end
	end
end

function AntiCheat:removePlayerFromWhitelist(player, cmd, name, acCode, serial)
	if player:getRank() >= RANK.Developer then
		acCode = tonumber(acCode)
		if not AntiCheat.Check[acCode] then
			return player:sendError(_("Man kann Spieler für den Anticheat Code #%s nicht whitelisten.", player, acCode))
		end

		if serial then
			if not self.m_AntiCheatWhitelist[serial] then
				return player:sendError(_("Die Serial ist nicht für den Anticheat Code #%s gewhitelistet.", player, acCode))
			end
			if not table.find(self.m_AntiCheatWhitelist[serial], acCode) then
				return player:sendError(_("Die Serial ist nicht für den Anticheat Code #%s gewhitelistet", player, acCode))
			end
				
			table.removevalue(self.m_AntiCheatWhitelist[serial], acCode)
			player:sendSuccess(_("Die Serial wurde bis zum Server Restart erfolgreich aus der Whitelist für den Anticheat Code #%s entfernt.", player, acCode))
		end

		if name and name ~= "false" and #name > 2 then
			if not Account.getIdFromName(name) then
				return player:sendError(_("Fehler: Spieler nicht gefunden!", player))
			end
				
			local userId = Account.getIdFromName(name)
			local userName = Account.getNameFromId(userId)
			local result = sql:queryFetch("SELECT Serial FROM ??_account_to_serial WHERE PlayerId = ?", sql:getPrefix(), userId)
			local count = 0
			local errorCount = 0

			if result then
				for __, value in pairs(result) do
					count = count + 1
					if self.m_AntiCheatWhitelist[value.Serial] then
						if table.find(self.m_AntiCheatWhitelist[value.Serial], acCode) then
							table.removevalue(self.m_AntiCheatWhitelist[value.Serial], acCode)
							if table.size(self.m_AntiCheatWhitelist[value.Serial]) == 0 then
								self.m_AntiCheatWhitelist[value.Serial] = nil
							end
						else
							errorCount = errorCount + 1
						end
					else
						errorCount = errorCount + 1
					end
				end

				if count == errorCount then
					return player:sendError(_("Der Spieler %s (Id: %d) ist für den Anticheat Code #%s nicht gewhitelistet", player, userName, userId, acCode))
				elseif errorCount > 0 then
					player:sendWarning(_("Eine oder mehrere Serials von dem Spieler %s (Id: %d) waren bereits für den Anticheat Code #%s von der Whitelist entfernt oder nie gewhitelistet.", player, userName, userId, acCode))
				end
			end

			local bypassTbl, numRows = sql:queryFetch("SELECT Bypass FROM ??_account_anticheat_whitelist WHERE PlayerId = ?", sql:getPrefix(), userId)
			if numRows > 0 then
				bypassTbl = fromJSON(bypassTbl[1].Bypass)
				table.removevalue(bypassTbl, acCode)
				if table.size(bypassTbl) == 0 then
					sql:queryExec("DELETE FROM ??_account_anticheat_whitelist WHERE PlayerId = ?", sql:getPrefix(), userId)
				else
					sql:queryExec("UPDATE ??_account_anticheat_whitelist SET Bypass = ? WHERE PlayerId = ?", sql:getPrefix(), toJSON(bypassTbl), userId)
				end
			end

			player:sendSuccess(_("Der Spieler %s (Id: %d) wurde erfolgreich aus der Whitelist für den Anticheat Code #%s entfernt.", player, userName, userId, acCode))
		end
	end
end