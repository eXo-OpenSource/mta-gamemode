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
	[2] = "Zombies"
}
DeathmatchHalloween.MinPlayers = 4
DeathmatchHalloween.WaitingTime = 30 -- in seconds
DeathmatchHalloween.Spawns = {
	["Bewohner"] = {
		Vector3(-1317.41, 2526.57, 87.55),
		Vector3(-1307.98, 2543.80, 87.74)
	},
	["Zombies"] = {
		Vector3(-1227.48, 2515.95, 110.62),
		Vector3(-1197.02, 2503.23, 112.16),
		Vector3(-1193.24, 2412.06, 117.67)
	}
}

DeathmatchHalloween.Markers = {
	Vector3(-1316.82, 2527.12, 87.58),
	Vector3(-1290.74, 2512.20, 87.04)
}

DeathmatchHalloween.MarkerColor = {
	["Bewohner"] = {0, 255, 0, 255},
	["Zombies"] = {255, 0, 0, 255}
}

function DeathmatchHalloween:constructor(id, name, owner, map, weapons, mode, maxPlayer, password)
	DeathmatchLobby.constructor(self, id, name, owner, map, weapons, mode, maxPlayer, password)
	self.m_Zombies = {}
	self.m_Residents = {}
	self.m_IsOpen = true
	self.m_HasStarted = false
	self.m_StartTimer = setTimer(bind(self.startRound, self), DeathmatchHalloween.WaitingTime*1000, 1)
	self.m_Markers = {}
end

function DeathmatchHalloween:destructor()
	DeathmatchLobby.destructor(self)
end

function DeathmatchHalloween:refreshGUI()
	local countdown = 0
	if self.m_StartTimer and isTimer(self.m_StartTimer) then
		countdown = self.m_StartTimer:getDetails()
	end

	local roundData = {
		["started"] = self.m_HasStarted,
		["timeToStart"] = countdown,
		["playersCount"] = table.size(self.m_Players),
		["minPlayers"] = DeathmatchHalloween.MinPlayers
	}

	for player, data in pairs(self:getPlayers()) do
		player:triggerEvent("dmHalloweenRefreshGUI", self.m_Players, roundData)
	end
end

function DeathmatchHalloween:startRound()
	self.m_IsOpen = false
	self.m_HasStarted = true
	for player, data in pairs(self:getPlayers()) do
		player:setFrozen(false)
	end	
	self:refreshGUI()
	self:spawnMarkers()
end

function DeathmatchHalloween:setPlayerTeamProperties(player, team)
	if team == DeathmatchHalloween.Teams[1] then
		table.insert(self.m_Residents, player)
		player:setModel(1)
		giveWeapon(player, Randomizer:getRandomTableValue(self.m_Weapons), 9999, true) -- Todo Add Weapon-Select GUI
		player:sendShortMessage(_("Du wurdest ins Team der %s gesetzt!", player, team))
	else
		table.insert(self.m_Zombies, player)
		player:setModel(310)
	end
end

function DeathmatchHalloween:addPlayer(player)
	if not self.m_IsOpen then
		player:sendError("Die Arena ist bereits geschlossen! Bitte komme zur nächsten Runde wieder")
		return
	end
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
		["Team"] = team,
	}

	for _, stat in ipairs({69, 70, 71, 72, 74, 76, 77, 78}) do
		setPedStat(player, stat, stat == 69 and 900 or 1000)
	end

	self:respawnPlayer(player, false, nil, nil, Randomizer:getRandomTableValue(DeathmatchHalloween.Spawns[team]))
	self:refreshGUI()

	player:setFrozen(true)
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

function DeathmatchHalloween:spawnMarkers()
	for index, pos in pairs (DeathmatchHalloween.Markers) do
		self.m_Markers[index] = createMarker(pos, "cylinder", 2, unpack(DeathmatchHalloween.MarkerColor["Bewohner"]))
		self.m_Markers[index]:setDimension(self.m_MapData["dim"])
		addEventHandler("onMarkerHit", self.m_Markers[index], bind(self.onMarkerHit, self))
	end
end

function DeathmatchHalloween:onMarkerHit(player, dim)
	if player and player:getType() == "player" and dim then
		source:setColor(unpack(DeathmatchHalloween.MarkerColor[self.m_Players[player].Team]))
		self:sendShortMessage(string.format("Ein Marker wurde von den %s eingenommen!", self.m_Players[player].Team))
	end
end