-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/SniperGame.lua
-- *  PURPOSE:     SniperGame for Deathmatch-Script
-- *
-- ****************************************************************************

SniperGame = inherit(Object)

SniperGame.Positions = {
	{-682.33, 2075.49, 60.38, 241.17},
	{-671.85, 2064.23, 60.24, 241.5},
	{-654.30, 2066.57, 60.19, 235.85},
	{-621.16, 2059.04, 60.19, 230.21},
	{-623.49, 2038.68, 60.19, 240.86},
	{-628.52, 2049.55, 60.38, 239},
	{-637.20, 2061.85, 60.19, 236.16}
}

function SniperGame.initalize()
	--[[
	--local sniperPed = createPed(162 ,-531.40, 1972.36, 60.56, 333.32)
	--sniperPed:setFrozen(true)
	--local sniperMarker = createMarker(-530.19, 1974.61, 59.5, "cylinder", 1, 255, 0, 0, 125)
	--Blip:new("SniperGame.png", -530.19, 1974.61) -- Todo: Change Blip

	addEventHandler("onMarkerHit", sniperMarker, function(hitElement, dim)
		if hitElement:getType() == "player" and dim and not hitElement.vehicle then
			hitElement:triggerEvent("showMinigameGUI", "SniperGame")
		end
	end)

	addRemoteEvents{"startSniperGame", "SniperGame:onPedDamage"}
	addEventHandler("startSniperGame", root, function()
		local instance = SniperGame:new()
		instance:addPlayer(client)
		local index = #MinigameManager.Current+1
		MinigameManager.Current[index] = instance
		MinigameManager.Current[index].Type = "SniperGame"
		client.Minigame = MinigameManager.Current[index]
	end)

	addEventHandler("SniperGame:onPedDamage", root, function(ped, bodypart)
		if bodypart == 9 then
			ped:setHeadless(true)
			ped:kill(client, 34, 9)
			client:giveWeapon(34, 2, true)
		else
			ped:setAnimation("ped", "WOMAN_walknorm")
		end
	end)
	]]
end

function SniperGame:constructor()

	self.m_Dimension = math.random(1, 999) -- Testing
	self.m_Peds = {}
	self.m_PedKills = {}
	self.m_PedTimers = {}
	self.m_PedTime = 8000
	self.m_IncreaseTimer = setTimer(bind(self.increasePeds, self), 10000, 0)

	self.m_TargetSphere = createColPolygon(-548.38, 1986.61, -530.92, 2008.69, -526.18, 2004.47, -543.17, 1982.32, -548.38, 1986.61)
	self.m_TargetSphere:setDimension(self.m_Dimension)
	addEventHandler("onColShapeHit", self.m_TargetSphere, bind(self.onColshapeHit, self))

	self.m_PlayerSphere = createColSphere( -596.35, 2015.65, 77.00, 8)
	self.m_PlayerSphere:setDimension(self.m_Dimension)
	addEventHandler("onColShapeLeave", self.m_PlayerSphere, function(hitElement, dim)
		if hitElement:getType() == "player" and dim then
			hitElement:sendInfo(_("Du hast den Sniper-Bereich verlassen!", hitElement))
			self:removePlayer(hitElement)
		end
	end)

	self:addPed()
	self:loadMap()

end

function SniperGame:destructor()
	for index, object in pairs(self.m_Map) do
		if isElement(object) then
			object:destroy()
		end
	end
	for index, ped in pairs(self.m_Peds) do
		delete(ped)
	end
	for player, score in pairs(self.m_PedKills) do
		if score then
			self:removePlayer(player)
		end
	end
	for index, timer in pairs(self.m_PedTimers) do
		if isTimer(timer) then killTimer(timer) end
	end

	if isTimer(self.m_IncreaseTimer) then killTimer(self.m_IncreaseTimer) end
	if isElement(self.m_TargetSphere) then self.m_TargetSphere:destroy() end
	if isElement(self.m_PlayerSphere) then self.m_PlayerSphere:destroy() end

end


