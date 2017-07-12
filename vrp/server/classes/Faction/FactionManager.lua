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
	self:loadFactions()

  -- Events
	addRemoteEvents{"getFactions", "factionRequestInfo", "factionRequestLog", "factionQuit", "factionDeposit",	"factionWithdraw", "factionAddPlayer", "factionDeleteMember", "factionInvitationAccept", "factionInvitationDecline",	"factionRankUp", "factionRankDown","factionReceiveWeaponShopInfos","factionWeaponShopBuy","factionSaveRank",	"factionRespawnVehicles", "factionVehicleServiceMarkerPerformAction", "factionRequestDiplomacy", "factionToggleLoan"}

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
	addEventHandler("factionReceiveWeaponShopInfos", root, bind(self.Event_receiveFactionWeaponShopInfos, self))
	addEventHandler("factionWeaponShopBuy", root, bind(self.Event_factionWeaponShopBuy, self))
	addEventHandler("factionSaveRank", root, bind(self.Event_factionSaveRank, self))
	addEventHandler("factionRespawnVehicles", root, bind(self.Event_factionRespawnVehicles, self))
	addEventHandler("factionVehicleServiceMarkerPerformAction", root, bind(self.Event_serviceMarkerPerformAction, self))
	addEventHandler("factionRequestDiplomacy", root, bind(self.Event_requestDiplomacy, self))
	addEventHandler("factionToggleLoan", root, bind(self.Event_ToggleLoan, self))

	FactionState:new()
	FactionRescue:new()
	FactionEvil:new(self.EvilFactions)

	self.m_ServiceMarkerErrorTexts = { --valid faction types for vehicle service markers
		["State"] = {"Nur für Fahrzeuge des Staates!", "Nur für Staatsfraktionisten im Dienst!"},
		["Rescue"] = {"Nur für Fahrzeuge des Medical Centers!", "Nur für Mitglieder des Rettungsdienstes im Dienst!"},
	}
end

function FactionManager:destructor()
	for k, v in pairs(FactionManager.Map) do
		delete(v)
	end
end

function FactionManager:loadFactions()
  	local st, count = getTickCount(), 0
  	local result = sql:queryFetch("SELECT * FROM ??_factions WHERE active = 1", sql:getPrefix())
  	for k, row in pairs(result) do
		local result2 = sql:queryFetch("SELECT Id, FactionRank, FactionLoanEnabled FROM ??_character WHERE FactionID = ?", sql:getPrefix(), row.Id)
		local players, playerLoans = {}, {}
		for i, factionRow in ipairs(result2) do
			players[factionRow.Id] = factionRow.FactionRank
			playerLoans[factionRow.Id] = factionRow.FactionLoanEnabled
		end

		local instance = Faction:new(row.Id, row.Name_Short, row.Name, row.BankAccount, {players, playerLoans}, row.RankLoans, row.RankSkins, row.RankWeapons, row.Depot, row.Type, row.Diplomacy)
		FactionManager.Map[row.Id] = instance
		count = count + 1
	end

  	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s factions in %sms"):format(count, getTickCount()-st)) end
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
		client:triggerEvent("factionRetrieveInfo", faction:getId(), faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers(), faction.m_Skins, faction.m_RankNames, faction.m_RankLoans, faction.m_RankSkins, faction.m_ValidWeapons, faction.m_RankWeapons, ActionsCheck:getSingleton():getStatus())
	else
		client:triggerEvent("factionRetrieveInfo")
	end
end

function FactionManager:Event_factionQuit()
	local faction = client:getFaction()
	if not faction then return end

	if faction:getPlayerRank(client) == FactionRank.Leader then
		client:sendWarning(_("Als Leader kannst du nicht die Fraktion verlassen!", client))
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
	if not amount then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	client:takeMoney(amount, "Fraktion-Einlage")
	faction:giveMoney(amount, "Fraktion-Einlage")
	faction:addLog(client, "Kasse", "hat "..amount.."$ in die Kasse gelegt!")
	self:sendInfosToClient(client)
	faction:refreshBankAccountGUI(client)
end

