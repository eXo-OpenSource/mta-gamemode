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
  outputServerLog("Loading companies...")
  local result = sql:queryFetch("SELECT * FROM ??_companies", sql:getPrefix())
  for i, row in pairs(result) do
    local result2 = sql:queryFetch("SELECT Id, CompanyRank FROM ??_character WHERE CompanyId = ?", sql:getPrefix(), row.Id)
    local players = {}
    for i, row2 in ipairs(result2) do
      players[row2.Id] = row2.CompanyRank
    end

    if Company.DerivedClasses[row.Id] then
      self:addRef(Company.DerivedClasses[row.Id]:new(row.Id, row.Name, row.Creator, players, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins))
    else
      self:addRef(Company:new(row.Id, row.Name, row.Creator, players, row.lastNameChange, row.BankAccount, fromJSON(row.Settings) or {["VehiclesCanBeModified"]=false}, row.RankLoans, row.RankSkins))
    end
  end

  -- Add events
  addRemoteEvents{"companyRequestInfo", "companyQuit", "companyDeposit", "companyWithdraw", "companyAddPlayer", "companyDeleteMember", "companyInvitationAccept", "companyInvitationDecline", "companyRankUp", "companyRankDown", "companySaveRank","companyRespawnVehicles", "companyChangeSkin", "companyToggleDuty"}
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
		client:sendWarning(_("Bitte übertrage den Leader-Status erst auf ein anderes Mitglied der Fraktion!", client))
		return
	end
	company:removePlayer(client)
	client:sendSuccess(_("Du hast die Fraktion erfolgreich verlassen!", client))
	self:sendInfosToClient(client)
end

function CompanyManager:Event_companyDeposit(amount)
	local company = client:getCompany()
	if not company then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	client:takeMoney(amount)
	company:giveMoney(amount)
	self:sendInfosToClient(client)
end

function CompanyManager:Event_companyWithdraw(amount)
	local company = client:getCompany()
	if not company then return end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company.m_BankAccount:getMoney() < amount then
		client:sendError(_("In der Gruppenkasse befindet sich nicht genügend Geld!", client))
		return
	end

	company:takeMoney(amount)
	client:giveMoney(amount)
	self:sendInfosToClient(client)
end

function CompanyManager:Event_companyAddPlayer(player)
	if not player then return end
	local company = client:getCompany()
	if not company then return end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Fraktionnmitglieder hinzuzufügen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if player:getCompany() then
		client:sendError(_("Dieser Benutzer ist bereits in einer Fraktion!", client))
		return
	end

	if not company:isPlayerMember(player) then
		if not company:hasInvitation(player) then
			company:invitePlayer(player)
		else
			client:sendError(_("Dieser Benutzer hat bereits eine Einladung!", client))
		end
		--company:addPlayer(player)
		--client:triggerEvent("companyRetrieveInfo", company:getId(),company:getName(), company:getPlayerRank(client), company:getMoney(), company:getPlayers())
	else
		client:sendError(_("Dieser Spieler ist bereits in der Fraktion!", client))
	end
end

function CompanyManager:Event_companyDeleteMember(playerId)
	if not playerId then return end
	local company = client:getCompany()
	if not company then return end

	if client:getId() == playerId then
		client:sendError(_("Du kannst dich nicht selbst aus der Fraktion werfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(client) < CompanyRank.Manager then
		client:sendError(_("Du kannst den Spieler nicht rauswerfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(playerId) == CompanyRank.Leader then
		client:sendError(_("Du kannst den Fraktionnleiter nicht rauswerfen!", client))
		return
	end

	company:removePlayer(playerId)
	self:sendInfosToClient(client)
end

function CompanyManager:Event_companyInvitationAccept(companyId)
	local company = self:getFromId(companyId)
	if not company then
		client:sendError(_("Company not found!", client))
		return
	end

	if company:hasInvitation(client) then
		company:addPlayer(client)
		company:removeInvitation(client)
		company:sendMessage(_("%s ist soeben der Fraktion beigetreten", client, getPlayerName(client)))
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du hast keine Einladung für diese Fraktion", client))
	end
end

function CompanyManager:Event_companyInvitationDecline(companyId)
	local company = self.getFromId(companyId)
	if not company then return end

	if company:hasInvitation(client) then
		company:removeInvitation(client)
		company:sendMessage(_("%s hat die Fraktionneinladung abgelehnt", client, getPlayerName(client)))
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du hast keine Einladung für diese Fraktion", client))
	end
end

function CompanyManager:Event_companyRankUp(playerId)
	if not playerId then return end
	local company = client:getCompany()
	if not company then return end

	if not company:isPlayerMember(client) or not company:isPlayerMember(playerId) then
		return
	end

	if company:getPlayerRank(client) < CompanyRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(playerId) < CompanyRank.Manager then
		company:setPlayerRank(playerId, company:getPlayerRank(playerId) + 1)
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du kannst Spieler nicht höher als auf Rang 'Manager' setzen!", client))
	end
end

function CompanyManager:Event_companyRankDown(playerId)
	if not playerId then return end
	local company = client:getCompany()
	if not company then return end

	if not company:isPlayerMember(client) or not company:isPlayerMember(playerId) then
		client:sendError(_("Du oder das Ziel sind nicht mehr in der Fraktion!", client))
		return
	end

	if company:getPlayerRank(client) < CompanyRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if company:getPlayerRank(playerId) >= CompanyRank.Manager then
		company:setPlayerRank(playerId, company:getPlayerRank(playerId) - 1)
		self:sendInfosToClient(client)
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
	client:getCompany():respawnVehicles()
end

function CompanyManager:Event_companySaveRank(rank,skinId,loan)
	local company = client:getCompany()
	if company then
		company:setRankSkin(rank,skinId)
		company:setRankLoan(rank,loan)
		company:save()
		client:sendInfo(_("Die Einstellungen für Rang "..rank.." wurden gespeichert!", client))
		self:sendInfosToClient(client)
	end
end

function CompanyManager:Event_changeSkin()
	if client:isCompanyDuty() then
		client:getCompany():changeSkin(client)
	end
end

function CompanyManager:Event_toggleDuty()
	local company = client:getCompany()
	if company then
		if client:isCompanyDuty() then
			client:setDefaultSkin()
			client.m_CompanyDuty = false
			company:updateCompanyDutyGUI(client)
			client:sendInfo(_("Du bist nicht mehr im Unternehmens-Dienst!", client))
			client:setPublicSync("Company:Duty",false)

            if company.stop then
                company:stop(client)
            end
		else
			company:changeSkin(client)
			client.m_CompanyDuty = true
			company:updateCompanyDutyGUI(client)
			client:sendInfo(_("Du bist nun im Unternehmens-Dienst!", client))
			client:setPublicSync("Company:Duty",true)

            if company.start then
                company:start(client)
            end
		end
	else
		client:sendError(_("Du bist in keinem Unternehmen!", client))
	end
end
