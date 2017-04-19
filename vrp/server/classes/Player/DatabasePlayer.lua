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
	self.m_Money = 3000
	self.m_BankMoney = 4000
	self.m_WantedLevel = 0
	self.m_WeaponLevel = 0
	self.m_VehicleLevel = 0
	self.m_SkinLevel = 0
	self.m_AlcoholLevel = 0
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
	self.m_SpawnerVehicle = false
	self.m_GarageType = 0
	self.m_HangarType = 0
	self.m_LastGarageEntrance = 0
	self.m_SpawnLocation = SPAWN_LOCATION_DEFAULT
	self.m_Collectables = {}
	self.m_Achievements = {[0] = false} -- Dummy element, otherwise the JSON string is built wrong
	self.m_DMMatchID = 0
	self.m_SessionId = false
	self.m_PrisonTime = 0
	self.m_Bail = 0
end

function DatabasePlayer:virtual_destructor()
	if self.m_Id > 0 then
		DatabasePlayer.Map[self.m_Id] = nil
	end
end

function DatabasePlayer:load()
	local row = sql:asyncQueryFetchSingle("SELECT PosX, PosY, PosZ, Interior, Dimension, Skin, XP, Karma, Points, WeaponLevel, VehicleLevel, SkinLevel, JobLevel, Money, WantedLevel, Job, GroupId, GroupRank, FactionId, FactionRank, DrivingSkill, GunSkill, FlyingSkill, SneakingSkill, EnduranceSkill, TutorialStage, InventoryId, GarageType, LastGarageEntrance, HangarType, LastHangarEntrance, SpawnLocation, Collectables, HasPilotsLicense, HasTheory, HasDrivingLicense, HasBikeLicense, HasTruckLicense, PaNote, STVO, Achievements, PlayTime, BankAccount, CompanyId, PrisonTime, GunBox, Bail, JailTime, SpawnWithFacSkin, AltSkin, AlcoholLevel, CJClothes FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	if not row then
		return false
	end

	if row.Achievements and type(fromJSON(row.Achievements)) == "table" then
		self:updateAchievements(table.setIndexToInteger(fromJSON(row.Achievements)))
	else
		self:updateAchievements({[0] = false}) -- Dummy element, otherwise the JSON string is built wrong
	end

	self.m_SavedPosition = Vector3(row.PosX, row.PosY, row.PosZ)
	self.m_SavedInterior = row.Interior
	self.m_SavedDimension = row.Dimension
	self.m_Skin = row.Skin
	self.m_SkinData = {}
	self.m_CJData = fromJSON(row.CJClothes) or {}
	self.m_AltSkin = row.AltSkin
	if self.m_AltSkin == 0 then
		self.m_AltSkin = self.m_Skin
	end
	self:setXP(row.XP)
	self:setKarma(row.Karma)
	self:setPoints(row.Points)
	self:setMoney(row.Money, true)
	self:setSTVO(row.STVO)

	if tonumber(row.SpawnWithFacSkin) == 1 then
		self.m_SpawnWithFactionSkin = true
	else
		self.m_SpawnWithFactionSkin = false
	end
	self:setWantedLevel(row.WantedLevel, true)
	self.m_TutorialStage = row.TutorialStage

	if not row.BankAccount or row.BankAccount == 0 then
		self.m_BankAccount = BankAccount.create(BankAccountTypes.Player, self:getId())
	else
		self.m_BankAccount = BankAccount.load(row.BankAccount)
	end
	self.m_BankAccount:update()

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
	self.m_GunBox = fromJSON(row.GunBox or "")
	self.m_HasPilotsLicense = toboolean(row.HasPilotsLicense)
	self.m_HasTheory = toboolean(row.HasTheory)
	self.m_HasDrivingLicense = toboolean(row.HasDrivingLicense)
	self.m_HasBikeLicense = toboolean(row.HasBikeLicense)
	self.m_HasTruckLicense = toboolean(row.HasTruckLicense)
	self.m_PaNote = row.PaNote

	self.m_PrisonTime = row.PrisonTime

	self.m_Skills["Driving"] 	= row.DrivingSkill
	self.m_Skills["Gun"] 		= row.GunSkill
	self.m_Skills["Flying"] 	= row.FlyingSkill
	self.m_Skills["Sneaking"] 	= row.SneakingSkill
	self.m_Skills["Endurance"] 	= row.EnduranceSkill

	if self:isActive() then
		setPlayerWantedLevel(self, self.m_WantedLevel)
		setPlayerMoney(self, self.m_Money, true) -- Todo: Remove this line later

		-- Generate Session Id
		self:setSessionId(hash("md5", self:getSerial()..self:getName()..self.m_Account:getLastLogin()))
	end

	self:setWeaponLevel(row.WeaponLevel)
	self:setVehicleLevel(row.VehicleLevel)
	self:setSkinLevel(row.SkinLevel)
	self:setJobLevel(row.JobLevel)
	self:setAlcoholLevel(row.AlcoholLevel)
	self:setPlayTime(row.PlayTime)
	self:setPrison(0)
	self:setWarns()
	self:setBail( row.Bail )
	self:setJailTime( row.JailTime or 0)
	self.m_LoggedIn = true

	self.m_Statistics = {}
	self:loadStatistics()
end

function DatabasePlayer:save()
	if self:isGuest() then
		return false
	end
	if self.m_LoggedIn then
		self:saveStatistics()

		if self.m_BankAccount then
			self.m_BankAccount:save()
		end

		local spawnFac
		if self.m_SpawnWithFactionSkin then
			spawnFac = 1
		else
			spawnFac = 0
		end
		return sql:queryExec("UPDATE ??_character SET Skin=?, XP=?, Karma=?, Points=?, WeaponLevel=?, VehicleLevel=?, SkinLevel=?, Money=?, WantedLevel=?, TutorialStage=?, Job=?, SpawnLocation=?, LastGarageEntrance=?, LastHangarEntrance=?, Collectables=?, JobLevel=?, Achievements=?, BankAccount=?, HasPilotsLicense=?, HasTheory=?, hasDrivingLicense=?, hasBikeLicense=?, hasTruckLicense=?, PaNote=?, STVO=?, PrisonTime=?, GunBox=?, Bail=?, JailTime=? ,SpawnWithFacSkin=?, AltSkin=?, AlcoholLevel = ?, CJClothes = ? WHERE Id=?", sql:getPrefix(),
			self.m_Skin, self.m_XP,	self.m_Karma, self.m_Points, self.m_WeaponLevel, self.m_VehicleLevel, self.m_SkinLevel,	self:getMoney(), self.m_WantedLevel, self.m_TutorialStage, 0, self.m_SpawnLocation, self.m_LastGarageEntrance, self.m_LastHangarEntrance,	toJSON(self.m_Collectables or {}, true), self:getJobLevel(), toJSON(self:getAchievements() or {}, true), self:getBankAccount() and self:getBankAccount():getId() or 0, self.m_HasPilotsLicense, self.m_HasTheory, self.m_HasDrivingLicense, self.m_HasBikeLicense, self.m_HasTruckLicense, self.m_PaNote, self.m_STVO, self:getRemainingPrisonTime(), toJSON(self.m_GunBox or {}, true), self.m_Bail or 0,self.m_JailTime or 0, spawnFac, self.m_AltSkin or 0, self.m_AlcoholLevel, toJSON(self.m_SkinData or {}), self:getId())
	end
	return false
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
function DatabasePlayer:getRegistrationDate() return self.m_Account and self.m_Account:getRegistrationDate() end


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
function DatabasePlayer:getSpawnerVehicle() return self.m_SpawnerVehicle end
function DatabasePlayer:getGroup()		return self.m_Group		end
function DatabasePlayer:getFaction()	return self.m_Faction	end
function DatabasePlayer:getJailTime() return self.m_JailTime end
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
function DatabasePlayer:getPaNote() return self.m_PaNote end
function DatabasePlayer:getSTVO() return self.m_STVO end
function DatabasePlayer:getBail() return self.m_Bail end

-- Short setters
function DatabasePlayer:setMoney(money, instant) self.m_Money = money if self:isActive() then setPlayerMoney(self, money, instant) self:setPublicSync("Money", money) end end
function DatabasePlayer:setLocale(locale)	self.m_Locale = locale	end
function DatabasePlayer:setTutorialStage(stage) self.m_TutorialStage = stage end
function DatabasePlayer:setSpawnerVehicle(vehicle) self.m_SpawnerVehicle = vehicle end
function DatabasePlayer:setSpawnLocation(l) self.m_SpawnLocation = l end
function DatabasePlayer:setLastGarageEntrance(e) self.m_LastGarageEntrance = e end
function DatabasePlayer:setLastHangarEntrance(e) self.m_LastHangarEntrance = e end
function DatabasePlayer:setCollectables(t) self.m_Collectables = t end
function DatabasePlayer:setHasPilotsLicense(s) self.m_HasPilotsLicense = s end
function DatabasePlayer:setPlayTime(playTime) self.m_LastPlayTime = playTime if self:isActive() then self:setPrivateSync("LastPlayTime", self.m_LastPlayTime) end end
function DatabasePlayer:setPaNote(note) self.m_PaNote = note end
function DatabasePlayer:setBail( bail ) self.m_Bail = bail end
function DatabasePlayer:setJailTime( jail ) self.m_JailTime = jail end

function DatabasePlayer:loadStatistics()
	local row = sql:queryFetchSingle("SELECT * FROM ??_stats WHERE Id = ?", sql:getPrefix(), self.m_Id)
	if not row then
		local row = sql:queryExec("INSERT INTO ??_stats (Id) VALUES (?)", sql:getPrefix(), self.m_Id)
		self:loadStatistics()
		return
	end
	for index, value in pairs(row) do
		if index ~= "Id" then
			self.m_Statistics[index] = value
			if self:isActive() then
				self:setPrivateSync("Stat_"..index, value)
			end
		end
	end
end

function DatabasePlayer:saveStatistics()
	local string = ""
	for index, value in pairs(self.m_Statistics) do
		string = string..index.." = "..value..", "
	end
	string = string:sub(1, -3) -- Removed last ", " cause of sql error

	sql:queryExec("UPDATE ??_stats SET ?? WHERE Id = ?", sql:getPrefix(), string ,self.m_Id)

end

function DatabasePlayer:increaseStatistics(stat, value)
	if not self.m_Statistics then return end
	value = value and value or 1
	if self.m_Statistics[stat] then
		self.m_Statistics[stat] = self.m_Statistics[stat] + value

		if self:isActive() then
			self:setPrivateSync("Stat_"..stat, self.m_Statistics[stat])
		end
	else
		outputDebug("Error increasing Stat. "..stat.." for Player Id: "..self.m_Id.."! DB-Column missing!")
	end
end

function DatabasePlayer:setGroup(group)
	self.m_Group = group
	if self:isActive() then
		self:setPublicSync("GroupId", group and group:getId() or 0)
		self:setPublicSync("GroupName", group and group:getName() or "")
		self:setPublicSync("GroupType", group and group:getType() or false)
	end
end

function DatabasePlayer:setWarns()
	local rows = sql:queryFetch("SELECT * FROM ??_warns WHERE userId = ?;", sql:getPrefix(), self.m_Id)
	for index, row in pairs(rows) do
		row.adminName = Account.getNameFromId(row["adminId"])
	end
	self.m_Warns = rows

	if self:isActive() then
		self:setPublicSync("Warns", rows)
	end
end

function DatabasePlayer:getWarns()
	return self.m_Warns
end

function DatabasePlayer:setWantedLevel(level, disableAchievement)
	if level > 6 then level = 6 end
	if level < 0 then level = 0 end
	if not disableAchievement then
		-- give Achievement
		if level == 6 then
			self:giveAchievement(46)
		elseif level > 0 then
			self:giveAchievement(45)
		end
	end

	-- set data
	self.m_WantedLevel = level
	if self:isActive() then
		self:setPublicSync("Wanteds", level)
		setPlayerWantedLevel(self, level)
	end
end

function DatabasePlayer:setCompany(company)
	self.m_Company = company
	if self:isActive() then
		self:setPublicSync("CompanyId", company and company:getId() or 0)
		self:setPublicSync("CompanyName", company and company:getName() or "")
		self:setPublicSync("ShortCompanyName", company and company:getShortName() or "")

	end
end

function DatabasePlayer:setFaction(faction)
	self.m_Faction = faction
	if self:isActive() then
		self:setPublicSync("FactionId", faction and faction:getId() or 0)
		--if faction and faction:isStateFaction() then
		--	bindKey(self, "m", "down", "chatbox", "BeamtenChat")
		--end
	end
end

function DatabasePlayer:giveMoney(amount, reason)
	self:setMoney(self:getMoney() + amount)
	StatisticsLogger:getSingleton():addMoneyLog("player", self, amount, reason or "Unbekannt")
end

function DatabasePlayer:takeMoney(amount, reason)
	self:giveMoney(-amount, reason)
end

function DatabasePlayer:setXP(xp)
	self.m_XP = xp
end

function DatabasePlayer:getLevel()
	return calculatePlayerLevel(self.m_XP)
end

function DatabasePlayer:setKarma(karma)
	self.m_Karma = karma
	if self.m_Karma > MAX_KARMA_LEVEL then self.m_Karma = MAX_KARMA_LEVEL end
	if self.m_Karma < -MAX_KARMA_LEVEL then self.m_Karma = -MAX_KARMA_LEVEL end

	if self:isActive() then self:setPrivateSync("KarmaLevel", self.m_Karma) end
end

function DatabasePlayer:giveKarma(value)
	self:setXP(self.m_XP + value)
	self:setKarma(self.m_Karma + value)

	local group = self:getGroup()
	if group then
		group:giveKarma(value)
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
	if self:isActive() then
		self:setPrivateSync("WeaponLevel", self.m_WeaponLevel)
		for _, stat in ipairs({ 69, 70, 71, 72, 74, 76, 77, 78}) do
			if stat == 69 then
				setPedStat(self, stat, self.m_WeaponLevel*90)
			else
		  		setPedStat(self, stat, self.m_WeaponLevel*100)
			end
	   end
	end
end

function DatabasePlayer:setVehicleLevel (level)
	if level < 1 then level = 1 end
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

function DatabasePlayer:setAlcoholLevel(level, oldLevel)
	self.m_AlcoholLevel = math.round(level, 2)

	if self:isActive() then
		if level > MAX_ALCOHOL_LEVEL then
			self.m_AlcoholLevel = MAX_ALCOHOL_LEVEL
		elseif level < 0 then
			self.m_AlcoholLevel = 0
			toggleControl(self,"sprint",true)
			setPedWalkingStyle(self,0)
		elseif level  >= 2 then
			setPedWalkingStyle(self,126)
		elseif level <= 2 then
			toggleControl(self,"sprint",true)
			setControlState(self,"walk",false)
		elseif level == 0 then
			toggleControl(self,"sprint",true)
			setPedWalkingStyle(self,0)
		end

		if level >= MAX_ALCOHOL_LEVEL then
			self:sendShortMessage(_("Du wurdest wegen einer Alkoholvergiftung ins Krankenhaus befördert!", self))
			self:setAlcoholLevel(0)
			self:kill()
			return
		end
		if oldLevel then
			local diff = self.m_AlcoholLevel - oldLevel
			self:sendShortMessage(_("Aktueller Alkoholgehalt: %s ‰ (%s)", self, tostring(self.m_AlcoholLevel), tostring(diff > 0 and "+"..diff or diff)), "Alkoholgehalt")
		end

		self:setPrivateSync("AlcoholLevel", self.m_AlcoholLevel)
	end
end

function DatabasePlayer:incrementAlcoholLevel(value)
	local oldLevel = self.m_AlcoholLevel
	local newLevel = oldLevel + value
	self:setAlcoholLevel(newLevel, oldLevel)
end

function DatabasePlayer:decreaseAlcoholLevel(value)
	local oldLevel = self.m_AlcoholLevel
	local newLevel = oldLevel - value
	self:setAlcoholLevel(newLevel, oldLevel)
end

function DatabasePlayer:addBankMoney(amount, reason)
	if StatisticsLogger:getSingleton():addMoneyLog("player", self, amount, reason or "Unbekannt", 1) then
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

function DatabasePlayer:takeBankMoney(amount, reason)
	if StatisticsLogger:getSingleton():addMoneyLog("player", self, -amount, reason or "Unbekannt", 1) then
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

function DatabasePlayer:updateAchievements(tbl)
	if tbl ~= nil then
		self.m_Achievements = tbl
	end
	if self:isActive() then
		self:setPrivateSync("Achievements", toJSON(self.m_Achievements))
	end
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

function DatabasePlayer:loadMigratorData()
	local row = sql:queryFetchSingle("SELECT Money, PlayTime, Points, HasDrivingLicense, HasPilotsLicense, HasBikeLicense, HasTruckLicense, HasTheory, PaNote, GroupId FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	if not row then return false end
	self:setMoney(row.Money)
	self:setPoints(row.Points)
	self:setPlayTime(row.PlayTime)
	self.m_HasPilotsLicense = toboolean(row.HasPilotsLicense)
	self.m_HasTheory = toboolean(row.HasTheory)
	self.m_HasDrivingLicense = toboolean(row.HasDrivingLicense)
	self.m_HasBikeLicense = toboolean(row.HasBikeLicense)
	self.m_HasTruckLicense = toboolean(row.HasTruckLicense)
	self.m_PaNote = row.PaNote

	if row.GroupId and row.GroupId ~= 0 then
		if GroupManager:getSingleton():getFromId(row.GroupId) then
			self:setGroup(GroupManager:getSingleton():getFromId(row.GroupId))
		else
			GroupManager:getSingleton():loadFromId(row.GroupId)
			self:setGroup(GroupManager:getSingleton():getFromId(row.GroupId))
		end
		VehicleManager:getSingleton():refreshGroupVehicles(self:getGroup())
	end

	VehicleManager:getSingleton():createVehiclesForPlayer(self)
	self.m_Premium = PremiumPlayer:new(self)
end


function DatabasePlayer:setPrison(duration, forceTime)
	self.m_PrisonTime = forceTime and duration or self.m_PrisonTime + duration

	if self:isActive() then
		if isTimer(self.m_PrisonTimer) then killTimer(self.m_PrisonTimer) end
		if self.m_PrisonTime > 0 then
			if self:getOccupiedVehicle() then self:removeFromVehicle() end
			self:setData("inAdminPrison",true,true)
			toggleControl(self, "fire", false)
			toggleControl(self, "jump", false)
			toggleControl(self, "aim_weapon", false)
			takeAllWeapons(self)
			setElementDimension(self, 0)
			setElementInterior(self, 0)
			self:setPosition(Vector3(-224,2371.29,5688.73))
			self:triggerEvent("playerPrisoned", self.m_PrisonTime/60)
			self.m_PrisonTimer = setTimer(bind(self.endPrison, self), self.m_PrisonTime*1000, 1, player)
		end
	end
end

function DatabasePlayer:hasCorrectLicense(vehicle)
	if table.find(NO_LICENSE_VEHICLES, vehicle:getModel()) then
		return true
	end
	if vehicle:getVehicleType() == VehicleType.Automobile then
		if table.find(TRUCK_MODELS, vehicle:getModel()) then
			return self:hasTruckLicense()
		else
			return self:hasDrivingLicense()
		end
	elseif vehicle:getVehicleType() == VehicleType.Bike then
		return self:hasBikeLicense()
	elseif vehicle:getVehicleType() == VehicleType.Plane or vehicle:getVehicleType() == VehicleType.Helicopter then
		return self:hasPilotsLicense()
	end
	return true
end

function DatabasePlayer:setJailNewTime()
	if self.m_JailStart then
		local now = getRealTime().timestamp
		if self.m_JailStart < now then
			local dif = now - self.m_JailStart
			local minutes = math.floor((dif % 3600) / 60)
			self.m_JailTime = self.m_JailTime - minutes
			if self.m_JailTime <= 0 then
				if self:isActive() then
					FactionState:getSingleton():freePlayer(self)
				else
					self.m_JailTime = 0
					self.m_Bail = 0
					self:setWantedLevel(0)
				end
			end
		end
	end
end


function DatabasePlayer:getRemainingPrisonTime()
	if self:isActive() then
		local timerLeft = false
		if isTimer(self.m_PrisonTimer) then
			timerLeft = getTimerDetails(self.m_PrisonTimer)/1000
		end
		if timerLeft then
			self.m_PrisonTime = timerLeft
		end
	end
	return self.m_PrisonTime
end


function DatabasePlayer:setNewNick(admin, newNick)
	if not self:getId() or self:getId() <= 0 then
		admin:sendError(_("Id nicht gefunden!", admin))
		return false
	end



	if not newNick:match("^[a-zA-Z0-9_.%[%]]*$") or #newNick < 3 then
		admin:sendError(_("Ungültiger Nickname!", admin))
		return false
	end

	local row = board:queryFetchSingle("SELECT username FROM wcf1_user WHERE username LIKE ?", newNick)
	if row then
		admin:sendError(_("Nickname bereits vergeben!", admin))
		return false
	end

	local oldNick = Account.getNameFromId(self.m_Id)
	local boardId = Account.getBoardIdFromId(self.m_Id)

	sql:queryExec("UPDATE ??_account SET Name = ? WHERE Id = ?", sql:getPrefix(), newNick, self.m_Id)
	board:queryExec("UPDATE wcf1_user SET username = ? WHERE UserID = ?", newNick, boardId)
	StatisticsLogger:getSingleton():addPunishLog(admin, self.m_Id, func, "von "..oldNick.." zu "..newNick, 0)

	if self:isActive() then
		self:getAccount().m_Username = newNick
		self:setName(self:getAccount():getName())
		self:sendMessage(_("%s hat dein Nickname von %s in %s geändert!", self, admin:getName(), oldNick, newNick), 255, 0, 0)
	end

	return true
end

function DatabasePlayer:addOfflineMessage( text, typ)
	local id = self:getId()
	if id then
		sql:queryExec("INSERT INTO ??_offlineMessage ( PlayerId, Text, Typ, Time ) VALUES(?, ?, ?, ?)", sql:getPrefix(), id, text or "" , typ or 1 , getRealTime().timestamp )
	end
end

function DatabasePlayer:getOfflineMessages( text, typ)
	local id = self:getId()
	if id then
		self.m_OfflineMessages = {}
		local row = sql:queryFetch("SELECT * FROM ??_offlineMessage WHERE PlayerId = ?", sql:getPrefix(), id)
		if row then
			for k, d in pairs( row ) do
				self.m_OfflineMessages[#self.m_OfflineMessages+1] = {d["Text"], d["Typ"], d["Time"]}
				sql:queryExec("DELETE FROM ??_offlineMessage WHERE Id = ?", sql:getPrefix(), d["Id"])
			end
		end
	end
end

function DatabasePlayer:setSTVO(stvo)
	self.m_STVO = stvo or 0

	if self.m_STVO >= 20 then
		self.m_HasDrivingLicense = false
		self.m_STVO = 0
		if self:isActive() then
			self:sendMessage(_("Du hast 20 STVO Punkte! Dein Auto-Führerschein wurde abgenommen!", self), 255, 0, 0)
		else
			self:addOfflineMessage( "Du hattest 20 STVO Punkte dein Führerschein wurde abgenommen!", 1)
		end
	end

	if self:isActive() then
		self:setPublicSync("STVO", self.m_STVO)
	end
end
