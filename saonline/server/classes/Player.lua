-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player.lua
-- *  PURPOSE:     Player class
-- *
-- ****************************************************************************
Player = inherit(MTAElement)
registerElementClass("player", Player)

addEventHandler("onPlayerConnect", root, 
	function(name)
		local player = getPlayerFromName(name)
		Async.create(Player.connect)(player)
	end
)
addEventHandler("onPlayerJoin", root, function() source:join() end)
addEvent("introFinished", true)
addEventHandler("introFinished", root, function() client:spawn() end)

function Player:constructor()
	self.m_Account = false
	self.m_Locale = "de"
	self.m_Id = -1
	self.m_Skills = {}
	self.m_XP 	 = 0
	self.m_Karma = 0
	self.m_Money = 0
	self.m_BankMoney = 0
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

function Player:loadCharacter(charid)
	self.m_Id = charid
	self:loadCharacterInfo()
end

function Player:createCharacter(id)
	sql:queryExec("INSERT INTO ??_character(Id) VALUES(?);", sql:getPrefix(), id)
end

function Player:loadCharacterInfo()
	sql:queryFetchSingle(Async.waitFor(self), "SELECT XP, Karma, Money, BankMoney, DrivingSkill, GunSkill, FlyingSkill, SneakingSkill, EnduranceSkill, TutorialStage FROM ??_character WHERE Id = ?;", sql:getPrefix(), self.m_Id)
	local row = Async.wait()
	
	self.m_XP 	 = row.XP
	self.m_Karma = row.Karma
	self.m_Money = row.Money
	setPlayerMoney(self, self.m_Money) -- Todo: Remove this line later
	self.m_BankMoney = row.BankMoney
	self.m_TutorialStage = row.TutorialStage
	
	self.m_Skills["Driving"] 	= row.DrivingSkill
	self.m_Skills["Gun"] 		= row.GunSkill
	self.m_Skills["Flying"] 	= row.FlyingSkill
	self.m_Skills["Sneaking"] 	= row.SneakingSkill
	self.m_Skills["Endurance"] 	= row.EnduranceSkill
end

function Player:save()
	return sql:queryExec("UPDATE ??_character SET XP = ?, Karma = ?, Money = ?, BankMoney = ?, TutorialStage = ? WHERE Id = ?;", sql:getPrefix(), self.m_XP, self.m_Karma, self:getMoney(), self.m_BankMoney, self.m_TutorialStage, self.m_Id)
end

function Player:spawn()
	setElementDimension(self, 0)
end

-- Message Boxes
function Player:sendError(text, ...) 	self:triggerEvent("errorBox", text:format(...)) 	end
function Player:sendWarning(text, ...)	self:triggerEvent("warningBox", text:format(...)) 	end
function Player:sendInfo(text, ...)		self:triggerEvent("infoBox", text:format(...))		end
function Player:sendSuccess(text, ...)	self:triggerEvent("successBox", text:format(...))	end

-- Short getters
function Player:getId()			return self.m_Id		end
function Player:getAccount()	return self.m_Account 	end
function Player:getPlayer()		return self.m_Player	end
function Player:getMoney()		return getPlayerMoney(self)	end
function Player:getXP()			return self.m_XP		end
function Player:getKarma()		return self.m_Karma		end
function Player:getBankMoney()	return self.m_BankMoney	end
function Player:getJob()   		return self.m_Job		end
function Player:getAccount()	return self.m_Account	end
function Player:getLocale()		return self.m_Locale	end
function Player:getPhonePartner() return self.m_PhonePartner end
function Player:getTutorialStage() return self.m_TutorialStage end
function Player:getJobVehicle() return self.m_JobVehicle end

-- Short setters
function Player:setMoney(money) self.m_Money = money setPlayerMoney(self, money) end
function Player:setJob(job)	 	self.m_Job = job 		end
function Player:setLocale(locale)	self.m_Locale = locale	end
function Player:setPhonePartner(partner) self.m_PhonePartner = partner end
function Player:setTutorialStage(stage) self.m_TutorialStage = stage end
function Player:setJobVehicle(vehicle) self.m_JobVehicle = vehicle end

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