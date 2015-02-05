-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Account.lua
-- *  PURPOSE:     Account class
-- *
-- ****************************************************************************
Account = inherit(Object)

function Account.login(player, username, password, pwhash)
	if player:getAccount() then return false end
	if (not username or not password) and not pwhash then return false end

	-- Ask SQL to fetch the salt and id
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id, Salt FROM ??_account WHERE Name = ? ", sql:getPrefix(), username)
	local row = Async.wait()
		
	if not row or not row.Id then
		player:triggerEvent("loginfailed", "Fehler: Falscher Name oder Passwort") -- "Error: Invalid username or password"
		return false
	end
	
	if not pwhash then
		pwhash = sha256(row.Salt..password)
	end
	
	-- Ask SQL to attempt a Login
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id FROM ??_account WHERE Id = ? AND Password = ?;", sql:getPrefix(), row.Id, pwhash)
	local row = Async.wait()
	if not row or not row.Id then
		player:triggerEvent("loginfailed", "Fehler: Falscher Name oder Passwort 2") -- Error: Invalid username or password2
		return false
	end
	
	if DatabasePlayer.getFromId(row.Id) then
		player:triggerEvent("loginfailed", "Fehler: Dieser Account ist schon in Benutzung")
		return false
	end
	
	-- Update last serial and last login
	sql:queryExec("UPDATE ??_account SET LastSerial = ?, LastLogin = NOW() WHERE Id = ?", sql:getPrefix(), getPlayerSerial(player), row.Id)
	
	player.m_Account = Account:new(row.Id, username, player, false)

	if player:getTutorialStage() == 1 then
		player:createCharacter()
	end
	player:loadCharacter()
	player:spawn()
	triggerClientEvent(player, "loginsuccess", root, pwhash, player:getTutorialStage())
	
end
addEvent("accountlogin", true)
addEventHandler("accountlogin", root, function(...) Async.create(Account.login)(client, ...) end)

function Account.register(player, username, password, email)
	if player:getAccount() then return false end
	if not username or not password then return false end
	
	-- Some sanity checks on the username (enable later)
	if false then
		-- Require at least 1 letter and a length of 3
		if not username:match("[a-zA-Z]") or #username < 3 then 
			player:triggerEvent("registerfailed", "Error: Invalid Nickname")
			return false
		end
	end
	
	local response,errno = Forum:getSingleton():createAccount(player, username, password, email)
	
	if response == "ERROR" then 
		player:triggerEvent("registerfailed", "Error: Interner Fehler. Bitte einen Administrator kontaktieren!")
		return false
	end
	
	if response == "0" then
		player:triggerEvent("registerfailed", "Error: Invalid Nickname")
		return false
	end
	local forumId = tonumber(response)

	-- Check if someone uses this username already
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id FROM ??_account WHERE Name = ? ", sql:getPrefix(), username)
	local row = Async.wait()
	if row then
		player:triggerEvent("registerfailed", "Error: Username is already in use")
		return false
	end
	
	-- Create an account
	
	-- todo: get a better salt
	local salt = md5(math.random())

	sql:queryExec("INSERT INTO ??_account(Id, Name, Password, Salt, Rank, LastSerial, LastLogin) VALUES (?, ?, ?, ?, ?, ?, NOW());", sql:getPrefix(), forumId, username, sha256(salt..password), salt, 0, getPlayerSerial(player))
	
	player.m_Account = Account:new(forumId, username, player, false)
	
	player:createCharacter()
	player:loadCharacter()
	player:spawn()
	triggerClientEvent(player, "loginsuccess", root, nil, player:getTutorialStage())
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

function Account:constructor(id, username, player, guest)
	-- Account Information
	self.m_Id = id
	self.m_Username = username
	self.m_Player = player
	player.m_IsGuest = guest;
	player.m_Id = self.m_Id
	
	if not guest then
		sql:queryFetchSingle(Async.waitFor(self), "SELECT Rank FROM ??_account WHERE Id = ?;", sql:getPrefix(), self.m_Id)
		local row = Async.wait()
		
		self.m_Rank = row.Rank
		
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

function Account:getName()
	return self.m_Username
end

function Account.getNameFromId(id)
	--[[sql:queryFetchSingle(Async.waitFor(self), "SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	local row = Async.wait()]]
	
	local row = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	return row and row.Name
end

function Account.getIdFromName(name)
	local row = sql:queryFetchSingle("SELECT Id FROM ??_account WHERE Name = ?", sql:getPrefix(), name)
	return row and row.Id
end
