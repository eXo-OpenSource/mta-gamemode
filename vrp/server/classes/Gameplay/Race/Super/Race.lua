-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
Race = inherit(Object)

Race.STATES = {
	[1] = "NoMap",
	[2] = "LoadingMap",
	[3] = "PreGridCountdown",
	[4] = "GridCountdown",
	[5] = "Running",
	[6] = "SomeoneWon",
	[7] = "TimesUp",
	[8] = "EveryoneFinished",
	[9] = "PostFinish",
	[10] = "NextMapSelect",
	[11] = "NextMapVote",
}

function Race:virtual_constructor()
	self.m_Players = {}
	self.m_Ranks = {}
	self.m_State = "none"
end

function Race:virtual_destructor()

end

function Race:join(player)
	table.insert(self.m_Players, player)
	outputChatBox("Added " .. getPlayerName(player))

end

function Race:quit()

end

function Race:getPlayers()
	return self.m_Players
end

function Race:setState()

end