function FactionManager:Event_factionWithdraw(amount)
	local faction = client:getFaction()
	if not faction then return end
	if not amount then return end

	if faction:getPlayerRank(client) < FactionRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if faction:getMoney() < amount then
		client:sendError(_("In der Fraktionskasse befindet sich nicht genügend Geld!", client))
		return
	end

	faction:takeMoney(amount, "Fraktion-Auslage")
	faction:addLog(client, "Kasse", "hat "..amount.."$ aus der Kasse genommen!")
	client:giveMoney(amount, "Fraktion-Auslage")
	self:sendInfosToClient(client)
	faction:refreshBankAccountGUI(client)
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
			if faction:isEvilFaction() then
				if player:getKarma() > -FACTION_MIN_RANK_KARMA[0] then
					client:sendError(_("Der Spieler hat zuwenig negatives Karma! (Benötigt: %s)", client, -FACTION_MIN_RANK_KARMA[0]))
					return
				end
			else
				if player:getKarma() < FACTION_MIN_RANK_KARMA[0] then
					client:sendError(_("Der Spieler hat zuwenig positives Karma! (Benötigt: %s)", client, FACTION_MIN_RANK_KARMA[0]))
					return
				end
			end

			faction:invitePlayer(player)
			faction:addLog(client, "Fraktion", "hat den Spieler "..player:getName().." in die Fraktion eingeladen!")
		else
			client:sendError(_("Dieser Benutzer hat bereits eine Einladung!", client))
		end
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
		if not client:getFaction() then
			faction:addPlayer(client)
			faction:addLog(client, "Fraktion", "ist der Fraktion beigetreten!")
			faction:sendMessage(_("#008888Fraktion: #FFFFFF%s ist soeben der Fraktion beigetreten!", client, getPlayerName(client)),200,200,200,true)
			if faction:isEvilFaction() then
				faction:changeSkin(client)
			end
			self:sendInfosToClient(client)
		else
			client:sendError(_("Du bisd bereits einer Fraktion beigetreten!", client))
		end

		faction:removeInvitation(client)
	else
		client:sendError(_("Du hast keine Einladung für diese Fraktion", client))
	end
end

function FactionManager:Event_factionInvitationDecline(factionId)
	local faction = self:getFromId(factionId)
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
	Async.create(
		function (client)
			if not playerId then return end
			local faction = client:getFaction()
			if not faction then return end

			if not faction:isPlayerMember(client) or not faction:isPlayerMember(playerId) then
				return
			end

			if faction:getPlayerRank(client) < FactionRank.Manager then
				client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
				-- Todo: Report possible cheat attempt
				return
			end

			if client:getId() == playerId then
				client:sendError(_("Du kannst deinen eigenen Rang nicht höher setzen!", client))
				return
			end

			local playerRank = faction:getPlayerRank(playerId)
			local player, isOffline = DatabasePlayer.get(playerId)
			if isOffline then
				player:load()
			end
			if faction:isEvilFaction() then
				if player:getKarma() > ( -FACTION_MIN_RANK_KARMA[playerRank + 1] or -100000) and playerRank < FactionRank.Leader then
					client:sendError(_("Der Spieler hat zuwenig negatives Karma! (Benötigt: %s)", client, -FACTION_MIN_RANK_KARMA[playerRank + 1]))
					if isOffline then delete(player) end
					return
				end
			else
				if player:getKarma() < (FACTION_MIN_RANK_KARMA[playerRank + 1] or 10000) and playerRank < FactionRank.Leader then
					client:sendError(_("Der Spieler hat zuwenig positives Karma! (Benötigt: %s)", client, FACTION_MIN_RANK_KARMA[playerRank + 1]))
					if isOffline then delete(player) end
					return
				end
			end

			if playerRank < FactionRank.Leader then
				if playerRank < faction:getPlayerRank(client) then
					faction:setPlayerRank(playerId, playerRank + 1)
					faction:addLog(client, "Fraktion", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..(playerRank + 1).." befördert!")
					if isOffline then
						delete(player)
					else
						if isElement(player) then
							player:sendShortMessage(_("Du wurdest von %s auf Rang %d befördert!", player, client:getName(), faction:getPlayerRank(playerId)), faction:getName())
						end
					end
					self:sendInfosToClient(client)
				else
					client:sendError(_("Mit deinem Rang kannst du Spieler maximal auf Rang %d befördern!", client, faction:getPlayerRank(client)))
				end
			else
				client:sendError(_("Du kannst Spieler nicht höher als auf Rang 6 befördern!", client))
				if isOffline then delete(player) end
			end
		end
	)(client)
end

function FactionManager:Event_factionRankDown(playerId)
	Async.create(
		function(client)
			if not playerId then return end
			local faction = client:getFaction()
			if not faction then return end

			if not faction:isPlayerMember(client) or not faction:isPlayerMember(playerId) then
				client:sendError(_("Du oder das Ziel sind nicht mehr in der Fraktion!", client))
				return
			end

			if faction:getPlayerRank(client) < FactionRank.Manager then
				client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
				-- Todo: Report possible cheat attempt
				return
			end
			local player, isOffline = DatabasePlayer.get(playerId)
			if isOffline then
				player:load()
			end
			if faction:getPlayerRank(playerId)-1 >= FactionRank.Normal then
				if faction:getPlayerRank(playerId) <= faction:getPlayerRank(client) then
					faction:setPlayerRank(playerId, faction:getPlayerRank(playerId) - 1)
					faction:addLog(client, "Fraktion", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..faction:getPlayerRank(playerId).." degradiert!")
					if isOffline then
						delete(player)
					else
						if isElement(player) then
							player:sendShortMessage(_("Du wurdest von %s auf Rang %d degradiert!", player, client:getName(), faction:getPlayerRank(playerId)), faction:getName())
						end
					end
					self:sendInfosToClient(client)
				else
					client:sendError(_("Du kannst ranghöhere Mitglieder nicht degradieren!", client))
				end
			else
				client:sendError(_("Du kannst Spieler nicht niedriger als auf Rang 0 setzen!", client))
				if isOffline then delete(player) end
			end
		end
	)(client)
