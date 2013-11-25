Character = inherit(Object)
Character.Map = {}

function Character:constructor(id, account, player, charnum)
	-- Character Information
	self.m_Id = id
	self.m_Account = account
	self.m_Player = player
	self.m_Skills = {}
	
	sql:queryFetch(Async.waitFor(self), "SELECT Level, XP, Karma, DrivingSkill, GunSkill, FlyingSkill, SneakingSkill, EnduranceSkill FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	local row = Async.wait()
	
	self.m_Level = row.Level;
	self.m_XP 	 = row.XP;
	self.m_Karma = row.Karma;
	self.m_Skills["Driving"] 	= row.DrivingSkill;
	self.m_Skills["Gun"] 		= row.GunSkill;
	self.m_Skills["Flying"] 	= row.FlyingSkill;
	self.m_Skills["Sneaking"] 	= row.SneakingSkill;
	self.m_Skills["Endurance"] 	= row.EnduranceSkill;
end

function Character:destructor()
end

function Character:getAccount()
	return self.m_Account
end

function Character:getPlayer()
	return self.m_Player
end

function Character:getId()
	return self.m_Id
end

function Character:addBankStatement(logType, amount)
	return sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", self.m_Id, logType, amount)
end
