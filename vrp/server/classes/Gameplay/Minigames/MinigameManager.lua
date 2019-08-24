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
	self.m_2Cars = {}

	self.m_GoJump.ms_Highscore = Highscore:new("GoJump")
	self.m_SideSwipe.ms_Highscore = Highscore:new("SideSwipe")
	self.m_2Cars.ms_Highscore = Highscore:new("2Cars")

	-- Zombie Survival
	--ZombieSurvival.initalize()
	--self.m_ZombieSurvivalHighscore = Highscore:new("ZombieSurvival")

	-- Sniper Game
	--SniperGame.initalize()
	--self.m_SniperGameHighscore = Highscore:new("SniperGame")

	self:addHooks()

	-- Freak AchievementIds
	self.m_FreakIds = {54, 55} -- Todo: add more Achievements!

	SlotGameManager:new()
	RouletteManager:new()
	HighStakeRouletteManager:new()
	BlackJackManager:new()
	CasinoWheelManager:new()
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

function MinigameManager:addHooks()
	PlayerManager:getSingleton():getWastedHook():register(
		function(player)
			if player.Minigame then
				player:triggerEvent("abortDeathGUI", true)
				player.Minigame:removePlayer(player)
				return true
			end
		end
	)

	PlayerManager:getSingleton():getAFKHook():register(
		function(player)
			if player.Minigame then
				player.Minigame:removePlayer(player)
			end
		end
	)

	Player.getQuitHook():register(
		function(player)
			if player.Minigame then
				player.Minigame:removePlayer(player)
			end
		end
	)
end

function MinigameManager:getPlayerMinigame(player)
	for index, match in pairs(MinigameManager.Current) do
		if match.m_ZombieKills and match.m_ZombieKills[player] then --ZombieSurvival
			return match
		end
		if match.m_PedKills and match.m_PedKills[player] then --SniperGame
			return match
		end
	end
	return false
end

function MinigameManager:checkForFreaks(player)
	local bool = true
	for i, v in ipairs(self.m_FreakIds) do
		bool = player:getAchievementStatus(v)
		if not bool then
			break;
		end
	end

	return bool
end
