-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/MinigameManager.lua
-- *  PURPOSE:     Minigame Manager
-- *
-- ****************************************************************************
MinigameManager = inherit(Singleton)

function MinigameManager:constructor()
	self.m_GoJump = {}
	self.m_SideSwipe = {}

	self.m_GoJump.ms_Highscore = Highscore:new("GoJump")
	self.m_SideSwipe.ms_Highscore = Highscore:new("SideSwipe")

	self.m_GoJump.m_Highscores = self.m_GoJump.ms_Highscore:getHighscores()
	self.m_SideSwipe.m_Highscores = self.m_SideSwipe.ms_Highscore:getHighscores()
end
