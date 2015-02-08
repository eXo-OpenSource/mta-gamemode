-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupManager.lua
-- *  PURPOSE:     Group manager class
-- *
-- ****************************************************************************
GroupManager = inherit(Singleton)
GroupManager.Map = {}
GroupManager.GroupCosts = 30000

function GroupManager:constructor()
	outputServerLog("Loading groups...")
	local result = sql:queryFetch("SELECT Id, Name, Money FROM ??_groups", sql:getPrefix())
	for k, row in ipairs(result) do
		local result2 = sql:queryFetch("SELECT Id, GroupRank FROM ??_character WHERE GroupId = ?", sql:getPrefix(), row.Id)
		local players = {}
		for i, groupRow in ipairs(result2) do
			players[groupRow.Id] = groupRow.GroupRank
		end
		
		local group = Group:new(row.Id, row.Name, row.Money, players)
		GroupManager.Map[row.Id] = group
	end
	
	-- Events
	addRemoteEvents{"groupRequestInfo", "groupCreate", "groupQuit", "groupDelete", "groupDeposit", "groupWithdraw",
		"groupAddPlayer", "groupDeleteMember", "groupInvitationAccept", "groupInvitationDecline", "groupRankUp", "groupRankDown"}
	addEventHandler("groupRequestInfo", root, bind(self.Event_groupRequestInfo, self))
	addEventHandler("groupCreate", root, bind(self.Event_groupCreate, self))
	addEventHandler("groupQuit", root, bind(self.Event_groupQuit, self))
	addEventHandler("groupDelete", root, bind(self.Event_groupDelete, self))
	addEventHandler("groupDeposit", root, bind(self.Event_groupDeposit, self))
	addEventHandler("groupWithdraw", root, bind(self.Event_groupWithdraw, self))
	addEventHandler("groupAddPlayer", root, bind(self.Event_groupAddPlayer, self))
	addEventHandler("groupDeleteMember", root, bind(self.Event_groupDeleteMember, self))
	addEventHandler("groupInvitationAccept", root, bind(self.Event_groupInvitationAccept, self))
	addEventHandler("groupInvitationDecline", root, bind(self.Event_groupInvitationDecline, self))
	addEventHandler("groupRankUp", root, bind(self.Event_groupRankUp, self))
	addEventHandler("groupRankDown", root, bind(self.Event_groupRankDown, self))
end

function GroupManager:destructor()
	for k, v in pairs(GroupManager.Map) do
		delete(v)
	end
end

function GroupManager:getFromId(Id)
	return GroupManager.Map[Id]
end

function GroupManager:addRef(ref)
	GroupManager.Map[ref:getId()] = ref
end

function GroupManager:removeRef(ref)
	GroupManager.Map[ref:getId()] = nil
end

function GroupManager:getByName(groupName)
	for k, group in pairs(GroupManager.Map) do
		if group:getName() == groupName then
			return group
		end
	end
	return false
end

function GroupManager:Event_groupRequestInfo()
	local group = client:getGroup()
	
	if group then
		client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
	else
		client:triggerEvent("groupRetrieveInfo")
	end
end

function GroupManager:Event_groupCreate(name)
	if client:getMoney() < GroupManager.GroupCosts then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end
	
	-- Does the group already exist?
	if self:getByName(name) then
		client:sendError(_("Eine Gruppe mit diesem Namen existiert bereits!", client))
		return
	end
	
	-- Create the group and the the client as leader (rank 2)
	local group = Group.create(name)
	if group then
		group:addPlayer(client, GroupRank.Leader)
		client:takeMoney(GroupManager.GroupCosts)
		client:sendSuccess(_("Herzlichen Glückwunsch! Du bist nun Leiter der Gruppe %s", client, name))
		client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
	else
		client:sendError(_("Interner Fehler beim Erstellen der Gruppe", client))
	end
end

function GroupManager:Event_groupQuit()
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) == GroupRank.Leader then
		client:sendWarning(_("Bitte übertrage den Leiter-Status erst auf ein anderes Mitglied der Gruppe!", client))
		return
	end
	group:removePlayer(client)
	client:sendSuccess(_("Du hast die Gruppe erfolgreich verlassen!", client))
	client:triggerEvent("groupRetrieveInfo")
