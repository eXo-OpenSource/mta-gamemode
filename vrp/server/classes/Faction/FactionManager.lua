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
  outputServerLog("Loading factions...")
	local result = sql:queryFetch("SELECT Id, Name, Name_Short, Money FROM ??_factions", sql:getPrefix())
	for k, row in ipairs(result) do
		local result2 = sql:queryFetch("SELECT Id, FactionRank FROM ??_character WHERE FactionID = ?", sql:getPrefix(), row.Id)
		local players = {}
		for i, factionRow in ipairs(result2) do
			players[factionRow.Id] = factionRow.FactionRank
		end
		--self.m_Factions = {
		local faction =	Faction:new(row.Id, row.Name_Short, row.Name, row.Money, players)
		FactionManager.Map[row.Id] = faction
		--}
	end
  
-- Events
	addRemoteEvents{"factionRequestInfo", "factionQuit", "factionDeposit", "factionWithdraw",
		"factionAddPlayer", "factionDeleteMember", "factionInvitationAccept", "factionInvitationDecline", "factionRankUp", "factionRankDown"}
	addEventHandler("factionRequestInfo", root, bind(self.Event_factionRequestInfo, self))
	addEventHandler("factionQuit", root, bind(self.Event_factionQuit, self))
	addEventHandler("factionDeposit", root, bind(self.Event_factionDeposit, self))
	addEventHandler("factionWithdraw", root, bind(self.Event_factionWithdraw, self))
	addEventHandler("factionAddPlayer", root, bind(self.Event_factionAddPlayer, self))
	addEventHandler("factionDeleteMember", root, bind(self.Event_factionDeleteMember, self))
	addEventHandler("factionInvitationAccept", root, bind(self.Event_factionInvitationAccept, self))
	addEventHandler("factionInvitationDecline", root, bind(self.Event_factionInvitationDecline, self))
	addEventHandler("factionRankUp", root, bind(self.Event_factionRankUp, self))
	addEventHandler("factionRankDown", root, bind(self.Event_factionRankDown, self))
end

function FactionManager:destructor()
	for k, v in pairs(FactionManager.Map) do
		delete(v)
	end
end

function FactionManager:getFromId(Id)
	return FactionManager.Map[Id]
end

function FactionManager:Event_factionRequestInfo()
	local faction = client:getFaction()

	if faction then
		client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
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
	client:triggerEvent("factionRetrieveInfo")
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
	client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
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
	client:giveMoney(amount)
	client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
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

	faction:removePlayer(playerId)
		client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
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
		faction:sendMessage(_("%s ist soeben der Fraktion beigetreten", client, getPlayerName(client)))
		client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
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
		client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
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
		client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
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
		client:triggerEvent("factionRetrieveInfo", faction:getId(),faction:getName(), faction:getPlayerRank(client), faction:getMoney(), faction:getPlayers())
	end
end