-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     AttackSession Client
-- *
-- ****************************************************************************

AttackClient = inherit(Object)
local pseudoSingleton

function AttackClient:constructor( faction1 , faction2 , pParticipants, pDisqualified) 
	self.m_Faction = faction1 
	self.m_Faction2 = faction2
	self.m_Participants = pParticipants 
	self.m_Disqualified = pDisqualified
	localPlayer.attackSession = self 
	self.m_Display = GangwarDisplay:new( faction1, faction2, pParticipants )
end

function AttackClient:destructor() 
	if self.m_Display then 
		self.m_Display:destructor()
	end
end 

function AttackClient:synchronizeLists( pParticipants, pDisqualified )
	self.m_Participants = pParticipants 
	self.m_Disqualified = pDisqualified
end

function AttackClient:synchronizeTime( ) 

end

addEvent("AttackClient:synchronizeLists",true)
function AttackClient.remoteSynchronize( pParticipants, pDisqualified )
	pseudoSingleton:synchronizeLists( pParticipants , pDisqualified )
end
addEventHandler("AttackClient:synchronizeLists",root,AttackClient.remoteSynchronize)

addEvent("AttackClient:launchClient",true)
function AttackClient.newClient( faction1, faction2, pParticipants, pDisqualified )
	if pseudoSingleton then 
		pseudoSingleton:delete()
	end
	pseudoSingleton = AttackClient:new( faction1, faction2, pParticipants, pDisqualified)
end
addEventHandler("AttackClient:launchClient",localPlayer,AttackClient.newClient)

addEvent("AttackClient:stopClient",true)
function AttackClient.stopClient(   )
	if pseudoSingleton then 
		pseudoSingleton:delete()
	end
end
addEventHandler("AttackClient:stopClient",localPlayer,AttackClient.stopClient)