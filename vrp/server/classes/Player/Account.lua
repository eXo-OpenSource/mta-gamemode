-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Account.lua
-- *  PURPOSE:     Account class
-- *
-- ****************************************************************************
Account = inherit(Object)

function Account.login(player, username, password, pwhash)
	if player:getAccount() then return false end
	if (not username or not password) and not pwhash then return false end

	-- Ask SQL to fetch ForumID
	sql:queryFetchSingle(Async.waitFor(self), ("SELECT Id, ForumID, Name FROM ??_account WHERE %s = ?"):format(username:find("@") and "email" or "Name"), sql:getPrefix(), username)
	local row = Async.wait()
	if not row or not row.Id then
		player:triggerEvent("loginfailed", "Fehler: Falscher Name oder Passwort")
		return false
	end

	-- Todo: Remove this workaround when done?
	-- -- -- -- -- -- Workaround -- -- -- -- -- --
	if row.ForumID == 0 then
		local Id = row.Id
		local Username = row.Name

		sql:queryFetchSingle(Async.waitFor(self), ("SELECT Salt, Password, EMail FROM ??_account WHERE Id = ?"), sql:getPrefix(), Id)
		local row = Async.wait()
		if not row or not row.Salt or not row.Password or not row.EMail then
			player:triggerEvent("loginfailed", "Internal error while creating forum account #1. Please contact an admin. ID: " .. tostring(Id))
			return false
		end

		-- Need password in plaintext
		if pwhash then
			player:triggerEvent("loginfailed", "Bitte gib dein Passwort erneut ein")
			return false
		else
			pwhash = sha256(("%s%s"):format(row.Salt, password))
		end

		if pwhash ~= row.Password then
			player:triggerEvent("loginfailed", "Fehler: Falscher Name oder Passwort") -- "Error: Invalid username or password"
			return false
		end

		-- Validate email
		if not row.EMail:match("^[%w._-]+@%w+%.%w+$") or #row.EMail > 50 then
			player:triggerEvent("loginfailed", "Internal error while creating forum account #2. Please contact an admin. ID: " .. tostring(Id))
			return false
		end

		-- Check if someone uses this username already
		board:queryFetchSingle(Async.waitFor(self), "SELECT userID, username, email FROM wcf1_user WHERE username = ? OR email = ?", Username, row.EMail)
		local result = Async.wait()
		if result then
			player:triggerEvent("loginfailed", "Internal error while creating forum account #3. Please contact an admin. ID: " .. tostring(Id))
			return false
		end

		local userID = Account.createForumAccount(Username, password, row.EMail)
		if userID then
			sql:queryExec("UPDATE ??_account SET LastSerial = ?, ForumID = ?, Password = 0, Salt = 0, LastLogin = NOW() WHERE Id = ?", sql:getPrefix(), getPlayerSerial(player), userID, Id)

			if DatabasePlayer.getFromId(Id) then
				player:triggerEvent("loginfailed", "Fehler: Dieser Account ist schon in Benutzung")
				return false
			end

			if Account.MultiaccountCheck(player, Id) == false then
				return false
			end

			player.m_Account = Account:new(Id, Username, player, false)

			if player:getTutorialStage() == 1 then
				player:createCharacter()
			end

			player:loadCharacter()
			player:spawn()

			triggerClientEvent(player, "loginsuccess", root, pwhash, player:getTutorialStage())
			return
		end
	end
	-- -- -- -- -- -- Workaround end -- -- -- -- -- --

	local Id = row.Id
	local ForumID = row.ForumID
	local Username = row.Name

	-- Ask SQL to fetch the password from forum
	board:queryFetchSingle(Async.waitFor(self), "SELECT password FROM wcf1_user WHERE userID = ?", ForumID)
	local row = Async.wait()
	if not row or not row.password then
		player:triggerEvent("loginfailed", "Fehler: Falscher Name oder Passwort") -- "Error: Invalid username or password"
		return false
	end

	if not pwhash then
		local salt = string.sub(row.password, 1, 29)
		pwhash = WBBC.getDoubleSaltedHash(password, salt)
	end

	if pwhash ~= row.password then
		player:triggerEvent("loginfailed", "Fehler: Falscher Name oder Passwort") -- Error: Invalid username or password2
		return false
	end

	if DatabasePlayer.getFromId(Id) then
		player:triggerEvent("loginfailed", "Fehler: Dieser Account ist schon in Benutzung")
		return false
	end

	-- Update last serial and last login
	sql:queryExec("UPDATE ??_account SET LastSerial = ?, LastLogin = NOW() WHERE Id = ?", sql:getPrefix(), getPlayerSerial(player), Id)

	if Account.MultiaccountCheck(player, Id) == false then
		return false
	end

	player.m_Account = Account:new(Id, Username, player, false)

	if player:getTutorialStage() == 1 then
		player:createCharacter()
	end

	player:loadCharacter()
	player:spawn()

	triggerClientEvent(player, "loginsuccess", root, pwhash, player:getTutorialStage())
