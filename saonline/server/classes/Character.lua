Character = inherit(Object)
Character.Map = {}

function Character:constructor(id, account, player, charnum)
	-- Character Information
	self.m_Id = id
	self.m_Account = account
	self.m_Player = player
	self.m_Skills = {}
	
	sql:queryFetch(Async.waitFor(self), "SELECT Level, XP, Karma, Money, BankMoney, DrivingSkill, GunSkill, FlyingSkill, SneakingSkill, EnduranceSkill FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	local row = Async.wait()
	
	self.m_Level = row.Level
	self.m_XP 	 = row.XP
	self.m_Karma = row.Karma
	self.m_Money = row.Money
	self.m_BankMoney = row.BankMoney
	
	self.m_Skills["Driving"] 	= row.DrivingSkill
	self.m_Skills["Gun"] 		= row.GunSkill
	self.m_Skills["Flying"] 	= row.FlyingSkill
	self.m_Skills["Sneaking"] 	= row.SneakingSkill
	self.m_Skills["Endurance"] 	= row.EnduranceSkill
end

function Character:destructor()
end

function Character.select(player, id)
	-- Verify the player has no selected character
	if player.m_Character then return end
	-- Verify that the player has access to the character
	if not player.m_Account then return end
	
	local index = false
	for k, v in pairs(player.m_Account.m_Character) do
		if v.m_Id == id then 
			index = k
			break
		end
	end
	
	if not index then return end
	
	-- Go!
	local char = player.m_Account.m_Character[index]
	player.m_Character = char
	char:spawn()
end
addEvent("selectcharacter", true)
addEventHandler("selectcharacter", root, function(...) Async.create(Character.select)(client, ...) end)

function Character:firstspawn()
	spawnPlayer(self.m_Player, 0, 10, 10)
end

function Character.create(player, index)
	-- Verify the player has no selected character
	if player.m_Character then return end
	-- Verify that the player has access to the character
	if not player.m_Account then return end
	
	sql:queryExec("INSERT INTO ??_character(Account) VALUES(?);", sql:getPrefix(), player.m_Account.m_Id)
	
	player.m_Account.m_Character[index] = Character:new(id, player.m_Account, player, index)
	player.m_Account.m_Character[index]:firstspawn()
end
addEvent("createcharacter", true)
addEventHandler("createcharacter", root, function(...) Async.create(Character.create)(client, ...) end)

function Character:spawn()
	spawnPlayer(self.m_Player, 0, 0, 10)
end

-- Short getters
function Character:getId()			return self.m_Id		end
function Character:getAccount()		return self.m_Account 	end
function Character:getPlayer()		return self.m_Player	end
function Character:getXP()			return self.m_XP		end
function Character:getKarma()		return self.m_Karma		end
function Character:getBankMoney()	return self.m_BankMoney	end

function Character:addKarma(points)
	self.m_Karma = self.m_Karma + points
	self.m_Player:triggerEvent("karmaChange", self.m_Karma)
end

function Character:takeKarma(points)
	self.m_Karma = self.m_Karma - points
	self.m_Player:triggerEvent("karmaChange", self.m_Karma)
end

function Character:addBankMoney(amount, logType)
	logType = logType or BankStat.Income
	if sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney + amount
		return true
	end
	return false
end

function Character:takeBankMoney(amount, logType)
	logType = logType or BankStat.Payment
	if sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney - amount
		return true
	end
	return false
end
