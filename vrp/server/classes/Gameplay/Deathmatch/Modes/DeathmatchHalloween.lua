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
	[2] = "Zombies",
	[3] = "Neutral" -- only for markers
}
DeathmatchHalloween.MinPlayers = 4
DeathmatchHalloween.WaitingTime = 15 -- in seconds
DeathmatchHalloween.LivesPerPlayer = 5
DeathmatchHalloween.ZombieHeal = 10
DeathmatchHalloween.Spawns = {
	["Bewohner"] = {
		Vector3(-364.04, 2222.17, 42.48),
		Vector3(-358.17, 2239.25, 42.48),
		Vector3(-376.22, 2260.65, 43.06),
		Vector3(-431.26, 2240.80, 42.98),
		Vector3(-453.64, 2228.86, 42.47),
		Vector3(-431.26, 2240.80, 42.98),
		Vector3(-438.51, 2226.94, 43.12),
		Vector3(-403.55, 2248.98, 42.43),
		Vector3(-378.64, 2247.57, 42.62),
		Vector3(-384.31, 2205.86, 42.42),
		Vector3(-394.28, 2214.63, 42.43),
		Vector3( -410.58, 2225.93, 42.43),
	},
	["Zombies"] = {
		Vector3(-497.75, 2301.78, 64.55),
		Vector3(-475.56, 2324.11, 66.39),
		Vector3(-283.49, 2280.42, 71.23),
		Vector3(-283.49, 2280.42, 71.23),
		Vector3(-315.85, 2279.63, 70.01),
		Vector3(-324.26, 2155.72, 48.72),
		Vector3(-366.24, 2138.86, 58.79),
		Vector3(-414.49, 2129.68, 47.02),
		Vector3(-449.88, 2148.49, 48.14),
		Vector3(-483.73, 2165.30, 48.17),
		Vector3(-479.24, 2194.85, 42.17),
	}
}

DeathmatchHalloween.Markers = {
	Vector3(-404.66, 2258.09, 42.1),
	Vector3(-394.40, 2214.62, 42),
	Vector3(-377.28, 2242.12, 41.7),
	Vector3(-362.46, 2222.23, 42.1),
	Vector3(-394.40, 2214.62, 41.5),
	Vector3(-384.73, 2205.79, 41.5),
	Vector3(-427.46, 2203.27, 42.3),
	Vector3(-413.31, 2175.60, 40.8),


}

DeathmatchHalloween.MarkerColor = {
	["Bewohner"] = {0, 255, 0, 128},
	["Zombies"] = {255, 0, 0, 128},
	["Neutral"] = {255, 255, 255, 128}
}



function DeathmatchHalloween:constructor(id, name, owner, map, weapons, mode, maxPlayer, password)
	DeathmatchLobby.constructor(self, id, name, owner, map, weapons, mode, maxPlayer, password)
	self.m_Zombies = {}
	self.m_Residents = {}
	self.m_IsOpen = true
	self.m_HasStarted = false
	self.m_StartTimer = setTimer(bind(self.startRound, self), DeathmatchHalloween.WaitingTime*1000, 1)
	self.m_Markers = {}
	self.m_Colshapes = {}

	self.m_CheckMarkerBind = bind(self.checkMarkers, self)
	self.m_ZombieHealBind = bind(self.healZombies, self)
	self.m_MeleeBind = bind(self.onMeleeDamage, self)
end

function DeathmatchHalloween:destructor()
	DeathmatchLobby.destructor(self)

	if self.m_CheckMarkerTimer and isTimer(self.m_CheckMarkerTimer) then
		killTimer(self.m_CheckMarkerTimer)
	end
	if self.m_ZombieHealTimer and isTimer(self.m_ZombieHealTimer) then
		killTimer(self.m_ZombieHealTimer)
	end

	for index, marker in pairs (self.m_Markers) do
		marker:destroy()
	end

	for index, shape in pairs (self.m_Colshapes) do
		shape:destroy()
	end
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
		["minPlayers"] = DeathmatchHalloween.MinPlayers,
		["Markers"] = {
			["Zombies"] = self:countMarkers("Zombies"),
			["Bewohner"] = self:countMarkers("Bewohner")
		}
	}

	for player, data in pairs(self:getPlayers()) do

		player:triggerEvent("dmHalloweenRefreshGUI", self.m_Players, roundData)
	end
end