function SniperGame:onColshapeHit(hitElement, dim)
	if hitElement:getType() == "ped" and dim then
		for player, score in pairs(self.m_PedKills) do
			if score then
				player:sendInfo(_("Ein Ped hat die Linie überschritten! Score: %d", player, self.m_PedKills[player]))
			end
		end
		delete(self)
	end
end

function SniperGame:getRandomPosition()
	return Vector3(math.random(82, 210), math.random(1728, 1798), 17.64)
end

function SniperGame:addPlayer(player)
	player:giveAchievement(55)

	self.m_PedKills[player] = 0
	player:setDimension(self.m_Dimension)
	player:setPosition(-597.71, 2020.09, 77.90)
	player:setInterior(0)
	player:setArmor(0)
	player:setHealth(100)
	takeAllWeapons(player)
	player:giveWeapon(34, 15, true)
	player:triggerEvent("showScore")
end

function SniperGame:removePlayer(player)
	--player:spawn()
	player:fadeCamera(true, 1)
	player:setHealth(100)
	player:setDimension(0)
	player:setInterior(0)
	player:setPosition(-526.94, 1974.63, 60.41)

	MinigameManager:getSingleton().m_SniperGameHighscore:addHighscore(player:getId(), self.m_PedKills[player])
	self.m_PedKills[player] = nil
	takeAllWeapons(player)
	player:triggerEvent("hideScore")

	-- Check for Freaks Achievement
	if MinigameManager:getSingleton():checkForFreaks(player) then
		player:giveAchievement(22)
	end
end

function SniperGame:getPlayers()
	local players = {}
	for player, score in pairs(self.m_PedKills) do
		if score then
			table.insert(players, player)
		end
	end
	return players
end

function SniperGame:increasePeds()
	self.m_PedTime = self.m_PedTime*0.95
	if self.m_PedTime < 250 then
		self.m_PedTime = 250
		if isTimer(self.m_IncreaseTimer) then killTimer(self.m_IncreaseTimer) end
	end
end

function SniperGame:addPed()
	local rndPos = SniperGame.Positions[math.random(1, #SniperGame.Positions)]
	local x, y, z, rot = unpack(rndPos)
	self:createSmoke(Vector3(x, y, z))
	self.m_PedTimers[#self.m_PedTimers+1] = setTimer(bind(self.spawnPed, self), 2500, 1, Vector3(x, y, z), rot)
	self.m_PedTimers[#self.m_PedTimers+1] = setTimer(bind(self.addPed, self), self.m_PedTime, 1)
end

function SniperGame:spawnPed(pos, rot)
	local ped = createPed(183, pos, rot)
	ped:setDimension(self.m_Dimension)
	if math.random(0,5) == 5 then
		ped:setAnimation("ped", "woman_run")
	else
		ped:setAnimation("ped", "WOMAN_walknorm")
	end
	for player, score in pairs(self.m_PedKills) do
		if player and isElement(player) then
			if score then
				player:triggerEvent("addPedDamageHandler", ped)
			end
		else
			self.m_PedKills[player] = nil
		end
	end

	addEventHandler("onPedWasted", ped, function(ammo, player)
		self.m_PedKills[player] = self.m_PedKills[player]+1
		player:triggerEvent("setScore", self.m_PedKills[player])
	end)

	table.insert(self.m_Peds, ped)
end

function SniperGame:createSmoke(pos)
	local smoker = createObject(2780, pos.x, pos.y, pos.z-1)
	smoker:setAlpha(0)
	smoker:setDimension(self.m_Dimension)
	smoker:setCollisionsEnabled(false)
	setTimer(destroyElement, 3000, 1, smoker)
end

function SniperGame:loadMap()
	self.m_Map = {
		createObject(3578, -545.59998, 1990.7, 58.7, 0, 0, 52),
		createObject(3578, -539.40002, 1998.7, 58.7, 0, 0, 51.998),
		createObject(3578, -534, 2005.5, 58.7, 0, 0, 51.998 )
	}
	for index, object in pairs(self.m_Map) do
		object:setDimension(self.m_Dimension)
	end
end
