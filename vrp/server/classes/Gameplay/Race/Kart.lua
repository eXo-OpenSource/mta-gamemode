-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Kart.lua
-- *  PURPOSE:     Kart-Track class
-- *
-- ****************************************************************************
Kart = inherit(Singleton)
addRemoteEvents{"startKartTimeRace", "requestKartDatas"}

Kart.Maps = {
	"files/maps/Kart/Kartbahn.map",
	--"files/maps/Kart/EliteKartMap.map",
}

local lapPrice = 50
local lapPackDiscount = 4

function Kart:constructor()
	self.m_Players = {}
	self.m_MapIndex = {}
	self.m_Maps = {}

	-- Create and validate map instances
	for k, v in pairs(Kart.Maps) do
		if fileExists(v) then
			local mapFileName = v:match("[^/]+$"):sub(0, -5)
			if mapFileName then
				local instance = MapParser:new(v)
				local mapname = instance:getMapName()
				local author = instance:getMapAuthor()

				if mapname and author then
					self.m_Maps[mapFileName] = instance
					table.insert(self.m_MapIndex, mapFileName)
				else
					outputDebug(("Can't load map file '%s'. Invalid mapname or author"):format(v))
					delete(instance)
				end
			else
				outputDebug(("Can't load map file '%s'. Cant resolve filename from path"):format(v))
			end
		end
	end

	-- Function binds
	self.m_onStartMarkerHit = bind(Kart.startMarkerHit, self)
	self.m_onStartFinishMarkerHit = bind(Kart.startFinishMarkerHit, self)
	self.m_onCheckpointHit = bind(Kart.checkpointHit, self)
	self.m_OnKartDestroy = bind(Kart.onKartDestroy, self)
	self.m_OnPlayerQuit = bind(Kart.onPlayerQuit, self)
	self.m_KartAccessHandler = bind(Kart.onKartStartEnter, self)

	-- Load a random Map
	self:loadMap(self:getRandomMap())

	-- add default event handlers
	addEventHandler("startKartTimeRace", root, bind(Kart.startTimeRace, self))
	addEventHandler("requestKartDatas", root, bind(Kart.requestKartmapData, self))
end

---
-- load / unload Maps
--
function Kart:loadMap(mapFileName)
	if not self.m_Maps[mapFileName] then return end

	self.m_Map = self.m_Maps[mapFileName]
	self.m_Map:create()

	self.m_Toptimes = Toptimes:new(mapFileName)

	local startMarker = self.m_Map:getElementsByType("startmarker")[1]
	local infoPed = self.m_Map:getElementsByType("infoPed")[1]

	self.m_Checkpoints = self.m_Map:getElementsByType("checkpoint")
	self.m_Spawnpoints = self.m_Map:getElementsByType("spawnpoint")
	self.m_KartMarker = createMarker(startMarker.x, startMarker.y, startMarker.z, "cylinder", 1, 255, 125, 0, 125)
	self.m_Ped = createPed(infoPed.model, infoPed.x, infoPed.y, infoPed.z, infoPed.rz)
	self.m_StartFinishMarker = self:getStartFinishMarker()

	for _, v in pairs(self.m_Checkpoints) do
		addEventHandler("onMarkerHit", v, self.m_onCheckpointHit)
	end

	addEventHandler("onMarkerHit", 	self.m_StartFinishMarker, self.m_onStartFinishMarkerHit)
	addEventHandler("onMarkerHit", 	self.m_KartMarker, self.m_onStartMarkerHit)
end

function Kart:unloadMap()
	if table.size(self.m_Players) ~= 0 then return outputDebug("Can't unload map while player is playing") end
	if self.m_KartMarker then removeEventHandler("onMarkerHit", self.m_KartMarker, self.m_onStartMarkerHit) self.m_KartMarker:destroy() end
	if self.m_StartFinishMarker then removeEventHandler("onMarkerHit", self.m_StartFinishMarker, self.m_onStartFinishMarkerHit) end
	if self.m_Ped then self.m_Ped:destroy() end

	for _, v in pairs(self.m_Checkpoints) do
		removeEventHandler("onMarkerHit", v, self.m_onCheckpointHit)
	end

	if self.m_Map then self.m_Map:destroy(1) end
