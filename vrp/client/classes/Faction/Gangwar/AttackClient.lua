-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     AttackSession Client
-- *
-- ****************************************************************************

AttackClient = inherit(Singleton)


function AttackClient:constructor( faction1 , faction2 , pParticipants, pDisqualified) 
	self.m_Faction = faction1 
	self.m_Faction2 = faction2
	self.m_Participants = pParticipants 
	self.m_Disqualified = pDisqualified
	localPlayer.attackSession = self
end


function AttackClient:synchronizeLists( pParticipants, pDisqualified )
	self.m_Participants = pParticipants 
	self.m_Disqualified = pDisqualified
end

addEvent("AttackClient:synchronizeLists",true)
function AttackClient.remoteSynchronize( pParticipants, pDisqualified )
	AttackClient:getSingleton():synchronizeLists( pParticipants , pDisqualified )
end
addEventHandler("AttackClient:synchronizeLists",root,AttackClient.remoteSynchronize)