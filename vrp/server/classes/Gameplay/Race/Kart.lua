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
	"files/maps/Kart/Kartbahn.map"
}

local lapPrice = 50
local lapPackDiscount = 4

function Kart:constructor()
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

	self:loadMap(self:getRandomMap())

	--[[self.m_Map = MapParser:new(self:getRandomMap())
	self.m_Map:create()

	self.m_Toptimes = Toptimes:new(self.m_Map:getMapName())

	self.m_Players = {}
	self.m_Markers = self.m_Map:getElementsByType("marker")
	self.m_Spawnpoint = self.m_Map:getElementsByType("spawnpoint")[1]
	self.m_StartFinishMarker = self:getStartFinishMarker()

	self.m_onMarkerHit = bind(Kart.markerHit, self)
	self.m_OnKartDestroy = bind(Kart.onKartDestroy, self)

	for _, v in pairs(self.m_Markers) do
		v:setAlpha(0)
		addEventHandler("onMarkerHit", v, self.m_onMarkerHit)
	end

	--self.m_StartFinishMarker:setAlpha(0)
	addEventHandler("onMarkerHit", 	self.m_StartFinishMarker, self.m_onMarkerHit)
	addEventHandler("onMarkerHit", self.m_KartMarker, self.m_onMarkerHit)]]

	addEventHandler("startKartTimeRace", root, bind(Kart.startTimeRace, self))
	addEventHandler("requestKartDatas", root, bind(Kart.requestKartmapData, self))
end

