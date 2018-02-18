GangwarGuard = inherit(Object) 


function GangwarGuard:constructor() 
	self.m_LockedTime = 0
end

function GangwarGuard:destructor() 

end

function GangwarGuard:setLockedTime( seconds ) 
	local now = getRealTime().timestamp
	self.m_LockedTime = now + seconds
end

function GangwarGuard:getLockedTime() 
	return self.m_LockedTime
end

function GangwarGuard:isGangwarLocked() 
	local now = getRealTime().timestamp
	local lockedTime = self:getLockedTime() 
	if now >= lockedTime then 
		return false
	end
	return true, lockedTime-now
end



