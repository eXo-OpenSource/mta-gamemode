-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobPolice.lua
-- *  PURPOSE:     Police job class
-- *
-- ****************************************************************************
JobPolice = inherit(Job)
local JailCells

function JobPolice:constructor()
	Job.constructor(self)

	VehicleSpawner:new(1555.3, -1605.5, 12.5, {"Police LS"}, 180, bind(Job.requireVehicle, self))
	VehicleSpawner:new(1566.3, -1605.5, 12.5, {"Police LS"}, 180, bind(Job.requireVehicle, self))

	addEventHandler("onPlayerDamage", root, bind(self.playerDamage, self))
	addEventHandler("onPlayerVehicleExit", root, bind(self.playerVehicleExit, self))

	addEvent("policePanelListRequest", true)
	addEventHandler("policePanelListRequest", root,
		function()
			if client:getJob() ~= self then
				return
			end

			local data = {}
			for k, player in pairs(getElementsByType("player")) do
				if player:getWantedLevel() > 0 then
					local info = {
						player = player:getName(),
						wanted = player:getWantedLevel()
					}

					info.crimes = {}
					for k, crime in pairs(player:getCrimes()) do
						info.crimes[k] = crime.id
					end
					data[#data + 1] = info
				end
			end
			client:triggerEvent("policePanelListRetrieve", data)
		end
	)

	self.m_ClothesPickup = createPickup(248.8, 70.4, 1003.6, 3, 1275)
	setElementInterior(self.m_ClothesPickup, 6)
	addEventHandler("onPickupHit", self.m_ClothesPickup,
		function(hitElement)
			if getElementType(hitElement) == "player" and hitElement:getJob() == self then
				if getElementModel(hitElement) ~= 280 then
					hitElement:setJobDutySkin(280)
				else
					hitElement:setJobDutySkin(nil)
				end
			end
			cancelEvent()
		end
	)
end

function JobPolice:destructor()
	destroyElement(self.m_ClothesPickup)
end

function JobPolice:start(player)
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
	return true
end

function JobPolice:jailPlayer(player, policeman)
	-- Teleport to jail
	local pos = JailCells[math.random(1, #JailCells)]
	player:setPosition(pos + Vector3(math.random(-2, 2), math.random(-2, 2), 0))
	player:setRotation(0, 0, 180)
	player:toggleControl("fire", false)
	player:toggleControl("jump", false)
	player:toggleControl("aim_weapon ", false)

	-- Pay some money, karma and xp to the policeman
	policeman:giveMoney(player:getWantedLevel() * 100)
	policeman:giveKarma(player:getWantedLevel() * 0.05)
	policeman:givePoints(3)

	-- Start freeing timer
	local jailTime = player:getWantedLevel() * 360
	setTimer(
		function()
			if isElement(player) then
				player:setPosition(1539.7, -1659.5 + math.random(-3, 3), 13.6)
				player:setRotation(0, 0, 90)
				player:setWantedLevel(0)
				player:toggleControl("fire", true)
				player:toggleControl("jump", true)
				player:toggleControl("aim_weapon ", true)
			end
		end, jailTime * 1000, 1
	)

	-- Clear crimes
	player:clearCrimes()

	-- Tell the other policemen that we jailed someone
	self:sendMessage("%s wurde soeben von %s verhaftet!", getPlayerName(player), getPlayerName(policeman))

	-- Tell the client that we were jailed
	player:triggerEvent("playerJailed", jailTime)
end

function JobPolice:playerDamage(attacker, attackerWeapon, bodypart, loss)
	local criminal = source

	if criminal:getWantedLevel() > 0 then
		if attacker and attacker ~= criminal and getElementType(attacker) == "player" and attackerWeapon == 3 and attacker:getJob() == self then
			if not criminal.policeHits then
				criminal.policeHits = 1
				return
			end
			if criminal.policeHits < 2 then
				criminal.policeHits = criminal.policeHits + 1
				-- Give him 30 seconds to run away
				setTimer(function() if isElement(criminal) and criminal.policeHits then criminal.policeHits = criminal.policeHits > 0 and criminal.policeHits - 1 or 0 end end, 30000, 1)
				return
			end

			-- Jail if being hit more than twice and reset hit counter
			self:jailPlayer(criminal, attacker)
			criminal.policeHits = nil
		end
	end
end

function JobPolice:playerVehicleExit(vehicle, seat, jacker)
	if seat == 0 and jacker and jacker:getJob() == self and source:getWantedLevel() > 1 then
		self:jailPlayer(source, jacker)
	end
end

function JobPolice:reportCrime(player, crimeType)
	-- Give him a higher wantedlevel if a cop is close
	local playerX, playerY, playerZ = getElementPosition(player)
	for k, cop in pairs(getElementsByType("player")) do -- Todo: A table that stores the job players inside might be better generally
		if cop:getJob() == self and cop ~= player then
			local x, y, z = getElementPosition(cop)

			if getDistanceBetweenPoints3D(playerX, playerY, playerZ, x, y, z) < (crimeType.maxdistance or 100) then
				cop:sendMessage(_("%s hat folgende Straftat begangen: %s", cop, getPlayerName(player), _(crimeType.text, cop)))

				-- Give him a wanted level
				if player:getWantedLevel() < crimeType.maxwanted then
					player:giveWantedLevel(crimeType.maxwanted - player:getWantedLevel())
				end

				-- Store crimes
				player:addCrime(crimeType)
			end
		end
	end
end

function JobPolice:reportSpecialCrime(crimeType, message)
	self:sendMessage(message)
end

JailCells = {
	Vector3(3473.7, -2090.1001, 20.9),
	Vector3(3472.8999, -2106.1001, 20.9),
	Vector3(3486.8999, -2106.1001, 20.9),
	Vector3(3488.1001, -2090.3999, 20.9),
	Vector3(3453.8999, -2153.8999, 17.1),
	Vector3(3521, -2063.8, 21.3)
}
