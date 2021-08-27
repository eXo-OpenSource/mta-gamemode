-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/SuperSweeper/Modes/SuperSweeperDefault.lua
-- *  PURPOSE:     SuperSweeper Default Lobby class
-- *
-- ****************************************************************************

SuperSweeperTeam = inherit(SuperSweeperLobby)

SuperSweeperTeam.Name = "TDM"

function SuperSweeperTeam:constructor(id, name, owner, mode, maxPlayer, map, password)
	SuperSweeperLobby.constructor(self, id, name, owner, mode, maxPlayer, map, password)
end

function SuperSweeperTeam:destructor()
	SuperSweeperLobby.destructor(self)
end

function SuperSweeperTeam:refreshGUI()
	for player, data in pairs(self:getPlayers()) do
		player:triggerEvent("superSweeperRefreshGUI", self.m_Players)
	end
end

function SuperSweeperTeam:addPlayer(player)
	SuperSweeperLobby.addPlayer(self, player)

	self.m_Players[player] = {
		["Kills"] = 0,
		["Deaths"] = 0
	}

	self:refreshGUI()
	SuperSweeperLobby.respawnPlayer(self, player)
end


function SuperSweeperTeam:removePlayer(player, isServerStop)
	SuperSweeperLobby.removePlayer(self, player, isServerStop)
	self.m_Players[player] = nil

	if not isServerStop then
		-- player:triggerEvent("deathmatchCloseGUI")
		self:refreshGUI()
	end
end

function SuperSweeperTeam:onWasted(player, killer, weapon)
	SuperSweeperLobby.onWasted(self, player, killer, weapon)
	if killer then
		self:increaseKill(killer, weapon, true)
		self:increaseDead(player, weapon, true)
	end
	player.m_SuperSweeperLobby:respawnPlayer(player, true)
end


