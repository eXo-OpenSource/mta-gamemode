-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/WantedSystem.lua
-- *  PURPOSE:     Wantedsystem class
-- *
-- ****************************************************************************
WantedSystem = inherit(Singleton)

function WantedSystem:constructor()
	addEventHandler("onPlayerDamage", root, bind(self.playerDamage, self))
	addEventHandler("onPlayerWasted", root, bind(self.playerWasted, self))
end

function WantedSystem:playerDamage(attacker, attackerWeapon, bodypart, loss)
	if attacker and attacker ~= source and getElementType(attacker) == "player" then
		attacker:reportCrime(Crime.Damage)
	end
end

function WantedSystem:playerWasted(totalAmmo, killer, killerWeapon, bodypart, stealth)
	if killer and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		killer:reportCrime(Crime.Kill)
		
		-- Take karma
		killer:takeKarma(0.15)
	end
end
