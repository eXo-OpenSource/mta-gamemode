-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     Gangwar Attack class
-- *
-- ****************************************************************************
AttackSession = inherit(Object)


--// @param_desc: faction1: attacker-faction, faction2: defender-faction
function AttackSession:constructor( pAreaObj , faction1 , faction2  ) 
	self.m_AreaObj = pAreaObj
	self.m_Faction1 = faction1 
	self.m_Faction2 = faction2 
	self.m_Disqualified = {	} --//
	self.m_Participants = {	}
	self:fillListAtStart()
	
	self.m_BattleTime = setTimer(bind(self.attackEnd, self), GANGWAR_MATCH_TIME*60000, 1)
	
end

function AttackSession:fillListAtStart ( )
	for k,v in ipairs( self.m_Faction1:getPlayersOnline() ) do 
		self.m_Participants[#self.m_Participants + 1] = v
	end
end

function AttackSession:addParticipantToList( player )
	local bInList = self:isParticipantInList( player )
	if not bInList then 
		self.m_Participants[#self.m_Participants + 1] = player 
	end
end

function AttackSession:isParticipantInList( player )
	for index = 1,#self.m_Participants do 
		if self.m_Participants[index] == player then 
			return true
		end
	end
	return false
end

function AttackSession:removeParticipant( player )
	for index = 1,#self.m_Participants do 
		if self.m_Participants[index] == player then 
			return table.remove( self.m_Participants, index )
		end
	end
end

function AttackSession:joinPlayer( player ) 
	
end

function AttackSession:quitPlayer() 

end

function AttackSession:checkPlayersInCenter( )
	local pTable = getElementsWithinColShape( self.m_AreaObj.m_ColSphere, "player")
	local factionID
	for key, player in ipairs( pTable ) do 
		if not isPedDead( player ) then 
			factionID = player.m_Faction.m_Id 
			if factionID == self.m_Faction1 then 
				return true
			end
		end
	end
	return false
end


function AttackSession:attackEnd() 
	
end

function AttackSession:getFactions() 
	return self.m_Faction1,self.m_Faction2
end