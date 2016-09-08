-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Minigames/MinigameManager.lua
-- *  PURPOSE:     Minigame Manager
-- *
-- ****************************************************************************
MinigameManager = inherit(Singleton)
MinigameManager.Current = {}

addRemoteEvents{"MinigameSendHighscore", "MinigameRequestHighscores"}

function MinigameManager:constructor()
	MinigameManager.getRealTime()	--init

	self.m_GoJump = {}
	self.m_SideSwipe = {}

	self.m_GoJump.ms_Highscore = Highscore:new("GoJump")
	self.m_SideSwipe.ms_Highscore = Highscore:new("SideSwipe")

	-- Zombie Survival
	ZombieSurvival.initalize()
	self.m_ZombieSurvivalHighscore = Highscore:new("ZombieSurvival")

	-- Sniper Game
	SniperGame.initalize()
	self.m_SniperGameHighscore = Highscore:new("SniperGame")

	self:addPlayerDeathHook()

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


function MinigameManager:addPlayerDeathHook()
	PlayerManager:getSingleton():getWastedHook():register(
		function(player)
			local match = self:getPlayerDeathmatch(player)
			if match then
				match:removePlayer(player)
				return true
			end
		end
	)
end

function MinigameManager:getPlayerDeathmatch(player)
	for index, match in pairs(MinigameManager.Current) do
		if match.m_ZombieKills[player] then --ZombieSurvival
			return match
		end
		if match.m_PedKills[player] then --SniperGame
			return match
		end
	end
	return false
end
