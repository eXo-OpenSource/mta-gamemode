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
