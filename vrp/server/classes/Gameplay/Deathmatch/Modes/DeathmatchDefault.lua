-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/Modes/DeathmatchDefault.lua
-- *  PURPOSE:     Deathmatch Default Lobby class
-- *
-- ****************************************************************************

DeathmatchDefault = inherit(DeathmatchLobby)

function DeathmatchDefault:constructor(id, name, owner, map, weapons, mode, maxPlayer, password)
	DeathmatchLobby.constructor(self, id, name, owner, map, weapons, mode, maxPlayer, password)
end

function DeathmatchDefault:destructor()
	DeathmatchLobby.destructor(self)
end

function DeathmatchDefault:refreshGUI()
	for player, data in pairs(self:getPlayers()) do
		player:triggerEvent("deathmatchRefreshGUI", self.m_Players)
	end
end

function DeathmatchDefault:addPlayer(player)
	DeathmatchLobby.addPlayer(self, player)

	self.m_Players[player] = {
		["Kills"] = 0,
		["Deaths"] = 0
	}
	giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
	self:refreshGUI()
	DeathmatchLobby.respawnPlayer(self, player)
end


function DeathmatchDefault:removePlayer(player, isServerStop)
	DeathmatchLobby.removePlayer(self, player, isServerStop)
	self.m_Players[player] = nil

	if not isServerStop then
		player:triggerEvent("deathmatchCloseGUI")
		self:refreshGUI()
	end
end

function DeathmatchDefault:onWasted(player, killer, weapon)
	DeathmatchLobby.onWasted(self, player, killer, weapon)
	if killer then
		self:increaseKill(killer, weapon, true)
		self:increaseDead(player, weapon, true)
	end
	player.deathmatchLobby:respawnPlayer(player, true)
end


