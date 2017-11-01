-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Account.lua
-- *  PURPOSE:     Account class
-- *
-- ****************************************************************************
local MULTIACCOUNT_CHECK = GIT_BRANCH == "release/production" and true or false

Account = inherit(Object)

function Account.login(player, username, password, pwhash)
	if player:getAccount() then return false end
	if (not username or not password) and not pwhash then return false end

	if not username:match("^[a-zA-Z0-9_.%[%]]*$") then
		player:triggerEvent("loginfailed", "Ungültiger Nickname. Dein Name darf nur alphanumerische Zeichen verwenden.")
		return false
	end

	-- Ask SQL to fetch ForumID
	sql:queryFetchSingle(Async.waitFor(self), ("SELECT Id, ForumID, Name, RegisterDate FROM ??_account WHERE %s = ?"):format(username:find("@") and "email" or "Name"), sql:getPrefix(), username)
	local row = Async.wait()
	if not row or not row.Id then
		board:queryFetchSingle(Async.waitFor(self), "SELECT username, password, userID, email FROM wcf1_user WHERE username LIKE ?", username)
		local row2 = Async.wait()
		if row2 and row2.password then
			if pwhash then
				if pwhash == row2.password then
					outputConsole("Creating Account for "..username)
					Account.createAccount(player, row2.userID, row2.username, row2.email)
					return
				else
					player:triggerEvent("loginfailed", "Gespeichertes Passwort ungültig! Bitte gib dein Passwort erneut in das Eingabefeld ein.")
					return false
				end
			else
				local param = {["userId"] = row2.userID; ["password"] = password;}
				local data, responseInfo = Account.asyncCallAPI("checkPassword", toJSON(param))
				if responseInfo["success"] == true then
					local returnData = fromJSON(data)
					if not returnData then outputConsole(data, player) return end
					if returnData.error then
						player:triggerEvent("loginfailed", returnData.error)
						return false
					end
					if returnData.login == true then
						Account.createAccount(player, row2.userID, row2.username, row2.email)
						return
					else
						player:triggerEvent("loginfailed", "Unbekannter Fehler")
						return
					end
				else
					outputDebugString("Error@FetchRemote: "..responseInfo["statusCode"])
				end
			end
		end
		player:triggerEvent("loginfailed", "Spieler nicht gefunden!")
		return
	end

	local Id = row.Id
	local ForumID = row.ForumID
	local Username = row.Name
	local RegisterDate = row.RegisterDate

	-- Ask SQL to fetch the password from forum
	board:queryFetchSingle(Async.waitFor(self), "SELECT password, registrationDate FROM wcf1_user WHERE userID = ?", ForumID)
	local row = Async.wait()
	if not row or not row.password then
		player:triggerEvent("loginfailed", "Falscher Name oder Passwort") -- "Error: Invalid username or password"
		return false
	end

	if pwhash then
		if pwhash == row.password then
			Account.loginSuccess(player, Id, Username, ForumID, RegisterDate, pwhash)
		else
			player:triggerEvent("loginfailed", "Falscher Name oder Passwort") -- Error: Invalid username or password2
			return false
		end
	else
		local param = {["userId"] = ForumID; ["password"] = password;}
		local data, responseInfo = Account.asyncCallAPI("checkPassword", toJSON(param))
		if responseInfo["success"] == true then
			local returnData = fromJSON(data)
			if not returnData then outputConsole(data, player) return end
			if returnData.error then
				player:triggerEvent("loginfailed", returnData.error)
				return false
			end
			if returnData.login == true then
				Account.loginSuccess(player, Id, Username, ForumID, RegisterDate, row.password)
			else
				player:triggerEvent("loginfailed", "Unbekannter Fehler")
			end
		else
			outputDebugString("Error@FetchRemote: "..responseInfo["statusCode"])
		end
	end
end
addEvent("accountlogin", true)
addEventHandler("accountlogin", root, function(...) Async.create(Account.login)(client, ...) end)

