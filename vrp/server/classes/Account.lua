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
		player:triggerEvent("loginfailed", "Error: Invalid username or password")
		return false
	end
	
	if not pwhash then
		pwhash = sha256(row.Salt..password)
	end
	
	-- Ask SQL to attempt a Login
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id FROM ??_account WHERE Id = ? AND Password = ?;", sql:getPrefix(), row.Id, pwhash)
	local row = Async.wait()
	if not row or not row.Id then
		player:triggerEvent("loginfailed", "Error: Invalid username or password2")
		return false
	end
	
	return Account:new(row.Id, username, player, pwhash)
end
addEvent("accountlogin", true)
addEventHandler("accountlogin", root, function(u, p, h) Async.create(Account.login)(client, u, p, h) end)

function Account.register(player, username, password)
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
	sql:queryExec("INSERT INTO ??_account(Name, Password, Salt, Rank) VALUES (?, ?, ?, ?);", sql:getPrefix(), username, sha256(salt..password), salt, 0)
	
	return Account:new(sql:lastInsertId(), username, player, nil, true)
end
addEvent("accountregister", true)
addEventHandler("accountregister", root, function(u, p) Async.create(Account.register)(client, u, p) end)

function Account:constructor(id, username, player, pwhash, justRegistered)
	-- Account Information
	self.m_Id = id
	self.m_Username = username
	self.m_Player = player
	player.m_Account = self
	
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Rank FROM ??_account WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	local row = Async.wait()
	
	self.m_Rank = row.Rank
	
	if self.m_Rank == RANK.Banned then
		Ban:new(player)
		return
	end
	
	if justRegistered then
		player:createCharacter(self.m_Id)
	end
	
	-- Load Character
	player:loadCharacter(self.m_Id)
	
	triggerClientEvent(player, "loginsuccess", root, pwhash, player:getTutorialStage())
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

function Account.getNameFromId(id)
	--[[sql:queryFetchSingle(Async.waitFor(self), "SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	local row = Async.wait()]]
	
	local row = sql:queryFetchSingle("SELECT Name FROM ??_account WHERE Id = ?", sql:getPrefix(), id)
	return row.Name
end
