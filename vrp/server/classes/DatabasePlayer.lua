-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/DatabasePlayer.lua
-- *  PURPOSE:     Player class for possibly inactive players
-- *
-- ****************************************************************************
DatabasePlayer = inherit(Object)
DatabasePlayer.Map = setmetatable({}, { __mode = "v"  })

function DatabasePlayer.get(id)
	if DatabasePlayer.Map[id] then
		return DatabasePlayer.Map[id] 
	end
	
	return DatabasePlayer:new(id)
end

function DatabasePlayer:constructor(id)
	assert(id)
	self.m_Id = id
	DatabasePlayer.Map[id] = self
end

function DatabasePlayer:destructor()
	self:save()
end

function DatabasePlayer:virtual_constructor()
	self.m_Account = false
	self.m_Locale = "de"
	self.m_Id = -1
	self.m_Inventory = false
	self.m_Skills = {}
	self.m_XP 	 = 0
	self.m_Karma = 0
	self.m_Money = 0
	self.m_BankMoney = 0
	self.m_WantedLevel = 0
	--[[
	Tutorial Stages:
	0 - Just created an account
	1 - Watched the intro
	2 - Created his character
	3 - Played the tutorial
	4 - Done
	]]
	self.m_TutorialStage = 0
	self.m_JobVehicle = false
	self.m_GarageType = 0
	self.m_LastGarageEntrance = 0
	self.m_SpawnLocation = SPAWN_LOCATION_DEFAULT
end

function DatabasePlayer:virtual_destructor()
	if self.m_Id > 0 then
		DatabasePlayer.Map[self.m_Id] = nil
	end
end

