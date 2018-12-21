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

	self.m_SpawnerVehicle = false
	self.m_GarageType = 0
	self.m_HangarType = 0
	self.m_LastGarageEntrance = 0
	self.m_SpawnLocation = SPAWN_LOCATIONS.DEFAULT
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

function DatabasePlayer:load(sync)
	local row
	if sync then
		row = sql:queryFetchSingle("SELECT * FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	else
		row = sql:asyncQueryFetchSingle("SELECT * FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	end

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
	self.m_SkinData = fromJSON(row.CJClothes) or {}
	self:setXP(row.XP)
	self:setKarma(row.Karma)
	self:setPoints(row.Points)
	self:setMoney(row.Money, true)
	self:setSTVO(nil, fromJSON(row.STVO))

	if tonumber(row.SpawnWithFacSkin) == 1 then
		self.m_SpawnWithFactionSkin = true
	else
		self.m_SpawnWithFactionSkin = false
	end
	self:setWanteds(row.WantedLevel, true)

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

	self.m_GarageType = row.GarageType
	self.m_LastGarageEntrance = row.LastGarageEntrance
	self.m_HangarType = row.HangarType
	self.m_LastHangarEntrance = row.LastHangarEntrance
	self.m_SpawnLocationProperty = fromJSON(row.SpawnLocationProperty or "")
	self.m_Collectables = fromJSON(row.Collectables or "")
	self.m_GunBox = fromJSON(row.GunBox or "")
	self.m_FishSpeciesCaught = fromJSON(row.FishSpeciesCaught or "[[]]")
	self.m_HasPilotsLicense = toboolean(row.HasPilotsLicense)
	self.m_HasTheory = toboolean(row.HasTheory)
	self.m_HasDrivingLicense = toboolean(row.HasDrivingLicense)
	self.m_HasBikeLicense = toboolean(row.HasBikeLicense)
	self.m_HasTruckLicense = toboolean(row.HasTruckLicense)
	self.m_PaNote = row.PaNote
	self.m_PrisonTime = row.PrisonTime

	self.m_FishSpeciesCaught = table.setIndexToInteger(self.m_FishSpeciesCaught)

	self.m_Skills["Driving"] 	= row.DrivingSkill
	self.m_Skills["Gun"] 		= row.GunSkill
	self.m_Skills["Flying"] 	= row.FlyingSkill
	self.m_Skills["Sneaking"] 	= row.SneakingSkill
	self.m_Skills["Endurance"] 	= row.EnduranceSkill

	if self:isActive() then
		setPlayerMoney(self, self.m_Money, true) -- Todo: Remove this line later
	end

	self:setSpawnLocation(row.SpawnLocation)
	self:setFishingSkill(row.FishingSkill)
	self:setFishingLevel(row.FishingLevel)
	self:setWeaponLevel(row.WeaponLevel)
	self:setVehicleLevel(row.VehicleLevel)
	self:setSkinLevel(row.SkinLevel)
	self:setJobLevel(row.JobLevel)
	self:setAlcoholLevel(row.AlcoholLevel)
	self:setPlayTime(row.PlayTime)
	self.m_StartTime = row.PlayTime
	self.m_LoginTime = getRealTime().timestamp
	self:setPrison(0)
	self:setWarns()
	self:setBail( row.Bail )
	self:setJailTime( row.JailTime or 0)
	self.m_TeamspeakId = Account.getTeamspeakIdFromId(self.m_Id)
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

		local row = sql:queryFetchSingle("SELECT Id FROM ??_accountActivity WHERE UserID = ? AND SessionStart = ?;", sql:getPrefix(), self:getId(), self.m_LoginTime)

		if not row then
			sql:queryExec("INSERT INTO ??_accountActivity (Date, UserID, SessionStart, Duration) VALUES (FROM_UNIXTIME(?), ?, ?, ?);", sql:getPrefix(),
			self.m_LoginTime, self:getId(), self.m_LoginTime, self:getPlayTime() - self.m_StartTime)
		else
			sql:queryExec("UPDATE ??_accountActivity SET Duration = ? WHERE Id = ?;", sql:getPrefix(),
			self:getPlayTime() - self.m_StartTime, row.Id)
		end

		return sql:queryExec("UPDATE ??_character SET Skin=?, XP=?, Karma=?, Points=?, WeaponLevel=?, VehicleLevel=?, SkinLevel=?, Money=?, WantedLevel=?, Job=?, SpawnLocation=?, SpawnLocationProperty = ?, LastGarageEntrance=?, LastHangarEntrance=?, Collectables=?, JobLevel=?, Achievements=?, BankAccount=?, HasPilotsLicense=?, HasTheory=?, hasDrivingLicense=?, hasBikeLicense=?, hasTruckLicense=?, PaNote=?, STVO=?, PrisonTime=?, GunBox=?, Bail=?, JailTime=? ,SpawnWithFacSkin=?, AlcoholLevel = ?, CJClothes = ?, FishingSkill = ?, FishingLevel = ?, FishSpeciesCaught = ? WHERE Id=?", sql:getPrefix(),
			self.m_Skin, self.m_XP,	self.m_Karma, self.m_Points, self.m_WeaponLevel, self.m_VehicleLevel, self.m_SkinLevel,	self:getMoney(), self.m_WantedLevel, 0, self.m_SpawnLocation, toJSON(self.m_SpawnLocationProperty or ""), self.m_LastGarageEntrance, self.m_LastHangarEntrance,	toJSON(self.m_Collectables or {}, true), self:getJobLevel(), toJSON(self:getAchievements() or {}, true), self:getBankAccount() and self:getBankAccount():getId() or 0, self.m_HasPilotsLicense, self.m_HasTheory, self.m_HasDrivingLicense, self.m_HasBikeLicense, self.m_HasTruckLicense, self.m_PaNote, toJSON(self.m_STVO, true), self:getRemainingPrisonTime(), toJSON(self.m_GunBox or {}, true), self.m_Bail or 0,self.m_JailTime or 0, spawnFac, self.m_AlcoholLevel, toJSON(self.m_SkinData or {}), self.m_FishingSkill  or 0, self.m_FishingLevel or 0, toJSON(self.m_FishSpeciesCaught), self:getId())
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
function DatabasePlayer:hasAdminRightTo(strPerm) return ADMIN_RANK_PERMISSION[strPerm] and self:getRank() >= ADMIN_RANK_PERMISSION[strPerm] end
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
function DatabasePlayer:getWanteds()return self.m_WantedLevel end
function DatabasePlayer:getJob()   		return self.m_Job		end
function DatabasePlayer:getAccount()	return self.m_Account	end
function DatabasePlayer:getLocale()		return self.m_Locale	end
function DatabasePlayer:getPhonePartner() return self.m_PhonePartner end
function DatabasePlayer:getSpawnerVehicle() return self.m_SpawnerVehicle end
function DatabasePlayer:getGroup()		return self.m_Group		end
function DatabasePlayer:getFaction()	return self.m_Faction	end
function DatabasePlayer:getJailTime() return self.m_JailTime end
--function DatabasePlayer:getInventory()	return self.m_Inventory	end
function DatabasePlayer:getSkin()		return self.m_Skin		end
function DatabasePlayer:getGarageType() return self.m_GarageType end
function DatabasePlayer:getHangarType() return self.m_HangarType end -- Todo: Only Databseside implemented
function DatabasePlayer:getSpawnLocation() return self.m_SpawnLocation end
function DatabasePlayer:getSpawnLocationProperty() return self.m_SpawnLocationProperty end
function DatabasePlayer:getCollectables() return self.m_Collectables end
function DatabasePlayer:getCompany() return self.m_Company end
function DatabasePlayer:hasPilotsLicense() return self.m_HasPilotsLicense end
function DatabasePlayer:hasDrivingLicense() return self.m_HasDrivingLicense end
function DatabasePlayer:hasBikeLicense() return self.m_HasBikeLicense end
function DatabasePlayer:hasTruckLicense() return self.m_HasTruckLicense end
function DatabasePlayer:getPaNote() return self.m_PaNote end
function DatabasePlayer:getBail() return self.m_Bail end
function DatabasePlayer:isStateCuffed() return self.m_StateCuffed end
function DatabasePlayer:getFishingSkill() return self.m_FishingSkill end
function DatabasePlayer:getFishingLevel() return self.m_FishingLevel end

-- Short setters
function DatabasePlayer:setMoney(money, instant) self.m_Money = money if self:isActive() then setPlayerMoney(self, money, instant) self:setPublicSync("Money", money) end end
function DatabasePlayer:setLocale(locale)	self.m_Locale = locale	end
function DatabasePlayer:setSpawnerVehicle(vehicle) self.m_SpawnerVehicle = vehicle end
function DatabasePlayer:setSpawnLocation(l) self.m_SpawnLocation = l if self:isActive() then self:setPrivateSync("SpawnLocation", self.m_SpawnLocation) end end
function DatabasePlayer:setSpawnLocationProperty(prop) self.m_SpawnLocationProperty = prop end
function DatabasePlayer:setLastGarageEntrance(e) self.m_LastGarageEntrance = e end
function DatabasePlayer:setLastHangarEntrance(e) self.m_LastHangarEntrance = e end
function DatabasePlayer:setCollectables(t) self.m_Collectables = t end
function DatabasePlayer:setHasPilotsLicense(s) self.m_HasPilotsLicense = s end
function DatabasePlayer:setPlayTime(playTime) self.m_LastPlayTime = playTime if self:isActive() then self:setPrivateSync("LastPlayTime", self.m_LastPlayTime) end end
function DatabasePlayer:setPaNote(note) self.m_PaNote = note end
function DatabasePlayer:setBail( bail ) self.m_Bail = bail end
function DatabasePlayer:setJailTime( jail ) self.m_JailTime = jail end
function DatabasePlayer:setStateCuffed(state) self.m_StateCuffed = state end
function DatabasePlayer:setFishingSkill(points) self.m_FishingSkill = math.floor(points or 0) if self:isActive() then self:setPrivateSync("FishingSkill", self.m_FishingSkill) end end
function DatabasePlayer:setFishingLevel(level) self.m_FishingLevel = level or 0	if self:isActive() then self:setPrivateSync("FishingLevel", self.m_FishingLevel) end end

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
		if value then
			string = string..index.." = "..value..", "
		end
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

function DatabasePlayer:getStatistics(stat)
	if not self.m_Statistics then return end
	return self.m_Statistics[stat]
end

function DatabasePlayer:setGroup(group)
	self.m_Group = group
	if self:isActive() then
		self:setPublicSync("GroupId", group and group:getId() or 0)
		self:setPublicSync("GroupName", group and group:getName() or "")
		self:setPublicSync("GroupType", group and group:getType() or false)
		self:setPublicSync("GroupRank", group and group:getPlayerRank(self))
		self:setPublicSync("GroupRankNames", group and group.m_RankNames)
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

function DatabasePlayer:setWanteds(level, disableAchievement)
	if level > MAX_WANTED_LEVEL then level = MAX_WANTED_LEVEL end
	if level < 0 then level = 0 end
	if not disableAchievement then
		-- give Achievement
		if level == MAX_WANTED_LEVEL then
			self:giveAchievement(46)
		elseif level > 0 then
			self:giveAchievement(45)
		end
	end

	-- set data
	self.m_WantedLevel = level
	if self:isActive() then
		self:setPublicSync("Wanteds", level)
		--setPlayerWantedLevel(self, level)
	end
end

function DatabasePlayer:getWanteds()
	return self.m_WantedLevel
end

function DatabasePlayer:setCompany(company)
	self.m_Company = company
	if self:isActive() then
		self:setPublicSync("CompanyId", company and company:getId() or 0)
		self:setPublicSync("CompanyName", company and company:getName() or "")
		self:setPublicSync("CompanyRank", company and company:getPlayerRank(self) or 0)
		self:setPublicSync("ShortCompanyName", company and company:getShortName() or "")

	end
end

function DatabasePlayer:setFaction(faction)
	self.m_Faction = faction
	if self:isActive() then
		self:setPublicSync("FactionId", faction and faction:getId() or 0)
		self:setPublicSync("FactionRank", faction and faction:getPlayerRank(self) or 0)
		if self.m_Faction then
			self.m_Faction:onPlayerJoin(self)
		end
		--if faction and faction:isStateFaction() then
		--	bindKey(self, "m", "down", "chatbox", "BeamtenChat")
		--end
	end
end

function DatabasePlayer:__giveMoney(amount, reason, silent)
	self:setMoney(self:getMoney() + amount)
	StatisticsLogger:getSingleton():addMoneyLog("player", self, amount, reason or "Unbekannt")
	return true
end

function DatabasePlayer:__takeMoney(amount, reason, silent)
	return DatabasePlayer.__giveMoney(self, -amount, reason, silent)
end

function DatabasePlayer:transferMoney(toObject, amount, reason, category, subcategory, options)
	if amount == nil or not tonumber(amount) or isNan(amount) then error("DatabasePlayer.transferMoney @ Invalid parameter at position 2, Reason: " .. tostring(reason)) return false end
	if not options then options = {} end
	local amount = math.floor(amount)

	local targetObject = toObject
	local offlinePlayer = false
	local isPlayer = false
	local goesToBank = false
	local silent = false
	local allIfToMuch = false

	local toType = ""
	local toId = 0
	local toBank = -1

	if type(toObject) == "table" and not toObject.m_Id and not instanceof(targetObject, BankAccount) then
		if not (#toObject >= 2 and #toObject <= 5) then error("DatabasePlayer.transferMoney @ Invalid parameter at position 1, Reason: " .. tostring(reason)) end

		if type(toObject[1]) == "table" or type(toObject[1]) == "userdata" then
			targetObject = toObject[1]
			goesToBank = toObject[2]
			silent = toObject[3]
			allIfToMuch = toObject[4]
		else
			if toObject[1] == "player" then
				targetObject, offlinePlayer = DatabasePlayer.get(toObject[2])

				if offlinePlayer then
					targetObject:load(true)
				end
			elseif toObject[1] == "faction" then
				targetObject = FactionManager:getSingleton().Map[toObject[2]]
			elseif toObject[1] == "company" then
				targetObject = CompanyManager:getSingleton().Map[toObject[2]]
			elseif toObject[1] == "group" then
				targetObject = GroupManager:getSingleton().Map[toObject[2]]
			else
				error("DatabasePlayer.transferMoney @ Unsupported type " .. tostring(toObject[1]) .. ", Reason: " .. tostring(reason))
			end
			goesToBank = toObject[3]
			silent = toObject[4]
			allIfToMuch = toObject[5]
		end
	end

	if not instanceof(targetObject, BankAccount) and not targetObject.__giveMoney then
		error("BankAccount.transferMoney @ Target is missing (" .. tostring(reason) .."/" .. tostring(category) .."/" .. tostring(subcategory) ..")")
	end

	isPlayer = instanceof(targetObject, DatabasePlayer)

	if self:getMoney() < amount and not options.allowNegative then
		if allIfToMuch and self:getMoney() > 0 then
			amount = self:getMoney()
		else
			return false
		end
	end

	self:__takeMoney(amount, reason, options.silent)

	if isPlayer then
		toType = targetObject.m_BankAccount.m_OwnerType
		toId = targetObject.m_BankAccount.m_OwnerId

		if goesToBank then
			targetObject:__giveBankMoney(amount, reason, silent)
			toBank = targetObject.m_BankAccount.m_Id
		else
			targetObject:__giveMoney(amount, reason, silent)
			toBank = 0
		end
	else
		if instanceof(targetObject, BankAccount) then
			toBank = targetObject.m_Id
			toType = targetObject.m_OwnerType
			toId = targetObject.m_OwnerId
		else
			toBank = targetObject.m_BankAccount.m_Id
			toType = targetObject.m_BankAccount.m_OwnerType
			toId = targetObject.m_BankAccount.m_OwnerId
		end

		targetObject:__giveMoney(amount, reason, silent)
	end

	if offlinePlayer then
		delete(targetObject)
	end

	StatisticsLogger:getSingleton():addMoneyLogNew(self.m_Id, 1, 0, toId, toType, toBank, amount, reason, category, subcategory)

	return true
end

function DatabasePlayer:transferBankMoney(toObject, amount, reason, category, subcategory, options)
	local result = self:getBankAccount():transferMoney(toObject, amount, reason, category, subcategory, options)

	if result then
		local options = options and options or {}
		outputDebug(reason, options)
		if money ~= 0 and not options.silent then
			self:sendShortMessage(("%s$%s"):format("-"..amount, reason ~= nil and " - "..reason or ""), "SA National Bank (Konto)", {0, 94, 255}, 3000)
		end
		self:triggerEvent("playerCashChange", options.silent)
	end

	return result
end

function DatabasePlayer:getLogBalance(callback)
	local sql = "SELECT ((SELECT SUM(Amount) FROM ??_MoneyNew WHERE ToId = ? AND ToType = 1) - (SELECT SUM(Amount) FROM ??_MoneyNew WHERE FromId = ? AND FromType = 1)) AS Money"

	if callback then
		sqlLogs:queryFetchSingle(function(result)
			if result then
				callback(result["Money"])
				return
			end
			callback(false)
		end, sql, sqlLogs:getPrefix(), self.m_Id, sqlLogs:getPrefix(), self.m_Id)
	else
		local result = sqlLogs:queryFetchSingle(sql, sqlLogs:getPrefix(), self.m_Id, sqlLogs:getPrefix(), self.m_Id)
		if result then
			return result["Money"]
		end
		return false
	end
end

function DatabasePlayer:setXP(xp)
	self.m_XP = xp
end

function DatabasePlayer:getLevel()
	return calculatePlayerLevel(self.m_XP)
end

function DatabasePlayer:giveKarma(value, reason) -- TODO: maybe log it?
	self:setXP(self.m_XP + value)
	self:setKarma(self.m_Karma + value)
	if self:isActive() then
		self:setPrivateSync("KarmaLevel", self.m_Karma)
		self:setPublicSync("Karma", self.m_Karma)
	end

	local group = self:getGroup()
	if group then
		group:giveKarma(value)
	end
	return true
end

function DatabasePlayer:takeKarma(value, reason)
	return DatabasePlayer.giveKarma(self, -value, reason)
end

function DatabasePlayer:setKarma(karma, reason)
	self.m_Karma = karma
	if self.m_Karma > MAX_KARMA_LEVEL then self.m_Karma = MAX_KARMA_LEVEL end
	if self.m_Karma < -MAX_KARMA_LEVEL then self.m_Karma = -MAX_KARMA_LEVEL end

	if self:isActive() then
		self:setPrivateSync("KarmaLevel", self.m_Karma)
		self:setPublicSync("Karma", self.m_Karma)
	end
end

function DatabasePlayer:givePoints(p, reason) -- TODO: maybe log this?
	self.m_Points = self.m_Points + math.floor(p)
	if self:isActive() then self:setPrivateSync("Points", self.m_Points) end
end

function DatabasePlayer:takePoints(p, reason)
	DatabasePlayer.givePoints(self, -p, reason)
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

function DatabasePlayer:setWeaponLevel(level)
	self.m_WeaponLevel = level
	if self:isActive() then
		self:setPrivateSync("WeaponLevel", self.m_WeaponLevel)
		for _, stat in ipairs({69, 70, 71, 72, 74, 76, 77, 78}) do
			if stat == 69 then
				setPedStat(self, stat, self.m_WeaponLevel*90)
			else
		  		setPedStat(self, stat, self.m_WeaponLevel*100)
			end
	   end
	end
end

function DatabasePlayer:setVehicleLevel(level)
	if level < 1 then level = 1 end
	self.m_VehicleLevel = level
	if self:isActive() then self:setPrivateSync("VehicleLevel", self.m_VehicleLevel) end
end

function DatabasePlayer:setSkinLevel(level)
	self.m_SkinLevel = level
	if self:isActive() then self:setPrivateSync("SkinLevel", self.m_SkinLevel) end
end

function DatabasePlayer:setJobLevel(level)
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

function DatabasePlayer:__giveBankMoney(amount, reason, silent)
	if StatisticsLogger:getSingleton():addMoneyLog("player", self, amount, reason or "Unbekannt", 1) then
		self:getBankAccount():__giveMoney(amount)
--[[
		if amount ~= 0 and not silent and self.sendShortMessage then
			local prefix = "+"
			if amount < 0 then prefix = "-" end
			self:sendShortMessage(("%s%s"):format(prefix..toMoneyString(amount), reason ~= nil and " - "..reason or ""), "SA National Bank (Bank)", {0, 94, 255}, 3000)
			self:triggerEvent("playerCashChange", false)
		end]]

		if self:getBankAccount():getMoney() >= 10000000 then
			self:giveAchievement(40)
		elseif self:getBankAccount():getMoney() >= 1000000 then
			self:giveAchievement(21)
		end
		return true
	end
	return false
end

function DatabasePlayer:__takeBankMoney(amount, reason, silent)
	if StatisticsLogger:getSingleton():addMoneyLog("player", self, -amount, reason or "Unbekannt", 1) then
		self:getBankAccount():__takeMoney(amount)
		return true
	end
	return false
end

function DatabasePlayer:giveWanteds(level)
	local newLevel = self.m_WantedLevel + level
	if newLevel > MAX_WANTED_LEVEL then
		newLevel = MAX_WANTED_LEVEL
	end
	self:setWanteds(newLevel)

	if self:isActive() then
		self.m_LastGotWantedLevelTime = getTickCount()
	end
end

function DatabasePlayer:takeWanteds(level)
	local newLevel = self.m_WantedLevel - level
	if newLevel < 0 then
		newLevel = 0
	end
	self:setWanteds(newLevel)
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
					self:setWanteds(0)
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

	local boardId = Account.getBoardIdFromId(self.m_Id)
	local oldNick = Account.getNameFromId(self.m_Id)

	Forum:getSingleton():userUpdate(boardId, {username = newNick}, Async.waitFor(self))
	local result = Async.wait()
	local data = fromJSON(result)

	if data and data.status and data.status == 200 then
		sql:queryExec("UPDATE ??_account SET Name = ? WHERE Id = ?", sql:getPrefix(), newNick, self.m_Id)
		StatisticsLogger:getSingleton():addPunishLog(admin, self.m_Id, func, "von "..oldNick.." zu "..newNick, 0)
	else
		if data and data.status then
			admin:sendError(_("Nickname bereits vergeben!", admin))
		else
			admin:sendError(_("Fehler: Es gab ein Problem mit der Schnittstelle", admin))
		end
		return false
	end

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
		sql:queryExec("INSERT INTO ??_offlineMessage (PlayerId, Text, Typ, Time) VALUES (?, ?, ?, ?)", sql:getPrefix(), id, text or "" , typ or 1 , getRealTime().timestamp )
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

function DatabasePlayer:getSTVO(category)
	if category then
		return self.m_STVO[category] or 0
	end

	return self.m_STVO
end

function DatabasePlayer:setSTVO(category, stvo)
	if category then
		self.m_STVO[category] = stvo

		if stvo >= 20 then
			self.m_STVO[category] = 0
			if self:isActive() then
				self:sendMessage(_("Du hast 20 STVO Punkte! Dein Führerschein wurde abgenommen!", self), 255, 0, 0)
			else
				self:addOfflineMessage(_"Du hattest 20 STVO Punkte dein Führerschein wurde abgenommen!", 1)
			end

			if category == "Driving" then
				self.m_HasDrivingLicense = false
			elseif category == "Bike" then
				self.m_HasBikeLicense = false
			elseif category == "Truck" then
				self.m_HasTruckLicense = false
			elseif category == "Pilot" then
				self.m_HasPilotLicense = false
			end
		end
	else
		self.m_STVO = stvo
	end

	if self:isActive() then
		self:setPublicSync("STVO", toJSON(self.m_STVO))
	end
end

function DatabasePlayer:giveFishingSkill(points)
	self.m_FishingSkill = self.m_FishingSkill + math.floor(points)
	if self:isActive() then self:setPrivateSync("FishingSkill", self.m_FishingSkill) end
end

function DatabasePlayer:hasFishSpeciesCaught(fishId)
	for species in pairs(self.m_FishSpeciesCaught) do
		if species == fishId then
			return true
		end
	end
end

function DatabasePlayer:addFishSpecies(fishId, size)
	if not self:hasFishSpeciesCaught(fishId) then
		self.m_FishSpeciesCaught[fishId] = {1, size, getRealTime().timestamp }
		return true
	else
		local caughtCount = self.m_FishSpeciesCaught[fishId][1] + 1
		local previousSize = self.m_FishSpeciesCaught[fishId][2]
		self.m_FishSpeciesCaught[fishId] = {caughtCount, math.max(size, previousSize or 0), getRealTime().timestamp }
		return size > (previousSize or 0)
	end
end

function DatabasePlayer:getFishSpeciesCaught()
	return self.m_FishSpeciesCaught
end
