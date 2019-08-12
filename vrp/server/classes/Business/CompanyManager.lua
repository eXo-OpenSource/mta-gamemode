-- ****************************************************************************
-- *
-- *  PROJECT:     eXo
-- *  FILE:        server/classes/Business/CompanyManager.lua
-- *  PURPOSE:     CompanyManager class
-- *
-- ****************************************************************************
CompanyManager = inherit(Singleton)
CompanyManager.Map = {}

function CompanyManager:constructor()
	self:loadCompanies()

	-- Events
	addRemoteEvents{"getCompanies", "companyRequestInfo", "companyQuit", "companyDeposit", "companyWithdraw", "companyAddPlayer", "companyDeleteMember", "companyInvitationAccept", "companyInvitationDecline", "companyRankUp", "companyRankDown", "companySaveRank","companyRespawnVehicles", "companyChangeSkin", "companyToggleDuty", "companyToggleLoan", "companyRequestSkinSelection", "companyPlayerSelectSkin", "companyUpdateSkinPermissions"}

	addEventHandler("getCompanies", root, bind(self.Event_getCompanies, self))
	addEventHandler("companyRequestInfo", root, bind(self.Event_companyRequestInfo, self))
	addEventHandler("companyDeposit", root, bind(self.Event_companyDeposit, self))
	addEventHandler("companyWithdraw", root, bind(self.Event_companyWithdraw, self))
	addEventHandler("companyAddPlayer", root, bind(self.Event_companyAddPlayer, self))
	addEventHandler("companyDeleteMember", root, bind(self.Event_companyDeleteMember, self))
	addEventHandler("companyInvitationAccept", root, bind(self.Event_companyInvitationAccept, self))
	addEventHandler("companyInvitationDecline", root, bind(self.Event_companyInvitationDecline, self))
	addEventHandler("companyRankUp", root, bind(self.Event_companyRankUp, self))
	addEventHandler("companyRankDown", root, bind(self.Event_companyRankDown, self))
	addEventHandler("companySaveRank", root, bind(self.Event_companySaveRank, self))
	addEventHandler("companyRespawnVehicles", root, bind(self.Event_companyRespawnVehicles, self))
	addEventHandler("companyChangeSkin", root, bind(self.Event_changeSkin, self))
	addEventHandler("companyToggleDuty", root, bind(self.Event_toggleDuty, self))
	addEventHandler("companyToggleLoan", root, bind(self.Event_toggleLoan, self))
	addEventHandler("companyRequestSkinSelection", root, bind(self.Event_requestSkins, self))
	addEventHandler("companyPlayerSelectSkin", root, bind(self.Event_setPlayerDutySkin, self))
	addEventHandler("companyUpdateSkinPermissions", root, bind(self.Event_UpdateSkinPermissions, self))
end

function CompanyManager:destructor()
	for i, v in pairs(CompanyManager.Map) do
		delete(v)
	end
end

function CompanyManager:loadCompanies()
	local st, count = getTickCount(), 0
	local result = sql:queryFetch("SELECT * FROM ??_companies", sql:getPrefix())
	for i, row in pairs(result) do
		local result2 = sql:queryFetch("SELECT Id, CompanyRank, CompanyLoanEnabled FROM ??_character WHERE CompanyId = ?", sql:getPrefix(), row.Id)
		local players, playerLoans = {}, {}
		for i, row2 in ipairs(result2) do
			players[row2.Id] = row2.CompanyRank
			playerLoans[row2.Id] = row2.CompanyLoanEnabled
		end

		if Company.DerivedClasses[row.Id] then
			self:addRef(Company.DerivedClasses[row.Id]:new(row.Id, row.Name, row.Name_Short, row.Name_Shorter, row.Creator, {players, playerLoans}, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins))
		else
			outputServerLog(("Company class for Id %s not found!"):format(row.Id))
			--self:addRef(Company:new(row.Id, row.Name, row.Name_Short, row.Creator, players, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins))
		end

		count = count + 1
	end
	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s companies in %sms"):format(count, getTickCount()-st)) end
end

function CompanyManager:getFromId(Id)
	return CompanyManager.Map[Id]
end

function CompanyManager:addRef(ref)
	CompanyManager.Map[ref:getId()] = ref
end

function CompanyManager:removeRef(ref)
	CompanyManager.Map[ref:getId()] = nil
end

function CompanyManager:Event_companyRequestInfo()
	self:sendInfosToClient(client)
end

