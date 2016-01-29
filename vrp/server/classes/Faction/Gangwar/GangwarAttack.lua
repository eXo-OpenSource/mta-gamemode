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
	self.m_BattleTime = setTimer(bind(self.attackEnd, self), GANGWAR_MATCH_TIME, 1)

end

function AttackSession:onPlayerJoin() 
	
end

function AttackSession:onPlayerQuit() 

end


function AttackSession:attackEnd() 
	
end

function AttackSession:getFactions() 
	return self.m_Faction1,self.m_Faction2
end