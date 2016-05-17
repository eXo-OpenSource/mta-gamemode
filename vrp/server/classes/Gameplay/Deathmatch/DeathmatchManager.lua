-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/DeathmatchManager.lua
-- *  PURPOSE:     DeathmatchManager
-- *
-- ****************************************************************************

DeathmatchManager = inherit(Singleton)

function DeathmatchManager:constructor()

	--Zombie Survival
	Highscore:new("ZombieSurvival")

	 local zombiePed = createPed(1 ,-31.64, 1377.67, 9.17, 90)
	 zombiePed:setFrozen(true)
	 local zombieMarker = createMarker(-34.24, 1377.80, 8.5, "cylinder", 1, 255, 0, 0, 125)
	 Blip:new("Zombie.png", -34.24, 1377.80)
	 addEventHandler("onMarkerHit", zombieMarker, bind(self.onZombieMarkerHit, self))

	 addRemoteEvents{"startZombieSurvival"}
	 addEventHandler("startZombieSurvival", root, bind(self.startZombieSurvival))
end

function DeathmatchManager:onZombieMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		hitElement:triggerEvent("questionBox", _("Möchtest du eine Runde Zombie Survival spielen?", hitElement), "startZombieSurvival")
	end
end

function DeathmatchManager:startZombieSurvival()
	ZombieSurvival:new(client)
end
