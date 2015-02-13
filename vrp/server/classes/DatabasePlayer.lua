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
	-- Second return determines whether the account is offline
	if DatabasePlayer.Map[id] then
		return DatabasePlayer.Map[id], not isElement(DatabasePlayer.Map[id])
	end
	
	return DatabasePlayer:new(id), true
end

function DatabasePlayer:constructor(id)
	assert(id)
	DatabasePlayer.virtual_constructor(self)
	
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
	self.m_Points = 0
    self.m_Money = 0
	self.m_BankMoney = 0
	self.m_WantedLevel = 0
	self.m_WeaponLevel = 0
	self.m_VehicleLevel = 0
	self.m_SkinLevel = 0
	
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
	self.m_Collectables = {}
	self.m_LadderTeam = {}
	self.m_Achievements = {[0] = false} -- Dummy element, otherwise the JSON string is built wrong
end

function DatabasePlayer:virtual_destructor()
	if self.m_Id > 0 then
		DatabasePlayer.Map[self.m_Id] = nil
	end
end

function DatabasePlayer:load()
	local row = sql:asyncQueryFetchSingle("SELECT PosX, PosY, PosZ, Interior, Skin, XP, Karma, Points, WeaponLevel, VehicleLevel, SkinLevel, JobLevel, Money, BankMoney, WantedLevel, Job, GroupId, GroupRank, DrivingSkill, GunSkill, FlyingSkill, SneakingSkill, EnduranceSkill, TutorialStage, InventoryId, GarageType, LastGarageEntrance, SpawnLocation, Collectables, HasPilotsLicense, Achievements FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	if not row then
		return false
	end
	
	self.m_SavedPosition = Vector3(row.PosX, row.PosY, row.PosZ)
	self.m_SavedInterior = row.Interior
	self.m_Skin = row.Skin
	self:setXP(row.XP)
	self:setKarma(row.Karma)
	self:givePoints(row.Points)
	self.m_Money = row.Money
	self.m_WantedLevel = row.WantedLevel
	self.m_BankMoney = row.BankMoney
	self.m_TutorialStage = row.TutorialStage

    if row.Achievements and type(fromJSON(row.Achievements)) == "table" then
        self:updateAchievements(fromJSON(row.Achievements))
    else
        self:updateAchievements({[0] = false}) -- Dummy element, otherwise the JSON string is built wrong
    end

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
	self.m_Collectables = fromJSON(row.Collectables or "")
	self.m_HasPilotsLicense = toboolean(row.HasPilotsLicense)
	self.m_LadderTeam = fromJSON(row.Ladder or "[[]]")
	
	self.m_Skills["Driving"] 	= row.DrivingSkill
	self.m_Skills["Gun"] 		= row.GunSkill
	self.m_Skills["Flying"] 	= row.FlyingSkill
	self.m_Skills["Sneaking"] 	= row.SneakingSkill
	self.m_Skills["Endurance"] 	= row.EnduranceSkill
	
	if self:isActive() then
		setPlayerWantedLevel(self, self.m_WantedLevel)
		setPlayerMoney(self, self.m_Money, true) -- Todo: Remove this line later
	end

    self:setWeaponLevel(row.WeaponLevel)
    self:setVehicleLevel(row.VehicleLevel)
    self:setSkinLevel(row.SkinLevel)
    self:setJobLevel(row.JobLevel)
end

function DatabasePlayer:save()
	if self:isGuest() then	
		return false
	end
	
	return sql:queryExec("UPDATE ??_character SET Skin=?, XP=?, Karma=?, Points=?, WeaponLevel=?, VehicleLevel=?, SkinLevel=?, Money=?, BankMoney=?, WantedLevel=?, TutorialStage=?, Job=?, SpawnLocation=?, LastGarageEntrance=?, Collectables=?, HasPilotsLicense=?, JobLevel=?, Achievements=?, Ladder=? WHERE Id=?;", sql:getPrefix(),
		self.m_Skin, self.m_XP, self.m_Karma, self.m_Points, self.m_WeaponLevel, self.m_VehicleLevel, self.m_SkinLevel, self:getMoney(), self.m_BankMoney, self.m_WantedLevel, self.m_TutorialStage, self.m_Job and self.m_Job:getId() or 0, self.m_SpawnLocation, self.m_LastGarageEntrance, toJSON(self.m_Collectables), self.m_HasPilotsLicense, self:getJobLevel(), toJSON(self:getAchievements()), self.m_LadderTeam, self:getId())
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
function DatabasePlayer:getRank()		return self.m_Account and self.m_Account:getRank() or RANK.User end
function DatabasePlayer:getMoney()		return self.m_Money		end
function DatabasePlayer:getXP()			return self.m_XP		end
function DatabasePlayer:getKarma()		return self.m_Karma		end
function DatabasePlayer:getPoints()		return self.m_Points 	end
function DatabasePlayer:getWeaponLevel()return self.m_WeaponLevel end
function DatabasePlayer:getVehicleLevel() return self.m_VehicleLevel end
function DatabasePlayer:getSkinLevel()	return self.m_SkinLevel	end
function DatabasePlayer:getJobLevel()	return self.m_JobLevel	end
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
function DatabasePlayer:getCollectables() return self.m_Collectables end
function DatabasePlayer:hasPilotsLicense() return self.m_HasPilotsLicense end

-- Short setters
function DatabasePlayer:setMoney(money, instant) self.m_Money = money setPlayerMoney(self, money, instant) end
function DatabasePlayer:setWantedLevel(level) self.m_WantedLevel = level setPlayerWantedLevel(self, level) end
function DatabasePlayer:setLocale(locale)	self.m_Locale = locale	end
function DatabasePlayer:setTutorialStage(stage) self.m_TutorialStage = stage end
function DatabasePlayer:setJobVehicle(vehicle) self.m_JobVehicle = vehicle end
function DatabasePlayer:setGroup(group)	self.m_Group = group if group then if self:isActive() then self:setPublicSync("GroupName", group:getName()) end end end
function DatabasePlayer:setSpawnLocation(l) self.m_SpawnLocation = l end
function DatabasePlayer:setLastGarageEntrance(e) self.m_LastGarageEntrance = e end
function DatabasePlayer:setCollectables(t) self.m_Collectables = t end
function DatabasePlayer:setHasPilotsLicense(s) self.m_HasPilotsLicense = s end

function DatabasePlayer:giveMoney(money)
	self:setMoney(self:getMoney() + money)
end

function DatabasePlayer:takeMoney(money)
	self:setMoney(self:getMoney() - money)
end

function DatabasePlayer:setXP(xp)
	self.m_XP = xp
end

function DatabasePlayer:getLevel()
	return calculatePlayerLevel(self.m_XP)
end

function DatabasePlayer:setKarma(karma)
	self.m_Karma = karma
    if self:isActive() then self:setPrivateSync("KarmaLevel", self.m_Karma) end
end

function DatabasePlayer:giveKarma(value, factor)
	local changekarma = Karma.calcKarma(self.m_Karma, self.m_Karma+value, factor or 1)
	if value < 0 then
		changekarma = -changekarma
	end
	self:setXP(self.m_XP + math.abs(changekarma) * 10)
	self:setKarma(self.m_Karma + changekarma)
end

function DatabasePlayer:givePoints(p)
	self.m_Points = self.m_Points + math.floor(p)
	if self:isActive() then self:setPrivateSync("Points", self.m_Points) end
end

function DatabasePlayer:incrementWeaponLevel()
	self.m_WeaponLevel = self.m_WeaponLevel + 1
	if self:isActive() then self:setPrivateSync("WeaponLevel", self.m_WeaponLevel) end
end

function DatabasePlayer:incrementVehicleLevel()
	self.m_VehicleLevel = self.m_VehicleLevel + 1
	if self:isActive() then self:setPrivateSync("VehicleLevel", self.m_VehicleLevel) end
end

function DatabasePlayer:incrementSkinLevel()
	self.m_SkinLevel = self.m_SkinLevel + 1
	if self:isActive() then self:setPrivateSync("SkinLevel", self.m_SkinLevel) end
end

function DatabasePlayer:incrementJobLevel()
	self.m_JobLevel = self.m_JobLevel + 1
	if self:isActive() then self:setPrivateSync("JobLevel", self.m_JobLevel) end
end

function DatabasePlayer:setWeaponLevel (level)
    self.m_WeaponLevel = level
    if self:isActive() then self:setPrivateSync("WeaponLevel", self.m_WeaponLevel) end
end

function DatabasePlayer:setVehicleLevel (level)
    self.m_VehicleLevel = level
    if self:isActive() then self:setPrivateSync("VehicleLevel", self.m_VehicleLevel) end
end

function DatabasePlayer:setSkinLevel (level)
    self.m_SkinLevel = level
    if self:isActive() then self:setPrivateSync("SkinLevel", self.m_SkinLevel) end
end

function DatabasePlayer:setJobLevel (level)
    self.m_JobLevel = level
    if self:isActive() then self:setPrivateSync("JobLevel", self.m_JobLevel) end
end

function DatabasePlayer:addBankMoney(amount, logType)
	logType = logType or BankStat.Income
	if sql:queryExec("INSERT INTO ??_bank_statements (UserId, Type, Amount, Date) VALUES(?, ?, ?, NOW())", sql:getPrefix(), self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney + amount
		return true
	end
	return false
end

function DatabasePlayer:takeBankMoney(amount, logType)
	logType = logType or BankStat.Payment
	if sql:queryExec("INSERT INTO ??_bank_statements (UserId, Type, Amount, Date) VALUES(?, ?, ?, NOW())", sql:getPrefix(), self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney - amount
		return true
	end
	return false
end

function DatabasePlayer:giveWantedLevel(level)
	local newLevel = self.m_WantedLevel + level
	if newLevel > 6 then
		newLevel = 6
	end
	self:setWantedLevel(newLevel)
	
	if self:isActive() then
		self.m_LastGotWantedLevelTime = getTickCount()
	end
end

function DatabasePlayer:takeWantedLevel(level)
	local newLevel = self.m_WantedLevel - level
	if newLevel < 0 then
		newLevel = 0
	end
	self:setWantedLevel(newLevel)
end

function DatabasePlayer:setJob(job)
	if self:isActive() then
		if job then
			JobManager:getSingleton():startJobForPlayer(job, self)
		else
			JobManager:getSingleton():stopJobForPlayer(self)
		end
		self:setPublicSync("JobId", job and job:getId() or 0)
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

function DatabasePlayer:getTeamId(kind)
	return self.m_LadderTeam[kind]
end

function DatabasePlayer:setTeamId(kind,id)
	if self.m_LadderTeam[kind] then
		return false
	end
	self.m_LadderTeam[kind] = id
	return true
end

function DatabasePlayer:updateAchievements (tbl)
    if tbl ~= nil then
        self.m_Achievements = tbl
    end
    if self:isActive() then self:setPrivateSync("Achievements", table.copy(self.m_Achievements)) end
end

function DatabasePlayer:getAchievements ()
    return self:getPrivateSync("Achievements")
end

function DatabasePlayer:giveAchievement (...)
    if Achievement:isInstantiated() then
        Achievement:getSingleton():giveAchievement(self, ...)
    else
        outputDebug("Achievement hasn't been instantiated yet!")
    end
end

function DatabasePlayer:getAchievementStatus (id)
    local id = tostring(id)
    if Achievement:isInstantiated() then
        if self.m_Achievements[id] ~= nil then
            return self.m_Achievements[id]
        else
            return false
        end
    else
        outputDebug("Achievement hasn't been instantiated yet!")
        return false
    end
end

function DatabasePlayer:setAchievementStatus (id, status)
    local id = tostring(id)
    if Achievement:isInstantiated() then
        self.m_Achievements[id] = status
        self:updateAchievements()
    else
        outputDebug("Achievement hasn't been instantiated yet!")
    end
end