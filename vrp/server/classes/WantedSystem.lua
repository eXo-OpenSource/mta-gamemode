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
		if attacker:getWantedLevel() < 1 then
			attacker:giveWantedLevel(1)
		end
	end
end

function WantedSystem:playerWasted(totalAmmo, killer, killerWeapon, bodypart, stealth)
	if killer and killer ~= source and killerWeapon ~= 3 and getElementType(killer) == "player" then
		if killer:getWantedLevel() < 4 then
			killer:giveWantedLevel(1)
		end
		
		-- Take karma
		killer:takeKarma(0.15)
	end
end
