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
  local st, count = getTickCount(), 0
  local result = sql:queryFetch("SELECT * FROM ??_companies", sql:getPrefix())
  for i, row in pairs(result) do
    local result2 = sql:queryFetch("SELECT Id, CompanyRank FROM ??_character WHERE CompanyId = ?", sql:getPrefix(), row.Id)
    local players = {}
    for i, row2 in ipairs(result2) do
      players[row2.Id] = row2.CompanyRank
    end

    if Company.DerivedClasses[row.Id] then
      self:addRef(Company.DerivedClasses[row.Id]:new(row.Id, row.Name, row.Name_Short, row.Creator, players, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins))
    else
        outputServerLog(("Company class for Id %s not found!"):format(row.Id))
      --self:addRef(Company:new(row.Id, row.Name, row.Name_Short, row.Creator, players, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins))
    end
	count = count + 1
  end
  if DEBUG_LOAD_SAVE then outputServerLog(("Created %s companies in %sms"):format(count, getTickCount()-st)) end
  -- Add events
  addRemoteEvents{"getCompanies", "companyRequestInfo", "companyRequestLog", "companyQuit", "companyDeposit", "companyWithdraw", "companyAddPlayer", "companyDeleteMember", "companyInvitationAccept", "companyInvitationDecline", "companyRankUp", "companyRankDown", "companySaveRank","companyRespawnVehicles", "companyChangeSkin", "companyToggleDuty"}
  addEventHandler("getCompanies", root, bind(self.Event_getCompanies, self))
  addEventHandler("companyRequestInfo", root, bind(self.Event_companyRequestInfo, self))
  addEventHandler("companyRequestLog", root, bind(self.Event_companyRequestLog, self))
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

end

function CompanyManager:destructor()
  for i, v in pairs(CompanyManager.Map) do
    delete(v)
  end
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

function CompanyManager:Event_companyRequestLog()
    local company = client:getCompany()
	if company then
		client:triggerEvent("companyRetrieveLog", company:getPlayers(), company:getLog())
	end
end

function CompanyManager:Event_companyRequestInfo()
	self:sendInfosToClient(client)
end

function CompanyManager:sendInfosToClient(client)
	local company = client:getCompany()

	if company then
        client:triggerEvent("companyRetrieveInfo",company:getId(), company:getName(), company:getPlayerRank(client), company:getMoney(), company:getPlayers(), company.m_Skins, company.m_RankNames, company.m_RankLoans, company.m_RankSkins)
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
end

function CompanyManager:Event_companyDeposit(amount)
	local company = client:getCompany()
	if not company then return end
    if not amount then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	client:takeMoney(amount, "Unternehmen-Einlage")
	company:giveMoney(amount, "Unternehmen-Einlage")
    company:addLog(client, "Kasse", "hat "..amount.."$ in die Kasse gelegt!")
	self:sendInfosToClient(client)
    company:refreshBankAccountGUI(client)

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

	if company.m_BankAccount:getMoney() < amount then
		client:sendError(_("In der Unternehmenskasse befindet sich nicht genügend Geld!", client))
		return
	end

	company:takeMoney(amount, "Unternehmen-Auslage")
	client:giveMoney(amount, "Unternehmen-Auslage")
    company:addLog(client, "Kasse", "hat "..amount.."$ aus der Kasse genommen!")
	self:sendInfosToClient(client)
    company:refreshBankAccountGUI(client)
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

