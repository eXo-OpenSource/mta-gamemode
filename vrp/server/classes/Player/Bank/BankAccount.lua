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
  BankAccount.Map[Id] = BankAccount:new(Id, 0)
  return BankAccount.Map[Id]
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

function BankAccount:addMoney(money, reason, silent)
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

function BankAccount:takeMoney(money, reason, silent)
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
