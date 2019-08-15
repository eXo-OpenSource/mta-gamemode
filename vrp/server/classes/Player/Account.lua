-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/Account.lua
-- *  PURPOSE:     Account class
-- *
-- ****************************************************************************

-- DEV NOTICE
--[[
	Steps on Register:
		1.) checkRegisterAllowed triggered From Client
		2.) receiveRegisterAllowed triggered to Client
		3.) Account.register triggered from Client
		4.) Account.createForumAccount
		5.) Account.createAccount
		6.) Account.loginSuccess
		7.) In Account.loginSuccess there is Account.checkCharacter and
		8.) player:createCharacter() in Account.loginSuccess
		9.) Finished
]]

local MULTIACCOUNT_CHECK = GIT_BRANCH == "release/production" and true or false

Account = inherit(Object)
Account.REGISTRATION_ACTIVATED = true

function Account.login(player, username, password, pwhash, enableAutologin)
	if player:getAccount() then return false end
	if (not username or not password) and not pwhash then return false end

	outputServerLog("[ACCOUNT] " .. inspect(player) .. " - "  .. inspect(player.getSerial) .. " - "  .. inspect(player.loadCharacter))

	if not player or not player.loadCharacter or not player.getSerial  then
		if player then
			kickPlayer(player)
		end
		player:triggerEvent("loginfailed", "Interner Fehler")
		return false
	end

	if not username:match("^[a-zA-Z0-9_.%[%]]*$") then
		player:triggerEvent("loginfailed", "Ungültiger Nickname. Dein Name darf nur alphanumerische Zeichen verwenden.")
		return false
	end

	if pwhash and #pwhash == 65 then
		-- check if is an autologin token
		local data = split(pwhash, ".")
		if #data == 2 and #data[1] == 32 and #data[2] == 32 then
			sql:queryFetchSingle(Async.waitFor(self), ("SELECT Id, ForumId, Name, RegisterDate, TeamspeakId FROM ??_account WHERE LCASE(Name) = ? AND AutologinToken = ?"), sql:getPrefix(), username, pwhash)
			local row = Async.wait()

			if row and player:getSerial() == data[2] then
				Account.loginSuccess(player, row.Id, row.Name, row.ForumId, row.RegisterDate, row.TeamspeakId, pwhash)
				return
			end
		end
	end

	Forum:getSingleton():userLogin(username, password, Async.waitFor(self))
	local data = Async.wait()

	local resData = fromJSON(data)

	if resData and resData.status and resData.status == 200 then
		local data = resData.data
		sql:queryFetchSingle(Async.waitFor(self), ("SELECT Id, ForumId, Name, RegisterDate, TeamspeakId, AutologinToken FROM ??_account WHERE ForumId = ?"), sql:getPrefix(), data.userID)
		local row = Async.wait()

		if not row then
			Account.createAccount(player, data.userID, data.username, data.email)
			return
		else
			local loginToken = nil

			if enableAutologin then
				loginToken = string.random(32) .. "." .. player:getSerial()
				sql:queryExec("UPDATE ??_account SET AutologinToken = ? WHERE Id = ?", sql:getPrefix(), loginToken, row.Id)
			else
				if row.AutologinToken then
					sql:queryExec("UPDATE ??_account SET AutologinToken = ? WHERE Id = ?", sql:getPrefix(), "", row.Id)
				end
			end

			Account.loginSuccess(player, row.Id, row.Name, row.ForumId, row.RegisterDate, row.TeamspeakId, loginToken)
			return
		end

	else
		player:triggerEvent("loginfailed", "Falscher Name oder Passwort") -- Error: Invalid username or password2
		return false
	end
end
addEvent("accountlogin", true)
addEventHandler("accountlogin", root, function(...) Async.create(Account.login)(client, ...) end)

