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
	addRemoteEvents{"getCompanies", "companyRequestInfo", "companyQuit", "companyDeposit", "companyWithdraw", "companyAddPlayer", 
		"companyDeleteMember", "companyInvitationAccept", "companyInvitationDecline", "companyRankUp", "companyRankDown", 
		"companySaveRank","companyRespawnVehicles", "companyChangeSkin", "companyToggleDuty", "companyToggleLoan", "companyRequestSkinSelection", 
		"companyPlayerSelectSkin", "companyUpdateSkinPermissions", "stopCompanyRespawnAnnouncement"}

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
	addEventHandler("stopCompanyRespawnAnnouncement", root, bind(self.Event_stopRespawnAnnoucement, self))
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
		local result2 = sql:queryFetch("SELECT Id, CompanyRank, CompanyLoanEnabled, CompanyPermissions FROM ??_character WHERE CompanyId = ?", sql:getPrefix(), row.Id)
		local players, playerLoans, playerPermissions = {}, {}, {}
		for i, row2 in ipairs(result2) do
			players[row2.Id] = row2.CompanyRank
			playerLoans[row2.Id] = row2.CompanyLoanEnabled
			playerPermissions[row2.Id] = fromJSON(row2.CompanyPermissions)
		end

		if Company.DerivedClasses[row.Id] then
			self:addRef(Company.DerivedClasses[row.Id]:new(row.Id, row.Name, row.Name_Short, row.Name_Shorter, row.Creator, {players, playerLoans, playerPermissions}, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins, row.RankPermissions))
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
		if company:getPlayerRank(client) < CompanyRank.Manager and not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "editLoan") then
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

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "withdrawMoney") then
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

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "invite"	) then
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

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "uninvite") then
		client:sendError(_("Du kannst den Spieler nicht rauswerfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(client) <= company:getPlayerRank(playerId) then
		client:sendError(_("Du kannst den Spieler nicht rauswerfen!", client))
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

function CompanyManager:Event_companyRankUp(playerId, leaderSwitch)
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

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "changeRank") then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(client) ~= CompanyRank.Leader and company:getPlayerRank(client) <= company:getPlayerRank(playerId) + 1 then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		return
	end

	if company:getPlayerRank(playerId) + 1 >= CompanyRank.Manager then
		if LeaderCheck:getSingleton():hasPlayerLeaderBan(playerId) then
			client:sendError(_("Dieser Spieler kann aufgrund einer Leadersperre nicht befördert werden!", client))
			return
		end
	end

	if company:getPlayerRank(playerId) < CompanyRank.Leader then
		if company:getPlayerRank(playerId) < company:getPlayerRank(client) then
			if leaderSwitch then
				self:switchLeaders(client, playerId)
			end

			company:setPlayerRank(playerId, company:getPlayerRank(playerId) + 1)
			HistoryPlayer:getSingleton():setHighestRank(playerId, company:getPlayerRank(playerId), company.m_Id, "company")
			company:addLog(client, "Unternehmen", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..company:getPlayerRank(playerId).." befördert!")
			local player = DatabasePlayer.getFromId(playerId)
			if player and isElement(player) and player:isActive() then
				player:sendShortMessage(_("Du wurdest von %s auf Rang %d befördert!", player, client:getName(), company:getPlayerRank(playerId)), company:getName())
				player:setPublicSync("CompanyRank", company:getPlayerRank(playerId))
			end
			self:sendInfosToClient(client)
			PermissionsManager:getSingleton():onRankChange("up", client, playerId, "company")
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

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "changeRank") then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(client) ~= CompanyRank.Leader and company:getPlayerRank(client) <= company:getPlayerRank(playerId) then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
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
			PermissionsManager:getSingleton():onRankChange("down", client, playerId, "company")
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(playerId)
		else
			client:sendError(_("Du kannst ranghöhere Mitglieder nicht degradieren!", client))
		end
	end
end

function CompanyManager:switchLeaders(oldLeader, newLeader)
	Async.create(
		function(oldLeader)
			local company = oldLeader:getCompany()
			
			company:setPlayerRank(oldLeader, company:getPlayerRank(oldLeader) - 1)
			company:addLog(newLeader, "Unternehmen", "hat den Spieler "..oldLeader:getName().." auf Rang "..company:getPlayerRank(oldLeader).." degradiert!")

			if isElement(oldLeader) then
				oldLeader:sendShortMessage(_("Du wurdest von %s auf Rang %d degradiert!", player, Account.getNameFromId(newLeader), company:getPlayerRank(oldLeader)), company:getName())
				oldLeader:setPublicSync("CompanyRank", company:getPlayerRank(oldLeader))
			end
			
			self:sendInfosToClient(oldLeader)
			PermissionsManager:getSingleton():onRankChange("down", oldLeader, oldLeader:getId(), "company")
			Async.create(function(id) ServiceSync:getSingleton():syncPlayer(id) end)(oldLeader:getId())
		end
	)(oldLeader)
