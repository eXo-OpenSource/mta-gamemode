-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/Modes/DeathmatchHalloween.lua
-- *  PURPOSE:     Deathmatch Default Lobby class
-- *
-- ****************************************************************************

DeathmatchHalloween = inherit(DeathmatchLobby)
DeathmatchHalloween.Teams = {
	[1] = "Bewohner",
	[2] = "Zombie"
}
function DeathmatchHalloween:constructor(id, name, owner, map, weapons, mode, maxPlayer, password)
	DeathmatchLobby.constructor(self, id, name, owner, map, weapons, mode, maxPlayer, password)
	self.m_Zombies = {}
	self.m_Residents = {}
end

function DeathmatchHalloween:destructor()
	DeathmatchLobby.destructor(self)
end

function DeathmatchHalloween:refreshGUI()
	for player, data in pairs(self:getPlayers()) do
		player:triggerEvent("dmHalloweenRefreshGUI", self.m_Players)
	end
end

function DeathmatchHalloween:setPlayerTeamProperties(player, team)
	if team == DeathmatchHalloween.Teams[1] then
		table.insert(self.m_Residents, player)
		player:setModel(1)
		giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
		player:sendShortMessage(_("Du wurdest ins %s-Team gesetzt!", player, team))
	else
		table.insert(self.m_Zombies, player)
		player:setModel(310)
	end
end

function DeathmatchHalloween:addPlayer(player)
	DeathmatchLobby.addPlayer(self, player)
	local team
	if table.size(self.m_Zombies) <= table.size(self.m_Residents) then
		team = DeathmatchHalloween.Teams[2]
	else
		team = DeathmatchHalloween.Teams[1]
	end

	self:setPlayerTeamProperties(player, team)

	self.m_Players[player] = {
		["Kills"] = 0,
		["Deaths"] = 0,
		["Team"] = team
	}


	for _, stat in ipairs({69, 70, 71, 72, 74, 76, 77, 78}) do
		setPedStat(player, stat, stat == 69 and 900 or 1000)
	end

	self:respawnPlayer(player)
	self:refreshGUI()
end


function DeathmatchHalloween:removePlayer(player, isServerStop)
	DeathmatchLobby.removePlayer(self, player, isServerStop)
	self.m_Players[player] = nil
	table.remove(self.m_Zombies, table.find(self.m_Zombies, player))
	table.remove(self.m_Residents, table.find(self.m_Residents, player))

	player:setCorrectSkin()

	if not isServerStop then
		player:triggerEvent("dmHalloweenCloseGUI")
		self:refreshGUI()
	end
end

function DeathmatchHalloween:isDamageAllowed(player, attacker, weapon)
	if self.m_Players[player] and self.m_Players[attacker] then
		if self.m_Players[player].Team ~= self.m_Players[attacker].Team then
			return true
		else
			attacker:sendShortMessage("Du darfst nicht auf Teamkollegen schießen!")
		end
	end
	return false
end
