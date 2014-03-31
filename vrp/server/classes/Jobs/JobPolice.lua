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

	VehicleSpawner:new(1555.3, -1605.5, 12.5, {"Police LS"}, 180, bind(Job.requireVehicle, self))
	VehicleSpawner:new(1566.3, -1605.5, 12.5, {"Police LS"}, 180, bind(Job.requireVehicle, self))
	
	addEventHandler("onPlayerDamage", root, bind(self.playerDamage, self))
	addEventHandler("onPlayerVehicleExit", root, bind(self.playerVehicleExit, self))
	
	addEvent("policePanelListRequest", true)
	addEventHandler("policePanelListRequest", root,
		function()
			--[[if client:getJob() ~= self then
				return
			end]]
		
			local data = {}
			for k, v in ipairs(getElementsByType("player")) do
				if v:getWantedLevel() > 0 then
					data[v] = getPlayerWantedLevel(v)
				end
			end
			client:triggerEvent("policePanelListRetrieve", data)
		end
	)
end

function JobPolice:start(player)
	--setElementModel(player, 280)
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

function JobPolice:jailPlayer(player, policeman)
	-- Teleport to jail
	setElementPosition(player, 264, 77.6, 1001.1)
	setElementRotation(player, 0, 0, 270)
	setElementInterior(player, 6)
	
	-- Pay some money, karma and xp to the policeman
	policeman:giveMoney(player:getWantedLevel() * 100)
	policeman:giveXP(player:getWantedLevel() * 1)
	policeman:giveKarma(player:getWantedLevel() * 0.01)
	
	-- Start freeing timer
	local jailTime = player:getWantedLevel() * 20
	player:sendInfo(_("Willkommen im Gefängnis! Hier wirst du nun für die nächsten %ds verweilen!", player, jailTime))
	setTimer(
		function()
			setElementInterior(player, 0, 1539.7, -1659.5 + math.random(-3, 3), 13.6)
			setElementRotation(player, 0, 0, 90)
			player:setWantedLevel(0)
		end, jailTime * 1000, 1
	)
	
	-- Tell the other policemen that we jailed someone
	self:sendMessage("%s wurde soeben von %s verhaftet!", getPlayerName(player), getPlayerName(policeman))
end

function JobPolice:playerDamage(attacker, attackerWeapon, bodypart, loss)
	if source:getWantedLevel() > 0 then
		if attacker and attacker ~= source and getElementType(attacker) == "player" and attackerWeapon == 3 and attacker:getJob() == self then
			self:jailPlayer(source, attacker)
		end
	end
end

function JobPolice:playerVehicleExit(vehicle, seat, jacker)
	if seat == 0 and jacker and source:getWantedLevel() > 1 then
		self:jailPlayer(source, jacker)
	end
end
