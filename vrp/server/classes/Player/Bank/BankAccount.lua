-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Player/BankManager.lua
-- *  PURPOSE:     Bank account class
-- *
-- ****************************************************************************
BankAccount = inherit(Object)
BankAccount.Map = {}

function BankAccount.create(OwnerType, OwnerId)
  sql:queryExec("INSERT INTO ??_bank_accounts(OwnerType, OwnerId, Money, CreationTime) VALUES (?, ?, 0, NOW());", sql:getPrefix(), OwnerType, OwnerId)

  local Id = sql:lastInsertId()
  BankAccount.Map[Id] = BankAccount:new(Id, 0, OwnerType, OwnerId)
  return BankAccount.Map[Id]
end

function BankAccount.loadByOwner(id, type)
	local row = sql:queryFetchSingle("SELECT Id FROM ??_bank_accounts WHERE OwnerId = ? AND OwnerType = ?;", sql:getPrefix(), id, type)
	
	if not row then
    return false
  end
	return BankAccount.load(row.Id)
end

function BankAccount.load(Id)
  if BankAccount.Map[Id] then return BankAccount.Map[Id] end

  local row = sql:queryFetchSingle("SELECT OwnerType, OwnerId, Money FROM ??_bank_accounts WHERE Id = ?;", sql:getPrefix(), Id)
  if not row then
    return false
  end

  BankAccount.Map[Id] = BankAccount:new(Id, row.Money, row.OwnerType, row.OwnerId)
  return BankAccount.Map[Id]
end

function BankAccount:constructor(Id, Money, OwnerType, OwnerId)
  self.m_Id = Id
  self.m_Money = Money
  self.m_Activity = ""
  self.m_OwnerType = OwnerType
  self.m_OwnerId = OwnerId
	self.m_Negative = false
end

function BankAccount:destructor()
  self:save()
end

function BankAccount:save()
  return sql:queryExec("UPDATE ??_bank_accounts SET Money = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_Id)
end

function BankAccount:update()
  if self.m_OwnerType == BankAccountTypes.Player then
    local player = DatabasePlayer.get(self.m_OwnerId)

    if player:isActive() then
        player:setPublicSync("BankMoney", self:getMoney())
    end
  elseif self.m_OwnerType == BankAccountTypes.Faction then
    return false
  elseif self.m_OwnerType == BankAccountTypes.Company then
    return false
  elseif self.m_OwnerType == BankAccountTypes.Admin then
    return false
  end
end

function BankAccount:getId()
  return self.m_Id
end

function BankAccount:setMoney(amount, reason, silent)
	if isNan(amount) then return end

	self.m_Money = amount

	if not silent then
		if self.m_OwnerType == BankAccountTypes.Company then
			CompanyManager:getSingleton():getFromId(self.m_OwnerId):sendShortMessage(("%s$ - %s"):format(self.m_Money, reason or ""))
		elseif self.m_OwnerType == BankAccountTypes.Faction then
			FactionManager:getSingleton():getFromId(self.m_OwnerId):sendShortMessage(("%s$ - %s"):format(self.m_Money, reason or ""))
		elseif self.m_OwnerType == BankAccountTypes.Admin then
			Admin:getSingleton():sendShortMessage(("%s$ - %s"):format(self.m_Money, reason or ""), "Admin-Eventkasse")
		end
	end
	self:update()
end

function BankAccount:getMoney()
  return tonumber(self.m_Money)
end

function BankAccount:__giveMoney(money, reason, silent)
	if isNan(money) then return end
		local money = math.round(money)
  	if money > 0 then
		self.m_Money = self.m_Money + money
		if not silent then
			if self.m_OwnerType == BankAccountTypes.Company then
				CompanyManager:getSingleton():getFromId(self.m_OwnerId):sendShortMessage(("+%s$ (%s$) - %s"):format(money, self.m_Money, reason or ""))
			elseif self.m_OwnerType == BankAccountTypes.Faction then
				FactionManager:getSingleton():getFromId(self.m_OwnerId):sendShortMessage(("+%s$ (%s$) - %s"):format(money, self.m_Money, reason or ""))
			elseif self.m_OwnerType == BankAccountTypes.Admin then
				Admin:getSingleton():sendShortMessage(("+%s$ (%s$) - %s"):format(money, self.m_Money, reason or ""), "Admin-Eventkasse")
			end
		end
		self:update()
	end
end

function BankAccount:__takeMoney(money, reason, silent)
	if isNan(money) then return end
	local money = math.round(money)
	if money > 0 then
		self.m_Money = self.m_Money - money
		if not silent then
			if self.m_OwnerType == BankAccountTypes.Company then
				CompanyManager:getSingleton():getFromId(self.m_OwnerId):sendShortMessage(("-%s$ (%s$) - %s"):format(money, self.m_Money, reason or ""))
			elseif self.m_OwnerType == BankAccountTypes.Faction then
				FactionManager:getSingleton():getFromId(self.m_OwnerId):sendShortMessage(("-%s$ (%s$) - %s"):format(money, self.m_Money, reason or ""))
			elseif self.m_OwnerType == BankAccountTypes.Admin then
				Admin:getSingleton():sendShortMessage(("-%s$ (%s$) - %s"):format(money, self.m_Money, reason or ""), "Admin-Eventkasse")
			end
		end
		self:update()
	end
end

--[[
	[==
		object (Player, Faction, Company, Group, BankAccount) ||
		{string objectName, int objectId [, bool toBank, bool silent, bool allIfToMuch} ||
		{object (Player, Faction, Company, Group), bool toBank [, bool silent, bool allIfToMuch]}
	==] toObject
	int amount
	string reason
	string category
	string subcategory

	table options = {
		slient = false,
		allowNegative = false
	}
]]

function BankAccount:transferMoney(toObject, amount, reason, category, subcategory, options)
	if isNan(amount) then return false end
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
		if not (#toObject >= 2 and #toObject <= 5) then error("BankAccount.transferMoney @ Invalid parameter at position 1, Reason: " .. tostring(reason)) end

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
				error("BankAccount.transferMoney @ Unsupported type " .. tostring(toObject[1]))	
			end
			goesToBank = toObject[3]
			silent = toObject[4]
			allIfToMuch = toObject[5]
		end
	end

	if not targetObject or (not instanceof(targetObject, BankAccount) and not targetObject.__giveMoney) then
		error("BankAccount.transferMoney @ Target is missing (" .. tostring(reason) .."/" .. tostring(category) .."/" .. tostring(subcategory) ..")")
	end
	
	isPlayer = instanceof(targetObject, DatabasePlayer)

	if self:getMoney() < amount and not self.m_Negative and not options.allowNegative then
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

	StatisticsLogger:getSingleton():addMoneyLogNew(self.m_OwnerId, self.m_OwnerType, self.m_Id, toId, toType, toBank, amount, reason, category, subcategory)

	return true
end