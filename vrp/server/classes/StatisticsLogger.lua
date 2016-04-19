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

function StatisticsLogger:addGroupLog(player, groupType, group, category, desc)
    local userId = 0
    local groupId = 0
    if isElement(player) then userId = player:getId() end
    if group then groupId = group:getId() end
    sql:queryExec("INSERT INTO ??_logsGroups (UserId, GroupType, GroupId, Category, Description, Timestamp) VALUES(?, ?, ?, ?, ?, ?)",
        sql:getPrefix(), userId, groupType, groupId, category, desc, getRealTime().timestamp)
end

function StatisticsLogger:getGroupLogs(groupType, groupId)
    local result = sql:queryFetch("SELECT * FROM ??_logsGroups WHERE GroupType = ? AND GroupId = ? ORDER BY Id DESC", sql:getPrefix(), groupType, groupId)
    return result
end

function StatisticsLogger:addPunishLog(admin, player, type, reason, duration)
    local userId = 0
    local adminId = 0
    if isElement(admin) then adminId = admin:getId() end
    if isElement(player) then userId = player:getId() end

    sql:queryExec("INSERT INTO ??_logsPunish (UserId, AdminId, Type, Reason, Duration, Timestamp) VALUES(?, ?, ?, ?, ?, ?)",
        sql:getPrefix(), userId, adminId, type, reason, duration, getRealTime().timestamp)
end

function StatisticsLogger:getPunishLogs(userId)
    if userId then
        local result = sql:queryFetch("SELECT * FROM ??_logsPunish WHERE UserId = ? ORDER BY Id DESC", sql:getPrefix(), userId)
    else
        local result = sql:queryFetch("SELECT * FROM ??_logsPunish WHERE ORDER BY Id DESC", sql:getPrefix())
    end
    return result
end
