-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
Player.Map = {}
registerElementClass("player", Player)

addEvent("introFinished", true)
addEventHandler("introFinished", root, function()
	client.m_TutorialStage = 3 -- todo: character creation and tutorial mission
	client:spawn() 
end)

function Player:constructor()
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
	
	setElementDimension(self, PRIVATE_DIMENSION_SERVER)
	setElementFrozen(self, true)
end

function Player:destructor()
	if self.m_JobVehicle and isElement(self.m_JobVehicle) then
		destroyElement(self.m_JobVehicle)
	end
	
	self:save()
	
	-- Unload stuff
	self.m_Inventory:unload()
	
	-- Remove reference
	Player.Map[self.m_Id] = nil
end

function Player:connect()
	if not Ban.checkBan(self) then return end
end

function Player:join()
	if Forum:getSingleton() and #Forum:getSingleton():getNews() > 0 then
		self:sendNews()
	end
end

function Player:sendNews()
	self:triggerEvent("ingamenews", Forum:getSingleton():getNews())
end

function Player:triggerEvent(ev, ...)
	triggerClientEvent(self, ev, self, ...)
end

function Player:sendMessage(text, r, g, b, ...)
	outputChatBox(text:format(...), self, r, g, b, true)
end

function Player:startNavigationTo(x, y, z)
	self:triggerEvent("navigationStart", x, y, z)
end

function Player:stopNavigation()
	self:triggerEvent("navigationStop")
end

function Player:loadCharacter()
	Player.Map[self.m_Id] = self
	self:loadCharacterInfo()
	
	-- Send infos to client
	local info = {
		Rank = self:getRank();
	}
	self:triggerEvent("retrieveInfo", info)
	
	-- Add binds
	bindKey(self, "u", "down", "chatbox", "Group")
	
	-- Add command and event handler
	addCommandHandler("Group", Player.staticGroupChatHandler)
end

function Player:createCharacter()
	sql:queryExec("INSERT INTO ??_character(Id) VALUES(?);", sql:getPrefix(), self.m_Id)
	
	self.m_Inventory = Inventory.create()
end

function Player.getFromId(id)
	return Player.Map[id]
end

