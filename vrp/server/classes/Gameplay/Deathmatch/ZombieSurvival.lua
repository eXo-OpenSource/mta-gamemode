-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/ZombieSurvival.lua
-- *  PURPOSE:     ZombieSurvival for Deathmatch-Script
-- *
-- ****************************************************************************

ZombieSurvival = inherit(Object)

function ZombieSurvival:constructor(player)
	self.m_PickupWeapons = {25, 24, 22, 33, 30}

	self.m_Player = player
	self.m_Dimension = math.random(1, 999) -- Testing
	self.m_Zombies = {}
	self.m_ZombieKills = {}
	self.m_ZombieKills[player] = 0

	self.m_ZombieTime = 10000
	self.m_IncreaseTimer = setTimer(bind(self.increaseZombies, self), 20000, 0)

	self.m_CreatePickupTimer = setTimer(bind(self.createPickup, self), 20000, 0)

	self:addZombie()

	player:setDimension(self.m_Dimension)
	player:setPosition(183.62, 1764.55, 17.64)
	player:setInterior(0)
	player:setArmor(0)
	takeAllWeapons(player)
	player:giveWeapon(24, 30, true)


	self:loadMap()


	addEventHandler("onPlayerDamage", player, function(attacker, weapon, bodypart, loss)
		if isElement(attacker) and getElementData(attacker, "zombie") == true then
			source:setHealth(source:getHealth()-loss*15)
		end
	end)

	addEventHandler("onZombieWasted", root, function(ped, player)
		if isElement(player) then
			player:sendInfo("Du hast einen Zombie getötet!")
			self.m_ZombieKills[player] = self.m_ZombieKills[player]+1
		end
	end)

	PlayerManager:getSingleton():getWastedHook():register(
		function(player)
			if self.m_Player == player then
				self.m_Player:setPosition(-35.72, 1380.00, 9.42)
				self.m_Player:setDimension(0)
				player:sendInfo(_("Du bist gestorben! Das Zombie Survival wurde beendet!", player))
				delete(self)
				return true
			end
		end
	)
end

function ZombieSurvival:destructor()
	for index, object in pairs(self.m_Map) do
		object:destroy()
	end
	for index, zombie in pairs(self.m_Zombies) do
		if isElement(zombie) then
			zombie:destroy()
		end
	end
	if isTimer(self.m_CreatePickupTimer) then killTimer(self.m_CreatePickupTimer) end
	if isTimer(self.ZombieTimer) then killTimer(self.ZombieTimer) end
	if isTimer(self.m_IncreaseTimer) then killTimer(self.m_IncreaseTimer) end
	if isElement(self.m_Pickup) then self.m_Pickup:destroy() end
end

function ZombieSurvival:increaseZombies()


	self.m_ZombieTime = self.m_ZombieTime*0.95
	if self.m_ZombieTime < 500 then
		self.m_ZombieTime = 500
		if isTimer(self.m_IncreaseTimer) then killTimer(self.m_IncreaseTimer) end
	end

end

function ZombieSurvival:createPickup()
	self.m_Pickup = createPickup(math.random(82, 210), math.random(1728, 1798), 17.64, 2, self.m_PickupWeapons[math.random(1, #self.m_PickupWeapons)], 5000000, 30)
	self.m_Pickup:setDimension(self.m_Dimension)
end

function ZombieSurvival:addZombie()
	local zombie = Zombie:new(math.random(82, 210), math.random(1728, 1798), 17.64, 310, self.m_Dimension)
	table.insert(self.m_Zombies, zombie)
	self.ZombieTimer = setTimer(bind(self.addZombie, self), self.m_ZombieTime, 1)
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