function Kart:getRandomMap()
	return self.m_MapIndex[math.random(1, #self.m_MapIndex)]
end

function Kart:loadMap(mapFileName)
	if not self.m_Maps[mapFileName] then return end

	self.m_Map = self.m_Maps[mapFileName]
	self.m_Map:create()

	self.m_Toptimes = Toptimes:new(mapFileName)

	local startMarker = self.m_Map:getElementsByType("startmarker")[1]
	local infoPed = self.m_Map:getElementsByType("infoPed")[1]
	self.m_KartMarker = createMarker(startMarker.x, startMarker.y, startMarker.z, "cylinder", 1, 255, 125, 0, 125)
	self.m_Ped = createPed(infoPed.model, infoPed.x, infoPed.y, infoPed.z, infoPed.rz)
end

---
-- todo
---
function Kart:getStartFinishMarker()
	local spawnpoint = Vector3(self.m_Spawnpoint.x, self.m_Spawnpoint.y, self.m_Spawnpoint.z)

	local markerToSpawnpoint = {}
	for k, v in pairs(self.m_Markers) do
		local distance = getDistanceBetweenPoints3D(spawnpoint, v.position)
		table.insert(markerToSpawnpoint, {ID = k, marker = v, distance = distance})
	end

	table.sort(markerToSpawnpoint, function(a, b) return a.distance < b.distance end)
	table.remove(self.m_Markers, markerToSpawnpoint[1].ID)

	return markerToSpawnpoint[1].marker
end

function Kart:getRandomSpawnpoint()
	local spawnpoints = self.m_Map:getElementsByType("spawnpoint")
	return spawnpoints[math.random(1, #spawnpoints)]
end

function Kart:requestKartmapData()
	client:triggerEvent("receiveKartDatas", self.m_Map:getMapName(), self.m_Map:getMapAuthor(), self.m_Toptimes.m_Toptimes)
end

function Kart:markerHit(hitElement, matchingDimension)
	if not matchingDimension then return end
	if hitElement.type ~= "player" then return end
	--if hitElement.m_SupMode then return hitElement:sendError(_("Bitte deaktiviere den Support Modus!", hitElement)) end

	if source == self.m_KartMarker then
		if hitElement.vehicle then return end

		-- dev  --> create a gui like highscore gui to show toptimes and start time race
		--hitElement:triggerEvent("questionBox", _("Möchtest du ein Zeitrennen starten?", hitElement), "startKartTimeRace")
		hitElement:triggerEvent("showKartGUI", true)
		return
	end

	if not hitElement.vehicle then return end

	if source == self.m_StartFinishMarker then
		if self.m_Players[hitElement] then
			if self.m_Players[hitElement].state == "Flying" then
				if getTickCount() - self.m_Players[hitElement].startTick >= 20000 then
					self.m_Players[hitElement].startTick = getTickCount()
					self.m_Players[hitElement].state = "Running"
					outputChatBox("GO GO GO")

					local toptime = self.m_Toptimes:getToptimeFromPlayer(hitElement:getId())
					hitElement:triggerEvent("HUDRaceUpdateTimes", true, toptime.time)
				end
			elseif self.m_Players[hitElement].state == "Running" then
				if #self.m_Players[hitElement].markers == #self.m_Markers then
					-- get last toptimedatas to calc delta time
					local toptimeData = self.m_Toptimes:getToptimeFromPlayer(hitElement:getId())
					local oldToptime = toptimeData and toptimeData.time or 0

					local lapTime = getTickCount() - self.m_Players[hitElement].startTick
					self.m_Toptimes:addNewToptime(hitElement:getId(), lapTime)
					self.m_Players[hitElement].startTick = getTickCount()
					self.m_Players[hitElement].markers = {}
					self.m_Players[hitElement].laps = self.m_Players[hitElement].laps + 1

					local toptime = self.m_Toptimes:getToptimeFromPlayer(hitElement:getId())
					hitElement:triggerEvent("HUDRaceUpdateTimes", true, toptime.time)
				else
					outputChatBox("invalid markers count :/ Cant save the time")
					self.m_Players[hitElement].startTick = getTickCount()
					self.m_Players[hitElement].markers = {}
				end
			end
		end

		return
	end

	for k, v in pairs(self.m_Markers) do
		if v == source then
			if self.m_Players[hitElement] and self.m_Players[hitElement].state ~= "Flying" then
				for k2, v2 in pairs(self.m_Players[hitElement].markers) do
					if v == v2 then
						return
					end
				end

				table.insert(self.m_Players[hitElement].markers, v)
			end
		end
	end
end

function Kart:startTimeRace(laps, index)
	if not laps or not index then return end

	if isElement(client.kartVehicle) then
		destroyElement(client.kartVehicle)
	end

	local selectedLaps = laps
	local discount = lapPackDiscount*(index-1)
	local price = selectedLaps*lapPrice
	price = price - (price/100*discount)

	if client:getMoney() < price then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end
	client:takeMoney(price, ("Kart Zeitrennen (%s Runden)"):format(laps))

	client:triggerEvent("showKartGUI", false)

	local vehicle = TemporaryVehicle.create(self.m_Spawnpoint.model, self.m_Spawnpoint.x, self.m_Spawnpoint.y, self.m_Spawnpoint.z, self.m_Spawnpoint.rz)
	client:warpIntoVehicle(vehicle)
	vehicle:setEngineState(true)
	vehicle:addCountdownDestroy(10)
	vehicle:setDamageProof(true)

	vehicle.timeRacePlayer = client
	client.kartVehicle = vehicle

	addEventHandler("onElementDestroy", vehicle, self.m_OnKartDestroy)

	-- Set Stats
	setPedStat(client, 160, 1000)
	setPedStat(client, 229, 1000)
	setPedStat(client, 230, 1000)

	self.m_Players[client] = {vehicle = vehicle, laps = 1, state = "Flying", markers = {}, startTick = getTickCount() }
	client:triggerEvent("showRaceHUD", true)

	local toptime = self.m_Toptimes:getToptimeFromPlayer(client:getId())
	client:triggerEvent("HUDRaceUpdateTimes", true, toptime.time)
	client:triggerEvent("HUDRaceUpdateTimes", false, self.m_Toptimes.m_Toptimes[1].time)
end

function Kart:onKartDestroy()
	if self.m_Players[source.timeRacePlayer] then
		outputChatBox("kill")
		self.m_Players[source.timeRacePlayer] = nil

		if source.timeRacePlayer then
			source.timeRacePlayer:triggerEvent("showRaceHUD", false)
		end
	end

	removeEventHandler("onElementDestroy", source, self.m_OnKartDestroy)
end

--[[ Possible player states for time race
	Flying = fliegende Runde
	Running = kwt(5 Runden?)
]]

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