end

function CompanyManager:Event_companyRespawnVehicles(instant)
	if client:getCompany() then
		local company = client:getCompany()

		if PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "vehicleRespawnAll") then
			if not client:getCompany().m_RespawnTimer or not isTimer(client:getCompany().m_RespawnTimer) then
				if instant then
					company:respawnVehicles()
				else
					company:startRespawnAnnouncement(client)
				end
			else
				client:sendError(_("Es wurde bereits eine Respawn Ankündigung erstellt.", client))
			end
		else
			client:sendError(_("Dazu bist du nicht berechtigt.", client))
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

		if tonumber(company.m_RankLoans[tostring(rank)]) ~= tonumber(loan) then
			if PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "editLoan") then
				if company:getPlayerRank(client) > rank or company:getPlayerRank(client) == CompanyRank.Leader then
					company:setRankLoan(rank,loan)
					company:save()
					client:sendInfo(_("Die Einstellungen für Rang %d wurden gespeichert!", client, rank))
					company:addLog(client, "Unternehmen", "hat die Einstellungen für Rang "..rank.." geändert!")
				else
					client:sendError(_("Du kannst das Gehalt von dem Rang nicht verändern!", client))
				end
			else
				client:sendError(_("Du bist nicht berechtigt das Gehalt zu ändern", client))
			end
		end

		self:sendInfosToClient(client)
	end
end

function CompanyManager:Event_changeSkin()
	if client:isCompanyDuty() then
		client:getCompany():changeSkin(client)
	end
end

function CompanyManager:Event_toggleDuty(wasted, preferredSkin, dontChangeSkin, player)
	if not client then client = player end
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
				client:restoreStorage()
				if company.stop then
					company:stop(client)
				end
			else
				if client:isFactionDuty() then
					--client:sendWarning(_("Bitte beende zuerst deinen Dienst in deiner Fraktion!", client))
					--return false
					FactionManager:getSingleton():factionForceOffduty(client)
				end
				company:changeSkin(client, preferredSkin) 
				client:setCompanyDuty(true)

				company:updateCompanyDutyGUI(client)
				client:sendInfo(_("Du bist nun im Dienst deines Unternehmens!", client))
				client:setPublicSync("Company:Duty",true)
				client:createStorage()
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

	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "toggleLoan") then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end

	local current = company:isPlayerLoanEnabled(playerId)
	
	if company:getPlayerRank(client) <= company:getPlayerRank(playerId) and company:getPlayerRank(client) ~= CompanyRank.Leader then
		client:sendError(_("Du kannst das Gehalt vom dem Spieler nicht %saktivieren", client, current and "de" or ""))
		return
	end
	
	company:setPlayerLoanEnabled(playerId, current and 0 or 1)
	self:sendInfosToClient(client)

	company:addLog(client, "Unternehmen", ("hat das Gehalt von Spieler %s %saktiviert!"):format(Account.getNameFromId(playerId), current and "de" or ""))
end

function CompanyManager:Event_getCompanies()
	for id, company in pairs(CompanyManager.Map) do
		client:triggerEvent("loadClientCompany", company:getId(), company:getName(), company:getShortName(), company.m_RankNames, companyColors[company:getId()])
	end
end


function CompanyManager:Event_requestSkins()
	if not client:getCompany() then
		client:sendError(_("Du gehörst keinem Unternehmen an!", client))
		return false
	end
	local c = client:getCompany()
	local r = c:getPlayerRank(client)
	triggerClientEvent(client, "openSkinSelectGUI", client, c:getSkinsForRank(r), c:getId(), "company", PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "editRankSkins"), c:getAllSkins())
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
	if not PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "editRankSkins") then
		client:sendError(_("Dein Rang ist zu niedrig!", client))
		return false
	end
	for i, v in pairs(skinTable) do
		client:getCompany():setSetting("Skin", i, v)
	end
	client:sendSuccess(_("Einstellungen gespeichert!", client))

	local c = client:getCompany()
	local r = c:getPlayerRank(client)
	triggerClientEvent(client, "openSkinSelectGUI", client, c:getSkinsForRank(r), c:getId(), "company", PermissionsManager:getSingleton():hasPlayerPermissionsTo(client, "company", "editRankSkins"), c:getAllSkins())
end

function CompanyManager:getFromName(name)
	for k, company in pairs(CompanyManager.Map) do
		if company:getName() == name then
			return company
		end
	end
	return false
end

function CompanyManager:companyForceOffduty(player)
	if player:getPublicSync("Company:Duty") and player:getCompany() then
		self:Event_toggleDuty(true, false, true, player)
	end
end

function CompanyManager:Event_stopRespawnAnnoucement()
	if client:getCompany() then
		client:getCompany():stopRespawnAnnouncement(client)
	end
end