function Account.loginSuccess(player, Id, Username, ForumID, RegisterDate, pwhash)
	if DatabasePlayer.getFromId(Id) then
		player:triggerEvent("loginfailed", "Dieser Account ist schon in Benutzung")
		return false
	end

	if MULTIACCOUNT_CHECK then
		MultiAccount.addSerial(Id, player:getSerial())

		if #MultiAccount.getAccountsBySerial(player:getSerial()) > 1 then
			if not MultiAccount.isAccountLinkedToSerial(Id, player:getSerial()) then
				if not MultiAccount.allowedToCreateAnMultiAccount(player:getSerial()) then
					player:triggerEvent("loginfailed", "Deine Serial wird für mehrere Accounts benutzt. Dies kann passieren, wenn sich jemand auf deinem PC mit anderen Accountdaten einloggt. Bitte melde dich im Forum (forum.exo-reallife.de) unter 'administrative Anfragen', um das Problem zu beseitigen.")
					return false
				else
					MultiAccount.linkAccountToSerial(Id, player:getSerial())
				end
			end
		end
	end

	if Warn.checkWarn(player, true) or Ban.checkBan(player, true) then
		player:triggerEvent("loginfailed", "Du wurdest gebannt!")
		return false
	end

	-- Update last serial and last login
	sql:queryExec("UPDATE ??_account SET LastSerial = ?, LastIP = ?, LastLogin = NOW() WHERE Id = ?", sql:getPrefix(), player:getSerial(), player:getIP(), Id)

	player.m_Account = Account:new(Id, Username, player, false, ForumID, RegisterDate)

	if not player or not isElement(player) then -- Cause of kick directly after login (e.g. ban, warn) / Should not happened now
		outputDebugString("Account.loginSuccess: Player-Element for "..UserName.." not found!", 1)
		return
	end

	if not Account.checkCharacter(Id) then
		Admin:getSingleton():sendNewPlayerMessage(player)
		player:createCharacter()
	end

	player:loadCharacter()
	player:spawn()

	StatisticsLogger:addLogin( player, Username, "Login")
	ClientStatistics:getSingleton():handle(player)
	player:triggerEvent("loginsuccess", pwhash)
end

function Account.checkCharacter(Id)
	local row = sql:queryFetchSingle("SELECT Id FROM ??_character WHERE Id = ?", sql:getPrefix(), Id)
	return row and true or false
end

addEvent("checkRegisterAllowed", true)
addEventHandler("checkRegisterAllowed", root, function()
	if MULTIACCOUNT_CHECK then
		local playerId = MultiAccount.isSerialUsed(client:getSerial())
		if playerId then
			if not MultiAccount.allowedToCreateAnMultiAccount(client:getSerial()) then
				local name = Account.getNameFromId(playerId)
				client:triggerEvent("receiveRegisterAllowed", false, name)
			end
		end
	end
end)

function Account.register(player, username, password, email)
	if player:getAccount() then return false end
	if not username or not password then return false end

	-- Some sanity checks on the username
	-- Require at least 1 letter and a length of 3
	if not username:match("^[a-zA-Z0-9_.]*$") or #username < 3 or #username > 22 then
		player:triggerEvent("registerfailed", _("Ungültiger Nickname. Dein Name darf nur alphanumerische Zeichen und den Unterstrich (_) verwenden.", player))
		return false
	end

	if #password < 5 then
		player:triggerEvent("registerfailed", _("Passwort zu kurz! Min. 5 Zeichen!", player))
		return false
	end

	-- Validate email
	if not email:match("^[%w._-]+@[%w._-]+%.%w+$") or #email > 50 then
		player:triggerEvent("registerfailed", _("Ungültige eMail", player))
		return false
	end

	-- Check Serial
	if MULTIACCOUNT_CHECK then
		if MultiAccount.isSerialUsed(player:getSerial()) then
			if not MultiAccount.allowedToCreateAnMultiAccount(player:getSerial()) then
				player:triggerEvent("registerfailed", _("Du besitzt bereits ein Account!", player))
				return false
			end
		end
	end

	-- Check if someone uses this username already
	board:queryFetchSingle(Async.waitFor(self), "SELECT userID, username, email FROM wcf1_user WHERE username = ? OR email = ?", username, email)
	local row = Async.wait()
	if row then
		if row.username == username then
			player:triggerEvent("registerfailed", _("Benutzername wird bereits verwendet", player))
		elseif row.email == email then
			player:triggerEvent("registerfailed", _("Diese E-Mail wird bereits verwendet", player))
		end

		return false
	end

	Account.createForumAccount(player, username, password, email)
