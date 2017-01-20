-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/DeathmatchRoom.lua
-- *  PURPOSE:     Deathmatch Room class
-- *
-- ****************************************************************************

DeathmatchRoom = inherit(Object)
DeathmatchRoom.Types = {[1] = "permanent", [2] = "temporary"}

function DeathmatchRoom:constructor(id, name, owner, map, weapons, mode, maxPlayer)
	self.m_Id = id
	self.m_Type = owner == "Server" and DeathmatchRoom.Types[1] or DeathmatchRoom.Types[2]
	self.m_Name = name
	self.m_Map = map
	self.m_Weapons = weapons
	self.m_Mode = mode
	self.m_MaxPlayer = maxPlayer

	self.m_Players = {}
	self:loadMap()

	if self.m_Type == DeathmatchRoom.Types[1] then
		self.m_Owner = "Server"
		self.m_OwnerName = "eXo-RL"
	else
		self.m_Owner = owner
		self.m_OwnerName = owner:getName()
		self:addPlayer(owner)
	end
end

function DeathmatchRoom:loadMap()
	if not DeathmatchManager.Maps[self.m_Map] then
		outputDebugString("DeathmatchRoom: Invalid Map")
		return
	end
	local map = DeathmatchManager.Maps[self.m_Map]
	self.m_MapName = map.Name
	self.m_MapData = {}
	self.m_MapData["dim"] = 2000+self.m_Id
	self.m_MapData["int"] = map.Interior
	self.m_MapData["spawns"] = map.Spawns
end

function DeathmatchRoom:getPlayers()
	local players = {}
	local count = 0
	for player, data in pairs(self.m_Players) do
		if isElement(player) then
			players[player] = data
			count = count + 1
		else
			self:removePlayer(player)
		end
	end
	return players, count
end

function DeathmatchRoom:sendShortMessage(text, ...)
	for player, data in pairs(self:getPlayers()) do
		player:sendShortMessage(_(text, player), "Deathmatch-Arena", {255, 125, 0}, ...)
	end
end

function DeathmatchRoom:getPlayerCount()
	local _, count = self:getPlayers()
	return count
end

function DeathmatchRoom:addPlayer(player)
	self.m_Players[player] = {
		["Kills"] = 0,
		["Deaths"] = 0
	}
	takeAllWeapons(player)
	giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
	player.m_RemoveWeaponsOnLogout = true
	self:respawnPlayer(player)
	player.deathmatchRoom = self
	self:sendShortMessage(player:getName().." ist beigetreten!")
end

function DeathmatchRoom:respawnPlayer(player, dead)
	local pos = Randomizer:getRandomTableValue(self.m_MapData["spawns"])
	if dead then
		fadeCamera(player, false, 2)
		player:triggerEvent("Countdown", 10, "Respawn in")
		setTimer(function()
			local skin = player:getModel()
			spawnPlayer(player, pos, 0, skin, self.m_MapData["int"], self.m_MapData["dim"])
			player:setCameraTarget(player)
			player:fadeCamera(true, 1)
			player:triggerEvent("CountdownStop", "Respawn in")
			giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
		end,10000,1)
	else
		player:setDimension(self.m_MapData["dim"])
		player:setInterior(self.m_MapData["int"])
		player:setPosition(pos)
		giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
	end
end

function DeathmatchRoom:removePlayer(player)
	self.m_Players[player] = nil
	if isElement(player) then
		takeAllWeapons(player)
		player.m_RemoveWeaponsOnLogout = nil
		player:setDimension(self.m_MapData["dim"])
		player:setInterior(self.m_MapData["int"])
		player:setPosition(Randomizer:getRandomTableValue(self.m_MapData["spawns"]))
		player.deathmatchRoom = nil
		self:sendShortMessage(player:getName().." hat die Arena verlassen!")
	end
end
