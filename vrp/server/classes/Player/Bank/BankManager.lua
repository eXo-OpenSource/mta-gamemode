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
		client:sendError(_("Auf deinem Konto befindet sich nicht soviel Geld!", client))
		return
	end

	if client:takeBankMoney(amount, "Bank Auszahlung") then
		client:giveMoney(amount, "Bank Auszahlung")
		client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
	end
end

function BankManager:Event_Deposit(amount)
	amount = tonumber(amount)
	if not amount or amount <= 0 then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht soviel Geld!", client))
		return
	end

	if client:addBankMoney(amount, "Bank Einzahlung") then
		client:takeMoney(amount, "Bank Einzahlung")
		client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
	end
end

function BankManager:Event_Transfer(toPlayerName, amount)
	local client = client
	if tonumber(amount) and amount > 0 then
		if client:getBankMoney() < amount then
			client:sendError(_("Nicht genügend Geld!", client))
			return
		end
		Async.create(
			function()
				local id = Account.getIdFromName(toPlayerName)
				if not id or id == 0 then
					client:sendError(_("Dieser Spieler existiert nicht!", client))
					return
				end

				local toPlayer, offline = DatabasePlayer.get(id)
				if offline then
					toPlayer:load()
				end

				if client:takeBankMoney(amount, "Überweisung (an "..toPlayerName..")") then
					toPlayer:addBankMoney(amount, "Überweisung (von "..client:getName()..")")


					if offline then
						toPlayer:save()
					else
						toPlayer:triggerEvent("bankMoneyBalanceRetrieve", toPlayer:getBankMoney())
						toPlayer:sendShortMessage(_("%s hat dir %d$ überwiesen!", toPlayer, client:getName(), amount))
					end
					client:sendShortMessage(_("Du hast an %s %d$ überwiesen!", client, toPlayerName, amount))
					client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
				end
			end
		)()
	else
		client:sendError(_("Ungültiger Betrag!", client))
	end
end

function BankManager:Event_bankMoneyBalanceRequest()
	client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
end
