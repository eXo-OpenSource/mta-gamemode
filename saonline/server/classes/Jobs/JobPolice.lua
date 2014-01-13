-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobPolice.lua
-- *  PURPOSE:     Police job class
-- *
-- ****************************************************************************
JobPolice = inherit(Job)

function JobPolice:constructor()
	Job.constructor(self)

	VehicleSpawner:new(1555.3, -1605.5, 12.3, {"Police LS"}, 180, bind(Job.requireVehicle, self))
	VehicleSpawner:new(1566.3, -1605.5, 12.3, {"Police LS"}, 180, bind(Job.requireVehicle, self))
	
	addEventHandler("onPlayerDamage", root, bind(self.playerDamage, self))
end

function JobPolice:start(player)
	setElementModel(player, 280)
	giveWeapon(player, 3, 1, true)
end

function JobPolice:stop(player)
	takeWeapon(player, 3)
end

function JobPolice:checkRequirements(player)
	if player:getKarma() < 30 then
		player:sendMessage(_("Du hast nicht genügend Karma gesammelt, um als Polizist/-in zu arbeiten!", player), 255, 0, 0)
		return false
	end
	if player:getXP() < 150 then
		player:sendMessage(_("Du hast nicht genügend Erfahrungspunkte, um als Polizist/-in zu arbeiten!", player), 255, 0, 0)
		return false
	end
	return true
end

function JobPolice:playerDamage(attacker, attackerWeapon, bodypart, loss)
	if source:getWantedLevel() > 0 then
		attacker = source
		if attacker and getElementType(attacker) == "player" --[[and weapon == 3 and attacker:getJob() == self]] then
			-- Teleport to jail
			setElementPosition(source, 264, 77.6, 1001.1)
			setElementRotation(source, 0, 0, 270)
			setElementInterior(source, 6)
			
			-- Pay some money, karma and xp to the policeman
			attacker:giveMoney(source:getWantedLevel() * 100)
			attacker:giveXP(source:getWantedLevel() * 1)
			attacker:giveKarma(source:getWantedLevel() * 0.01)
			
			-- Start freeing timer
			local jailTime = source:getWantedLevel() * 20
			source:sendInfo(_("Willkommen im Gefängnis! Hier wirst du nun für die nächsten %ds verweilen!", source), jailTime)
			setTimer(
				function(player)
					setElementInterior(player, 0, 1539.7, -1659.5 + math.random(-3, 3), 13.6)
					setElementRotation(player, 0, 0, 90)
					player:setWantedLevel(0)
				end, jailTime * 1000, 1, source
			)
		end
		
	end
end

