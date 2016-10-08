-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/StatisticsLogger.lua
-- *  PURPOSE:     Logs statistics/debug stuff to the database (helps us to find money lacks, balancing, etc.)
-- *
-- ****************************************************************************
StatisticsLogger = inherit(Singleton)

function StatisticsLogger:constructor()
	if not getResourceFromName("vrp_data") then createResource("vrp_data") end
    if not getResourceState(getResourceFromName("vrp_data")) == "running" then startResource(getResourceFromName("vrp_data")) end
	self.m_TextLogPath = ":vrp_data/logs/"
end

function StatisticsLogger:getZone(player)
	return 	("%s - %s"):format(player:getZoneName(), player:getZoneName(true))
end

function StatisticsLogger:addMoneyLog(type, element, money, reason)
    local elementId = 0
    if element then elementId = element:getId() end
    sqlLogs:queryExec("INSERT INTO ??_Money (ElementType, ElementId, Money, Reason, Timestamp) VALUES(?, ?, ?, ?, ?)",
        sqlLogs:getPrefix(), type, elementId, money, reason, getRealTime().timestamp)
end

function StatisticsLogger:addGroupLog(player, groupType, group, category, desc)
    local userId = 0
    local groupId = 0
    if isElement(player) then userId = player:getId() end
    if group then groupId = group:getId() end
    sqlLogs:queryExec("INSERT INTO ??_Groups (UserId, GroupType, GroupId, Category, Description, Timestamp) VALUES(?, ?, ?, ?, ?, ?)",
        sqlLogs:getPrefix(), userId, groupType, groupId, category, desc, getRealTime().timestamp)
end

function StatisticsLogger:getGroupLogs(groupType, groupId)
    local result = sqlLogs:queryFetch("SELECT * FROM ??_Groups WHERE GroupType = ? AND GroupId = ? ORDER BY Id DESC", sqlLogs:getPrefix(), groupType, groupId)
    return result
end

function StatisticsLogger:addPunishLog(admin, player, type, reason, duration)
    local userId = player
    local adminId = 0
    if isElement(admin) then adminId = admin:getId() end
    if isElement(player) then userId = player:getId() end

    sqlLogs:queryExec("INSERT INTO ??_Punish (UserId, AdminId, Type, Reason, Duration, Date) VALUES(?, ?, ?, ?, ?, now())",
        sqlLogs:getPrefix(), userId, adminId, type, reason, duration)
end

function StatisticsLogger:getPunishLogs(userId)
    if userId then
        local result = sqlLogs:queryFetch("SELECT * FROM ??_logsPunish WHERE UserId = ? ORDER BY Id DESC", sqlLogs:getPrefix(), userId)
    else
        local result = sqlLogs:queryFetch("SELECT * FROM ??_logsPunish WHERE ORDER BY Id DESC", sqlLogs:getPrefix())
    end
    return result
end

function StatisticsLogger:addChatLog(player, type, text, heared)
    if isElement(player) then userId = player:getId() end

    sqlLogs:queryExec("INSERT INTO ??_Chat (UserId, Type, Text, Heared, Position, Date) VALUES (?, ?, ?, ?, ?, Now())",
        sqlLogs:getPrefix(), userId, type, text, heared, self:getZone(player))
end

function StatisticsLogger:addKillLog(player, target, weapon)
    if isElement(player) then userId = player:getId() else userId = player end
	if isElement(target) then targetId = target:getId() else targetId = target end
	local range = getDistanceBetweenPoints3D(player:getPosition(), target:getPosition())
    sqlLogs:queryExec("INSERT INTO ??_Kills (UserId, TargetId, Weapon, RangeBetween, Position, Date) VALUES (?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, targetId, weapon, range, self:getZone(target))
end

function StatisticsLogger:addHealLog(player, heal, reason)
	if isElement(player) then userId = player:getId() else userId = player end
    sqlLogs:queryExec("INSERT INTO ??_Heal (UserId, Heal, Reason, Position, Date) VALUES (?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, heal, reason, self:getZone(player))
end

function StatisticsLogger:addActionLog(action, type, player, group, groupType)
	if isElement(player) then userId = player:getId() else userId = player or 0 end
    if group then groupId = group:getId() end
    sqlLogs:queryExec("INSERT INTO ??_Actions (Action, UserId, Group, GroupType, Type, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), action, userId, group, groupType, type)
end

function StatisticsLogger:addArrestLog(player, wanteds, duration, policeMan, bail)
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	if isElement(policeMan) then policeId = policeMan:getId() else policeId = policeMan or 0 end
	sqlLogs:queryExec("INSERT INTO ??_Arrest (UserId, Wanteds, Duration, PoliceId, Bail, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, wanteds, duration, policeId, bail)
end

function StatisticsLogger:addAmmunationLog(player, type, weapons, costs)
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_Ammunation (UserId, Type, Weapons, Costs, Position, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, type, weapons, costs, self:getZone(player))
end

function StatisticsLogger:addTextLog(logname, text)
	local filePath = self.m_TextLogPath..logname..".log"

	if not fileExists(filePath) then
		fileClose(fileCreate(filePath))
	end

	local file = fileOpen(filePath, false)
	fileSetPos(file, fileGetSize(file))
	fileWrite(file, getOpticalTimestamp()..": "..text.."\n" )
	fileClose(file)
end
