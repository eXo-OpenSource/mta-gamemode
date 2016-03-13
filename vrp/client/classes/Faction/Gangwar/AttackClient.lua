-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Faction/Gangwar/GangwarAttack.lua
-- *  PURPOSE:     AttackSession Client
-- *
-- ****************************************************************************

AttackClient = inherit(Object)
local pseudoSingleton

function AttackClient:constructor( faction1 , faction2 , pParticipants, pDisqualified, pInitTime) 
	self.m_Faction = faction1 
	self.m_Faction2 = faction2
	self.m_Participants = pParticipants 
	self.m_Disqualified = pDisqualified
	localPlayer.attackSession = self 
	self.m_GangwarDamage = 0
	self.m_GangwarKill = 0
	self.m_Display = GangwarDisplay:new( faction1, faction2, self, pInitTime )
	self.m_DamageFunc = bind( self.addDamage, self)
	addEventHandler("onClientPlayerDamage",root, self.m_DamageFunc)
	self.m_KillFunc = bind( self.addKill, self)
	addEventHandler("onClientPlayerWasted",root, self.m_KillFunc)
end

function AttackClient:addDamage( attacker, weapon, bodypart, loss )
	if source ~= localPlayer then 
		local facSource = source:getFaction()
		local facAttacker = attacker:getFaction()
		if facSource ~= facAttacker then 
			if facSource == self.m_Faction or facSource == self.m_Faction2 then 
				if facAttacker == self.m_Faction or facAttacker == self.m_Faction2 then 
					if attacker == localPlayer then 
						localPlayer.m_GangwarDamage = localPlayer.m_GangwarDamage + loss
					end
				end
			end
		end
	end
end

function AttackClient:addKill( attacker, weapon, bodypart)
	if source ~= localPlayer then 
		local facSource = source:getFaction()
		local facAttacker = attacker:getFaction()
		if facSource ~= facAttacker then 
			if facSource == self.m_Faction or facSource == self.m_Faction2 then 
				if facAttacker == self.m_Faction or facAttacker == self.m_Faction2 then 
					if attacker == localPlayer then 
						localPlayer.m_GangwarKill = localPlayer.m_GangwarKill + 1
					end
				end
			end
		end
	end
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

function AttackClient:getFactionParticipants( pFac )
	local table_ = { }
	for k, v in ipairs( self.m_Participants ) do 
		if v:getFactionId() == pFac.m_Id then 
			table_[#table_+1] = v
		end
	end
	return table_
end

function AttackClient:getFactionsMembers( pFac )
	local tAll = getElementsByType("player")
	local table_ = { }
	for k, v in ipairs( tAll ) do 
		if v:getFactionId() == pFac.m_Id then 
			table_[#table_+1] = v
		end
	end
	return table_
end

addEvent("AttackClient:synchronizeLists",true)
function AttackClient.remoteSynchronize( pParticipants, pDisqualified )
	pseudoSingleton:synchronizeLists( pParticipants , pDisqualified )
end
addEventHandler("AttackClient:synchronizeLists",root,AttackClient.remoteSynchronize)

addEvent("AttackClient:launchClient",true)
function AttackClient.newClient( faction1, faction2, pParticipants, pDisqualified, pTime )
	if pseudoSingleton then 
		pseudoSingleton:delete()
	end
	pseudoSingleton = AttackClient:new( faction1, faction2, pParticipants, pDisqualified, pTime)
end
addEventHandler("AttackClient:launchClient",localPlayer,AttackClient.newClient)

addEvent("AttackClient:stopClient",true)
function AttackClient.stopClient(   )
	if pseudoSingleton then 
		pseudoSingleton:delete()
	end
end
addEventHandler("AttackClient:stopClient",localPlayer,AttackClient.stopClient)