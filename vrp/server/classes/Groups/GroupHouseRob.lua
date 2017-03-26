-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupHouseRob.lua
-- *  PURPOSE:     Group HouseRob class
-- *
-- ****************************************************************************

GroupHouseRob = inherit( Singleton )

function GroupHouseRob:constructor() 
	self.m_LastRob = false 
	self.m_LastGroupRobbing = false 
	
end


function GroupHouseRob:destructor() 

end