function Account.loginSuccess(player, Id, Username, ForumId, RegisterDate, TeamspeakId, pwhash)
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

	if not Warn.checkWarn(player, Id, true) then
		-- Todo Maybe it´s more beautiful not kicking player directly only display a more information error
		if player and isElement(player) then player:triggerEvent("loginfailed", "Du wurdest aufgrund von 3 Warns gebannt!") end
		return false
	end

	if not Ban.checkBan(player, Id, true) then
		-- Todo Maybe it´s more beautiful not kicking player directly only display a more information error
		if player and isElement(player) then player:triggerEvent("loginfailed", "Du wurdest gebannt!") end
		return false
	end

	-- Update last serial and last login
	sql:queryExec("UPDATE ??_account SET LastSerial = ?, LastIP = ?, LastLogin = NOW() WHERE Id = ?", sql:getPrefix(), player:getSerial(), player:getIP(), Id)

	player.m_Account = Account:new(Id, Username, player, false, ForumId, TeamspeakId, RegisterDate)

	if not player or not isElement(player) then -- Cause of kick directly after login (e.g. ban, warn) / Should not happened now
		outputDebugString("Account.loginSuccess: Player-Element for "..UserName.." not found!", 1)
		return
	end

	if not Account.checkCharacter(Id) then
		Admin:getSingleton():sendNewPlayerMessage(Username)
		player:createCharacter()
	end

	StatisticsLogger:addLogin( player, Username, "Login")
	ClientStatistics:getSingleton():handle(player)

	if not DEBUG and SERVICE_SYNC then
		ServiceSync:getSingleton():syncPlayer(Id)
	end

	player:loadCharacter()
	player:spawn()
	player:triggerEvent("loginsuccess", pwhash)

	if player:isActive() then
		local header = toJSON({["alg"] = "HS256", ["typ"] = "JWT"}, true):sub(2, -2)
		local payload = toJSON({["sub"] = player:getId(), ["name"] = player:getName(), ["exp"] = getRealTime().timestamp + 60 * 60 * 24}, true):sub(2, -2)

		local jwtBase = base64Encode(header) .. "." .. base64Encode(payload)

		fetchRemote(INGAME_WEB_PATH .. "/ingame/hmac.php?value=" .. jwtBase, function(responseData) player:setSessionId(jwtBase.."."..responseData)	end)
	end

	ServiceSync:getSingleton():syncPlayer(Id)
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

	if not Account.REGISTRATION_ACTIVATED then
		player:triggerEvent("registerfailed", _("Registration ist vorübergehend deaktiviert. Bitte versuchen es später erneut.", player))
		return false
	end

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
	Forum:getSingleton():userCreate(username, password, email, Async.waitFor(self))
	local result = Async.wait()
	local data = fromJSON(result)

	if data and data.status and data.status == 200 then
		Account.createAccount(player, data.data.userID, username, email)
	else
		if data and data.message then
			if data.message == "username is not notUnique" then
				player:triggerEvent("registerfailed", _("Benutzername wird bereits verwendet", player))
			elseif data.message == "username is not invalid" then
				player:triggerEvent("registerfailed", _("Benutzername enthält nicht erlaubte Zeichen", player))
			elseif data.message == "email is not notUnique" then
				player:triggerEvent("registerfailed", _("Diese E-Mail wird bereits verwendet", player))
			elseif data.message == "email is not invalid" then
				player:triggerEvent("registerfailed", _("Diese E-Mail ist nicht gültig", player))
			else
				player:triggerEvent("loginfailed", "Fehler: Forum-Acc konnte nicht angelegt werden")
			end
		else
			player:triggerEvent("loginfailed", "Fehler: Forum-Acc konnte nicht angelegt werden")
		end
	end
end
addEvent("accountregister", true)
addEventHandler("accountregister", root, function(...) Async.create(Account.register)(client, ...) end)

function Account.createAccount(player, boardId, username, email)
	local result, _, Id = sql:queryFetch("INSERT INTO ??_account (ForumId, Name, EMail, Rank, LastSerial, LastIP, LastLogin, RegisterDate) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW());", sql:getPrefix(), boardId, username, email, 0, player:getSerial(), player:getIP())
	if result then
		Account.loginSuccess(player, Id, username, boardId, RegisterDate, 0, nil, false)
	else
		player:triggerEvent("loginfailed", "Fehler: Unable to create Ingame-Acc.")
	end
end

function Account.asyncCallAPI(func, postData)
	local options = {
		["connectionAttempts"] = 1,
		["postData"] = postData
	}
	fetchRemote((INGAME_WEB_PATH .. "/ingame/userApi/api.php?func=%s"):format(func), options, Async.waitFor())
	return Async.wait()
end

function Account:constructor(id, username, player, guest, ForumId, TeamspeakId, RegisterDate)
	-- Account Information
	self.m_Id = id
	self.m_Username = username
	self.m_Player = player
	self.m_ForumId = ForumId
	self.m_TeamspeakId = TeamspeakId
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
	local player = Player.getFromId(id)
	if player and isElement(player) then
		return player:getName()
	end

	local row = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	return row and row.Name
end

function Account.getBoardIdFromId(id)
	local player = Player.getFromId(id)
	if player and isElement(player) then
		return player:getAccount().m_ForumId
	end

	local row = sql:queryFetchSingle("SELECT ForumId FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	return row and row.ForumId
end

function Account.getIdFromIdBoard(id)
	local row = sql:queryFetchSingle("SELECT Id FROM ??_account WHERE ForumId = ?", sql:getPrefix(), id)
	return row and row.Id
end

function Account.getTeamspeakIdFromId(id)
	local player = Player.getFromId(id)
	if player and isElement(player) then
		return player:getAccount().m_TeamspeakId
	end

	local row = sql:queryFetchSingle("SELECT TeamspeakId FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	return row and row.TeamspeakId
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
	local row = sql:queryFetchSingle("SELECT ForumId FROM ??_account WHERE Name = ?", sql:getPrefix(), name)
	return row.ForumId or 0
end
