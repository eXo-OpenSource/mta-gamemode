-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
MovementRecorder = inherit(Singleton)

function MovementRecorder:constructor(mapID)
	self.m_MapID = mapID
end

function MovementRecorder:destructor()
end

function MovementRecorder:getRecord(playerID)
	local result = sql:asyncQueryFetchSingle("SELECT Data FROM ??_ghostdriver WHERE MapID = ? AND PlayerID = ?", sql:getPrefix(), self.m_MapID, playerID)
	return result and result.Data or false
end

function MovementRecorder:saveRecord(player, data)
	local result = sql:queryFetchSingle("SELECT Data FROM ??_ghostdriver WHERE MapID = ? AND PlayerID = ?", sql:getPrefix(), self.m_MapID, player:getId())
	if result then
		sql:queryExec("UPDATE ??_ghostdriver SET Data = ? WHERE MapID = ? AND PlayerID = ?", sql:getPrefix(), data, self.m_MapID, player:getId())
	else
		sql:queryExec("INSERT INTO ??_ghostdriver (MapID, PlayerID, Data) VALUES (?, ?, ?)", sql:getPrefix(), self.m_MapID, player:getId(), data)
	end
end
