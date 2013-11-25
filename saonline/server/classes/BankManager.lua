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
end

function BankManager:Event_Withdraw(amount)
	amount = tonumber(amount)
	if not amount or amount <= 0 then return end
	
	if client:getCharacter():getBankMoney() < amount then
		client:sendError(_("You cannot withdraw more money than you have", client))
		return
	end
	
	if client:getCharacter():takeBankMoney(amount, BankStat.Withdrawal) then
		givePlayerMoney(client, amount)
	end
end

function BankManager:Event_Deposit(amount)
	amount = tonumber(amount)
	if not amount or amount <= 0 then return end
	
	if getPlayerMoney(client) < amount then
		client:sendError(_("You cannot deposit more money than you have", client))
		return
	end
	
	if client:getCharacter():addBankMoney(amount, BankStat.Deposit) then
		takePlayerMoney(client, amount)
	end
end

function BankManager:Event_Transfer(amount, toPlayerName)
	-- Todo (getCharacterByName or something is missing yet)
end

function BankManager:Event_bankMoneyBalanceRequest()
	client:triggerEvent("bankMoneyBalanceRetrieve", client:getCharacter():getBankMoney())
end