end
addEvent("accountlogin", true)
addEventHandler("accountlogin", root, function(...) Async.create(Account.login)(client, ...) end)

addEvent("checkRegisterAllowed", true)
addEventHandler("checkRegisterAllowed", root, function()
	local name = Account.getNameFromSerial(client:getSerial())
	if name then
		client:triggerEvent("receiveRegisterAllowed", false, name)
	else
		client:triggerEvent("receiveRegisterAllowed", true)
	end
end)

function Account.register(player, username, password, email)
	if player:getAccount() then return false end
	if not username or not password then return false end

	-- Some sanity checks on the username
	-- Require at least 1 letter and a length of 3
	if not username:match("[a-zA-Z]") or #username < 3 then
		player:triggerEvent("registerfailed", _("Fehler: Ungültiger Nickname", player))
		return false
	end

	if #password < 5 then
		player:triggerEvent("registerfailed", _("Fehler: Passwort zu kurz! Min. 5 Zeichen!", player))
		return false
	end

	-- Validate email
	if not email:match("^[%w._-]+@%w+%.%w+$") or #email > 50 then
		player:triggerEvent("registerfailed", _("Fehler: Ungültige eMail", player))
		return false
	end

	-- Check if someone uses this username already
	board:queryFetchSingle(Async.waitFor(self), "SELECT userID, username, email FROM wcf1_user WHERE username = ? OR email = ?", username, email)
	local row = Async.wait()
	if row then
		if row.username == username then
			player:triggerEvent("registerfailed", _("Fehler: Benutzername wird bereits verwendet", player))
		elseif row.email == email then
			player:triggerEvent("registerfailed", _("Fehler: Diese E-Mail wird bereits verwendet", player))
		end

		return false
	end

	local userID = Account.createForumAccount(username, password, email)
	if userID then
		local result, _, Id = sql:queryFetch("INSERT INTO ??_account (ForumID, Name, EMail, Rank, LastSerial, LastLogin) VALUES (?, ?, ?, ?, ?, NOW());", sql:getPrefix(), userID, username, email, 0, getPlayerSerial(player))
		if result then
			player.m_Account = Account:new(Id, username, player, false)
			player:createCharacter()
			player:loadCharacter()
			player:spawn()
			player:triggerEvent("loginsuccess", nil, player:getTutorialStage())

			-- TODO: Send validation mail via PHP
		end
	end
end
addEvent("accountregister", true)
addEventHandler("accountregister", root, function(...) Async.create(Account.register)(client, ...) end)

function Account.guest(player)
	player.m_Account = Account:new(0, "Guest", player, true)
	player:spawn()
	triggerClientEvent(player, "loginsuccess", root, nil, 0)
end
addEvent("accountguest", true)
addEventHandler("accountguest", root, function() Async.create(Account.guest)(client) end)

