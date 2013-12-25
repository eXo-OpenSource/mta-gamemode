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

function Player:constructor()
	self.m_Account = false
	self.m_Locale = "de"
	self.m_Id = -1
	self.m_Skills = {}
	self.m_Level = 0
	self.m_XP 	 = 0
	self.m_Karma = 0
	self.m_Money = 0
	self.m_BankMoney = 0
end

function Player:connect()
	if not Ban.checkBan(self) then return end
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
	if not charid then
		self:createCharacter()
	else
		self.m_Id = charid
	end
	
	self:loadCharacterInfo()
end

function Player:createCharacter()
	sql:queryExec("INSERT INTO ??_character(Account) VALUES(?);", sql:getPrefix(), player.m_Account.m_Id)
	self.m_Id = sql:lastInsertId()
end

function Player:loadCharacterInfo()
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

-- Message Boxes
function Player:sendError(text, ...) 	self:triggerEvent("errorBox", text:format(...)) 	end
function Player:sendWarning(text, ...)	self:triggerEvent("warningBox", text:format(...)) 	end
function Player:sendInfo(text, ...)		self:triggerEvent("infoBox", text:format(...))		end
function Player:sendSuccess(text, ...)	self:triggerEvent("successBox", text:format(...))	end

-- Short getters
function Player:getId()			return self.m_Id		end
function Player:getAccount()	return self.m_Account 	end
function Player:getPlayer()		return self.m_Player	end
function Player:getXP()			return self.m_XP		end
function Player:getKarma()		return self.m_Karma		end
function Player:getBankMoney()	return self.m_BankMoney	end
function Player:getJob()   		return self.m_Job		end
function Player:getAccount()	return self.m_Account	end
function Player:getLocale()		return self.m_Locale	end
function Player:getPhonePartner() return self.m_PhonePartner end

-- Short setters
function Player:setJob(job)	 	self.m_Job = job 		end
function Player:setLocale(locale)	self.m_Locale = locale	end
function Player:setPhonePartner(partner) self.m_PhonePartner = partner end

function Player:addKarma(points)
	self.m_Karma = self.m_Karma + points
	self:triggerEvent("karmaChange", self.m_Karma)
end

function Player:takeKarma(points)
	self.m_Karma = self.m_Karma - points
	self:triggerEvent("karmaChange", self.m_Karma)
end

function Player:addBankMoney(amount, logType)
	logType = logType or BankStat.Income
	if sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney + amount
		return true
	end
	return false
end

function Player:takeBankMoney(amount, logType)
	logType = logType or BankStat.Payment
	if sql:queryExec("INSERT INTO ??_bank_statements (CharacterId, Type, Amount) VALUES(?, ?, ?)", self.m_Id, logType, amount) then
		self.m_BankMoney = self.m_BankMoney - amount
		return true
	end
	return false
end