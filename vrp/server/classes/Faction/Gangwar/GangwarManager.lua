-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarManager.lua
-- *  PURPOSE:     Gangwar Class
-- *
-- ****************************************************************************

Gangwar = inherit(Singleton)

--// Gangwar - Constants //--
GANGWAR_MATCH_TIME = 15
GANGWAR_CENTER_HOLD_RANGE = 20
addRemoteEvents{"onLoadCharacter","onDeloadCharacter"}

function Gangwar:constructor( )
	self.m_Areas = {	}
	self.m_CurrentAttacks = {	}
	local sql_query = "SELECT * FROM ??_gangwar"
	local drow = sql:queryFetch(sql_query,sql:getPrefix())
	if drow then 
		for i, datarow in ipairs( drow ) do 
			self.m_Areas[#self.m_Areas+1] = Area:new( datarow )
		end
	end
	
	addEventHandler("onLoadCharacter",root,bind(self.onPlayerJoin,self))
	addEventHandler("onDeloadCharacter",root,bind(self.onPlayerQuit,self))
end	

function Gangwar:destructor( )
	for index = 1,#self.m_Areas do 
		self.m_Areas[index]:delete()
	end
end

function Gangwar:onPlayerJoin()
	local factionObj = source.m_Faction
	if factionObj then 
		local factionID = factionObj.m_Id
		for index = 1,#self.m_CurrentAttacks do 
			local faction1,faction2 = self.m_CurrentAttacks[index]:getMatchFactions()
			if faction1 == factionID or faction2 == factionID then 
				--// gangwar join
			end
		end
	end
end

function Gangwar:onPlayerQuit()
	local factionObj = source.m_Faction
	if factionObj then 
		local factionID = factionObj.m_Id
		for index = 1,#self.m_CurrentAttacks do 
			local faction1,faction2 = self.m_CurrentAttacks[index]:getMatchFactions()
			if faction1 == factionID or faction2 == factionID then 
				--// gangwar quit
			end
		end
	end
end

function Gangwar:addAreaToAttacks( pArea ) 
	self.m_CurrentAttacks[#self.m_CurrentAttacks + 1] = pArea
end

function Gangwar:removeAreaFromAttacks( pArea ) 
	local area
	for index = 1,#self.m_CurrentAttacks do 
		area = self.m_CurrentAttacks[index]
		if area == pArea then
			table.remove( self.m_CurrentAttacks,index)
		end
	end
end

function Gangwar:getCurrentGangwars( ) 
	local area
	local objTable = {	}
	for index = 1,#self.m_CurrentAttacks do 
		area = self.m_CurrentAttacks[index]
		if area:isUnderAttack() then 
			objTable[#objTable + 1] = area 
		end
	end
	return objTable
end