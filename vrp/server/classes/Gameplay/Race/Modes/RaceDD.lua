-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
RaceDD = inherit(Race)

function RaceDD:constructor()
	self.m_Mode = "dd"
	self.m_ModeName = "Destruction-Derby"
	self.m_ModeShortName = "dm"
	self.m_Dimension = 4001
end

function RaceDD:destructor()
end

function RaceDD:killPlayer(player)
	self.m_AlivePlayers[player] = nil

	if table.size(self.m_AlivePlayers) == 1 then
		self:setState("SomeoneWon")
	end
end
