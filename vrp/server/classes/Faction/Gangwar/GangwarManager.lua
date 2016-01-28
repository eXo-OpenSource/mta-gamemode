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

function Gangwar:constructor( )
	self.m_Areas = {	}
	local sql_query = "SELECT * FROM ??_gangwar"
	local drow = sql:queryFetch(sql_query,sql:getPrefix())
	if drow then 
		for i, datarow in ipairs( drow ) do 
			self.m_Areas[#self.m_Areas+1] = Area:new( datarow )
		end
	end
end	

function Gangwar:destructor( )
	for index = 1,#self.m_Areas do 
		self.m_Areas[index]:destructor()
	end
end