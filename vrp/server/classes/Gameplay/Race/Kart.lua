-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Kart.lua
-- *  PURPOSE:     Kart-Track class
-- *
-- ****************************************************************************
Kart = inherit(Singleton)
addRemoteEvents{"startKartTimeRace", "requestKartDatas", "sendKartGhost", "requestKartGhost"}

Kart.Maps = {
	"files/maps/Kart/Kartbahn.map",
	"files/maps/Kart/Kartbahn2.map",
	"files/maps/Kart/Karthalle.map",
	"files/maps/Kart/8-Track.map",
	"files/maps/Kart/CircleCourt.map",
	--"files/maps/Kart/Funny Tubes.map",
	"files/maps/Kart/CircleCourt.map",
}

local lapPrice = 50
local lapPackDiscount = 4

function Kart:constructor()
	self.m_Blip = Blip:new("Wheel.png", 1300.59, 140.70)

	self.m_Polygon = createColPolygon(1269, 66, 1269.32, 66.64, 1347.71, 31.07, 1382.18, 41.35, 1413.99, 117.01, 1314.21, 163.72)
	self.m_Timers = {}

	self.m_Players = {}
	self.m_MapIndex = {}
	self.m_Maps = {}
	self.m_GhostCache = {}

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
	addEventHandler("onColShapeHit", self.m_Polygon, bind(Kart.onKartZoneEnter, self))
	addEventHandler("onColShapeLeave", self.m_Polygon, bind(Kart.onKartZoneLeave, self))
	addEventHandler("sendKartGhost", root, bind(Kart.clientSendRecord, self))
	addEventHandler("requestKartGhost", root, bindAsync(Kart.clientRequestRecord, self))

	GlobalTimer:getSingleton():registerEvent(bind(self.changeMap, self), "KartMapChange", nil, nil, 00)
end

---
-- load / unload Maps
--
function Kart:changeMap(mapFileName)
	if self:unloadMap() then
		if not mapFileName then
			local rnd =  Randomizer:getRandomTableValue(Kart.Maps)
			rnd = rnd:gsub("files/maps/Kart/", "")
			mapFileName = rnd:gsub(".map", "")
		end
		self:loadMap(mapFileName)
	end
end

function Kart:loadMap(mapFileName)
	if not self.m_Maps[mapFileName] then return end

	self.m_Map = self.m_Maps[mapFileName]
	self.m_Map:create()

	self.m_Toptimes = Toptimes:new(mapFileName)
	self.m_MovementRecorder = MovementRecorder:new(self.m_Toptimes:getMapID())

	local startMarker = self.m_Map:getElementsByType("startmarker")[1]
	local infoPed = self.m_Map:getElementsByType("infoPed")[1]

	self.m_Checkpoints = self.m_Map:getElementsByType("checkpoint")
	self.m_Spawnpoints = self.m_Map:getElementsByType("spawnpoint")
	self.m_KartMarker = createMarker(startMarker.x, startMarker.y, startMarker.z, "cylinder", 1, 255, 125, 0, 125)
	self.m_Ped = NPC:new(infoPed.model, infoPed.x, infoPed.y, infoPed.z, infoPed.rz)
	self.m_Ped:setImmortal(true)
	self.m_StartFinishMarker = self:getStartFinishMarker()

	self.m_PlayRespawnPosition = self.m_Ped.matrix:transformPosition(Vector3(0, 5, 0))

	for _, v in pairs(self.m_Checkpoints) do
		addEventHandler("onMarkerHit", v, self.m_onCheckpointHit)
	end

	addEventHandler("onMarkerHit", 	self.m_StartFinishMarker, self.m_onStartFinishMarkerHit)
	addEventHandler("onMarkerHit", 	self.m_KartMarker, self.m_onStartMarkerHit)
end

