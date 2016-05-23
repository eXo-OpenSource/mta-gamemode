-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/ZombieSurvival.lua
-- *  PURPOSE:     ZombieSurvival for Deathmatch-Script
-- *
-- ****************************************************************************

ZombieSurvival = inherit(Object)
ZombieSurvival.PickupWeapons = {25, 24, 22, 33}

function ZombieSurvival:constructor()

	self.m_Dimension = math.random(1, 999) -- Testing
	self.m_Zombies = {}
	self.m_ZombieKills = {}

	self.m_ZombieTime = 10000
	self.m_IncreaseTimer = setTimer(bind(self.increaseZombies, self), 20000, 0)

	self.m_CreatePickupTimer = setTimer(bind(self.createPickup, self), 20000, 0)

	self:addZombie()
	self:loadMap()

	addEventHandler("onZombieWasted", root, bind(self.zombieWasted, self))
end

function ZombieSurvival:destructor()
	for index, object in pairs(self.m_Map) do
		object:destroy()
	end
	for index, zombie in pairs(self.m_Zombies) do
		delete(zombie)
	end

	for player, score in pairs(self.m_ZombieKills) do
		self:removePlayer(player)
	end

	if isTimer(self.m_CreatePickupTimer) then killTimer(self.m_CreatePickupTimer) end
	if isTimer(self.ZombieTimer) then killTimer(self.ZombieTimer) end
	if isTimer(self.m_IncreaseTimer) then killTimer(self.m_IncreaseTimer) end
	if isElement(self.m_Pickup) then self.m_Pickup:destroy() end
end

function ZombieSurvival:zombieWasted(ped, player)
	if isElement(player) then
		self.m_ZombieKills[player] = self.m_ZombieKills[player]+1
		player:triggerEvent("setScore", self.m_ZombieKills[player])
	end
end

function ZombieSurvival:getRandomPosition()
	return Vector3(math.random(82, 210), math.random(1728, 1798), 17.64)
end

function ZombieSurvival:addPlayer(player)
	self.m_ZombieKills[player] = 0
	player:setDimension(self.m_Dimension)
	player:setPosition(self:getRandomPosition())
	player:setInterior(0)
	player:setArmor(0)
	player:setHealth(100)
	takeAllWeapons(player)
	player:giveWeapon(24, 15, true)
	player:triggerEvent("showScore")

	addEventHandler("onPlayerDamage", player, function(attacker, weapon, bodypart, loss)
		if isElement(attacker) and getElementData(attacker, "zombie") == true then
			source:setHealth(source:getHealth()-loss*15)
		end
	end)


end

function ZombieSurvival:removePlayer(player)
	player:setPosition(-35.72, 1380.00, 9.42)
	player:setDimension(0)
	player:sendInfo(_("Du bist gestorben! Das Zombie Survival wurde beendet! Score: %d", player, self.m_ZombieKills[player]))



	DeathmatchManager:getSingleton().m_ZombieSurvivalHighscore:addHighscore(player:getId(), self.m_ZombieKills[player])
	self.m_ZombieKills[player] = nil
	takeAllWeapons(player)
	player:triggerEvent("hideScore")
	
	if self:getPlayers() == 0 then
		delete(self)
	end
end

function ZombieSurvival:getRandomPlayer()
	local random = {}
	for player, score in pairs(self.m_ZombieKills) do
		table.insert(random, player)
	end
	return random[math.random(1, #random)]
end

function ZombieSurvival:getPlayers()
	local players = {}
	for player, score in pairs(self.m_ZombieKills) do
		table.insert(players, player)
	end
	return players
end

function ZombieSurvival:increaseZombies()
	self.m_ZombieTime = self.m_ZombieTime*0.95
	if self.m_ZombieTime < 500 then
		self.m_ZombieTime = 500
		if isTimer(self.m_IncreaseTimer) then killTimer(self.m_IncreaseTimer) end
	end
end

function ZombieSurvival:createPickup()
	self.m_Pickup = createPickup(self:getRandomPosition(), 2, ZombieSurvival.PickupWeapons[math.random(1, #ZombieSurvival.PickupWeapons)], 5000000, 30)
	self.m_Pickup:setDimension(self.m_Dimension)
end

function ZombieSurvival:addZombie()
	local pos = self:getRandomPosition()
	self:createSmoke(pos)
	setTimer(function()
		local zombie = Zombie:new(pos, 310, self.m_Dimension)
		zombie:disableSeeCheck()
		zombie:SprintToPlayer(getRandomPlayer())
		table.insert(self.m_Zombies, zombie)
	end, 2500, 1)

	self.ZombieTimer = setTimer(bind(self.addZombie, self), self.m_ZombieTime, 1)
end

function ZombieSurvival:createSmoke(pos)
	local smoker = createObject(2780, pos.x, pos.y, pos.z-1)
	smoker:setAlpha(0)
	smoker:setDimension(self.m_Dimension)
	smoker:setCollisionsEnabled(false)
	setTimer(destroyElement, 3000, 1, smoker)
end

function ZombieSurvival:loadMap()
	self.m_Map = {
		createObject ( 987, 213.2, 1787.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1775.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1763.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1751.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1739.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 213.2, 1727.2, 16.6, 0, 0, 90 ),
		createObject ( 987, 201.3, 1727.2, 16.6 ),
		createObject ( 987, 189.3, 1727.2, 16.6 ),
		createObject ( 987, 177.3, 1727.2, 16.6 ),
		createObject ( 987, 165.3, 1727.2, 16.6 ),
		createObject ( 987, 153.3, 1727.2, 16.6 ),
		createObject ( 987, 141.3, 1727.2, 16.6 ),
		createObject ( 987, 129.3, 1727.2, 16.6 ),
		createObject ( 987, 117.3, 1727.2, 16.6 ),
		createObject ( 987, 105.2, 1727.2, 16.6 ),
		createObject ( 987, 93.2, 1727.2, 16.6 ),
		createObject ( 987, 81.2, 1727.2, 16.6 ),
		createObject ( 987, 81.2, 1739.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1751.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1763.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1775.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1787.1, 16.6, 0, 0, 270 ),
		createObject ( 987, 81.2, 1799, 16.6, 0, 0, 270 ),
		createObject ( 987, 93.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 105.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 117.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 129.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 141.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 153.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 165.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 177.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 189.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 201.2, 1799, 16.6, 0, 0, 180 ),
		createObject ( 987, 213.2, 1799, 16.6, 0, 0, 180 )
	}
	for index, object in pairs(self.m_Map) do
		object:setDimension(self.m_Dimension)
	end
end
