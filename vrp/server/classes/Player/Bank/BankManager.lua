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

	if client:transferBankMoney(client, amount, "Bank Auszahlung", "Bank", "Withdraw", {bank = true, silent = true}) then
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

	if client:transferMoney({client, true, true}, amount, "Bank Einzahlung", "Bank", "Deposit") then
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
			client:transferBankMoney(CompanyManager:getSingleton():getFromId(CompanyStaticId.SANNEWS), amount, ("Spende an San News von %s"):format(client:getName()), "Gameplay", "SanNewsDonation")
			client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
		elseif toPlayerName == "eXo Event-Team" then
			client:transferBankMoney(Admin:getSingleton().m_BankAccount, amount, ("Spende an eXo Event-Team von %s"):format(client:getName()), "Gameplay", "eXoTeamDonation")
			client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
		else
			local id = Account.getIdFromName(toPlayerName)
			if not id or id == 0 then
				client:sendError(_("Dieser Spieler existiert nicht!", client))
				return
			end

			if client:transferBankMoney({"player", id, true}, amount, ("Überweisung von %s an %s"):format(client:getName(), toPlayerName), "Bank", "Transfer") then

				local toPlayer, offline = DatabasePlayer.get(id)
				if not offline then
					toPlayer:triggerEvent("bankMoneyBalanceRetrieve", toPlayer:getBankMoney())
					toPlayer:sendShortMessage(_("%s hat dir %d$ überwiesen!", toPlayer, client:getName(), amount))
				end

				client:sendShortMessage(_("Du hast an %s %d$ überwiesen!", client, toPlayerName, amount))
				client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())

				if offline then
					toPlayer:addOfflineMessage(("Du hast eine Offline-Überweisung über %s$ von %s erhalten."):format(amount, client.name), 1)
					delete(toPlayer)
				end
			end
		end
	else
		client:sendError(_("Ungültiger Betrag!", client))
	end
end

function BankManager:Event_bankMoneyBalanceRequest()
	client:triggerEvent("bankMoneyBalanceRetrieve", client:getBankMoney())
end