function Kart:unloadMap()
	if table.size(self.m_Players) ~= 0 then outputDebug("Can't unload map while player is playing") return false end
	if self.m_KartMarker then removeEventHandler("onMarkerHit", self.m_KartMarker, self.m_onStartMarkerHit) self.m_KartMarker:destroy() end
	if self.m_StartFinishMarker then removeEventHandler("onMarkerHit", self.m_StartFinishMarker, self.m_onStartFinishMarkerHit) end
	if self.m_Ped then self.m_Ped:destroy() end

	delete(self.m_Toptimes)
	delete(self.m_MovementRecorder)
	self.m_GhostCache = {}

	for _, v in pairs(self.m_Checkpoints) do
		removeEventHandler("onMarkerHit", v, self.m_onCheckpointHit)
	end

	if self.m_Map then self.m_Map:destroy(1) end
	return true
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
			player:sendShortMessage(_("Einführungsrunde abgeschlossen!", player))
			playerPointer.state = "Running"
			playerPointer.startTick = getTickCount()
			playerPointer.checkpoints = {}
		end
	elseif playerPointer.state == "Running" then
		if #playerPointer.checkpoints == #self.m_Checkpoints then
			-- get last toptimedatas to calc delta time
			local toptimeData = self.m_Toptimes:getToptimeFromPlayer(player:getId())
			local oldToptime = toptimeData and toptimeData.time or false

			local lapTime = getTickCount() - playerPointer.startTick
			local anyChange = self.m_Toptimes:addNewToptime(player:getId(), lapTime)
			playerPointer.startTick = getTickCount()
			playerPointer.checkpoints = {}
			playerPointer.laps = playerPointer.laps + 1

			if oldToptime then
				local deltaTime = lapTime - oldToptime
				player:triggerEvent("HUDRaceUpdateDelta", deltaTime)

				if deltaTime < 0 then
					player:giveAchievement(71) -- Kart Enthusiast
				end
			end

			if anyChange then
				self:syncToptimes()
				player:triggerEvent("KartRequestGhostDriver", lapTime)

				local toptimeData, pos = self.m_Toptimes:getToptimeFromPlayer(player:getId())
				if pos == 1 then
					player:giveAchievement(59) -- Kart Pro
				end
			end

			if playerPointer.laps > playerPointer.selectedLaps then
				self:onTimeRaceDone(player, playerPointer.vehicle)
				if playerPointer.selectedLaps >= 50 then
					player:giveAchievement(76) -- Kart Le Mans
				end
			end

			player:giveAchievement(58) -- Kartdriver
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

	addEventHandler("onElementDestroy", vehicle, self.m_OnKartDestroy, false)
	addEventHandler("onVehicleStartEnter", vehicle, self.m_KartAccessHandler)
	addEventHandler("onPlayerQuit", client, self.m_OnPlayerQuit)

	-- Set Stats
	setPedStat(client, 160, 1000)
	setPedStat(client, 229, 1000)
	setPedStat(client, 230, 1000)

	self.m_Players[client] = {vehicle = vehicle, laps = 1, selectedLaps = selectedLaps, state = "Flying", checkpoints = {}, startTick = getTickCount()}
	client:triggerEvent("showRaceHUD", true, true)
	client:triggerEvent("KartStart", self.m_StartFinishMarker, self.m_Checkpoints, selectedLaps)
	client:sendInfo("Vollende eine Einführungsrunde!")

	self:syncToptimes(client)
end

function Kart:onTimeRaceDone(player, vehicle)
	player:sendInfo(_("Du hast alle Runden abgeschlossen!", player))
	player:triggerEvent("HUDRaceUpdate", false)
	player:triggerEvent("KartStop")
	vehicle:setEngineState(false)

	setTimer(
		function(player, vehicle)
			vehicle:destroy()
			nextframe(
				function()
					player:setPosition(self.m_PlayRespawnPosition)
				end
			)
		end, 3000, 1, player, vehicle
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
		player:triggerEvent("KartStop")

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

---
-- Kart zone handling
---
function Kart:onKartZoneEnter(hitElement, matchingDimension)
	if not matchingDimension then return end
	if hitElement.type ~= "vehicle" then return end

	for _, v in pairs(self.m_Players) do
		if v.vehicle == hitElement then
			return
		end
	end

	if hitElement:getVehicleType() == VehicleType.Plane or hitElement:getVehicleType() == VehicleType.Helicopter then
		if not hitElement.controller then return hitElement:respawn() end

		local pos = hitElement:getPosition()
		local vel = hitElement:getVelocity()
		if pos.z <= 40 then
			hitElement:setPosition(pos.x, pos.y, 45)
			hitElement:setVelocity(vel.x, vel.y, 2)
		end

		self.m_Timers[hitElement] = setTimer(
			function(vehicle)
				if not vehicle:isWithinColShape(self.m_Polygon) then return self.m_Timers[vehicle]:destroy() end
				local pos = hitElement:getPosition()
				local vel = hitElement:getVelocity()
				if pos.z <= 40 then
					hitElement:setPosition(pos.x, pos.y, 45)
					hitElement:setVelocity(vel.x, vel.y, 2)
				end
			end, 200, 0, hitElement
		)

		return
	end

	if hitElement.controller then
		hitElement.controller:sendError("Du darfst die Kartbahn nicht mit einem Fahrzeug betreten!")
	end

	hitElement:setPosition(1268.794, 196.042, 19.414)
	hitElement:setRotation(0, 0, 333)
end

function Kart:onKartZoneLeave(leaveElement, matchingDimension)
	if not matchingDimension then return end
	if leaveElement.type ~= "vehicle" then return end

	for _, v in pairs(self.m_Players) do
		if v.vehicle == leaveElement then
			local player = leaveElement.controller
			leaveElement:destroy()
			nextframe(
				function()
					player:setPosition(player.matrix:transformPosition(Vector3(0, 0, 1)))
				end
			)
			return
		end
	end
end

-- Ghostdriver handling
function Kart:clientSendRecord(record)
	local json = toJSON(record, true)
	if json then
		self.m_MovementRecorder:saveRecord(client, json)
		self.m_GhostCache[client:getId()] = json
	end
end

function Kart:clientRequestRecord(id)
	local c = client
	local playerID = self.m_Toptimes:getPlayerFromToptime(id)

	if playerID then
		local record = self.m_GhostCache[playerID] or self.m_MovementRecorder:getRecord(playerID)

		if record then
			self.m_GhostCache[playerID] = record

			triggerLatentClientEvent(c, "KartReceiveGhostDriver", 8388608, resourceRoot, record)
			c:sendInfo("Geist übernommen!")
			return
		end
	end

	c:sendError("Für den Spieler ist kein Geist gespeichert!")
end
