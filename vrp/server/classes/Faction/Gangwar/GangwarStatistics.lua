-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Gangwar/GangwarStatistics.lua
-- *  PURPOSE:     Gangwar-Statistics Class
-- *
-- ****************************************************************************

GangwarStatistics = inherit(Singleton)
addRemoteEvents{"gwClientGetDamage"}
function GangwarStatistics:constructor() 
	self.m_CollectorMap =  {}
	self.m_CollectorTimeouts =  {}
	self.sqlMostDamage = {}
	self.runtimeMostDamage = {}
	local result = sql:queryFetch("SELECT * FROM ??_gangwar_stats;", sql:getPrefix())
	for i, row in pairs(result) do
		if row.type == "mvp" then
			if not self.mostDamage[row.Name] then 
				self.mostDamage[row.Name] = 1
			else 
				self.mostDamage[row.Name] = self.mostDamage[row.Name] + 1
			end
		end
	end
	addEventHandler("gwClientGetDamage", root, bind( self.addDamageToCollector, self))
end

function GangwarStatistics:newCollector( mAreaID )
	self.m_CollectorMap[mAreaID] = {}
end

function GangwarStatistics:stopAndOutput( mAreaID )
	local bestTable = self:getBestOfCollector( mAreaID )
	for _, value in ipairs( self.m_CollectorMap[mAreaID] ) do 
		value[1]:triggerEvent( "GangwarStatistics:clientGetMVP", bestTable )
	end
	self.m_CollectorMap[mAreaID] = {}
	self.m_CollectorTimeouts[mAreaID] = {}
	self:addNewEntry( bestTable[1][1] )
end

function GangwarStatistics:setCollectorTimeout( mAreaID, timeout )
	self.m_CollectorTimeouts[mAreaID] = timeout
end

function GangwarStatistics:addDamageToCollector( mAreaID, damage  )
	if client == source then 
		self.m_CollectorMap[mAreaID][#self.m_CollectorMap[mAreaID]+1] = { client, damage}
		if #self.m_CollectorMap[mAreaID] == self.m_CollectorTimeouts[mAreaID] then 
			self:stopAndOutput( mAreaID )
		end
	end 
end

function GangwarStatistics:getBestOfCollector( mAreaID )
	table.sort( self.m_CollectorMap[mAreaID] , function( a ,b ) return a[2] > b[2] end)
	return self.m_CollectorMap[mAreaID]
end

function GangwarStatistics:addNewEntry( player )
	if not self.runtimeMostDamage[player] then 
		self.runtimeMostDamage[player] = 1 
	else 
		self.runtimeMostDamage[player] = self.runtimeMostDamage[player] + 1 
	end
end

function GangwarStatistics:destructor()	
	--[[ NEEDS better sql operation
	sqlQuery = "INSERT OR REPLACE INTO ??_gangwar_stats(Name, Typ, MVP) VALUES(?,?,?)"
	for player, value in pairs( self.runtimeMostDamage ) do 
		sql:queryExec(sqlQuery, sql:getPrefix(), player.name, "MVP", value)
	end
	--]]
end
