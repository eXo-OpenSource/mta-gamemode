-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/BankManager.lua
-- *  PURPOSE:     Bank manager class
-- *
-- ****************************************************************************
BankManager = inherit(Singleton)

function BankManager:constructor()
	addRemoteEvents{"bankWithdraw", "bankDeposit", "bankTransfer", "bankMoneyBalanceRequest"}

	addEventHandler("bankWithdraw", root, bind(self.Event_Withdraw, self))
	addEventHandler("bankDeposit", root, bind(self.Event_Deposit, self))
	addEventHandler("bankTransfer", root, bind(self.Event_Transfer, self))
	addEventHandler("bankMoneyBalanceRequest", root, bind(self.Event_bankMoneyBalanceRequest, self))

	self:createInteriors()
end

function BankManager:createInteriors()
	InteriorEnterExit:new(Vector3(1660.4, -1272.8, 14.6), Vector3(802.9, 4225.1, 15.7), 270, 180, 1)
	InteriorEnterExit:new(Vector3(1667.1, -1269.3, 233.3), Vector3(794.2, 4225.4, 18.4), 270, 0, 1)
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
		client:takeMoney(amount, "Bank Einzahlung")
		client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
	end
end

function BankManager:Event_Transfer(toPlayerName, amount)
	if tonumber(amount) and amount > 0 then
		if client:getBankMoney() < amount then
			client:sendError(_("Nicht genügend Geld!", client))
			return
		end

		Async.create(function(player)
			local id = Account.getIdFromName(toPlayerName)
			if not id then
				player:sendError(_("Dieser Spieler existiert nicht!", player))
				return
			end

			local toPlayer, offline = DatabasePlayer.get(id)
			if offline then
				toPlayer:load()
			end

			toPlayer:addBankMoney(amount)
			player:takeBankMoney(amount)

			if offline then
				toPlayer:save()
			else
				toPlayer:triggerEvent("bankMoneyBalanceRetrieve", toPlayer:getBankMoney())
			end

			player:triggerEvent("bankMoneyBalanceRetrieve", player:getBankMoney())
		end)(client)
	end
end

function BankManager:Event_bankMoneyBalanceRequest()
	client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
end