function CompanyManager:Event_companyDeleteMember(playerId)
	if not playerId then return end
	local company = client:getCompany()
	if not company then return end

	if client:getId() == playerId then
		client:sendError(_("Du kannst dich nicht selbst aus der Unternehmen werfen!", client))
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

	company:removePlayer(playerId)
    company:addLog(client, "Unternehmen", "hat den Spieler "..Account.getNameFromId(playerId).." aus dem Unternehmen geworfen!")

	self:sendInfosToClient(client)
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

			self:sendInfosToClient(client)
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

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(playerId) < CompanyRank.Leader then
		if company:getPlayerRank(playerId) < company:getPlayerRank(client) then
			company:setPlayerRank(playerId, company:getPlayerRank(playerId) + 1)
			company:addLog(client, "Unternehmen", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..company:getPlayerRank(playerId).." befördert!")
			local player = DatabasePlayer.getFromId(playerId)
			if player and isElement(player) and player:isActive() then
				player:sendShortMessage(_("Du wurdest von %s auf Rang %d befördert!", player, client:getName(), company:getPlayerRank(playerId)), company:getName())
			end
			self:sendInfosToClient(client)
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

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

    if company:getPlayerRank(playerId)-1 >= CompanyRank.Normal then
		if company:getPlayerRank(playerId) <= company:getPlayerRank(client) then
			company:setPlayerRank(playerId, company:getPlayerRank(playerId) - 1)
			company:addLog(client, "Unternehmen", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..company:getPlayerRank(playerId).." degradiert!")
			local player = DatabasePlayer.getFromId(playerId)
			if player and isElement(player) and player:isActive() then
				player:sendShortMessage(_("Du wurdest von %s auf Rang %d degradiert!", player, client:getName(), company:getPlayerRank(playerId), company:getName()))
			end
			self:sendInfosToClient(client)
		else
			client:sendError(_("Du kannst ranghöhere Mitglieder nicht degradieren!", client))
		end
	end
end

function CompanyManager:Event_openCompanyWeaponShopGUI()
	local company = client:getCompany()
	if company then
		client:triggerEvent("showCompanyWeaponShopGUI")
	end
end

function CompanyManager:Event_receiveCompanyWeaponShopInfos()
	local company = client:getCompany()
	local depot = company.m_Depot
	local playerId = client:getId()
	local rank = company.m_Players[playerId]
	triggerClientEvent(client,"updateCompanyWeaponShopGUI",client,company.m_ValidWeapons, company.m_WeaponDepotInfo, depot:getWeaponTable(id), company:getRankWeapons(rank))
end

function CompanyManager:Event_companyWeaponShopBuy(weaponTable)
	local company = client:getCompany()
	local depot = company.m_Depot
	depot:takeWeaponsFromDepot(client,weaponTable)
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

function CompanyManager:Event_companySaveRank(rank,skinId,loan)
	local company = client:getCompany()
	if company then
        if tonumber(loan) > COMPANY_MAX_RANK_LOANS[rank] then
			client:sendError(_("Der maximale Lohn für diesen Rang beträgt %d$", client, COMPANY_MAX_RANK_LOANS[rank]))
			return
		end
        company:setRankLoan(rank,loan)
        company:setRankSkin(rank,skinId)
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

function CompanyManager:Event_toggleDuty(wasted)
	if getPedOccupiedVehicle(client) and not wasted then
		return client:sendError("Steige erst aus dem Fahrzeug aus!")
	end
	local company = client:getCompany()
	if company then
		if getDistanceBetweenPoints3D(client.position, company.m_DutyPickup.position) <= 10 or wasted then
			if client:isCompanyDuty() then
				client:setDefaultSkin()
				client.m_CompanyDuty = false
				company:updateCompanyDutyGUI(client)
				client:sendInfo(_("Du bist nicht mehr im Unternehmens-Dienst!", client))
				client:setPublicSync("Company:Duty",false)
				takeAllWeapons(client)
				if company.stop then
					company:stop(client)
				end
			else
				if client:getPublicSync("Faction:Duty") and client:getFaction() then
					client:sendWarning(_("Bitte beende zuerst deinen Dienst in deiner Fraktion!", client))
					return false
				end		
				company:changeSkin(client)
				client.m_CompanyDuty = true
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

function CompanyManager:Event_getCompanies()
	for id, company in pairs(CompanyManager.Map) do
		client:triggerEvent("loadClientCompany", company:getId(), company:getName(), company:getShortName())
	end
end
