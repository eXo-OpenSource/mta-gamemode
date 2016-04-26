-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/FactionManager.lua
-- *  PURPOSE:     Factionmanager Class
-- *
-- ****************************************************************************

FactionManager = inherit(Singleton)
FactionManager.Map = {}


function FactionManager:constructor()
	self.StateFactions = {
	[1] = true,
	[2] = true,
	[3] = true
	}
	self.EvilFactions = {
	[5] = true,
	[6] = true
	}
	self.RescueFactions = {
	[4] = true
	}

	self:loadFactions()

  -- Events
	addRemoteEvents{"getFactions", "factionRequestInfo", "factionRequestLog", "factionQuit", "factionDeposit", "factionWithdraw", "factionAddPlayer", "factionDeleteMember", "factionInvitationAccept", "factionInvitationDecline", "factionRankUp", "factionRankDown","factionReceiveWeaponShopInfos","factionWeaponShopBuy","openFactionWeaponShopGUI","factionSaveRank","factionRespawnVehicles"}
	addEventHandler("getFactions", root, bind(self.Event_getFactions, self))
	addEventHandler("factionRequestInfo", root, bind(self.Event_factionRequestInfo, self))
	addEventHandler("factionRequestLog", root, bind(self.Event_factionRequestLog, self))
	addEventHandler("factionQuit", root, bind(self.Event_factionQuit, self))
	addEventHandler("factionDeposit", root, bind(self.Event_factionDeposit, self))
	addEventHandler("factionWithdraw", root, bind(self.Event_factionWithdraw, self))
	addEventHandler("factionAddPlayer", root, bind(self.Event_factionAddPlayer, self))
	addEventHandler("factionDeleteMember", root, bind(self.Event_factionDeleteMember, self))
	addEventHandler("factionInvitationAccept", root, bind(self.Event_factionInvitationAccept, self))
	addEventHandler("factionInvitationDecline", root, bind(self.Event_factionInvitationDecline, self))
	addEventHandler("factionRankUp", root, bind(self.Event_factionRankUp, self))
	addEventHandler("factionRankDown", root, bind(self.Event_factionRankDown, self))
	addEventHandler("openFactionWeaponShopGUI", root, bind(self.Event_openFactionWeaponShopGUI, self))
	addEventHandler("factionReceiveWeaponShopInfos", root, bind(self.Event_receiveFactionWeaponShopInfos, self))
	addEventHandler("factionWeaponShopBuy", root, bind(self.Event_factionWeaponShopBuy, self))
	addEventHandler("factionSaveRank", root, bind(self.Event_factionSaveRank, self))
	addEventHandler("factionRespawnVehicles", root, bind(self.Event_factionRespawnVehicles, self))



	FactionState:new()
	FactionRescue:new()
	FactionEvil:new(self.EvilFactions)
end

function FactionManager:destructor()
	for k, v in pairs(FactionManager.Map) do
		delete(v)
	end
end

function FactionManager:loadFactions()
  outputServerLog("Loading factions...")
  local result = sql:queryFetch("SELECT * FROM ??_factions", sql:getPrefix())
  for k, row in ipairs(result) do
    local result2 = sql:queryFetch("SELECT Id, FactionRank FROM ??_character WHERE FactionID = ?", sql:getPrefix(), row.Id)
    local players = {}
    for i, factionRow in ipairs(result2) do
      players[factionRow.Id] = factionRow.FactionRank
    end

	local FactionType = "Default"
	if self.StateFactions[row.Id] == true then FactionType = "State" elseif self.EvilFactions[row.Id] == true then FactionType = "Evil" elseif self.RescueFactions[row.Id] == true then FactionType = "Rescue" end

	local instance = Faction:new(row.Id, row.Name_Short, row.Name, row.BankAccount, players,row.RankLoans,row.RankSkins,row.RankWeapons,row.Depot,FactionType)
    FactionManager.Map[row.Id] = instance
  end
end

function FactionManager:getAllFactions()
	return self.Map
end

function FactionManager:getFromId(Id)
	return self.Map[Id]
end

