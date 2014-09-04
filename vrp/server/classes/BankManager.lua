-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/BankManager.lua
-- *  PURPOSE:     Bank manager class
-- *
-- ****************************************************************************
BankManager = inherit(Singleton)

function BankManager:constructor()
	addEvent("bankWithdraw", true)
	addEvent("bankDeposit", true)
	addEvent("bankTransfer", true)
	addEvent("bankMoneyBalanceRequest", true)
	
	addEventHandler("bankWithdraw", root, bind(self.Event_Withdraw, self))
	addEventHandler("bankDeposit", root, bind(self.Event_Deposit, self))
	addEventHandler("bankTransfer", root, bind(self.Event_Transfer, self))
	addEventHandler("bankMoneyBalanceRequest", root, bind(self.Event_bankMoneyBalanceRequest, self))
	
	self:createInteriors()
end

function BankManager:createInteriors()
	InteriorEnterExit:new(Vector(1660.4, -1272.8, 14.6), Vector(802.9, 4225.1, 15.7), 270, 180, 1)
	InteriorEnterExit:new(Vector(1667.1, -1269.3, 233.3), Vector(794.2, 4225.4, 18.4), 270, 0, 1)
end

function BankManager:Event_Withdraw(amount)
	amount = tonumber(amount)
	if not amount or amount <= 0 then return end
	
	if client:getBankMoney() < amount then
		client:sendError(_("You cannot withdraw more money than you have", client))
		return
	end
	
	if client:takeBankMoney(amount, BankStat.Withdrawal) then
		client:giveMoney(amount)
		client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
	end
end

function BankManager:Event_Deposit(amount)
	amount = tonumber(amount)
	if not amount or amount <= 0 then return end
	
	if client:getMoney() < amount then
		client:sendError(_("You cannot deposit more money than you have", client))
		return
	end
	
	if client:addBankMoney(amount, BankStat.Deposit) then
		client:takeMoney(amount)
		client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
	end
end

function BankManager:Event_Transfer(amount, toPlayerName)
	-- Todo (getCharacterByName or something is missing yet)
	
	client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
end

function BankManager:Event_bankMoneyBalanceRequest()
	client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
end