function DatabasePlayer:load()
	local row = sql:asyncQueryFetchSingle("SELECT PosX, PosY, PosZ, Interior, Skin, XP, Karma, Money, BankMoney, WantedLevel, Job, GroupId, GroupRank, DrivingSkill, GunSkill, FlyingSkill, SneakingSkill, EnduranceSkill, TutorialStage, Weapons, InventoryId, GarageType, LastGarageEntrance, SpawnLocation FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	if not row then
		return false
	end
	
	self.m_SavedPosition = Vector(row.PosX, row.PosY, row.PosZ)
	self.m_SavedInterior = row.Interior
	self.m_Skin = row.Skin
	self.m_XP 	 = row.XP
	self.m_Karma = row.Karma
	self.m_Money = row.Money
	setPlayerMoney(self, self.m_Money, true) -- Todo: Remove this line later
	self.m_WantedLevel = row.WantedLevel
	setPlayerWantedLevel(self, self.m_WantedLevel)
	self.m_BankMoney = row.BankMoney
	self.m_TutorialStage = row.TutorialStage
	if row.Job > 0 then
		self:setJob(JobManager:getSingleton():getFromId(row.Job))
	end
	if row.GroupId and row.GroupId ~= 0 then
		self:setGroup(GroupManager:getSingleton():getFromId(row.GroupId))
	end
	self.m_Inventory = self.m_Inventory or Inventory.loadById(row.InventoryId) or Inventory.create()
	self.m_GarageType = row.GarageType
	self.m_LastGarageEntrance = row.LastGarageEntrance
	self.m_SpawnLocation = row.SpawnLocation
	
	self.m_Skills["Driving"] 	= row.DrivingSkill
	self.m_Skills["Gun"] 		= row.GunSkill
	self.m_Skills["Flying"] 	= row.FlyingSkill
	self.m_Skills["Sneaking"] 	= row.SneakingSkill
	self.m_Skills["Endurance"] 	= row.EnduranceSkill
	
	if row.Weapons and row.Weapons ~= "" then
		local weaponID = 0
		for i = 1, 26 do
			local value = gettok(row.Weapons, i, string.byte('|'))
			if tonumber(value) ~= 0 then
				if math.mod(i, 2) == 1 then
					weaponID = value
				else
					giveWeapon(self, weaponID, value)
				end
			end
		end
	end
end

function DatabasePlayer:save()
	if not self:isActive() or self:isGuest() then	
		return false
	end
	
	return sql:queryExec("UPDATE ??_character SET Skin = ?, XP = ?, Karma = ?, Money = ?, BankMoney = ?, WantedLevel = ?, TutorialStage = ?, Job = ?, SpawnLocation = ?, LastGarageEntrance = ? WHERE Id = ?;", sql:getPrefix(),
		self.m_Skin, self.m_XP, self.m_Karma, self:getMoney(), self.m_BankMoney, self.m_WantedLevel, self.m_TutorialStage, self.m_Job and self.m_Job:getId() or 0, self.m_SpawnLocation, self.m_LastGarageEntrance, self:getId())
end

function DatabasePlayer.getFromId(id)
	return DatabasePlayer.Map[id]
end


-- Short getters
function DatabasePlayer:isActive()		return false end
function DatabasePlayer:getId()			return self.m_Id		end
function DatabasePlayer:isLoggedIn()	return self.m_Id ~= -1	end
function DatabasePlayer:isGuest()		return self.m_IsGuest   end
function DatabasePlayer:getAccount()	return self.m_Account 	end
function DatabasePlayer:getRank()		return self.m_Account:getRank() end
function DatabasePlayer:getMoney()		return getPlayerMoney(self)	end
function DatabasePlayer:getXP()			return self.m_XP		end
function DatabasePlayer:getKarma()		return self.m_Karma		end
function DatabasePlayer:getBankMoney()	return self.m_BankMoney	end
function DatabasePlayer:getWantedLevel()return self.m_WantedLevel end
function DatabasePlayer:getJob()   		return self.m_Job		end
function DatabasePlayer:getAccount()	return self.m_Account	end
function DatabasePlayer:getLocale()		return self.m_Locale	end
function DatabasePlayer:getPhonePartner() return self.m_PhonePartner end
function DatabasePlayer:getTutorialStage() return self.m_TutorialStage end
function DatabasePlayer:getJobVehicle() return self.m_JobVehicle end
function DatabasePlayer:getGroup()		return self.m_Group		end
function DatabasePlayer:getInventory()	return self.m_Inventory	end
function DatabasePlayer:getSkin()		return self.m_Skin		end
function DatabasePlayer:getGarageType() return self.m_GarageType end
function DatabasePlayer:getSpawnLocation() return self.m_SpawnLocation end

-- Short setters
function DatabasePlayer:setMoney(money, instant) self.m_Money = money setPlayerMoney(self, money, instant) end
function DatabasePlayer:setWantedLevel(level) self.m_WantedLevel = level setPlayerWantedLevel(self, level) end
function DatabasePlayer:setLocale(locale)	self.m_Locale = locale	end
function DatabasePlayer:setTutorialStage(stage) self.m_TutorialStage = stage end
function DatabasePlayer:setJobVehicle(vehicle) self.m_JobVehicle = vehicle end
function DatabasePlayer:setGroup(group)	self.m_Group = group if group then setElementData(self, "GroupName", group:getName()) end end
function DatabasePlayer:setSpawnLocation(l) self.m_SpawnLocation = l end
function DatabasePlayer:setLastGarageEntrance(e) self.m_LastGarageEntrance = e end

function DatabasePlayer:giveMoney(money)
	self:setMoney(self:getMoney() + money)
end

function DatabasePlayer:takeMoney(money)
	self:setMoney(self:getMoney() - money)
end

function DatabasePlayer:giveXP(xp)
	local oldLevel = self:getLevel()
	self.m_XP = self.m_XP + xp
	
	-- Check if the player needs a level up
	if self:getLevel() > oldLevel then
		--self:triggerEvent("levelUp", self:getLevel())
		self:sendInfo(_("Du bist zu Level %d aufgestiegen", self, self:getLevel()))
	end
end

function DatabasePlayer:getLevel()
	-- XP(level) = 0.5*x^2 --> level(XP) = sqrt(2*xp)
	return (2 * math.floor(self.m_XP))^0.5
end

function DatabasePlayer:giveKarma(value, factor)
	local changekarma = Karma.calcKarma(self.m_Karma, value, factor or 1)
	self:giveXP(changekarma)
	self.m_Karma = self.m_Karma + changekarma
	self:triggerEvent("karmaChange", self.m_Karma)
end

function DatabasePlayer:takeKarma(value, factor)
	local changekarma = Karma.calcKarma(self.m_Karma, value, factor or 1)
	self:giveXP(changekarma)
	self.m_Karma = self.m_Karma - changekarma
	self:triggerEvent("karmaChange", self.m_Karma)
end

function DatabasePlayer:addBankMoney(amount, logType)
	logType = logType or BankStat.Income
	if sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", sql:getPrefix(), self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney + amount
		return true
	end
	return false
end

function DatabasePlayer:takeBankMoney(amount, logType)
	logType = logType or BankStat.Payment
	if sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", sql:getPrefix(), self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney - amount
		return true
	end
	return false
end

function DatabasePlayer:giveWantedLevel(level)
	self:setWantedLevel(self.m_WantedLevel + level)
end

function DatabasePlayer:takeWantedLevel(level)
	self:setWantedLevel(self.m_WantedLevel - level)
end

function DatabasePlayer:setJob(job)
	if self:isActive() then
		if job then
			JobManager:getSingleton():startJobForPlayer(job, self)
		else
			JobManager:getSingleton():stopJobForPlayer(self)
		end
	end
	self.m_Job = job
end

function DatabasePlayer:getVehicles()
	return VehicleManager:getSingleton():getPlayerVehicles(self)
end

function DatabasePlayer:setGarageType(garageType)
	self.m_GarageType = garageType
	sql:queryExec("UPDATE ??_character SET GarageType = ? WHERE Id = ?", sql:getPrefix(), garageType, self.m_Id)
end