function FactionManager:Event_factionSaveRank(rank,skinId,loan,rankWeapons)
	local faction = client:getFaction()
	if faction then
		if tonumber(loan) > FACTION_MAX_RANK_LOANS[rank] then
			client:sendError(_("Der maximale Lohn für diesen Rang beträgt %d$", client, FACTION_MAX_RANK_LOANS[rank]))
			return
		end
		faction:setRankLoan(rank,loan)
		faction:setRankSkin(rank,skinId)
		faction:setRankWeapons(rank,rankWeapons)
		faction:save()
		client:sendInfo(_("Die Einstellungen für Rang %d wurden gespeichert!", client, rank))
		faction:addLog(client, "Fraktion", "hat die Einstellungen für Rang "..rank.." geändert!")
		self:sendInfosToClient(client)
	end
end

function FactionManager:Event_factionRequestInfo()
	self:sendInfosToClient(client)
end

function FactionManager:Event_factionRequestLog()
	local faction = client:getFaction()
	if faction then
		client:triggerEvent("factionRetrieveLog", faction:getPlayers(), faction:getLog())
	end
end

function FactionManager:sendInfosToClient(client)
	local faction = client:getFaction()

	if faction then
		client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers(),faction.m_Skins,faction.m_RankNames,faction.m_RankLoans,faction.m_RankSkins,faction.m_ValidWeapons,faction.m_RankWeapons)
	else
		client:triggerEvent("factionRetrieveInfo")
	end
end

function FactionManager:Event_factionQuit()
	local faction = client:getFaction()
	if not faction then return end

	if faction:getPlayerRank(client) == FactionRank.Leader then
		client:sendWarning(_("Bitte übertrage den Leader-Status erst auf ein anderes Mitglied der Fraktion!", client))
		return
	end
	faction:removePlayer(client)
	client:sendSuccess(_("Du hast die Fraktion erfolgreich verlassen!", client))
	faction:addLog(client, "Fraktion", "hat die Fraktion verlassen!")
	self:sendInfosToClient(client)
end

function FactionManager:Event_factionDeposit(amount)
	local faction = client:getFaction()
	if not faction then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	client:takeMoney(amount)
	faction:giveMoney(amount)
	faction:addLog(client, "Kasse", "hat "..amount.."$ in die Kasse gelegt!")
	self:sendInfosToClient(client)
end

function FactionManager:Event_factionWithdraw(amount)
	local faction = client:getFaction()
	if not faction then return end

	if faction:getPlayerRank(client) < FactionRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if faction:getMoney() < amount then
		client:sendError(_("In der Gruppenkasse befindet sich nicht genügend Geld!", client))
		return
	end

	faction:takeMoney(amount)
	faction:addLog(client, "Kasse", "hat "..amount.."$ aus der Kasse genommen!")
	client:giveMoney(amount)
	self:sendInfosToClient(client)
end

function FactionManager:Event_factionAddPlayer(player)
	if not player then return end
	local faction = client:getFaction()
	if not faction then return end

	if faction:getPlayerRank(client) < FactionRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Fraktionnmitglieder hinzuzufügen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if player:getFaction() then
		client:sendError(_("Dieser Benutzer ist bereits in einer Fraktion!", client))
		return
	end

	if not faction:isPlayerMember(player) then
		if not faction:hasInvitation(player) then
			faction:invitePlayer(player)
			faction:addLog(client, "Fraktion", "hat den Spieler "..player:getName().." in die Fraktion eingeladen!")
		else
			client:sendError(_("Dieser Benutzer hat bereits eine Einladung!", client))
		end
		--faction:addPlayer(player)
		--client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
	else
		client:sendError(_("Dieser Spieler ist bereits in der Fraktion!", client))
	end
end