end
addEvent("accountregister", true)
addEventHandler("accountregister", root, function(...) Async.create(Account.register)(client, ...) end)

function Account.createAccount(player, boardId, username, email)
	local result, _, Id = sql:queryFetch("INSERT INTO ??_account (ForumID, Name, EMail, Rank, LastSerial, LastIP, LastLogin, RegisterDate) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW());", sql:getPrefix(), boardId, username, email, 0, player:getSerial(), player:getIP())
	if result then
		player.m_Account = Account:new(Id, username, player, false)
		player:createCharacter()

		Account.loginSuccess(player, Id, username, boardId, RegisterDate, 0, false)
	else
		player:triggerEvent("loginfailed", "Fehler: Unable to create Ingame-Acc.")
	end
end

function Account.guest(player)
	player.m_Account = Account:new(0, "Guest", player, true)
	player:spawn()
	triggerClientEvent(player, "loginsuccess", root, nil, 0)
end
addEvent("accountguest", true)
addEventHandler("accountguest", root, function() Async.create(Account.guest)(client) end)

function Account.createForumAccount(player, username, password, email)
	if not password then return end
	local param = {["username"] = username; ["password"] = password; ["email"] = email;}
	local data, responseInfo = Account.asyncCallAPI("createAccount", toJSON(param))
	if responseInfo["success"] == true then
		local returnData = fromJSON(data)
		if not returnData then outputConsole(data, player) return end
		if returnData.error then
			player:triggerEvent("loginfailed", "Fehler: "..returnData.error)
			return false
		end
		if returnData.boardId then
			Account.createAccount(player, returnData.boardId, username, email)
		else
			player:triggerEvent("loginfailed", "Fehler: Forum-Acc konnte nicht angelegt werden")
		end
	else
		outputDebugString("Error@FetchRemote: "..responseInfo["statusCode"])
	end
end

function Account.asyncCallAPI(func, postData)
	local options = {
		["connectionAttempts"] = 1,
		["postData"] = postData
	}
	fetchRemote(("https://exo-reallife.de/ingame/userApi/api.php?func=%s"):format(func), options, Async.waitFor())
	return Async.wait()
end

function Account:constructor(id, username, player, guest, ForumID, RegisterDate)
	-- Account Information
	self.m_Id = id
	self.m_Username = username
	self.m_Player = player
	self.m_ForumId = ForumID
	self.m_RegisterDate = RegisterDate or "Unbekannt"
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
		self.m_RegisterDate = "Gast"
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

function Account:getRegistrationDate()
	return self.m_RegisterDate
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

function Account.getBoardIdFromId(id)
	--[[sql:queryFetchSingle(Async.waitFor(self), "SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	local row = Async.wait()]]
	local player = Player.getFromId(id)
	if player and isElement(player) then
		return player:getAccount().m_ForumId
	end

	local row = sql:queryFetchSingle("SELECT ForumID FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	return row and row.ForumID
end

function Account.getNameFromSerial(serial)
	local row = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE LastSerial = ?", sql:getPrefix(), serial)
	return row and row.Name
end

function Account.getSerialAmount(serial)
	local result = sql:queryFetch("SELECT Id FROM ??_account WHERE LastSerial = ?", sql:getPrefix(), serial)
	return #result
end

function Account.getLastSerialFromId(Id)
	local row = sql:queryFetchSingle("SELECT LastSerial FROM ??_account WHERE Id = ?", sql:getPrefix(), Id)
	return row.LastSerial or 0
end

function Account.getIdFromName(name)
	local row = sql:queryFetchSingle("SELECT Id FROM ??_account WHERE Name = ?", sql:getPrefix(), name)
	if row and row.Id then
		return row.Id
	end
	return false
end

function Account.getBoardIdFromName(name)
	local row = sql:queryFetchSingle("SELECT ForumID FROM ??_account WHERE Name = ?", sql:getPrefix(), name)
	return row.ForumID or 0
end