function CompanyManager:sendInfosToClient(client)
	local company = client:getCompany()

	if company then --use triggerLatentEvent to improve serverside performance
		if company:getPlayerRank(client) < CompanyRank.Manager then
        	client:triggerLatentEvent("companyRetrieveInfo",company:getId(), company:getName(), company:getPlayerRank(client), company:getMoney(), company:getPlayers(), company.m_RankNames)
		else
			client:triggerLatentEvent("companyRetrieveInfo",company:getId(), company:getName(), company:getPlayerRank(client), company:getMoney(), company:getPlayers(), company.m_RankNames, company.m_RankLoans)
		end
	else
		client:triggerEvent("companyRetrieveInfo")
	end
end

function CompanyManager:Event_companyQuit()
	local company = client:getCompany()
	if not company then return end

	if company:getPlayerRank(client) == CompanyRank.Leader then
		client:sendWarning(_("Als Leader kannst du nicht das Unternehmen verlassen!", client))
		return
	end
	company:removePlayer(client)
	client:sendSuccess(_("Du hast das Unternehmen erfolgreich verlassen!", client))
    company:addLog(client, "Unternehmen", "hat das Unternehmen verlassen!")

	self:sendInfosToClient(client)
	Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(client.m_Id)
end

function CompanyManager:Event_companyDeposit(amount)
	local company = client:getCompany()
	if not company then return end
    if not amount then return end

	if client:transferMoney(company, amount, "Unternehmen-Einlage", "Company", "Deposit") then
		company:addLog(client, "Kasse", "hat "..toMoneyString(amount).." in die Kasse gelegt!")
		self:sendInfosToClient(client)
		company:refreshBankAccountGUI(client)
	else
		client:sendError(_("Du hast nicht genügend Geld!", client))
	end
end

function CompanyManager:Event_companyWithdraw(amount)
	local company = client:getCompany()
	if not company then return end
    if not amount then return end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:transferMoney(client, amount, "Unternehmen-Auslage", "Company", "Withdraw") then
		company:addLog(client, "Kasse", "hat "..toMoneyString(amount).." aus der Kasse genommen!")
		self:sendInfosToClient(client)
		company:refreshBankAccountGUI(client)
	else
		client:sendError(_("In der Unternehmenskasse befindet sich nicht genügend Geld!", client))
	end
end

function CompanyManager:Event_companyAddPlayer(player)
	if not player then return end
	local company = client:getCompany()
	if not company then return end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Mitglieder hinzuzufügen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if player:getCompany() then
		client:sendError(_("Dieser Benutzer ist bereits in einem Unternehmen!", client))
		return
	end

	if not company:isPlayerMember(player) then
		if not company:hasInvitation(player) then
			company:invitePlayer(player)
            company:addLog(client, "Unternehmen", "hat den Spieler "..player:getName().." in das Unternehmen eingeladen!")
		else
			client:sendError(_("Dieser Benutzer hat bereits eine Einladung!", client))
		end
		--company:addPlayer(player)
		--client:triggerEvent("companyRetrieveInfo", company:getId(),company:getName(), company:getPlayerRank(client), company:getMoney(), company:getPlayers())
	else
		client:sendError(_("Dieser Spieler ist bereits im Unternehmen!", client))
	end
end

