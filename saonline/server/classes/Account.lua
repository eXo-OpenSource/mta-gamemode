Account = inherit(Object)
Account.Map = {}

function Account.login(player, username, password)
	if player:getAccount() then return false end
	if not username or not password then return false end
	
	-- Ask SQL to fetch the salt
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id, Salt FROM ??_account WHERE Name = ? ", sql:getPrefix(), username)
	local row = Async.wait()
	
	if not row or not row.Id then
		player:triggerEvent("loginfailed")
		return false
	end
	
	-- Ask SQL to attempt a Login
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id FROM ??_account WHERE Id = ? AND Password = ?;", sql:getPrefix(), row.Id, sha256(row.Salt..password))
	local row = Async.wait()
	if not row or not row.Id then
		player:triggerEvent("loginfailed")
		return false
	end
	
	return Account:new(self.m_Id, username, player)
end

function Account.register(player, username, password)
	if player:getAccount() then return false end
	if not username or not password then return false end
	
	-- Check if someone uses this username already
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id FROM ??_account WHERE Name = ? ", sql:getPrefix(), username)
	local row = Async.wait()
	if row then
		player:triggerEvent("registerfailed")
		return false
	end
	
	-- Create an account
	sql:queryExec("INSERT INTO ??_account(Name) VALUES (?);", sql:getPrefix(), username)
	
	return Account:new(self.m_Id, username, player)
end

function Account:constructor(id, username, player)
	-- Account Information
	self.m_Id = id
	self.m_Username = username
	self.m_Player = player
	self.m_Character = {}
	
	sql:queryFetch(Async.waitFor(self), "SELECT Rank, AvailableCharacterCount FROM ??_account WHERE Account = ?;", sql:getPrefix(), self.m_Id)
	local row = Async.wait()
	
	self.m_Rank = row.Rank;
	self.m_AvailableCharacterCount = row.AvailableCharacterCount;
	
	-- Load Characters
	sql:queryFetch(Async.waitFor(self), "SELECT Id FROM ??_character WHERE Account = ?;", sql:getPrefix(), row.Id)
	local characters = Async.wait()
	for charnum, charid in pairs(characters) do
		self.m_Character[charnum] = Character:new(charid, self, player, charnum)
	end
	
	Account.Map[self.m_Id] = self
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

