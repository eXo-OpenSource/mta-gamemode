GangwarGuard = inherit(Object) 


function GangwarGuard:constructor() 
	self.m_LockedTime = 0
	self.m_FactionAttacks = {}

end

function GangwarGuard:destructor() 

end

function GangwarGuard:setLockedTime( seconds ) 
	local now = getRealTime().timestamp
	self.m_LockedTime = now + seconds
end

function GangwarGuard:addAttack( faction )
	local factionId = faction:getId()
	if not self.m_FactionAttacks[factionId] then
		self.m_FactionAttacks[factionId] = 0
	end
	self.m_FactionAttacks[factionId] = self.m_FactionAttacks[factionId] + 1
end

function GangwarGuard:getAttackCount ( faction )
	local factionId = faction:getId()
	if not self.m_FactionAttacks[factionId] then
		self.m_FactionAttacks[factionId] = 0
	end
	return self.m_FactionAttacks[factionId]
end

function GangwarGuard:getLockedTime() 
	return self.m_LockedTime
end

function GangwarGuard:isGangwarLocked( faction ) 
	local now = getRealTime().timestamp
	local factionId = faction:getId()
	if not self.m_FactionAttacks[factionId] then
		self.m_FactionAttacks[factionId] = 0
	end
	local attackCount = self.m_FactionAttacks[factionId]
	local lockedTime = self:getLockedTime()
	lockedTime = lockedTime + (10*attackCount) 
	if now >= lockedTime then 
		return false
	end
	return true, lockedTime-now
end