function FactionManager:Event_factionDeleteMember(playerId)
	if not playerId then return end
	local faction = client:getFaction()
	if not faction then return end

	if client:getId() == playerId then
		client:sendError(_("Du kannst dich nicht selbst aus der Fraktion werfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if faction:getPlayerRank(client) < FactionRank.Manager then
		client:sendError(_("Du kannst den Spieler nicht rauswerfen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if faction:getPlayerRank(playerId) == FactionRank.Leader then
		client:sendError(_("Du kannst den Fraktionnleiter nicht rauswerfen!", client))
		return
	end
	faction:addLog(client, "Fraktion", "hat den Spieler "..Account.getNameFromId(playerId).." aus der Fraktion geworfen!")

	faction:removePlayer(playerId)
	self:sendInfosToClient(client)
end

function FactionManager:Event_factionInvitationAccept(factionId)
	local faction = self:getFromId(factionId)
	if not faction then
		client:sendError(_("Faction not found!", client))
		return
	end

	if faction:hasInvitation(client) then
		faction:addPlayer(client)
		faction:removeInvitation(client)
		faction:addLog(client, "Fraktion", "ist der Fraktion beigetreten!")
		faction:sendMessage(_("%s ist soeben der Fraktion beigetreten", client, getPlayerName(client)))
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du hast keine Einladung für diese Fraktion", client))
	end
end

function FactionManager:Event_factionInvitationDecline(factionId)
	local faction = self.getFromId(factionId)
	if not faction then return end

	if faction:hasInvitation(client) then
		faction:removeInvitation(client)
		faction:sendMessage(_("%s hat die Fraktionneinladung abgelehnt", client, getPlayerName(client)))
		faction:addLog(client, "Fraktion", "hat die Einladung abgelehnt!")

		self:sendInfosToClient(client)
	else
		client:sendError(_("Du hast keine Einladung für diese Fraktion", client))
	end
end

function FactionManager:Event_factionRankUp(playerId)
	if not playerId then return end
	local faction = client:getFaction()
	if not faction then return end

	if not faction:isPlayerMember(client) or not faction:isPlayerMember(playerId) then
		return
	end

	if faction:getPlayerRank(client) < FactionRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if faction:getPlayerRank(playerId) < FactionRank.Manager then
		faction:setPlayerRank(playerId, faction:getPlayerRank(playerId) + 1)
		faction:addLog(client, "Fraktion", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..faction:getPlayerRank(playerId).." befördert!")
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du kannst Spieler nicht höher als auf Rang 'Manager' setzen!", client))
	end
end

function FactionManager:Event_factionRankDown(playerId)
	if not playerId then return end
	local faction = client:getFaction()
	if not faction then return end

	if not faction:isPlayerMember(client) or not faction:isPlayerMember(playerId) then
		client:sendError(_("Du oder das Ziel sind nicht mehr in der Fraktion!", client))
		return
	end

	if faction:getPlayerRank(client) < FactionRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if faction:getPlayerRank(playerId) >= FactionRank.Manager then
		faction:setPlayerRank(playerId, faction:getPlayerRank(playerId) - 1)
		faction:addLog(client, "Fraktion", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..faction:getPlayerRank(playerId).." degradiert!")
		self:sendInfosToClient(client)
	end
end

function FactionManager:Event_openFactionWeaponShopGUI()
	local faction = client:getFaction()
	if faction then
		client:triggerEvent("showFactionWeaponShopGUI")
	end
end

function FactionManager:Event_receiveFactionWeaponShopInfos()
	local faction = client:getFaction()
	local depot = faction.m_Depot
	local playerId = client:getId()
	local rank = faction.m_Players[playerId]
	triggerClientEvent(client,"updateFactionWeaponShopGUI",client,faction.m_ValidWeapons, faction.m_WeaponDepotInfo, depot:getWeaponTable(id), faction:getRankWeapons(rank))
end

function FactionManager:Event_factionWeaponShopBuy(weaponTable)
	local faction = client:getFaction()
	local depot = faction.m_Depot
	depot:takeWeaponsFromDepot(client,weaponTable)
end

function FactionManager:Event_factionRespawnVehicles()
	client:getFaction():respawnVehicles()
end

function FactionManager:sendAllToClient(client)
	local vehicleTab = {}
	for i, faction in pairs(self:getAllFactions()) do
		if faction:isStateFaction() or faction:isRescueFaction() then
			for i, v in pairs(faction.m_Vehicles) do
				if not factionVehicleShaders[faction:getId()] or not factionVehicleShaders[faction:getId()][v:getModel()] then
					--outputDebug(("[%s] ShaderInfo for Vehicle Model %d not found!"):format(faction:getName(), v:getModel()))
				else
					local shaderInfo = factionVehicleShaders[faction:getId()][v:getModel()]
					if shaderInfo.shaderEnabled then
						vehicleTab[#vehicleTab+1] = {vehicle = v, textureName = shaderInfo.textureName, texturePath = shaderInfo.texturePath}
					end
				end
			end
		end
	end

	triggerClientEvent(client, "changeElementTexture", client, vehicleTab)
end

function FactionManager:Event_getFactions()
	for id, faction in pairs(FactionManager.Map) do
		client:triggerEvent("loadClientFaction", faction:getId(), faction:getName(), faction:getShortName(), faction:getRankNames(), faction:getType(), faction:getColor())
	end
end