end

function FactionManager:Event_receiveFactionWeaponShopInfos()
	local faction = client:getFaction()
	local depot = faction.m_Depot
	local playerId = client:getId()
	local rank = faction.m_Players[playerId]
	triggerClientEvent(client,"updateFactionWeaponShopGUI",client,faction.m_ValidWeapons, faction.m_WeaponDepotInfo, depot:getWeaponTable(id), faction:getRankWeapons(rank))
end

function FactionManager:Event_factionWeaponShopBuy(weaponTable)
	if not client.m_WeaponStoragePosition then return outputDebug("no weapon storage position for this faction implemented") end
	if getDistanceBetweenPoints3D(client.position, client.m_WeaponStoragePosition) <= 10 then
		local faction = client:getFaction()
		local depot = faction.m_Depot
		depot:takeWeaponsFromDepot(client,weaponTable)
	else
		client:sendError(_("Du bist zu weit entfernt", client))
	end
end

function FactionManager:Event_factionRespawnVehicles()
	if client:getFaction() then
		local faction = client:getFaction()

		if faction:getPlayerRank(client) >= FactionRank.Rank4 or (faction:getPlayerRank(client) >= FactionRank.Rank3 and faction:getId() == 3) then
			faction:respawnVehicles()
		else
			client:sendError(_("Die Fahrzeuge können erst ab Rang %d respawnt werden!", client, FactionRank.Manager))
		end
	end
end

function FactionManager:Event_getFactions()
	for id, faction in pairs(FactionManager.Map) do
		client:triggerEvent("loadClientFaction", faction:getId(), faction:getName(), faction:getShortName(), faction:getRankNames(), faction:getType(), faction:getColor())
	end
end

function FactionManager:checkPermissionForVehicleServiceMarker(player, type)
	if player.vehicle and player.vehicleSeat == 0 then
		if player:getFaction() and player:getFaction():getType() == type and player:isFactionDuty() then
			if player.vehicle:getFaction() and player.vehicle:getFaction():getType() == type then
				return true
			else
				player:sendError(_(self.m_ServiceMarkerErrorTexts[type][1], player))
			end
		else
			player:sendError(_(self.m_ServiceMarkerErrorTexts[type][2], player))
		end
	end
	return false
end

function FactionManager:createVehicleServiceMarker(type, pos, size)
	if not self.m_ServiceMarkerErrorTexts[type] then return outputDebug("invalid faction type") end
	local marker = createMarker(pos, "cylinder", size or 2, 255, 255, 0, 170)
	addEventHandler("onMarkerHit", marker ,
		function(hitElement, dim)
			if hitElement:getType() == "player" and dim then
				if self:checkPermissionForVehicleServiceMarker(hitElement, type) then
					hitElement.factionVehicleServiceMarker = source
					hitElement.vehicle:toggleHandBrake(hitElement, true)
					hitElement:triggerEvent("showFactionVehicleServiceGUI")
				end
			end
		end
	)
end

function FactionManager:Event_serviceMarkerPerformAction(type)
	if client.factionVehicleServiceMarker and getDistanceBetweenPoints3D(client:getPosition(), client.factionVehicleServiceMarker:getPosition()) <= 3 then
		local costs
		if type == "fill" then
			costs = math.floor((100-client.vehicle:getFuel())*5)
			if costs == 0 then client:sendInfo(_("Dein Fahrzeugtank ist noch voll.", client)) end
			client.vehicle:setFuel(100)
			client:getFaction():takeMoney(costs, "Fahrzeug-Betankung")
		elseif type == "repair" then
			costs = math.floor((1000-client.vehicle:getHealth()))
			if costs == 0 then client:sendInfo(_("Dein Fahrzeug benötigt keine Reparaturen.", client)) end
			client.vehicle:fix()
			client:getFaction():takeMoney(costs, "Fahrzeug-Reparatur")
		end
		client.vehicle:toggleHandBrake(client, false)
	else
		client:sendError(_("Du bist zu weit entfernt!", client))
	end
end

function FactionManager:Event_requestDiplomacy(factionId)
	local faction = self:getFromId(factionId)
	if faction and faction.m_Diplomacy then
		client:triggerEvent("factionRetrieveDiplomacy", factionId, faction.m_Diplomacy)
	else
		client:sendError("Internal Error: Invalid Faction")
	end
end

function FactionManager:Event_ToggleLoan(playerId)
	outputChatBox("toggle faction lol")
end