end

function GroupManager:Event_groupDelete()
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) ~= GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt die Gruppe zu löschen!", client))
		-- Todo: Report possible cheat attempt
		return
    end

    local leaderAmount = group.m_Money/2
    group.m_Money = group.m_Money - leaderAmount

    local memberAmount = 0
    local groupSize = table.size(group.m_Players)
    if groupSize == 1 then
        leaderAmount = leaderAmount + group.m_Money
    else
        memberAmount = group.m_Money/(#groupSize-1)
    end

	-- Distribute group's money
    for playerId, playerRank in pairs(group.m_Players) do
        local player, isOffline = DatabasePlayer.get(playerId)
        if playerRank == GroupRank.Leader then
            player:giveMoney(leaderAmount)
        else
            player:giveMoney(memberAmount)
        end

        if isOffline then
            delete(player)
        end
    end
	
	group:purge()
	client:sendShortMessage(_("Deine Gruppe wurde soeben gelöscht", client))
	client:triggerEvent("groupRetrieveInfo")
end

function GroupManager:Event_groupDeposit(amount)
	local group = client:getGroup()
	if not group then return end
	
	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end
	
	client:takeMoney(amount)
	group:giveMoney(amount)
	client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
end

function GroupManager:Event_groupWithdraw(amount)
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end
	
	if group:getMoney() < amount then
		client:sendError(_("In der Gruppenkasse befindet sich nicht genügend Geld!", client))
		return
	end
	
	group:takeMoney(amount)
	client:giveMoney(amount)
	client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
end

function GroupManager:Event_groupAddPlayer(player)
	if not player then return end
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Gruppenmitglieder hinzuzufügen!", client))
		-- Todo: Report possible cheat attempt
		return
	end
	
	if not group:isPlayerMember(player) then
		if not group:hasInvitation(player) then
			group:invitePlayer(player)
		else
			client:sendError(_("Dieser Benutzer hat bereits eine Einladung!"), client)
		end
		--group:addPlayer(player)
		--client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
	else
		client:sendError(_("Dieser Spieler ist bereits in der Gruppe!", client))
	end
end

function GroupManager:Event_groupDeleteMember(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end
	
	if group:getPlayerRank(playerId) == GroupRank.Leader then
		client:sendError(_("Du kannst den Gruppenleiter nicht rauswerfen!", client))
		return
	end
	
	group:removePlayer(playerId)
	client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
end

function GroupManager:Event_groupInvitationAccept(groupId)
	local group = self:getFromId(groupId)
	if not group then return end
	
	if group:hasInvitation(client) then
		group:addPlayer(client)
		group:removeInvitation(client)
		group:sendMessage(_("%s ist soeben der Gruppe beigetreten", client, getPlayerName(client)))
	else
		client:sendError(_("Du hast keine Einladung für diese Gruppe", client))
	end
end

function GroupManager:Event_groupInvitationDecline(groupId)
	local group = self:getFromId(groupId)
	if not group then return end
	
	if group:hasInvitation(client) then
		group:removeInvitation(client)
		group:sendMessage(_("%s hat die Gruppeneinladung abgelehnt", client, getPlayerName(client)))
	else
		client:sendError(_("Du hast keine Einladung für diese Gruppe", client))
	end
end

function GroupManager:Event_groupRankUp(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) < GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end
	
	if group:getPlayerRank(playerId) < GroupRank.Manager then
		group:setPlayerRank(playerId, group:getPlayerRank(playerId) + 1)
		client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
	else
		client:sendError(_("Du kannst Spieler nicht höher als auf Rang 'Manager' setzen!", client))
	end
end

function GroupManager:Event_groupRankDown(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) < GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end
	
	if group:getPlayerRank(playerId) == GroupRank.Manager then
		group:setPlayerRank(playerId, group:getPlayerRank(playerId) - 1)
		client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
	end
end
