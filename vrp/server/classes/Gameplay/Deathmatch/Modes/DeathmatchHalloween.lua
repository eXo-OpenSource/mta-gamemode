-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/Modes/DeathmatchHalloween.lua
-- *  PURPOSE:     Deathmatch Default Lobby class
-- *
-- ****************************************************************************

DeathmatchHalloween = inherit(DeathmatchLobby)

function DeathmatchHalloween:constructor(id, name, owner, map, weapons, mode, maxPlayer, password)
	DeathmatchLobby.constructor(self, id, name, owner, map, weapons, mode, maxPlayer, password)
end

function DeathmatchHalloween:destructor()
	DeathmatchLobby.destructor(self)
end

function DeathmatchHalloween:refreshGUI()
	for player, data in pairs(self:getPlayers()) do
		player:triggerEvent("deathmatchRefreshGUI", self.m_Players)
	end
end

function DeathmatchHalloween:addPlayer(player)
	DeathmatchLobby.addPlayer(self, player)

	self.m_Players[player] = {
		["Kills"] = 0,
		["Deaths"] = 0
	}
	giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI

	for _, stat in ipairs({69, 70, 71, 72, 74, 76, 77, 78}) do
		setPedStat(player, stat, stat == 69 and 900 or 1000)
	end

	self:respawnPlayer(player)
	self:refreshGUI()
end


function DeathmatchHalloween:removePlayer(player, isServerStop)
	DeathmatchLobby.removePlayer(self, player, isServerStop)
	self.m_Players[player] = nil

	if not isServerStop then
		player:triggerEvent("deathmatchCloseGUI")
		self:refreshGUI()
	end
end
