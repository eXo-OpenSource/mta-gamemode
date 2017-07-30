-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
RaceDM = inherit(Race)

function RaceDM:constructor()
	self.m_Mode = "dm"
	self.m_ModeName = "Deathmatch"
	self.m_ModeShortName = "DM"
	self.m_Dimension = 4000
end

function RaceDM:destructor()
end

function RaceDM:killPlayer(player)
	self.m_AlivePlayers[player] = nil

	if table.size(self.m_AlivePlayers) == 0 then
		self:setState("PostFinish")
	end
end
