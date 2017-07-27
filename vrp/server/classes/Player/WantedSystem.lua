-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Player/WantedSystem.lua
-- *  PURPOSE:     Wantedsystem class
-- *
-- ****************************************************************************
WantedSystem = inherit(Singleton)

function WantedSystem:constructor()
	--addEventHandler("onPlayerDamage", root, bind(self.playerDamage, self))
	addEventHandler("onPlayerWasted", root, bind(self.playerWasted, self))

	--self.m_WantedLevelLoosingPulse = TimedPulse:new(60*1000)
	--self.m_WantedLevelLoosingPulse:registerHandler(bind(self.updateWantedLevels, self))
end

--[[function WantedSystem:playerDamage(attacker, attackerWeapon, bodypart, loss)
	if attacker and attacker ~= source and getElementType(attacker) == "player" then
		attacker:reportCrime(Crime.Damage)
	end
end]]

function WantedSystem:playerWasted(totalAmmo, killer, killerWeapon, bodypart, stealth)
	if killer and isElement(killer) and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		--killer:reportCrime(Crime.Kill)

		-- Take karma
		killer:giveKarma(-0.15)
	end
end

function WantedSystem:updateWantedLevels()
	local tick = getTickCount()
	for k, player in pairs(getElementsByType("player")) do
		if player:getLastGotWantedLevelTime()+20*60*1000 >= tick then
			player:takeWanteds(1)
		end
	end
end
