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

	self.m_Gamestats = {}
	self:loadGameStats()
	--addEventHandler("onDebugMessage", getRootElement(), bind(self.onDebugMessageLog, self)) MTA:Bug - only outputDebugString is working, no MTA Errors/Warnings
end

function StatisticsLogger:destructor()
	self:saveGameStats()
end

function StatisticsLogger:getZone(player)
	return 	("%s - %s"):format(player:getZoneName(), player:getZoneName(true))
end

function StatisticsLogger:addMoneyLog(type, element, money, reason, bankaccount)
    local elementId = 0
    if element then elementId = element:getId() end
    if sqlLogs:queryExec("INSERT INTO ??_Money (ElementType, ElementId, Money, Reason, BankAccount, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), type, elementId, money, reason, bankaccount or 0) then
		return true
	end
	return false
end

function StatisticsLogger:addGroupLog(player, groupType, group, category, desc)
    local userId = 0
    local groupId = 0
    if isElement(player) then userId = player:getId() end
    if group then groupId = group:getId() end
    sqlLogs:queryExec("INSERT INTO ??_Groups (UserId, GroupType, GroupId, Category, Description, Timestamp, Date) VALUES(?, ?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, groupType, groupId, category, desc, getRealTime().timestamp)
end

function StatisticsLogger:getGroupLogs(groupType, groupId)
    local days = 7
	local since = getRealTime().timestamp-days*24*60*60
	local result = sqlLogs:queryFetch("SELECT * FROM ??_Groups WHERE GroupType = ? AND GroupId = ? AND Timestamp > ? ORDER BY Id DESC", sqlLogs:getPrefix(), groupType, groupId, since)
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

function StatisticsLogger:addChatLog(player, type, text, heared)
	local userId = 0
    if isElement(player) then userId = player:getId() end

    sqlLogs:queryExec("INSERT INTO ??_Chat (UserId, Type, Text, Heared, Position, Date) VALUES (?, ?, ?, ?, ?, Now())",
        sqlLogs:getPrefix(), userId, type, text, heared, self:getZone(player))
end

function StatisticsLogger:addJobLog(player, job, duration, earned)
	local userId = 0
    if isElement(player) then userId = player:getId() end

    sqlLogs:queryExec("INSERT INTO ??_Job (UserId, Job, Duration, Earned, Date) VALUES (?, ?, ?, ?, Now())",
        sqlLogs:getPrefix(), userId, job, duration, earned)
end

function StatisticsLogger:addKillLog(player, target, weapon)
	local userId = 0
    if isElement(player) then userId = player:getId() else userId = player or 0 end
	if isElement(target) then targetId = target:getId() else targetId = target or 0 end
	local range = getDistanceBetweenPoints3D(player:getPosition(), target:getPosition())
    sqlLogs:queryExec("INSERT INTO ??_Kills (UserId, TargetId, Weapon, RangeBetween, Position, Date) VALUES (?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, targetId, weapon, range, self:getZone(target))
end

function StatisticsLogger:addDamageLog(player, target, weapon, bodypart, damage)
	local userId = 0
    if isElement(player) then userId = player:getId() else userId = player or 0 end
	if isElement(target) then targetId = target:getId() else targetId = target or 0 end

	sqlLogs:queryExec("INSERT INTO ??_Damage (UserId, TargetId,  Weapon, Bodypart, Damage, Position, Date) VALUES (?, ?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, targetId, weapon, bodypart, damage, self:getZone(target))
end

function StatisticsLogger:addHealLog(player, heal, reason)
	local userId = 0
	if isElement(player) then userId = player:getId() else userId = player end
    sqlLogs:queryExec("INSERT INTO ??_Heal (UserId, Heal, Reason, Position, Date) VALUES (?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, heal, reason, self:getZone(player))
end

function StatisticsLogger:addActionLog(action, type, player, group, groupType)
	local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
    if group then groupId = group:getId() end
    sqlLogs:queryExec("INSERT INTO ??_Actions (Action, UserId, GroupId, GroupType, Type, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), action, userId, groupId, groupType, type)
end

function StatisticsLogger:addArrestLog(player, wanteds, duration, policeMan, bail)
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	if isElement(policeMan) then policeId = policeMan:getId() else policeId = policeMan or 0 end
	sqlLogs:queryExec("INSERT INTO ??_Arrest (UserId, Wanteds, Duration, PoliceId, Bail, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, wanteds, duration, policeId, bail)
end

function StatisticsLogger:addAmmunationLog(player, type, weapons, costs)
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_Ammunation (UserId, Type, Weapons, Costs, Position, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, type, weapons, costs, self:getZone(player))
end

function StatisticsLogger:addVehicleDeleteLog(userId, admin, model, reason)
	local adminId = 0
	if isElement(admin) then adminId = admin:getId() else adminId = admin or 0 end

	sqlLogs:queryExec("INSERT INTO ??_VehicleDeletion (UserId, Admin, Model, Position, Reason, Date) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, adminId, model, self:getZone(admin), reason)
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

function StatisticsLogger:addDrugPlantLog( player, type )
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_DrugPlants (UserId, Type, Date ) VALUES(?, ?,  NOW())",
        sqlLogs:getPrefix(), userId, type)
end

function StatisticsLogger:addDrugHarvestLog(player, type, owner, amount, state )
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_DrugHarvest (UserId, OwnerId, Type, Amount, State, Date ) VALUES(?, ?, ?, ?, ?,  NOW())",
        sqlLogs:getPrefix(), userId, owner, type, amount, state)
end

function StatisticsLogger:addDrugUse( player, type )
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_DrugUse (UserId, Type, Date ) VALUES(?, ?,  NOW())",
        sqlLogs:getPrefix(), userId, type)
end

function StatisticsLogger:addHouse( player, action, house )
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_House (UserId, Aktion, HouseId,  Date ) VALUES(?, ?, ?,  NOW())",
        sqlLogs:getPrefix(), userId, action, house)
end

function StatisticsLogger:addAdvert( player, text )
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_Advert (UserId, Text,  Date ) VALUES(?, ?,  NOW())",
        sqlLogs:getPrefix(), userId, text)
end

function StatisticsLogger:addCasino( player, wintype, prize)
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_Casino (UserId, WinType,  Prize, Date ) VALUES(?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, wintype, prize)
end

function StatisticsLogger:addItemDepotLog(player, depot, item, amount)
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	sqlLogs:queryExec("INSERT INTO ??_ItemDepot (UserId, DepotId,  Item, Amount, Date) VALUES(?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, depot, item, amount)
end

function StatisticsLogger:addLogin( player, name, logintype)
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	local ip = getPlayerIP( player )
	local serial = getPlayerSerial( player )
	sqlLogs:queryExec("INSERT INTO ??_Login (UserId, Name, Type, Ip, Serial, Date ) VALUES(?, ?, ?, ?, ?, NOW())",
        sqlLogs:getPrefix(), userId, name, logintype, ip, serial)
end

function StatisticsLogger:addAdminAction( player, action, target)
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	if target then
		if isElement(target) then
			if getElementType(target) == "player" then
				target = getPlayerName(target)
			elseif getElementType(target) == "vehicle" then
				target = target.m_Id or 0
			end
		end
	end
	if action == "spect" then
		sqlLogs:queryExec("INSERT INTO ??_AdminActionSpect (UserId, Type, Arg, Date ) VALUES(?, ?, ?, NOW())",
			sqlLogs:getPrefix(), userId, action, tostring(target) or "")
	elseif action == "goto" or action == "gethere" or action == "gotomark" or action == "mark" then
		sqlLogs:queryExec("INSERT INTO ??_AdminActionPort (UserId, Type, Arg, Date ) VALUES(?, ?, ?, NOW())",
			sqlLogs:getPrefix(), userId, action, tostring(target) or "")
	elseif action == "adminAnnounce" or string.upper(action) == "CLEARCHAT" or action == "a" or action == "o" then
		sqlLogs:queryExec("INSERT INTO ??_AdminActionChat (UserId, Type, Arg, Date ) VALUES(?, ?, ?, NOW())",
			sqlLogs:getPrefix(), userId, action, tostring(target) or "")
	else
		sqlLogs:queryExec("INSERT INTO ??_AdminActionOther (UserId, Type, Arg, Date ) VALUES(?, ?, ?, NOW())",
			sqlLogs:getPrefix(), userId, action, tostring(target) or "")
	end
end

function StatisticsLogger:onDebugMessageLog(message, level, file, line)
sqlLogs:queryExec("INSERT INTO ??_Errors (Message, Level, File, Line, Date) VALUES(?, ?, ?, ?, NOW())",
			sqlLogs:getPrefix(), message, level, file, line)
end

function StatisticsLogger:GroupBuyImmoLog( groupId, action, immo)
	if not tonumber(groupId) then return end
	sqlLogs:queryExec("INSERT INTO ??_GroupImmo (GroupId, Aktion, ImmoId,  Date ) VALUES(?, ?, ?,  NOW())",
        sqlLogs:getPrefix(), groupId, action, immo)
end


function StatisticsLogger:loadGameStats()
	local result = sqlLogs:queryFetch("SELECT * FROM ??_GameStats", sqlLogs:getPrefix())
	for i, row in pairs(result) do
		self.m_Gamestats[row["Game"]] = {
			["Incoming"] = row["Incoming"],
			["Outgoing"] = row["Outgoing"],
			["Played"] = row["Played"]
		}
	end
end

function StatisticsLogger:getGameStats(game)
	if self.m_Gamestats[game] then
		return self.m_Gamestats[game]
	else
		outputDebugString("Gamestats for Game "..game.." not found!")
	end
end

function StatisticsLogger:saveGameStats()
	for game, data in pairs(self.m_Gamestats) do
		sqlLogs:queryExec("UPDATE ??_GameStats SET Incoming = ?, Outgoing = ?, Played = ? WHERE Game = ?",
			sqlLogs:getPrefix(), data["Incoming"], data["Outgoing"], data["Played"], game)
	end
end

function StatisticsLogger:itemPlaceLogs( player, item, pos )
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	if item then
		if pos then
			sqlLogs:queryExec("INSERT INTO ??_ItemPlace ( PlayerId, Item,  Pos , Date) VALUES(?, ?, ?,  NOW())",
			sqlLogs:getPrefix(), userId, item, pos)
		end
	end
end

function StatisticsLogger:vehicleTowLogs( player, vehicle)
    local userId = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	if vehicle then
		if vehicle.m_Owner then
			if vehicle.m_Id then
				local ownerId = vehicle.m_Owner
				if type(vehicle.m_Owner) == "userdata" then
					ownerId = owner:getId()
				end
				sqlLogs:queryExec("INSERT INTO ??_VehicleTow ( PlayerId, OwnerId,  VehicleId , Date) VALUES(?, ?, ?,  NOW())",
					sqlLogs:getPrefix(), userId, ownerId, vehicle.m_Id)
			end
		end
	end
end

function StatisticsLogger:itemTradeLogs( player, player2, item, price, amount)
    local userId = 0
	local userId2 = 0
	if isElement(player) then userId = player:getId() else userId = player or 0 end
	if isElement(player2) then userId2 = player2:getId() else userId2 = player2 or 0 end
	if item and price then
		if tonumber(price) then
			sqlLogs:queryExec("INSERT INTO ??_ItemTrade ( GivingId, ReceivingId,  Item, Price, Amount, Date) VALUES(?, ?, ?, ?, ?,  NOW())",
				sqlLogs:getPrefix(), userId, userId2, item, tonumber(price), amount or 0)
		end
	end
end

function StatisticsLogger:addfishCaughtLogs(player, FishName, FishSize, Location)
	if player and FishName and FishSize and Location then
		sqlLogs:queryExec("INSERT INTO ??_fishCaught (PlayerId, FishName, FishSize, Location, Date) VALUES (?, ?, ?, ?, NOW())", sqlLogs:getPrefix(),
			player:getId(), FishName, FishSize, ("%s - %s"):format(Location, self:getZone(player)))
	end
end

function StatisticsLogger:addFishTradeLogs(PlayerId, ReceivingId, FishName, FishSize, Price, RareMultiplicator) -- ReceivingId 0 for server
	if PlayerId and ReceivingId and FishName and FishSize and Price and RareMultiplicator then
		sqlLogs:queryExec("INSERT INTO ??_fishTrade (PlayerId, ReceivingId, FishName, FishSize, Price, RareMultiplicator, Date) VALUES (?, ?, ?, ?, ?, ?, NOW())", sqlLogs:getPrefix(),
			PlayerId, ReceivingId, FishName, FishSize, Price, RareMultiplicator)
	end
end
