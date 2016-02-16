-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/DatabasePlayer.lua
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
	self.m_Health = 100
	self.m_Armor = 0
	self.m_XP 	 = 0
	self.m_Karma = 0
	self.m_Points = 0
	self.m_Money = 0
	self.m_BankMoney = 0
	self.m_WantedLevel = 0
	self.m_WeaponLevel = 0
	self.m_VehicleLevel = 0
	self.m_SkinLevel = 0
	self.m_FactionDuty = false
	self.m_CompanyDuty = false
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
	self.m_HangarType = 0
	self.m_LastGarageEntrance = 0
	self.m_SpawnLocation = SPAWN_LOCATION_DEFAULT
	self.m_Collectables = {}
	self.m_LadderTeam = {}
	self.m_Achievements = {[0] = false} -- Dummy element, otherwise the JSON string is built wrong
	self.m_DMMatchID = 0
	self.m_SessionId = false
end

function DatabasePlayer:virtual_destructor()
	if self.m_Id > 0 then
		DatabasePlayer.Map[self.m_Id] = nil
	end
end

function DatabasePlayer:load()
	local row = sql:asyncQueryFetchSingle("SELECT PosX, PosY, PosZ, Interior, Skin, XP, Karma, Points, WeaponLevel, VehicleLevel, SkinLevel, JobLevel, Money, WantedLevel, Job, GroupId, GroupRank, FactionId, FactionRank, DrivingSkill, GunSkill, FlyingSkill, SneakingSkill, EnduranceSkill, TutorialStage, InventoryId, GarageType, LastGarageEntrance, HangarType, LastHangarEntrance, SpawnLocation, Collectables, HasPilotsLicense, HasDrivingLicense, HasBikeLicense, HasTruckLicense, Achievements, PlayTime, Ladder, BankAccount, CompanyId FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	if not row then
		return false
	end

	self.m_SavedPosition = Vector3(row.PosX, row.PosY, row.PosZ)
	self.m_SavedInterior = row.Interior
	self.m_Skin = row.Skin
	self:setXP(row.XP)
	self:setKarma(row.Karma)
	self:setPoints(row.Points)
	self.m_Money = row.Money
	self.m_WantedLevel = row.WantedLevel
	self.m_TutorialStage = row.TutorialStage

	if row.BankAccount == 0 then
		self.m_BankAccount = BankAccount.create(BankAccountTypes.Player, self:getId())
	else
		self.m_BankAccount = BankAccount.load(row.BankAccount)
	end
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
	if row.FactionId and row.FactionId ~= 0 then
		self:setFaction(FactionManager:getSingleton():getFromId(row.FactionId))
	end
	if row.CompanyId and row.CompanyId ~= 0 then
		self:setCompany(CompanyManager:getSingleton():getFromId(row.CompanyId))
	end
	--self.m_Inventory = row.InventoryId and Inventory.loadById(row.InventoryId) or Inventory.create()
	self.m_GarageType = row.GarageType
	self.m_LastGarageEntrance = row.LastGarageEntrance
	self.m_HangarType = row.HangarType
	self.m_LastHangarEntrance = row.LastHangarEntrance
	self.m_SpawnLocation = row.SpawnLocation
	self.m_Collectables = fromJSON(row.Collectables or "")
	self.m_HasPilotsLicense = toboolean(row.HasPilotsLicense)
	self.m_HasDrivingLicense = toboolean(row.HasDrivingLicense)
	self.m_HasBikeLicense = toboolean(row.HasBikeLicense)
	self.m_HasTruckLicense = toboolean(row.HasTruckLicense)
	self.m_LadderTeam = fromJSON(row.Ladder or "[[]]")

	self.m_Skills["Driving"] 	= row.DrivingSkill
	self.m_Skills["Gun"] 		= row.GunSkill
	self.m_Skills["Flying"] 	= row.FlyingSkill
	self.m_Skills["Sneaking"] 	= row.SneakingSkill
	self.m_Skills["Endurance"] 	= row.EnduranceSkill

	if self:isActive() then
		setPlayerWantedLevel(self, self.m_WantedLevel)
		setPlayerMoney(self, self.m_Money, true) -- Todo: Remove this line later

		-- Generate Session Id
		self:setSessionId(hash("md5", ("%s-%s-%s"):format(getRealTime().timestamp, self:getName(), self.m_JoinTime)))
	end

	self:setWeaponLevel(row.WeaponLevel)
	self:setVehicleLevel(row.VehicleLevel)
	self:setSkinLevel(row.SkinLevel)
	self:setJobLevel(row.JobLevel)
	self:setPlayTime(row.PlayTime)
end

function DatabasePlayer:save()
	if self:isGuest() then
		return false
	end

	-- Unload stuff
	if self.m_BankAccount then
		delete(self.m_BankAccount)
	end

	return sql:queryExec("UPDATE ??_character SET Skin=?, XP=?, Karma=?, Points=?, WeaponLevel=?, VehicleLevel=?, SkinLevel=?, Money=?, WantedLevel=?, TutorialStage=?, Job=?, SpawnLocation=?, LastGarageEntrance=?, LastHangarEntrance=?, Collectables=?, JobLevel=?, Achievements=?, Ladder=?, BankAccount=?, HasPilotsLicense=?, hasDrivingLicense=?, hasBikeLicense=?, hasTruckLicense=? WHERE Id=?;", sql:getPrefix(),
		self.m_Skin, self.m_XP, self.m_Karma, self.m_Points, self.m_WeaponLevel, self.m_VehicleLevel, self.m_SkinLevel, self:getMoney(), self.m_WantedLevel, self.m_TutorialStage, self.m_Job and self.m_Job:getId() or 0, self.m_SpawnLocation, self.m_LastGarageEntrance, self.m_LastHangarEntrance, toJSON(self.m_Collectables or {}, true), self:getJobLevel(), toJSON(self:getAchievements() or {}, true), toJSON(self.m_LadderTeam or {}, true), self:getBankAccount():getId(), self.m_HasPilotsLicense, self.m_HasDrivingLicense, self.m_HasBikeLicense, self.m_HasTruckLicense, self:getId())
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
function DatabasePlayer:getBankAccount() return self.m_BankAccount end
function DatabasePlayer:getBankMoney()	return self.m_BankAccount:getMoney() end
function DatabasePlayer:getWantedLevel()return self.m_WantedLevel end
function DatabasePlayer:getJob()   		return self.m_Job		end
function DatabasePlayer:getAccount()	return self.m_Account	end
function DatabasePlayer:getLocale()		return self.m_Locale	end
function DatabasePlayer:getPhonePartner() return self.m_PhonePartner end
function DatabasePlayer:getTutorialStage() return self.m_TutorialStage end
function DatabasePlayer:getJobVehicle() return self.m_JobVehicle end
function DatabasePlayer:getGroup()		return self.m_Group		end
function DatabasePlayer:getFaction()	return self.m_Faction	end
--function DatabasePlayer:getInventory()	return self.m_Inventory	end
function DatabasePlayer:getSkin()		return self.m_Skin		end
function DatabasePlayer:getGarageType() return self.m_GarageType end
function DatabasePlayer:getHangarType() return self.m_HangarType end -- Todo: Only Databseside implemented
function DatabasePlayer:getSpawnLocation() return self.m_SpawnLocation end
function DatabasePlayer:getCollectables() return self.m_Collectables end
function DatabasePlayer:getCompany() return self.m_Company end
function DatabasePlayer:hasPilotsLicense() return self.m_HasPilotsLicense end
function DatabasePlayer:hasDrivingLicense() return self.m_HasDrivingLicense end
function DatabasePlayer:hasBikeLicense() return self.m_HasBikeLicense end
function DatabasePlayer:hasTruckLicense() return self.m_HasTruckLicense end

-- Short setters
function DatabasePlayer:setMoney(money, instant) self.m_Money = money if self:isActive() then setPlayerMoney(self, money, instant) end end
function DatabasePlayer:setLocale(locale)	self.m_Locale = locale	end
function DatabasePlayer:setTutorialStage(stage) self.m_TutorialStage = stage end
function DatabasePlayer:setJobVehicle(vehicle) self.m_JobVehicle = vehicle end
function DatabasePlayer:setGroup(group)	self.m_Group = group if self:isActive() then self:setPublicSync("GroupName", group and group:getName() or "") end end
function DatabasePlayer:setSpawnLocation(l) self.m_SpawnLocation = l end
function DatabasePlayer:setLastGarageEntrance(e) self.m_LastGarageEntrance = e end
function DatabasePlayer:setLastHangarEntrance(e) self.m_LastHangarEntrance = e end
function DatabasePlayer:setCollectables(t) self.m_Collectables = t end
function DatabasePlayer:setHasPilotsLicense(s) self.m_HasPilotsLicense = s end
function DatabasePlayer:setPlayTime(playTime) self.m_LastPlayTime = playTime if self:isActive() then self:setPrivateSync("LastPlayTime", self.m_LastPlayTime) end end

function DatabasePlayer:setWantedLevel(level)
	-- give Achievement
	if level == 6 then
		self:giveAchievement(46)
	elseif level > 0 then
		self:giveAchievement(45)
	end

	-- set data
	self.m_WantedLevel = level
	self:setPublicSync("Wanteds", level)
	setPlayerWantedLevel(self, level)
end

function DatabasePlayer:setCompany(company)
	self.m_Company = company
	if self:isActive() then
		self:setPublicSync("CompanyId", company and company:getId() or 0)
		self:setPublicSync("CompanyName", company and company:getName() or "")
	end
end

function DatabasePlayer:setFaction(faction)
	self.m_Faction = faction
	if self:isActive() then
		self:setPublicSync("FactionId", faction and faction:getId() or 0)
		self:setPublicSync("FactionName", faction and faction:getName() or "")
		self:setPublicSync("ShortFactionName", faction and faction:getShortName() or "")
	end
end

function DatabasePlayer:giveMoney(amount)
	self:setMoney(self:getMoney() + amount)

	-- Log to database
	if DEBUG then
		-- Use sourcefile as description here
		local debugInfo = debug.getinfo(4, "Sl")
		if debugInfo then
			StatisticsLogger:getSingleton():logMoney(self, amount, tostring(debugInfo.source)..":"..tostring(debugInfo.currentline))
		end
	end
end

function DatabasePlayer:takeMoney(amount)
	self:giveMoney(-amount)
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

function DatabasePlayer:giveKarma(value, factor, addDirectly)
	factor = factor or 1
	if not addDirectly and value < 0 then
		factor = -factor
	end

	local changekarma = addDirectly and value*factor or Karma.calcKarma(self.m_Karma, self.m_Karma+value, factor)

	self:setXP(self.m_XP + math.abs(changekarma) * 10)
	self:setKarma(self.m_Karma + changekarma)

	local group = self:getGroup()
	if group then
		group:giveKarma(changekarma)
	end
end

function DatabasePlayer:givePoints(p)
	self.m_Points = self.m_Points + math.floor(p)
	if self:isActive() then self:setPrivateSync("Points", self.m_Points) end
end

function DatabasePlayer:takePoints(p)
	self:givePoints(-p)
end

function DatabasePlayer:setPoints(p)
	self.m_Points = math.floor(p)
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
		self:getBankAccount():addMoney(amount)
		if self.m_BankMoney >= 10000000 then
			self:giveAchievement(40)
		elseif self.m_BankMoney >= 1000000 then
			self:giveAchievement(21)
		end

		return true
	end
	return false
end

function DatabasePlayer:takeBankMoney(amount, logType)
	logType = logType or BankStat.Payment
	if sql:queryExec("INSERT INTO ??_bank_statements (UserId, Type, Amount, Date) VALUES(?, ?, ?, NOW())", sql:getPrefix(), self.m_Id, logType, amount) then
		self:getBankAccount():takeMoney(amount)
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

function DatabasePlayer:setHangarType(hangarType)
	self.m_HangarType = hangarType
	sql:queryExec("UPDATE ??_character SET hangarType = ? WHERE Id = ?", sql:getPrefix(), hangarType, self.m_Id)
end

function DatabasePlayer:getTeamId(kind)
	return self.m_LadderTeam[kind]
end

function DatabasePlayer:setTeamId(kind,id)
	self.m_LadderTeam[kind] = id
	return true
end

function DatabasePlayer:updateAchievements (tbl)
	if tbl ~= nil then
		self.m_Achievements = tbl
	end
	if self:isActive() then self:setPrivateSync("Achievements", table.copy(self.m_Achievements)) end
	-- Todo: In my tests, the table must be copied, otherwise the client didn't received it. --> Find out why (Jusonex can't reproduce it)
end

function DatabasePlayer:getAchievements ()
	return (self.m_Achievements ~= nil and self.m_Achievements) or {[0] = false}
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

function DatabasePlayer:setMatchID (id)
	if self:isActive() then self:setPublicSync("DMMatchID", id) end
end

function DatabasePlayer:getMatchID ()
	if self:isActive() then
		return (
			(
				self:getPublicSync("DMMatchID") and
				self:getPublicSync("DMMatchID") > 0 and
				self:getPublicSync("DMMatchID")
			) or (0)
		)
	else
		return (0)
	end
end

function DatabasePlayer:getPlayTime() -- This function is overriden by Player:getPlayTime (to provide a live playtime)
	return self.m_LastPlayTime
end
