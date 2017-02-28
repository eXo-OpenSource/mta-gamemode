-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Account.lua
-- *  PURPOSE:     Account class
-- *
-- ****************************************************************************
local MULTIACCOUNT_CHECK = GIT_BRANCH == "release/production" and true or false
--local INVITATION = GIT_BRANCH == "release/production" and true or false
INVITATION = false

Account = inherit(Object)
addRemoteEvents{"remoteClientSpawn", "checkInvitationCode"}
function Account.login(player, username, password, pwhash)
	if player:getAccount() then return false end
	if (not username or not password) and not pwhash then return false end

	if not username:match("^[a-zA-Z0-9_.%[%]]*$") then
		player:triggerEvent("loginfailed", "Ungültiger Nickname. Bitte melde dich bei einem Admin!")
		return false
	end

	-- Ask SQL to fetch ForumID
	sql:queryFetchSingle(Async.waitFor(self), ("SELECT Id, ForumID, Name, RegisterDate, InvitationId FROM ??_account WHERE %s = ?"):format(username:find("@") and "email" or "Name"), sql:getPrefix(), username)
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
					player:triggerEvent("loginfailed", "Fehler: Gespeichertes Passwort ungültig!")
					return false
				end
			else
				local param = {["userId"] = row2.userID; ["password"] = password;}
				local data, errno = Account.asyncCallAPI("checkPassword", toJSON(param))
				if errno == 0 then
					local returnData = fromJSON(data)
					if not returnData then outputConsole(data, player) return end
					if returnData.error then
						player:triggerEvent("loginfailed", "Fehler: "..returnData.error)
						return false
					end
					if returnData.login == true then
						Account.createAccount(player, row2.userID, row2.username, row2.email)
						return
					else
						player:triggerEvent("loginfailed", "Fehler: Unbekannter Fehler")
						return
					end
				else
					outputDebugString("Error@FetchRemote: "..errno)
				end
			end
		end
		player:triggerEvent("loginfailed", "Fehler: Spieler nicht gefunden!")
		return
	end

	local Id = row.Id
	local ForumID = row.ForumID
	local Username = row.Name
	local InvitationId = row.InvitationId
	local RegisterDate = row.RegisterDate

	-- Ask SQL to fetch the password from forum
	board:queryFetchSingle(Async.waitFor(self), "SELECT password, registrationDate FROM wcf1_user WHERE userID = ?", ForumID)
	local row = Async.wait()
	if not row or not row.password then
		player:triggerEvent("loginfailed", "Fehler: Falscher Name oder Passwort") -- "Error: Invalid username or password"
		return false
	end

	if pwhash then
		if pwhash == row.password then
			Account.loginSuccess(player, Id, Username, ForumID, RegisterDate, InvitationId, pwhash)
		else
			player:triggerEvent("loginfailed", "Fehler: Falscher Name oder Passwort") -- Error: Invalid username or password2
			return false
		end
	else
		local param = {["userId"] = ForumID; ["password"] = password;}
		local data, errno = Account.asyncCallAPI("checkPassword", toJSON(param))
		if errno == 0 then
			local returnData = fromJSON(data)
			if not returnData then outputConsole(data, player) return end
			if returnData.error then
				player:triggerEvent("loginfailed", "Fehler: "..returnData.error)
				return false
			end
			if returnData.login == true then
				Account.loginSuccess(player, Id, Username, ForumID, RegisterDate, InvitationId, row.password)
			else
				player:triggerEvent("loginfailed", "Fehler: Unbekannter Fehler")
			end
		else
			outputDebugString("Error@FetchRemote: "..errno)
		end
	end
end
addEvent("accountlogin", true)
addEventHandler("accountlogin", root, function(...) Async.create(Account.login)(client, ...) end)

function Account.loginSuccess(player, Id, Username, ForumID, RegisterDate, InvitationId, pwhash)
	if DatabasePlayer.getFromId(Id) then
		player:triggerEvent("loginfailed", "Fehler: Dieser Account ist schon in Benutzung")
		return false
	end
	-- Update last serial and last login
	sql:queryExec("UPDATE ??_account SET LastSerial = ?, LastIP = ?, LastLogin = NOW() WHERE Id = ?", sql:getPrefix(), player:getSerial(), player:getIP(), Id)
	if MULTIACCOUNT_CHECK then
		if Account.MultiaccountCheck(player, Id) == false then
			return false
		end
	end

	if INVITATION then
		if not Account.checkInvitation(player, Id, InvitationId) then
			return
		end
	end
	player.m_Account = Account:new(Id, Username, player, false, ForumID, RegisterDate)

	Warn.checkWarn(player, true)
	Ban.checkBan(player, true)

	if player:getTutorialStage() == 1 then
		player:createCharacter()
	end
	player:loadCharacter()
	player:triggerEvent("Event_StartScreen")

	StatisticsLogger:addLogin( player, Username, "Login")
	triggerClientEvent(player, "loginsuccess", root, pwhash, player:getTutorialStage())
