Player = inherit(MTAElement)
registerElementClass("player", Player)

function Player:constructor()
	self.m_Id = nil
end

function Player:destructor()
	self:save()
end

function Player:save()
	-- Save player data to database
	
end

function Player:load()
	-- Load player data from database
	
end

function Player:loadDefault()
	-- Load default data
	
end

function Player:login(usermame, password)
	if not username or not password then return end
	
	-- Already logged in?
	if self.m_LoggedIn then 
		self:rpc(RPC_PLAYER_LOGIN, RPC_STATUS_ERROR, RPC_STATUS_ALREADY_LOGGED_IN)
		return false
	end
	
	-- Ask SQL to fetch the salt
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id, Salt FROM ??_player WHERE Name = ? ", sql:getPrefix(), username)
	local row = Async.wait()
	
	if not row or not row.Id then
		self:rpc(RPC_PLAYER_LOGIN, RPC_STATUS_ERROR, RPC_STATUS_INVALID_USERNAME)
		return
	end
	
	-- Ask SQL to attempt a Login
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id, Salt FROM ??_player WHERE Id = ? AND Password = ?;", sql:getPrefix(), row.Id, sha256(row.Salt..password))
	local row = Async.wait()
	if not row or not row.Id then
		self:rpc(RPC_PLAYER_LOGIN, RPC_STATUS_ERROR, RPC_STATUS_INVALID_PASSWORD)
		return
	end

	-- Success! report back and load
	self.m_Id = row.Id
	self:load()
	self:rpc(RPC_PLAYER_LOGIN, RPC_STATUS_SUCCESS, RPC_STATUS_SUCCESS)
end

function Player:register()
	if not username or not password or not salt then return end
	
	-- Already logged in?
	if self.m_LoggedIn then 
		self:rpc(RPC_PLAYER_REGISTER, RPC_STATUS_ERROR, RPC_STATUS_ALREADY_LOGGED_IN)
		return false
	end
	
	-- Check if we already know that username
	sql:queryFetchSingle(Async.waitFor(self), "SELECT Id FROM ??_player WHERE Name = ?;", sql:getPrefix(), username, password)
	local row = Async.wait()
	
	if row and row.Id then
		self:rpc(RPC_PLAYER_REGISTER, RPC_STATUS_ERROR, RPC_STATUS_DUPLICATE_USER)
		return
	end
	
	-- Create the user
	sql:queryExec("INSERT INTO ??_player(Name, Password, Salt, Admin, Locale) VALUES(?, ?, ?, ?, ?);", sql:getPrefix(), username, sha256(salt..password), salt, 0, "en")
	
	-- Fetch the userid
	self.m_Id = sql:lastInsertId()
	self:rpc(RPC_PLAYER_REGISTER, RPC_STATUS_SUCCESS)
	
	-- Load default data
	self:loadDefault()
end