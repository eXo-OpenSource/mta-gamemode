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
end

function BankManager:Event_Withdraw(amount)
	amount = tonumber(amount)
	if not amount or amount <= 0 then return end
	if isNan(amount) then return end

	if client:getBankMoney() < amount then
		client:sendError(_("Auf deinem Konto befindet sich nicht so viel Geld!", client))
		return
	end

	if client:takeBankMoney(amount, "Bank Auszahlung", true, true) then
		client:giveMoney(amount, "Bank Auszahlung")
		client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
	end
end

function BankManager:Event_Deposit(amount)
	amount = tonumber(amount)
	if not amount or amount <= 0 then return end
	if isNan(amount) then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht so viel Geld!", client))
		return
	end

	if client:addBankMoney(amount, "Bank Einzahlung", true, true) then
		client:takeMoney(amount, "Bank Einzahlung")
		client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
	end
end

function BankManager:Event_Transfer(toPlayerName, amount)
	local client = client
	if tonumber(amount) and amount > 0 then
		if isNan(amount) then return end

		if client:getBankMoney() < amount then
			client:sendError(_("Nicht genügend Geld!", client))
			return
		end
		if toPlayerName == "San News" then
			client:takeBankMoney(amount, "Überweisung an San News)")
			CompanyManager:getSingleton():getFromId(CompanyStaticId.SANNEWS):giveMoney(amount, ("Spende von %s"):format(client:getName()))
			client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
		elseif toPlayerName == "eXo Event-Team" then
			client:takeBankMoney(amount, "Überweisung an eXo Event-Team)")
			Admin:getSingleton().m_BankAccount:addMoney(amount, ("Spende von %s"):format(client:getName()))
			client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
		else
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
							delete(toPlayer)
						else
							toPlayer:triggerEvent("bankMoneyBalanceRetrieve", toPlayer:getBankMoney())
							toPlayer:sendShortMessage(_("%s hat dir %d$ überwiesen!", toPlayer, client:getName(), amount))
						end
						client:sendShortMessage(_("Du hast an %s %d$ überwiesen!", client, toPlayerName, amount))
						client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
					end
				end
			)()
		end
	else
		client:sendError(_("Ungültiger Betrag!", client))
	end
end

function BankManager:Event_bankMoneyBalanceRequest()
	client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
end