end

addEvent("checkRegisterAllowed", true)
addEventHandler("checkRegisterAllowed", root, function()
	local name = Account.getNameFromSerial(client:getSerial()) -- Todo Activate on production use
	if name and MULTIACCOUNT_CHECK then
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
	if not username:match("^[a-zA-Z0-9_.]*$") or #username < 3 then
		player:triggerEvent("registerfailed", _("Fehler: Ungültiger Nickname.", player))
		return false
	end

	if #password < 5 then
		player:triggerEvent("registerfailed", _("Fehler: Passwort zu kurz! Min. 5 Zeichen!", player))
		return false
	end

	-- Validate email
	if not email:match("^[%w._-]+@[%w._-]+%.%w+$") or #email > 50 then
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
	local data, errno = Account.asyncCallAPI("createAccount", toJSON(param))
	if errno == 0 then
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
		outputDebugString("Error@FetchRemote: "..errno)
	end
end

function Account.asyncCallAPI(func, postData)
	fetchRemote(("https://exo-reallife.de/ingame/userApi/api.php?func=%s"):format(func), 1, Async.waitFor(), postData, false)
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

function Account.checkInvitation(player, Id, InvitationId)
	if InvitationId and InvitationId > 0 then
		local row = sql:queryFetchSingle("SELECT * FROM ??_invitations WHERE Id = ?", sql:getPrefix(), InvitationId)
		if row then
			if row.UserId == Id then
				if row.Active == 1 then
					return true
				else
					player:sendError(_("Der Invitation-Code wurde deaktiviert!", player))
				end
			else
				player:sendError(_("Der Invitation-Code wird von einem anderen Spieler verwendet!", player))
			end
		else
			player:sendError(_("Der Invitation-Code wurde gelöscht!", player))
		end
	end
	player:triggerEvent("closeLogin")
	player:triggerEvent("inputBox", "Invitation-Code eingeben", "eXo-Reallife ist derzeit nur mit Invitation-Code spielbar! Bitte gib diesen hier ein:", "checkInvitationCode", Id)
	player.m_DoNotSave = true
	return false
end

function Account.checkInvitationCode(code, AccountId)
	local row = sql:queryFetchSingle("SELECT * FROM ??_invitations WHERE InvitationKey = ?", sql:getPrefix(), code)
	if row then
		if row.UserId == 0 then
			if row.Active == 1 then
				if not AccountId or AccountId == 0 then
					AccountId = Account.getIdFromName(client:getName())
				end
				--outputServerLog("AccountID: "..AccountId)
				sql:queryExec("UPDATE ??_invitations SET Serial = ?, UserId = ?, Used = NOW() WHERE Id = ? ", sql:getPrefix(), client:getSerial(), AccountId, row.Id)
				sql:queryExec("UPDATE ??_account SET InvitationId = ? WHERE Id = ? ", sql:getPrefix(), row.Id, AccountId)
				client:sendSuccess(_("Der Code wurde angenommen!\nDu wirst nun reconnected!", client))
				client.m_DoNotSave = true
				setTimer(function(player)
					redirectPlayer(player, "", 0)
				end, 5000, 1, client)
				return true
			else
				client:sendError(_("Der Invitation-Code wurde deaktiviert!", client))
			end
		else
			client:sendError(_("Der Invitation-Code wurde bereits benützt!", client))
		end
	else
		client:sendError(_("Ungültiger Invitation-Code!", client))
	end
	client:triggerEvent("inputBox", "Invitation-Code eingeben", "eXo-Reallife ist derzeit nur mit Invitation-Code spielbar! Bitte gib diesen hier ein:", "checkInvitationCode")
	client.m_DoNotSave = true
end
addEventHandler("checkInvitationCode", root, Account.checkInvitationCode)

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

addEventHandler("remoteClientSpawn", root, function()
	client:spawn()
end
)
