-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/DeathmatchManager.lua
-- *  PURPOSE:     DeathmatchManager
-- *
-- ****************************************************************************

DeathmatchManager = inherit(Singleton)
DeathmatchManager.Current = {}

function DeathmatchManager:constructor()

	--Zombie Survival
	 self.m_ZombieSurvivalHighscore = Highscore:new("ZombieSurvival")

	 local zombiePed = createPed(162 ,-31.64, 1377.67, 9.17, 90)
	 zombiePed:setFrozen(true)
	 local zombieMarker = createMarker(-34.24, 1377.80, 8.5, "cylinder", 1, 255, 0, 0, 125)
	 Blip:new("Zombie.png", -34.24, 1377.80)
	 addEventHandler("onMarkerHit", zombieMarker, bind(self.onZombieMarkerHit, self))

	 self:addPlayerDeathHook()

	 addRemoteEvents{"startZombieSurvival"}
	 addEventHandler("startZombieSurvival", root, bind(self.startZombieSurvival))
end

function DeathmatchManager:onZombieMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		hitElement:triggerEvent("questionBox", _("Möchtest du eine Runde Zombie Survival spielen?", hitElement), "startZombieSurvival")
	end
end

function DeathmatchManager:addPlayerDeathHook()
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

function DeathmatchManager:getPlayerDeathmatch(player)
	for index, match in pairs(DeathmatchManager.Current) do
		if match.m_ZombieKills[player] then
			return match
		end
	end
	return false
end

function DeathmatchManager:startZombieSurvival()
	local instance = ZombieSurvival:new()
	instance:addPlayer(client)
	local index = #DeathmatchManager.Current+1
	DeathmatchManager.Current[index] = instance
	DeathmatchManager.Current[index].Type = "ZombieSurvival"
end
