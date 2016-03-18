-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/StatisticsLogger.lua
-- *  PURPOSE:     Logs statistics/debug stuff to the database (helps us to find money lacks, balancing, etc.)
-- *
-- ****************************************************************************
StatisticsLogger = inherit(Singleton)

function StatisticsLogger:logMoney(player, amount, desc)
    if DEBUG then
        sql:queryExec("INSERT INTO ??_stats_money (UserId, Amount, Description, Date) VALUES(?, ?, ?, NOW())", sql:getPrefix(), player:getId(), amount, desc or "")
    end
end

function StatisticsLogger:addLog(player, groupType, group, category, desc)
    local userId = 0
    local groupId = 0
    if isElement(player) then userId = player:getId() end
    if group then groupId = group:getId() end
    sql:queryExec("INSERT INTO ??_logs (UserId, GroupType, GroupId, Category, Description, Timestamp) VALUES(?, ?, ?, ?, ?, ?)",
        sql:getPrefix(), userId, groupType, groupId, category, desc, getRealTime().timestamp)
end
