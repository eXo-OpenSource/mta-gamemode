Account = inherit(Object)
Account.Map = {}

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
		player:triggerEvent("loginfailed", "Error: Invalid username or password")
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
	sql:queryExec("INSERT INTO ??_account(Name, Password, Salt) VALUES (?, ?, ?);", sql:getPrefix(), username, sha256(salt..password), salt)
	
	return Account:new(sql:lastInsertId(), username, player)
end
addEvent("accountregister", true)
addEventHandler("accountregister", root, function(u, p) Async.create(Account.register)(client, u, p) end)

function Account:constructor(id, username, player, pwhash)
	-- Account Information
	self.m_Id = id
	self.m_Username = username
	self.m_Player = player
	player.m_Account = self
	self.m_Character = {}
	
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Rank, AvailableCharacterCount, Money, Bank FROM ??_account WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	local row = Async.wait()
	
	self.m_Rank = row.Rank;
	self.m_MaxCharacters = row.AvailableCharacterCount;
	self.m_Money = row.Money;
	self.m_Bank = row.Bank
	
	if self.m_Rank == RANK.Banned then
		Ban:new(player)
		return
	end
	
	-- Load Characters
	sql:queryFetch(Async.waitFor(self), "SELECT Id FROM ??_character WHERE Account = ?;", sql:getPrefix(), row.Id)
	local characters = Async.wait()
	for charnum, charid in pairs(characters) do
		self.m_Character[charnum] = Character:new(charid, self, player, charnum)
	end
	
	Account.Map[self.m_Id] = self
	
	local accsyncinfo = 
	{
		Username = username;
		Rank = self.m_Rank;
		MaxCharacters = self.m_MaxCharacters;
		Money = self.m_Money;
		Bank = self.m_Bank;
	}
	local charsyncinfo = {}
	for i, char in pairs(self.m_Character) do
		charsyncinfo[i] = 
		{
			Level = char.m_Level;
			XP 	 = char.m_XP;
			Karma = char.m_Karma;
			Skills = char.m_Skills	
		}
	end
	triggerClientEvent(player, "loginsuccess", root, accsyncinfo, charsyncinfo, pwhash)
end

function Account:destructor()
	Account.Map[self.m_Id] = nil
end

function Account:createCharacter(slot)
	if self.m_Character[slot] then return false end
	if slot > MAX_CHARACTERS then return false end
	
	sql:queryExec("INSERT INTO ??_character(Account) VALUES (?);", sql:getPrefix(), self.m_Id)
	local id = sql:queryFetchSingle("SELECT LAST_INSERT_ID() AS CharId;").CharId
	
	self.m_Character[slot] = Character:new(charid, self, self:getPlayer(), slot)
end

function Account:getCharacters()
	return self.m_Character
end

function Account:getPlayer()
	return self.m_Player
end

function Account:getId()
	return self.m_Id;
end