function CompanyManager:Event_companyDeleteMember(playerId, reasonInternaly, reasonExternaly)
	if not playerId then return end
	local company = client:getCompany()
	if not company then return end

	if client:getId() == playerId then
		client:sendError(_("Du kannst dich nicht selbst aus dem Unternehmen werfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du kannst den Spieler nicht rauswerfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(playerId) == CompanyRank.Leader then
		client:sendError(_("Du kannst den Unternehmensleiter nicht rauswerfen!", client))
		return
	end

	HistoryPlayer:getSingleton():addLeaveEntry(playerId, client.m_Id, company.m_Id, "company", company:getPlayerRank(playerId), reasonInternaly, reasonExternaly)

	company:removePlayer(playerId)

    company:addLog(client, "Unternehmen", "hat den Spieler "..Account.getNameFromId(playerId).." aus dem Unternehmen geworfen!")

	self:sendInfosToClient(client)
	Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(playerId)
end

function CompanyManager:Event_companyInvitationAccept(companyId)
	local company = self:getFromId(companyId)
	if not company then
		client:sendError(_("Company not found!", client))
		return
	end

	if company:hasInvitation(client) then
		if not client:getCompany() then
			company:addPlayer(client)

			company:sendMessage(_("#008888Unternehmen: #FFFFFF%s ist soeben dem Unternehmen beigetreten!", client, getPlayerName(client)),200,200,200,true)
			company:addLog(client, "Unternehmen", "ist dem Unternehmen beigetreten!")
			HistoryPlayer:getSingleton():addJoinEntry(client.m_Id, company:hasInvitation(client), company.m_Id, "company")

			self:sendInfosToClient(client)
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(client.m_Id)
		else
			client:sendError(_("Du bisd bereits in einem Unternehmen!", client))
		end
		company:removeInvitation(client)
	else
		client:sendError(_("Du hast keine Einladung für dieses Unternehmen", client))
	end
end

function CompanyManager:Event_companyInvitationDecline(companyId)
	local company = self:getFromId(companyId)
	if not company then return end

	if company:hasInvitation(client) then
		company:removeInvitation(client)
		company:sendMessage(_("%s hat die Unternehmenseinladung abgelehnt", client, getPlayerName(client)))
        company:addLog(client, "Unternehmen", "hat die Einladung abgelehnt!")
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du hast keine Einladung für dieses Unternehmen", client))
	end
end

function CompanyManager:Event_companyRankUp(playerId)
	if not playerId then return end
	local company = client:getCompany()
	if not company then return end

	if not company:isPlayerMember(client) or not company:isPlayerMember(playerId) then
		return
	end

	if client:getId() == playerId then
		client:sendError(_("Du kannst nicht deinen eigenen Rang verändern!", client))
		return
	end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(playerId) < CompanyRank.Leader then
		if company:getPlayerRank(playerId) < company:getPlayerRank(client) then
			company:setPlayerRank(playerId, company:getPlayerRank(playerId) + 1)
			HistoryPlayer:getSingleton():setHighestRank(playerId, company:getPlayerRank(playerId), company.m_Id, "company")
			company:addLog(client, "Unternehmen", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..company:getPlayerRank(playerId).." befördert!")
			local player = DatabasePlayer.getFromId(playerId)
			if player and isElement(player) and player:isActive() then
				player:sendShortMessage(_("Du wurdest von %s auf Rang %d befördert!", player, client:getName(), company:getPlayerRank(playerId)), company:getName())
				player:setPublicSync("CompanyRank", company:getPlayerRank(playerId))
			end
			self:sendInfosToClient(client)
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(playerId)
		else
			client:sendError(_("Mit deinem Rang kannst du Spieler maximal auf Rang %d befördern!", client, company:getPlayerRank(client)))
		end
	else
		client:sendError(_("Du kannst Spieler nicht höher als auf Rang 5 befördern!", client))
	end
end

function CompanyManager:Event_companyRankDown(playerId)
	if not playerId then return end
	local company = client:getCompany()
	if not company then return end

	if not company:isPlayerMember(client) or not company:isPlayerMember(playerId) then
		client:sendError(_("Du oder das Ziel sind nicht mehr im Unternehmen!", client))
		return
	end

	if client:getId() == playerId then
		client:sendError(_("Du kannst nicht deinen eigenen Rang verändern!", client))
		return
	end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

    if company:getPlayerRank(playerId)-1 >= CompanyRank.Normal then
		if company:getPlayerRank(playerId) <= company:getPlayerRank(client) then
			HistoryPlayer:getSingleton():setHighestRank(playerId, company:getPlayerRank(playerId), company.m_Id, "company")
			company:setPlayerRank(playerId, company:getPlayerRank(playerId) - 1)
			company:addLog(client, "Unternehmen", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..company:getPlayerRank(playerId).." degradiert!")
			local player = DatabasePlayer.getFromId(playerId)
			if player and isElement(player) and player:isActive() then
				player:sendShortMessage(_("Du wurdest von %s auf Rang %d degradiert!", player, client:getName(), company:getPlayerRank(playerId), company:getName()))
				player:setPublicSync("CompanyRank", company:getPlayerRank(playerId))
			end
			self:sendInfosToClient(client)
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(playerId)
		else
			client:sendError(_("Du kannst ranghöhere Mitglieder nicht degradieren!", client))
		end
	end
end

function CompanyManager:Event_companyRespawnVehicles()
	if client:getCompany() then
		local company = client:getCompany()
		if company:getPlayerRank(client) >= CompanyRank.Manager then
			company:respawnVehicles()
		else
			client:sendError(_("Die Fahrzeuge können erst ab Rang %d respawnt werden!", client, CompanyRank.Manager))
		end
	end
end

function CompanyManager:Event_companySaveRank(rank,loan)
	local company = client:getCompany()
	if company then
        if tonumber(loan) > COMPANY_MAX_RANK_LOANS[rank] then
			client:sendError(_("Der maximale Lohn für diesen Rang beträgt %d$", client, COMPANY_MAX_RANK_LOANS[rank]))
			return
		end
        company:setRankLoan(rank,loan)
		company:save()
		client:sendInfo(_("Die Einstellungen für Rang %d wurden gespeichert!", client, rank))
        company:addLog(client, "Unternehmen", "hat die Einstellungen für Rang "..rank.." geändert!")
		self:sendInfosToClient(client)
	end
end

function CompanyManager:Event_changeSkin()
	if client:isCompanyDuty() then
		client:getCompany():changeSkin(client)
	end
end

function CompanyManager:Event_toggleDuty(wasted, preferredSkin, dontChangeSkin)
	if getPedOccupiedVehicle(client) and not wasted then
		return client:sendError("Steige erst aus dem Fahrzeug aus!")
	end
	local company = client:getCompany()
	if company then
		if getDistanceBetweenPoints3D(client.position, company.m_DutyPickup.position) <= 10 or wasted then
			if client:isCompanyDuty() then
				if not dontChangeSkin then
					client:setCorrectSkin(true)
				end
				client:setCompanyDuty(false)
				company:updateCompanyDutyGUI(client)
				client:sendInfo(_("Du bist nicht mehr im Unternehmens-Dienst!", client))
				client:setPublicSync("Company:Duty",false)
				takeAllWeapons(client)
				if company.stop then
					company:stop(client)
				end
			else
				if client:isFactionDuty() then
					--client:sendWarning(_("Bitte beende zuerst deinen Dienst in deiner Fraktion!", client))
					--return false
					client:triggerEvent("factionForceOffduty", true)
				end
				company:changeSkin(client, preferredSkin) 
				client:setCompanyDuty(true)
				company:updateCompanyDutyGUI(client)
				client:sendInfo(_("Du bist nun im Dienst deines Unternehmens!", client))
				client:setPublicSync("Company:Duty",true)
				takeAllWeapons(client)
				if company.m_Id == CompanyStaticId.SANNEWS then
					giveWeapon(client, 43, 50) -- Camera
				end
				if company.start then
					company:start(client)
				end
			end
		else
			client:sendError(_("Du bist zu weit entfernt!", client))
		end
	else
		client:sendError(_("Du bist in keinem Unternehmen!", client))
        return false
	end
end

function CompanyManager:Event_toggleLoan(playerId)
	if not playerId then return end
	local company = client:getCompany()
	if not company then return end

	if not company:isPlayerMember(client) or not company:isPlayerMember(playerId) then
		client:sendError(_("Du oder das Ziel sind nicht mehr im Unternehmen!", client))
		return
	end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end

	local current = company:isPlayerLoanEnabled(playerId)
	company:setPlayerLoanEnabled(playerId, current and 0 or 1)
	self:sendInfosToClient(client)

	company:addLog(client, "Unternehmen", ("hat das Gehalt von Spieler %s %saktiviert!"):format(Account.getNameFromId(playerId), current and "de" or ""))
end

function CompanyManager:Event_getCompanies()
	for id, company in pairs(CompanyManager.Map) do
		client:triggerEvent("loadClientCompany", company:getId(), company:getName(), company:getShortName(), company.m_RankNames)
	end
end


function CompanyManager:Event_requestSkins()
	if not client:getCompany() then
		client:sendError(_("Du gehörst keinem Unternehmen an!", client))
		return false
	end
	local c = client:getCompany()
	local r = c:getPlayerRank(client)
	triggerClientEvent(client, "openSkinSelectGUI", client, c:getSkinsForRank(r), c:getId(), "company", r >= CompanyRank.Manager, c:getAllSkins())
end

function CompanyManager:Event_setPlayerDutySkin(skinId)
	if not client:getCompany() then
		client:sendError(_("Du gehörst keinem Unternehmen an!", client))
		return false
	end
	if not client:isCompanyDuty() then
		client:sendError(_("Du bist nicht im Dienst deines Unternehmens aktiv!", client))
		return
	end
	client:sendInfo(_("Kleidung gewechselt.", client))
	client:getCompany():changeSkin(client, skinId)
end

function CompanyManager:Event_UpdateSkinPermissions(skinTable)
	if not client:getCompany() then
		client:sendError(_("Du gehörst keinem Unternehmen an!", client))
		return false
	end
	if client:getCompany():getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Dein Rang ist zu niedrig!", client))
		return false
	end
	for i, v in pairs(skinTable) do
		client:getCompany():setSetting("Skin", i, v)
	end
	client:sendSuccess(_("Einstellungen gespeichert!", client))

	local c = client:getCompany()
	local r = c:getPlayerRank(client)
	triggerClientEvent(client, "openSkinSelectGUI", client, c:getSkinsForRank(r), c:getId(), "company", r >= CompanyRank.Manager, c:getAllSkins())
end

function CompanyManager:getFromName(name)
	for k, company in pairs(CompanyManager.Map) do
		if company:getName() == name then
			return company
		end
	end
	return false
end