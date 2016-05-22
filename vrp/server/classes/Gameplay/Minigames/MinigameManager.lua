-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/MinigameManager.lua
-- *  PURPOSE:     Minigame Manager
-- *
-- ****************************************************************************
MinigameManager = inherit(Singleton)
addRemoteEvents{"MinigameSendHighscore", "MinigameRequestHighscores"}

function MinigameManager:constructor()
	MinigameManager.getRealTime()	--init

	self.m_GoJump = {}
	self.m_SideSwipe = {}

	self.m_GoJump.ms_Highscore = Highscore:new("GoJump")
	self.m_SideSwipe.ms_Highscore = Highscore:new("SideSwipe")

	self.m_GoJump.m_Highscores = self.m_GoJump.ms_Highscore:getHighscores()
	self.m_SideSwipe.m_Highscores = self.m_SideSwipe.ms_Highscore:getHighscores()
end

function MinigameManager.getRealTime()
	local realtime = getRealTime()
	realtime.yearday = realtime.yearday

	if MinigameManager.m_Yearday ~= realtime.yearday then
		MinigameManager.m_Yearday = realtime.yearday
		MinigameManager.m_Week = getWeekNumber()
		MinigameManager.m_Month = realtime.month + 1
		MinigameManager.m_Year = realtime.year + 1900
	end

	return {yearday = tostring(MinigameManager.m_Yearday), week = tostring(MinigameManager.m_Week), month = tostring(MinigameManager.m_Month), year = tostring(MinigameManager.m_Year)}
end

function MinigameManager.receiveHighscore(sName, iScore)
	assert(type(sName) == "string")
	assert(type(iScore) == "number")
	MinigameManager:getSingleton()[("m_%s"):format(sName)].ms_Highscore:addHighscore(client.m_Id, iScore)
end
addEventHandler("MinigameSendHighscore", resourceRoot, MinigameManager.receiveHighscore)

function MinigameManager.requestHighscores(sName)
	local highscores = MinigameManager:getSingleton()[("m_%s"):format(sName)].ms_Highscore:getHighscores().Global
	local newTable = {}

	-- Todo: sort table and prepare for client.

	for i = 1, 10 do
		newTable[i] = {}
		if highscores[i] then
			newTable[i].name = Account.getNameFromId(highscores[i].PlayerID)
			newTable[i].score = highscores[i].Score
		end
	end

	if sName == "GoJump" then
		client:triggerEvent("GoJumpReceiveHighscores", newTable)
	end
end
addEventHandler("MinigameRequestHighscores", resourceRoot, MinigameManager.requestHighscores)