function Account.createForumAccount(username, password, email)
	local nTimestamp = getRealTime().timestamp
	local pwhash = WBBC.getDoubleSaltedHash(password)
	local nLanguageID = 1

	board:queryFetch("START TRANSACTION;")
	local result, _, userID = board:queryFetch("INSERT INTO wcf1_user (username, email, password, languageID, registrationDate, userOnlineGroupID, activationCode) VALUES (?, ?, ?, ?, ?, 1, 1)", username, email, pwhash, nLanguageID, nTimestamp)
	if result then
		local result = board:queryFetch("SELECT optionID, defaultValue FROM wcf1_user_option")
		if result then
			local columns = {}
			local values = {}
			for _, row in ipairs(result) do
				--table.insert(columns, "userOption" .. row["optionID"])
				table.insert(columns, ("userOption%s"):format(row["optionID"]))
				local v = row["defaultValue"]
				if v then v = tostring(v) else v = "" end
				table.insert(values, v)
			end

			board:queryExec(("INSERT INTO wcf1_user_option_value (userID, %s) VALUES (?, '%s')"):format(table.concat(columns, ","), table.concat(values, "','")), userID)
			board:queryExec("INSERT INTO wcf1_user_to_group (userID, groupID) VALUES (?,?)", userID, 1)
			board:queryExec("INSERT INTO wcf1_user_to_language (userID, languageID) VALUES (?,?)", userID, nLanguageID)

			board:queryFetch("COMMIT;")
			return userID
		end
	end

	board:queryFetch("ROLLBACK;")
	return false
end

function Account:constructor(id, username, player, guest)
	-- Account Information
	self.m_Id = id
	self.m_Username = username
	self.m_Player = player
	player.m_IsGuest = guest;
	player.m_Id = self.m_Id

	if not guest then
		sql:queryFetchSingle(Async.waitFor(self), "SELECT Rank, LastLogin FROM ??_account WHERE Id = ?;", sql:getPrefix(), self.m_Id)
		local row = Async.wait()

		self.m_Rank = row.Rank
		self.m_LastLogin = row.LastLogin

		if self.m_Rank == RANK.Banned then
			Ban:new(player)
			return
		end
	else
		self.m_Rank = RANK.Guest
        player:loadCharacter()
	end
end

function Account:getPlayer()
	return self.m_Player
end

function Account:getId()
	return self.m_Id;
end

function Account:getRank()
	return self.m_Rank
end

function Account:getLastLogin()
	return self.m_LastLogin
end

function Account:getName()
	return self.m_Username
end

function Account.getNameFromId(id)
	--[[sql:queryFetchSingle(Async.waitFor(self), "SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	local row = Async.wait()]]
	local player = Player.getFromId(id)
	if player and isElement(player) then
		return player:getName()
	end

	local row = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	return row and row.Name
end

function Account.getNameFromSerial(serial)
	local row = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE LastSerial = ?", sql:getPrefix(), serial)
	return row and row.Name
end

function Account.getSerialAmount(serial)
	local result = sql:queryFetch("SELECT Id FROM ??_account WHERE LastSerial = ?", sql:getPrefix(), serial)
	return #result
end

function Account.MultiaccountCheck(player, Id)
	if Account.getSerialAmount(player:getSerial()) > 1 then
		if not Account.getMultiaccount(Id) then
			player:triggerEvent("loginfailed", "Fehler: Deine Serial wurde von einem anderen Account benutzt!")
			return false
		else
			for dbId, serial in pairs(Account.getIdsFromSerial(player:getSerial())) do
				if dbId ~= Id then
					if not Account.isAcceptetMultiaccount(dbId, Id) then
						player:triggerEvent("loginfailed", "Fehler: Deine Serial wurde von einem anderen Account benutzt!")
						return false
					end
				end
			end
		end
	end
	return true
end

function Account.getIdsFromSerial(serial)
	local result = sql:queryFetch("SELECT Id, LastSerial FROM ??_account WHERE LastSerial = ?", sql:getPrefix(), serial)
	local accounts = {}
	for i, row in pairs(result) do
		accounts[row.Id] = row.LastSerial
	end
	return accounts
end

function Account.getMultiaccount(id)
	local row = sql:queryFetchSingle("SELECT Player1, Player2 FROM ??_multiaccounts WHERE Player1 = ? OR Player2 = ?", sql:getPrefix(), id, id)
	if row then
		if row["Player1"] == id then
			return row["Player2"]
		else
			return row["Player1"]
		end
	else
		return false
	end
end

function Account.isAcceptetMultiaccount(id1, id2)
	local row = sql:queryFetchSingle("SELECT Id FROM ??_multiaccounts WHERE (Player1 = ? AND Player2 = ?) or (Player2 = ? AND Player1 = ?)", sql:getPrefix(), id1, id2, id1, id2)
	if row then return true else return false end
end

function Account.getIdFromName(name)
	local row = sql:queryFetchSingle("SELECT Id FROM ??_account WHERE Name = ?", sql:getPrefix(), name)
	return row and row.Id
end