end

function Kart:getStartFinishMarker()
	local spawnpoint = self:getRandomSpawnpoint()
	local spawnpointPosition = Vector3(spawnpoint.x, spawnpoint.y, spawnpoint.z)

	local markerToSpawnpoint = {}
	for k, v in pairs(self.m_Checkpoints) do
		local distance = getDistanceBetweenPoints3D(spawnpointPosition, v.position)
		table.insert(markerToSpawnpoint, {ID = k, marker = v, distance = distance})
	end

	table.sort(markerToSpawnpoint, function(a, b) return a.distance < b.distance end)
	table.remove(self.m_Checkpoints, markerToSpawnpoint[1].ID)

	return markerToSpawnpoint[1].marker
end

function Kart:getRandomMap()
	return self.m_MapIndex[math.random(1, #self.m_MapIndex)]
end

function Kart:getRandomSpawnpoint()
	return self.m_Spawnpoints[math.random(1, #self.m_Spawnpoints)]
end

---
-- Marker handling
---
function Kart:startMarkerHit(hitElement, matchingDimension)
	if not matchingDimension then return end
	if hitElement.type ~= "player" then return end

	hitElement:triggerEvent("showKartGUI", true)
end

function Kart:startFinishMarkerHit(hitElement, matchingDimension)
	if not matchingDimension then return end
	if hitElement.type ~= "vehicle" then return end
	if not hitElement.controller then return end

	local player = hitElement.controller
	if not self.m_Players[player] then return end
	local playerPointer = self.m_Players[player]

	if playerPointer.state == "Flying" then
		if #playerPointer.checkpoints == #self.m_Checkpoints then
			playerPointer.state = "Running"
			playerPointer.startTick = getTickCount()
			player:triggerEvent("HUDRaceUpdate", true, playerPointer.laps)
		end
	elseif playerPointer.state == "Running" then
		if #playerPointer.checkpoints == #self.m_Checkpoints then
			if playerPointer.laps >= playerPointer.selectedLaps then
				self:onTimeRaceDone(player, playerPointer.vehicle)
				return
			end

			-- get last toptimedatas to calc delta time
			local toptimeData = self.m_Toptimes:getToptimeFromPlayer(player:getId())
			local oldToptime = toptimeData and toptimeData.time or 0

			local lapTime = getTickCount() - playerPointer.startTick
			local anyChange = self.m_Toptimes:addNewToptime(player:getId(), lapTime)
			playerPointer.startTick = getTickCount()
			playerPointer.checkpoints = {}
			playerPointer.laps = playerPointer.laps + 1

			local deltaTime = lapTime - oldToptime
			player:triggerEvent("HUDRaceUpdate", true, playerPointer.laps, deltaTime)
			if anyChange then self:syncToptimes() end
		else
			player:triggerEvent("HUDRaceUpdate", true)
			playerPointer.startTick = getTickCount()
			playerPointer.checkpoints = {}
		end
	end
end

function Kart:checkpointHit(hitElement, matchingDimension)
	if not matchingDimension then return end
	if hitElement.type ~= "vehicle" then return end
	if not hitElement.controller then return end

	local player = hitElement.controller
	if not self.m_Players[player] then return end
	local playerPointer = self.m_Players[player]

	if player.m_SupMode then return player:sendError(_("Bitte deaktiviere den Support Modus!", player)) end
	if hitElement.model ~= 571 then return end

	for _, v in pairs(self.m_Checkpoints) do
		if v == source then
			for _, v2 in pairs(playerPointer.checkpoints) do
				if v == v2 then
					return
				end
			end

			table.insert(playerPointer.checkpoints, v)
		end
	end
end

---
-- Sync toptimes with kart players
---
function Kart:syncToptimes(forcePlayer)
	if forcePlayer then
		forcePlayer:triggerEvent("HUDRaceUpdateTimes", self.m_Toptimes.m_Toptimes, forcePlayer:getId())
		return
	end

	for player in pairs(self.m_Players) do
		if isElement(player) then
			player:triggerEvent("HUDRaceUpdateTimes", self.m_Toptimes.m_Toptimes, player:getId())
		end
	end
end

function Kart:requestKartmapData()
	client:triggerEvent("receiveKartDatas", self.m_Map:getMapName(), self.m_Map:getMapAuthor(), self.m_Toptimes.m_Toptimes)
end

function Kart:startTimeRace(laps, index)
	if not laps or not index then return end

	if isElement(client.kartVehicle) then
		destroyElement(client.kartVehicle)
	end

	local selectedLaps = tonumber(laps)
	local discount = lapPackDiscount*(index-1)
	local price = selectedLaps*lapPrice
	price = price - (price/100*discount)

	if client:getMoney() < price then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end
	client:takeMoney(price, ("Kart Zeitrennen (%s Runden)"):format(laps))
	client:triggerEvent("showKartGUI", false)

	local spawnpoint = self:getRandomSpawnpoint()
	local vehicle = TemporaryVehicle.create(571, spawnpoint.x, spawnpoint.y, spawnpoint.z, spawnpoint.rz)
	client:warpIntoVehicle(vehicle)
	vehicle:setEngineState(true)
	vehicle.m_DisableToggleEngine = true
	vehicle:addCountdownDestroy(10)
	vehicle:setDamageProof(true)

	vehicle.timeRacePlayer = client
	client.kartVehicle = vehicle

	addEventHandler("onElementDestroy", vehicle, self.m_OnKartDestroy)
	addEventHandler("onVehicleStartEnter", vehicle, self.m_KartAccessHandler)
	addEventHandler("onPlayerQuit", client, self.m_OnPlayerQuit)

	-- Set Stats
	setPedStat(client, 160, 1000)
	setPedStat(client, 229, 1000)
	setPedStat(client, 230, 1000)

	self.m_Players[client] = {vehicle = vehicle, laps = 1, selectedLaps = selectedLaps, state = "Flying", checkpoints = {}, startTick = getTickCount()}
	client:triggerEvent("showRaceHUD", true, true)

	self:syncToptimes(client)
end

function Kart:onTimeRaceDone(player, vehicle)
	player:sendInfo(_("Du hast alle Runden abgeschlossen!", player))
	player:triggerEvent("HUDRaceUpdate", false)
	vehicle:setEngineState(false)

	setTimer(
		function(player, vehicle)
			vehicle:destroy()
			nextframe(
				function()
					player:setPosition(1297.421, 145.709, 20.022)
				end
			)
		end, 6000, 1, player, vehicle
	)
end

function Kart:onKartStartEnter(enteringPlayer)
	if source.timeRacePlayer ~= enteringPlayer then
		cancelEvent()
	end
end

function Kart:onKartDestroy()
	local player = source.timeRacePlayer

	if self.m_Players[player] then
		self.m_Players[player] = nil
		player:triggerEvent("showRaceHUD", false)

		setPedStat(player, 160, 0)
		setPedStat(player, 229, 0)
		setPedStat(player, 230, 0)

		removeEventHandler("onPlayerQuit", player, self.m_OnPlayerQuit)
	end

	removeEventHandler("onElementDestroy", source, self.m_OnKartDestroy)
end

function Kart:onPlayerQuit()
	source.kartVehicle:destroy()
end

--[[ Possible race states for kart race
	Waiting = Warten auf Spieler / Aufbau (o.ä.)
	Countdown
	Running
	SomeoneWon
	EveryoneFinished
]]

--[[

	NOTES:
		Features:
					Zeitrennen - Gegen die Uhr, mit möglicher einblendung eines Ghost-Drivers - Highscore für Rundenzeit

					Eventrennen - San News kann Event rennen starten. HUD mit Platzierung für jeden Spieler - Einstellbare Runden anzahl
									Benachrichtigung für die ersten 5 Plätze an die San News

		Sonstiges:
					Bei Runden, abfrage ob alle Marker durchfahren werden, damit nicht gecheatet wird
]]
