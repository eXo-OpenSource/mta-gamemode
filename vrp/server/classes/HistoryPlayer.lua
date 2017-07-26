-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HistoryPlayer.lua
-- *  PURPOSE:     History Player Class
-- *
-- ****************************************************************************
HistoryPlayer = inherit(Singleton)


function HistoryPlayer:constructor()
    addRemoteEvents{"historyPlayerRequest", "historySearchPlayer"}
	addEventHandler("historySearchPlayer", root, bind(self.Event_SearchPlayerHistory, self))
	addEventHandler("historyPlayerRequest", root, bind(self.Event_PlayerHistory, self))
end

function HistoryPlayer:destructor()

end

function HistoryPlayer:addLeaveEntry(playerId, uninviterId, elementId, elementType, uninviteRank, internal, external)
    local result = sql:queryFetch("SELECT * FROM ??_player_history WHERE UserId = ? AND ElementId = ? AND ElementType = ?;", sql:getPrefix(), playerId, elementId, elementType)
	
    if not result or #result == 0 then
        sql:queryExec("INSERT INTO ??_player_history (UserId, UninviterId, ElementId, ElementType, UninviteRank, HighestRank, InternalReason, ExternalReason, JoinDate, LeaveDate, InviterId) VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), 0)",
            sql:getPrefix(), playerId, uninviterId, elementId, elementType, uninviteRank, uninviteRank, internal, external)
    else
        sql:queryExec("UPDATE ??_player_history SET LeaveDate = NOW(), InternalReason = ?, ExternalReason = ?, UninviterId = ?, UninviteRank = ? WHERE UserId = ? AND ElementId = ? AND ElementType = ? AND LeaveDate IS NULL ORDER BY Id DESC",
            sql:getPrefix(), internal, external, uninviterId, uninviteRank, playerId, elementId, elementType)
    end
end

function HistoryPlayer:addJoinEntry(playerId, inviterId, elementId, elementType)
	sql:queryExec("INSERT INTO ??_player_history (UserId, InviterId, ElementId, ElementType, JoinDate) VALUES (?, ?, ?, ?, NOW())",
        sql:getPrefix(), playerId, inviterId, elementId, elementType)
end

function HistoryPlayer:setHighestRank(playerId, rank, elementId, elementType)
    local result = sql:queryFetch("SELECT * FROM ??_player_history WHERE UserId = ? AND ElementId = ? AND ElementType = ?;", sql:getPrefix(), playerId, elementId, elementType)

    if not result or #result == 0 then
        sql:queryExec("INSERT INTO ??_player_history (UserId, ElementId, ElementType, HighestRank, JoinDate, InviterId) VALUES (?, ?, ?, ?, NOW(), 0)",
            sql:getPrefix(), playerId, elementId, elementType, rank)
    else
        if rank > result[1].HighestRank then
            sql:queryExec("UPDATE ??_player_history SET HighestRank = ? WHERE UserId = ? AND ElementId = ? AND ElementType = ? AND LeaveDate IS NULL ORDER BY Id DESC",
                sql:getPrefix(), rank, playerId, elementId, elementType)
        end
    end
end

function HistoryPlayer:Event_SearchPlayerHistory(name)
	local faction = client:getFaction()
	local company = client:getCompany()
	if not name then return end

    if not ( (faction and faction:getPlayerRank(client) > FactionRank.Manager) or (company and company:getPlayerRank(client) > FactionRank.Manager) or (client:getRank() >= RANK.Supporter) ) then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end

	if not client.m_LastFileRequest or client.m_LastFileRequest > getTickCount() - 500 then
        local resultPlayers = {}
        local result = sql:queryFetch("SELECT Id, Name FROM ??_account WHERE Name LIKE ?;", sql:getPrefix(), ("%%%s%%"):format(name))
        for i, row in pairs(result) do
            resultPlayers[row.Id] = row.Name
        end
        client:triggerEvent("historyReceiveSearchedPlayers", resultPlayers)
	else
		client:sendError(_("Bitte versuchen sie es erneut!", client))
	end
end


function HistoryPlayer:Event_PlayerHistory(userId)
	local faction = client:getFaction()
	local company = client:getCompany()
	if not userId then return end

	if not ( (faction and faction:getPlayerRank(client) > FactionRank.Manager) or (company and company:getPlayerRank(client) > FactionRank.Manager) or (client:getRank() >= RANK.Supporter) ) then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end

	if not client.m_LastFileRequest or client.m_LastFileRequest > getTickCount() - 500 then
        local playerFile = {}
        local result = sql:queryFetch("SELECT Id, InviterId, HighestRank, UninviteRank, UninviterId, ElementType, ElementId, DATE_FORMAT(JoinDate, '%d.%m.%Y') AS JoinDate, DATE_FORMAT(LeaveDate, '%d.%m.%Y') AS LeaveDate, InternalReason, ExternalReason FROM ??_player_history WHERE UserId = ?;", sql:getPrefix(), userId)
        for i, row in pairs(result) do

            playerFile[row.Id] = {
				ElementType = row.ElementType,
                ElementId = row.ElementId,
				JoinDate = row.JoinDate and row.JoinDate or "",
				LeaveDate = row.LeaveDate and row.LeaveDate or "",
				ExternalReason = row.ExternalReason and row.ExternalReason or "",
				HighestRank = row.HighestRank and row.HighestRank or 0,
				UninviteRank = row.UninviteRank and row.UninviteRank or 0
			}
           
            if row.InviterId == 0 then
                playerFile[row.Id].Inviter = "keinem"
            else
                playerFile[row.Id].Inviter = Account.getNameFromId(row.InviterId)
            end
           
            if row.UninviterId == 0 then
                playerFile[row.Id].Uninviter = "keinem"
            else
                playerFile[row.Id].Uninviter = Account.getNameFromId(row.UninviterId)
            end

            if row.ElementType == "faction" then
                playerFile[row.Id].ElementName = FactionManager:getSingleton().Map[row.ElementId].m_Name_Short -- This will break!! I'm sure!
            elseif row.ElementType == "company" then
                playerFile[row.Id].ElementName = CompanyManager:getSingleton().Map[row.ElementId].m_Name_Short -- This will break!! I'm sure!
            end

			if (faction and row.ElementType == "faction" and faction.m_Id == row.ElementId) or (company and row.ElementType == "company" and company.m_Id == row.ElementId) or (client:getRank() >= RANK.Supporter) then
				playerFile[row.Id].InternalReason = row.InternalReason
			end
        end
        
        client:triggerEvent("historyPlayerReceived", playerFile)
	else
		client:sendError(_("Bitte versuchen sie es erneut!", client))
	end
end



--[[
DROP TABLE vrp_player_history;
CREATE TABLE vrp_player_history
(
    Id INT PRIMARY KEY AUTO_INCREMENT,
    UserId INT,
    InviterId INT DEFAULT 0,
    UninviterId INT DEFAULT 0,
    ElementType VARCHAR(12),
    ElementId INT,
    InternalReason VARCHAR(128),
    ExternalReason VARCHAR(128),
    HighestRank INT(1) DEFAULT 0,
    UninviteRank INT(1) DEFAULT 0,
    JoinDate DATE,
    LeaveDate DATE
);
]]