function DeathmatchHalloween:countMarkers(type)
	local count = 0
	for key, shape in pairs(self.m_Colshapes) do
		if shape.Team == type then
			count = count + 1
		end
	end
	return count
end

function DeathmatchHalloween:refreshMarkerGUI(player)
	local shapeData = false

	for index, shape in pairs(self.m_Colshapes) do
		if player:isWithinColShape(shape) then
			shapeData = {
				["AttackerTeam"] = self.m_Players[player].Team,
				["Owner"] = shape.Team,
				["Score"] = shape.Score
			}
		end
	end
	player:triggerEvent("dmHalloweenRefreshMarkerGUI", shapeData)

end


function DeathmatchHalloween:startRound()
	self.m_IsOpen = false
	self.m_HasStarted = true
	for player, data in pairs(self:getPlayers()) do
		player:setFrozen(false)
	end
	self:refreshGUI()
	self:spawnMarkers()
	self.m_CheckMarkerTimer = setTimer(self.m_CheckMarkerBind, 1000, 0)
	self.m_ZombieHealTimer = setTimer(self.m_ZombieHealBind, 5000, 0)
end

function DeathmatchHalloween:setPlayerTeamProperties(player, team)
	if team == DeathmatchHalloween.Teams[1] then
		table.insert(self.m_Residents, player)
		player:setModel(1)
		giveWeapon(player, 31, 9999, true) -- Todo Add Weapon-Select GUI
		addEventHandler("onPlayerDamage", player, self.m_MeleeBind)
		toggleControl(player, "sprint", true)
	else
		table.insert(self.m_Zombies, player)
		player:setModel(310)
		player:setArmor(0)
		toggleControl(player, "sprint", false)
	end
	player:sendShortMessage(_("Du wurdest ins Team der %s gesetzt!", player, team))
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
		["Lives"] = DeathmatchHalloween.LivesPerPlayer
	}

	for _, stat in ipairs({69, 70, 71, 72, 74, 76, 77, 78}) do
		setPedStat(player, stat, stat == 69 and 900 or 1000)
	end

	self:respawnPlayer(player, false, Randomizer:getRandomTableValue(DeathmatchHalloween.Spawns[team]))
	self:refreshGUI()

	player:setFrozen(true)
	player:triggerEvent("setHalloweenDarkness", true)
end


function DeathmatchHalloween:removePlayer(player, isServerStop)
	DeathmatchLobby.removePlayer(self, player, isServerStop)

	if self.m_Residents[player] then
		removeEventHandler("onPlayerDamage", player, self.m_MeleeBind)
	end

	self.m_Players[player] = nil
	table.remove(self.m_Zombies, table.find(self.m_Zombies, player))
	table.remove(self.m_Residents, table.find(self.m_Residents, player))

	player:setCorrectSkin()
	player:triggerEvent("setHalloweenDarkness")
	toggleControl(player, "sprint", true)

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
		self.m_Colshapes[index] = createColSphere(pos, 2)
		self.m_Colshapes[index]:setDimension(self.m_MapData["dim"])
		self.m_Colshapes[index].Marker = self.m_Markers[index]
		self.m_Colshapes[index].Team = DeathmatchHalloween.Teams[1]
		self.m_Colshapes[index].Id = index
		self.m_Colshapes[index].Score = 10
		addEventHandler("onColShapeLeave", self.m_Colshapes[index], function(player, dim)
			if player and player:getType() == "player" and self.m_Players[player] then
				player:triggerEvent("dmHalloweenRefreshMarkerGUI", false)
			end
		end)
	end
end

