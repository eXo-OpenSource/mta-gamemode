AmmuArena = inherit(Object)

local BUSY_CHECK = 1000*60*1

function AmmuArena:constructor(team1,team2)
	self.m_Team1 = team1
	self.m_Team2 = team2
	
	team1:setArena(self)
	team2:setArena(self)
	
	self:sendReadyCheck()
end

function AmmuArena:sendReadyCheck()

	self.m_BusyCheck = Timer(bind(self.cancelRequest,self),BUSY_CHECK,1)
end

function AmmuArena:cancelRequest(reason)
	
end

function AmmuArena:destructor()

end