function Player:loadCharacterInfo()
	sql:queryFetchSingle(Async.waitFor(self), "SELECT PosX, PosY, PosZ, Interior, Skin, XP, Karma, Money, BankMoney, WantedLevel, Job, GroupId, GroupRank, DrivingSkill, GunSkill, FlyingSkill, SneakingSkill, EnduranceSkill, TutorialStage, Weapons, InventoryId FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	local row = Async.wait()
	
	self.m_SavedPosition = Vector(row.PosX, row.PosY, row.PosZ)
	self.m_SavedInterior = row.Interior
	self.m_Skin = row.Skin
	self.m_XP 	 = row.XP
	self.m_Karma = row.Karma
	self.m_Money = row.Money
	setPlayerMoney(self, self.m_Money) -- Todo: Remove this line later
	self.m_WantedLevel = row.WantedLevel
	setPlayerWantedLevel(self, self.m_WantedLevel)
	self.m_BankMoney = row.BankMoney
	self.m_TutorialStage = row.TutorialStage
	if row.Job > 0 then
		self:setJob(JobManager:getSingleton():getFromId(row.Job))
	end
	if row.GroupId and row.GroupId ~= 0 then
		self.m_Group = GroupManager:getSingleton():getFromId(row.GroupId)
	end
	self.m_Inventory = self.m_Inventory or Inventory.loadById(row.InventoryId) or Inventory.create()
	
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

function Player:save()
	if not self.m_Account or self.m_Account:isGuest() then	
		return 
	end
	local x, y, z = getElementPosition(self)
	local interior = getElementInterior(self)
	local weapons = ""
	for i = 0, 12 do
		if i == 0 then weapons = getPedWeapon(self, i).."|"..getPedTotalAmmo(self, i)
		else weapons = weapons.."|"..getPedWeapon(self, i).."|"..getPedTotalAmmo(self, i) end
	end
	
	return sql:queryExec("UPDATE ??_character SET PosX = ?, PosY = ?, PosZ = ?, Interior = ?, Skin = ?, XP = ?, Karma = ?, Money = ?, BankMoney = ?, WantedLevel = ?, TutorialStage = ?, Job = ?, Weapons = ?, InventoryId = ? WHERE Id = ?;", sql:getPrefix(), 
		x, y, z, interior, getElementModel(self), self.m_XP, self.m_Karma, self:getMoney(), self.m_BankMoney, self.m_WantedLevel, self.m_TutorialStage, self.m_Job and self.m_Job:getId() or 0, weapons, self.m_Inventory:getId(), self.m_Id)
end

function Player:spawn()
	spawnPlayer(self, self.m_SavedPosition.X, self.m_SavedPosition.Y, self.m_SavedPosition.Z, 0, self.m_Skin, self.m_SavedInterior, 0)
	setElementFrozen(self, false)
	setElementDimension(self, 0)
	setCameraTarget(self, self)
	fadeCamera(self, true)
end

function Player:respawnAfterDeath()
	spawnPlayer(self, 2028+math.random(-4, 4), -1405+math.random(-2, 2), 18)
end

-- Message Boxes
function Player:sendError(text, ...) 	self:triggerEvent("errorBox", text:format(...)) 	end
function Player:sendWarning(text, ...)	self:triggerEvent("warningBox", text:format(...)) 	end
function Player:sendInfo(text, ...)		self:triggerEvent("infoBox", text:format(...))		end
function Player:sendSuccess(text, ...)	self:triggerEvent("successBox", text:format(...))	end
function Player:sendShortMessage(text, ...) self:triggerEvent("shortMessageBox", text:format(...))	end

-- Short getters
function Player:getId()			return self.m_Id		end
function Player:isLoggedIn()	return self.m_Id ~= -1	end
function Player:getAccount()	return self.m_Account 	end
function Player:getRank()		return self.m_Account:getRank() end
function Player:getMoney()		return getPlayerMoney(self)	end
function Player:getXP()			return self.m_XP		end
function Player:getKarma()		return self.m_Karma		end
function Player:getBankMoney()	return self.m_BankMoney	end
function Player:getWantedLevel()return self.m_WantedLevel end
function Player:getJob()   		return self.m_Job		end
function Player:getAccount()	return self.m_Account	end
function Player:getLocale()		return self.m_Locale	end
function Player:getPhonePartner() return self.m_PhonePartner end
function Player:getTutorialStage() return self.m_TutorialStage end
function Player:getJobVehicle() return self.m_JobVehicle end
function Player:getGroup()		return self.m_Group		end
function Player:getInventory()	return self.m_Inventory	end

-- Short setters
function Player:setMoney(money) self.m_Money = money setPlayerMoney(self, money) end
function Player:setWantedLevel(level) self.m_WantedLevel = level setPlayerWantedLevel(self, level) end
function Player:setLocale(locale)	self.m_Locale = locale	end
function Player:setPhonePartner(partner) self.m_PhonePartner = partner end
function Player:setTutorialStage(stage) self.m_TutorialStage = stage end
function Player:setJobVehicle(vehicle) self.m_JobVehicle = vehicle end
function Player:setGroup(group)	self.m_Group = group	end

function Player:giveMoney(money)
	self:setMoney(self:getMoney() + money)
end

function Player:takeMoney(money)
	self:setMoney(self:getMoney() - money)
end

function Player:giveXP(xp)
	local oldLevel = self:getLevel()
	self.m_XP = self.m_XP + xp
	
	-- Check if the player needs a level up
	if self:getLevel() > oldLevel then
		--self:triggerEvent("levelUp", self:getLevel())
		self:sendInfo(_("Du bist zu Level %d aufgestiegen", self), self:getLevel())
	end
end

function Player:getLevel()
	-- XP(level) = 0.5*x^2 --> level(XP) = sqrt(2*xp)
	return (2 * math.floor(self.m_XP))^0.5
end

function Player:giveKarma(points)
	self.m_Karma = self.m_Karma + points
	self:triggerEvent("karmaChange", self.m_Karma)
end

function Player:takeKarma(points)
	self.m_Karma = self.m_Karma - points
	self:triggerEvent("karmaChange", self.m_Karma)
end

function Player:addBankMoney(amount, logType)
	logType = logType or BankStat.Income
	if sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", sql:getPrefix(), self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney + amount
		return true
	end
	return false
end

function Player:takeBankMoney(amount, logType)
	logType = logType or BankStat.Payment
	if sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", sql:getPrefix(), self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney - amount
		return true
	end
	return false
end

function Player:giveWantedLevel(level)
	self:setWantedLevel(self.m_WantedLevel + level)
end

function Player:takeWantedLevel(level)
	self:setWantedLevel(self.m_WantedLevel - level)
end

function Player:setJob(job)
	if job then
		JobManager:getSingleton():startJobForPlayer(job, self)
	else
		JobManager:getSingleton():stopJobForPlayer(self)
	end
	self.m_Job = job
end

function Player.staticGroupChatHandler(self, command, ...)
	if self.m_Group then
		self.m_Group:sendMessage(("[GROUP] %s: %s"):format(getPlayerName(self), table.concat({...}, " ")))
	end
end

function Player:getVehicles()
	return VehicleManager:getSingleton():getPlayerVehicles(self)
end
