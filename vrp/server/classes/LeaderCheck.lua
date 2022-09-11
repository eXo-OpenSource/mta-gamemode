-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/LeaderCheck.lua
-- *  PURPOSE:     LeaderCheck class
-- *
-- ****************************************************************************
LeaderCheck = inherit(Singleton)

addRemoteEvents{"adminEditLeaderBans", "adminRequestLeaderBans"}
function LeaderCheck:constructor()
    self.m_LeaderBans = {}
    self:loadLeaderBans() 

    addEventHandler("adminEditLeaderBans", root, bind(self.Event_editLeaderBans, self))
    addEventHandler("adminRequestLeaderBans", root, bind(self.requestLeaderBans, self))
end

function LeaderCheck:loadLeaderBans()
	local result = sql:queryFetch("SELECT * FROM ??_leader_bans", sql:getPrefix())
	for i, data in pairs(result) do
        if data["ValidUntil"] > getRealTime().timestamp or data["ValidUntil"] == 0 then
		    self.m_LeaderBans[data["PlayerId"]] = {validUntil = data["ValidUntil"], reason = data["Reason"], admins = fromJSON(data["Admins"]), createdAt = data["CreatedAt"]}
        else
            sql:queryExec("DELETE FROM ??_leader_bans WHERE PlayerId = ? AND ValidUntil = ?", sql:getPrefix(), data["PlayerId"], data["ValidUntil"])
        end
    end
end

function LeaderCheck:hasPlayerLeaderBan(player)
	playerId = false
	if type(player) == "number" then playerId = player end
	if isElement(player) then playerId = player:getId() end
	if not playerId then return end


	if self.m_LeaderBans[tonumber(playerId)] then
		if self.m_LeaderBans[tonumber(playerId)].validUntil > getRealTime().timestamp or self.m_LeaderBans[tonumber(playerId)].validUntil == 0 then
			return true
		end
	end
	return false
end

function LeaderCheck:Event_editLeaderBans(type, player, pReason, pValidUntil, pAdmins)
    if client:getRank() >= RANK.Administrator then
        local playerId
        if isElement(player) then playerId = player:getId() else playerId = Account.getIdFromName(player) end
        if not playerId then return client:sendError(_("Spieler konnte nicht gefunden werden (Überprüfe den Namen).", client)) end 

        if type == "add" then
            if not self.m_LeaderBans[tonumber(playerId)] then
                if pValidUntil == 0 or pValidUntil - getRealTime().timestamp > 0 then
                    local nameTable = split(pAdmins, ",")
                    for i, v in pairs(nameTable) do
                        if Account.getIdFromName(v) then 
                            nameTable[i] = Account.getIdFromName(v)
                        else
                            return client:sendError("Fehler bei eingetragenen Admins (Überprüfe die Namen).")
                        end
                    end

                    local result = sql:queryExec("INSERT INTO ??_leader_bans (PlayerId, AdminId, Admins, CreatedAt, ValidUntil, Reason) VALUES (?, ?, ?, ?, ?, ?)", sql:getPrefix(), playerId, client:getId(), toJSON(nameTable), getRealTime().timestamp, pValidUntil, pReason)
                    if result then  
                        self.m_LeaderBans[tonumber(playerId)] = {validUntil = pValidUntil, reason = pReason, admins = nameTable, createdAt = getRealTime().timestamp}
                        Admin:getSingleton():sendShortMessage(_("%s hat %s eine Leadersperre gegeben!", client, client:getName(), Account.getNameFromId(playerId)))
                        StatisticsLogger:getSingleton():addPunishLog(client, playerId, "addLeaderBan", pReason, pValidUntil == 0 and 0 or pValidUntil - getRealTime().timestamp)
                    end
                else
                    client:sendError(_("Fehler bei eingegebener Dauer (Überprüfe den Timestamp).", client))
                end
            else
                client:sendError(_("Der Spieler hat bereits eine Leadersperre!", client))
            end
            
        elseif type == "remove" then
            local result = sql:queryExec("DELETE FROM ??_leader_bans WHERE PlayerId = ?", sql:getPrefix(), playerId)
            if result then
                self.m_LeaderBans[tonumber(playerId)] = nil
                Admin:getSingleton():sendShortMessage(_("%s hat die Leadersperre von %s entfernt!", client, client:getName(), Account.getNameFromId(playerId)))
                StatisticsLogger:getSingleton():addPunishLog(client, playerId, "removeLeaderBan", pReason)
            end
        end
        self:requestLeaderBans(client)
    else
        client:sendError("Nicht berechtigt!")
    end
end 

function LeaderCheck:requestLeaderBans(player)
    if not client then player = client end

    local temp = {}
    local tAdminNames = {}
    for i, v in pairs(self.m_LeaderBans) do
        local player = Account.getNameFromId(i)
        for _, id in pairs(v["admins"]) do
            local admin = Account.getNameFromId(id)
            table.insert(tAdminNames, admin)
        end
        temp[i] = {playerName = player, adminNames = tAdminNames}
        tAdminNames = {}
    end
    client:triggerEvent("adminSendLeaderBansToClient", self.m_LeaderBans, temp)
end