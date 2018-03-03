-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Gangwar/GangwarStatistics.lua
-- *  PURPOSE:     Gangwar-Statistics Class
-- *
-- ****************************************************************************
GangwarStatistics = inherit(Singleton)
local secondsPerDay = (60*60)*24
local CACHE_TIME = (60*1000)*30

GangwarStatistics.CacheStats = { }
function GangwarStatistics:constructor() 
	self.m_CollectorMap =  {}
	self.m_CollectorTimeouts =  {}
	self.m_SQLStats = {}
	self.runtimeMostDamage = {}
	self.m_BankAccountServer = BankServer.get("faction.gangwar")
	self:prepareAttackLog( )
	self:getTopTenList( )
end

function GangwarStatistics:prepareAttackLog() 
	self.m_AttackLog = {}
	local result = StatisticsLogger:getSingleton():getGangwarAttackLog( 20 ) 
	if result then 
		for k, row in pairs(result) do 
			self.m_AttackLog[#self.m_AttackLog+1] = {row["Gebiet"], row["Angreifer"], row["Besitzer"], row["StartZeit"], row["EndZeit"], row["Gewinner"]}
		end
	end
end

function GangwarStatistics:newCollector( mAreaID )
	self.m_CollectorMap[mAreaID] = {}
end

function GangwarStatistics:getAttackLog() 
	return self.m_AttackLog
end

function GangwarStatistics:addAttackLog( area, attacker, owner, start, endTime, winner)
	table.insert(self.m_AttackLog, 1, {area, attacker, owner, start, endTime, winner})
end

function GangwarStatistics:stopAndOutput( mAreaID )
	local bestTable = self:getBestOfCollector( mAreaID )
	for _, value in ipairs( self.m_CollectorMap[mAreaID] ) do 
		value[1]:triggerEvent( "GangwarStatistics:clientGetMVP", bestTable )
	end
	self.m_CollectorMap[mAreaID] = {}
	self.m_CollectorTimeouts[mAreaID] = {}
	self:addNewMVP( bestTable[1][1] )
	self:flushSQLTable()
	self:getTopTenList() 
end

function GangwarStatistics:collectDamage(mAreaID, facPlayers)
	local damage, moneyDamage, moneyKill, player, kill
	for i = 1, #facPlayers do 
		player = facPlayers[i]
		if player and isElement(player) then
			damage = math.ceil(player.g_damage or 0)
			kill = 0
			if player.g_kills then
				if tonumber(player.g_kills) then 
					kill = tonumber(player.g_kills)
				end
			end
			moneyDamage = damage * GANGWAR_PAY_PER_DAMAGE
			moneyKill = kill * GANGWAR_PAY_PER_KILL
			outputChatBox("[Gangwar-Boni] #FFFFFFDu erhälst "..moneyDamage.."$ für deinen Damage!",player,200,200,0,true)
			outputChatBox("[Gangwar-Boni] #FFFFFFDu erhälst "..moneyKill.."$ für deine Kills!",player,200,200,0,true)
			self.m_BankAccountServer:transferMoney(player, moneyDamage + moneyKill, "Gangwar-Boni", "Faction", "GangwarBoni")
			self.m_CollectorMap[mAreaID][#self.m_CollectorMap[mAreaID]+1] = { player, damage}
			self.m_SQLStats[#self.m_SQLStats+1] = {player:getId(), "Damage", damage, player:getName()}
			self.m_SQLStats[#self.m_SQLStats+1] = {player:getId(), "Kill", kill, player:getName()}
		end
	end
	self:stopAndOutput( mAreaID )
end

function GangwarStatistics:getBestOfCollector( mAreaID )
	table.sort( self.m_CollectorMap[mAreaID] , function( a ,b ) return a[2] > b[2] end)
	return self.m_CollectorMap[mAreaID]
end

function GangwarStatistics:addNewMVP( player )
	self.m_SQLStats[#self.m_SQLStats+1] = {player:getId(), "MVP", 1, player:getName()}
	
end

function GangwarStatistics:flushSQLTable() 
	local count = 0
	if self.m_SQLStats then 
		local user, type, amount
		for i = 1, #self.m_SQLStats do 
			user, type, amount, name = self.m_SQLStats[i][1], self.m_SQLStats[i][2], self.m_SQLStats[i][3], self.m_SQLStats[i][4]
			count = count + 1
			sqlLogs:queryExec("INSERT INTO ??_GangwarStatistics (UserId, Type, Amount, Date) VALUES(?, ?, ?, NOW())", sqlLogs:getPrefix(), user, type, amount or 1)
			if type == "Damage" then 
				sqlLogs:queryExec("INSERT INTO ??_GangwarTopList (UserId, Name, Damage, Kills, MVP ) VALUES(?, ?, ?, 0, 0) ON DUPLICATE KEY UPDATE Damage = Damage + ?, Name = ?", sqlLogs:getPrefix(), user, name, amount, amount, name)
			elseif type == "Kill" then
				sqlLogs:queryExec("INSERT INTO ??_GangwarTopList (UserId, Name, Damage, Kills, MVP ) VALUES(?, ?, 0, ?, 0) ON DUPLICATE KEY UPDATE Kills = Kills + ?, Name = ?", sqlLogs:getPrefix(), user, name, amount, amount, name)
			else
				sqlLogs:queryExec("INSERT INTO ??_GangwarTopList (UserId, Name, Damage, Kills, MVP ) VALUES(?, ?, 0, 0, 1) ON DUPLICATE KEY UPDATE MVP = MVP + 1, Name = ?", sqlLogs:getPrefix(), user, name, name)
			end
		end
	end
	outputDebugString(("-- Flushed Gangwar-Statistics into SQL (%s entries) --"):format(count))
	self.m_SQLStats = {}
end

function GangwarStatistics:getPlayerStats( player )  
	local now = getTickCount()
	if player then
		local user = player:getId() 
		if not GangwarStatistics.CacheStats[user] then
			local result = sqlLogs:queryFetchSingle("SELECT * FROM ??_GangwarTopList WHERE UserId = ?", sqlLogs:getPrefix(), user)
			if result then
				GangwarStatistics.CacheStats[user] = { getTickCount(), result.Damage, result.Kills, result.MVP }
				local result = sqlLogs:queryFetchSingle("SELECT (SELECT COUNT(*) FROM ??_GangwarTopList WHERE Damage >= ?) AS Position FROM ??_GangwarTopList WHERE UserId=?", sqlLogs:getPrefix(), result.Damage, sqlLogs:getPrefix(), user)
				if result then
					table.insert(GangwarStatistics.CacheStats[user], result.Position or "-")
				end
				local result = sqlLogs:queryFetchSingle("SELECT (SELECT COUNT(*) FROM ??_GangwarTopList WHERE Kills >= ?) AS Position FROM ??_GangwarTopList WHERE UserId=?", sqlLogs:getPrefix(), GangwarStatistics.CacheStats[user][3], sqlLogs:getPrefix(), user)
				if result then
					table.insert(GangwarStatistics.CacheStats[user], result.Position or "-")
				end
				local result = sqlLogs:queryFetchSingle("SELECT (SELECT COUNT(*) FROM ??_GangwarTopList WHERE MVP >= ?) AS Position FROM ??_GangwarTopList WHERE UserId=?", sqlLogs:getPrefix(), GangwarStatistics.CacheStats[user][4], sqlLogs:getPrefix(), user)
				if result then
					table.insert(GangwarStatistics.CacheStats[user], result.Position or "-")
				end
			else 
				GangwarStatistics.CacheStats[user] = { getTickCount(), 0, 0, 0, "-", "-", "-" }
			end
			return GangwarStatistics.CacheStats[user]
		else
			local user = player:getId() 
			local lastUpdated = GangwarStatistics.CacheStats[user][1]
			if not lastUpdated or ( now >= lastUpdated+CACHE_TIME) then 
				local result = sqlLogs:queryFetchSingle("SELECT * FROM ??_GangwarTopList WHERE UserId = ?", sqlLogs:getPrefix(), user)
				if result then
					GangwarStatistics.CacheStats[user] = { getTickCount(), result.Damage, result.Kills, result.MVP }
					local result = sqlLogs:queryFetchSingle("SELECT (SELECT COUNT(*) FROM ??_GangwarTopList WHERE Damage >= ?) AS Position FROM ??_GangwarTopList WHERE UserId=?", sqlLogs:getPrefix(), result.Damage, sqlLogs:getPrefix(), user)
					if result then
						table.insert(GangwarStatistics.CacheStats[user], result.Position or "-")
					end
					local result = sqlLogs:queryFetchSingle("SELECT (SELECT COUNT(*) FROM ??_GangwarTopList WHERE Kills >= ?) AS Position FROM ??_GangwarTopList WHERE UserId=?", sqlLogs:getPrefix(), GangwarStatistics.CacheStats[user][3], sqlLogs:getPrefix(), user)
					if result then
						table.insert(GangwarStatistics.CacheStats[user], result.Position or "-")
					end
					local result = sqlLogs:queryFetchSingle("SELECT (SELECT COUNT(*) FROM ??_GangwarTopList WHERE MVP >= ?) AS Position FROM ??_GangwarTopList WHERE UserId=?", sqlLogs:getPrefix(), GangwarStatistics.CacheStats[user][4], sqlLogs:getPrefix(), user)
					if result then
						table.insert(GangwarStatistics.CacheStats[user], result.Position or "-")
					end
				else 
					GangwarStatistics.CacheStats[user] = { getTickCount(), 0, 0, 0, "-", "-", "-" }
				end
				return GangwarStatistics.CacheStats[user]
			else 
				return GangwarStatistics.CacheStats[user]
			end
		end
	end
	return false
end

function GangwarStatistics:getTopTenList( ) 
	GangwarStatistics.TopStats = { }
	local result = StatisticsLogger:getSingleton():getGangwarTopDamage( 10 ) 
	GangwarStatistics.TopStats["Damage"] = { }
	for k, row in pairs(result) do
		GangwarStatistics.TopStats["Damage"][#GangwarStatistics.TopStats["Damage"]+1] = {row.Name, row.Damage}
	end
	GangwarStatistics.TopStats["Kill"] = { }
	local result = StatisticsLogger:getSingleton():getGangwarTopKill( 10 ) 
	for k, row in pairs(result) do
		GangwarStatistics.TopStats["Kill"][#GangwarStatistics.TopStats["Kill"]+1] = {row.Name, row.Kills}
	end
	GangwarStatistics.TopStats["MVP"] = { }
	local result = StatisticsLogger:getSingleton():getGangwarTopMVP( 10 ) 
	for k, row in pairs(result) do
		GangwarStatistics.TopStats["MVP"][#GangwarStatistics.TopStats["MVP"]+1] = {row.Name, row.MVP}
	end
end


function GangwarStatistics:destructor()	
	self:flushSQLTable()
end