function DeathmatchHalloween:checkMarkers()
	for index, shape in pairs(self.m_Colshapes) do
		local newScore = 0
		for index, player in pairs(getElementsWithinColShape(shape, "player")) do
			if self.m_Players[player] and not player:isDead() then
				self.m_Players[player].isInMarker = true
				self:refreshMarkerGUI(player)
				if self.m_Players[player] then
					if self.m_Players[player].Team == DeathmatchHalloween.Teams[1] then
						newScore = newScore + 1
					else
						newScore = newScore - 1
					end
				end
			end
		end

		shape.Score = shape.Score + newScore
		if shape.Score >= 10 then
			shape.Score = 10
			if shape.Team ~= DeathmatchHalloween.Teams[1] then
				shape.Team = DeathmatchHalloween.Teams[1]
				shape.Marker:setColor(unpack(DeathmatchHalloween.MarkerColor[DeathmatchHalloween.Teams[1]]))
				self:sendShortMessage(string.format("Ein Marker wurde von den %s eingenommen!", DeathmatchHalloween.Teams[1]))
				self:refreshGUI()
			end
		elseif shape.Score == 0 then
			shape.Marker:setColor(unpack(DeathmatchHalloween.MarkerColor[DeathmatchHalloween.Teams[3]]))
			if (shape.Team ~= DeathmatchHalloween.Teams[3]) then
				self:sendShortMessage(string.format("Ein Marker wurde neuralisiert!"))
				shape.Team = DeathmatchHalloween.Teams[3]
			end
			self:refreshGUI()
		elseif shape.Score <= -10 then
			shape.Score = -10
			if shape.Team ~= DeathmatchHalloween.Teams[2] then
				shape.Team = DeathmatchHalloween.Teams[2]
				shape.Marker:setColor(unpack(DeathmatchHalloween.MarkerColor[DeathmatchHalloween.Teams[2]]))
				self:refreshGUI()
				self:sendShortMessage(string.format("Ein Marker wurde von den %s eingenommen!", DeathmatchHalloween.Teams[2]))
			end
		end
	end

	if self:countMarkers("Zombies") == #self.m_Colshapes then
		for key, player in pairs(self.m_Zombies) do
			player:triggerEvent("showDmHalloweenFinishedGUI", "Gewonnen", "Ihr habt die Runde gewonnen! Du erhälst 5 Kürbisse!")
		end
		for key, player in pairs(self.m_Residents) do
			player:triggerEvent("showDmHalloweenFinishedGUI", "Verloren", "Die Zombies haben alle eure Stadt erobert!")
		end
		delete(self)
	end
end

function DeathmatchHalloween:onWasted(player, killer, weapon)
	DeathmatchLobby.onWasted(self, player, killer, weapon)
	if killer then
		self:increaseKill(killer, weapon)
		self:increaseDead(player, weapon)
	end
	self.m_Players[player].Lives = self.m_Players[player].Lives - 1
	if self.m_Players[player].Lives <= 0 then
		self:removePlayer(player)
		self:checkAlivePlayers()
	else
		self:respawnPlayer(player, true, Randomizer:getRandomTableValue(DeathmatchHalloween.Spawns[self.m_Players[player].Team]))
		player:sendShortMessage(_("Du wurdest getötet, du hast noch %d Leben", player, self.m_Players[player].Lives), "Halloween-Deathmatch")
	end
end

function DeathmatchHalloween:respawnPlayer(player, dead, pos)
	DeathmatchLobby.respawnPlayer(self, player, dead, pos)
		setTimer(function()
			if self.m_Players[player].Team == DeathmatchHalloween.Teams[1] then
				giveWeapon(player, 31, 9999, true)
			else
				player:setArmor(0)
			end

		end,10000,1)
end

function DeathmatchHalloween:healZombies()
	for key, player in pairs(self.m_Zombies) do
		player:setHealth(player:getHealth() + DeathmatchHalloween.ZombieHeal)
	end
end

function DeathmatchHalloween:checkAlivePlayers()
	if #self.m_Zombies <= 0 then
		for key, player in pairs(self.m_Zombies) do
			player:triggerEvent("showDmHalloweenFinishedGUI", "Verloren", "Die Bewohner haben alle Zombies getötet!")
		end
		for key, player in pairs(self.m_Residents) do
			player:triggerEvent("showDmHalloweenFinishedGUI", "Gewonnen", "Ihr habt alle Zombies getötet!")
		end
		delete(self)
	end
	if #self.m_Residents <= 0 then
		for key, player in pairs(self.m_Zombies) do
			player:triggerEvent("showDmHalloweenFinishedGUI", "Gewonnen", "Ihr habt alle Bewohner getötet!")
		end
		for key, player in pairs(self.m_Residents) do
			player:triggerEvent("showDmHalloweenFinishedGUI", "Verloren", "Die Zombies haben alle Bewohner getötet!")
		end
		delete(self)
	end
end

function DeathmatchHalloween:onMeleeDamage(attacker, weapon)
	if not attacker or not weapon then return end
	if not self.m_Players[attacker] or not self.m_Players[source] then return end
	if not weapon == 0 then return end
	if self.m_Players[attacker].Team == DeathmatchHalloween.Teams[2] and self.m_Players[source].Team == DeathmatchHalloween.Teams[1] then
		source:kill(attacker)
		if source:getExecutionPed() then delete(source:getExecutionPed()) end
	end
end
