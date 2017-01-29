-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Kart.lua
-- *  PURPOSE:     Kart-Track class
-- *
-- ****************************************************************************
Kart = inherit(Singleton)
addRemoteEvents{"startKartTimeRace", "requestKartToptimes"}

Kart.Maps = {
	"files/maps/Kart/Kartbahn.map"
}

function Kart:constructor()
	self.m_KartMarker = createMarker(1311.1, 141.6, 19.8, "cylinder", 1, 255, 125, 0, 125)
	self.m_Ped = createPed(64, 1311.8, 143.10001, 20.7, 147.252)

	self.m_Map = MapParser:new(self:getRandomMap())
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
	addEventHandler("onMarkerHit", self.m_KartMarker, self.m_onMarkerHit)

	addEventHandler("startKartTimeRace", root, bind(Kart.startTimeRace, self))
	addEventHandler("requestKartToptimes", root, bind(Kart.requestToptimes, self))
end

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

function Kart:getRandomMap()
	return Kart.Maps[math.random(1, #Kart.Maps)]
end

function Kart:getRandomSpawnpoint()
	local spawnpoints = self.m_Map:getElementsByType("spawnpoint")
	return spawnpoints[math.random(1, #spawnpoints)]
end

function Kart:requestToptimes()
	client:triggerEvent("KartReceiveToptimes", self.m_Map:getMapName(), self.m_Toptimes.m_Toptimes)
end

function Kart:markerHit(hitElement, matchingDimension)
	if not matchingDimension then return end
	if hitElement.type ~= "player" then return end
	--if hitElement.m_SupMode then return hitElement:sendError(_("Bitte deaktiviere den Support Modus!", hitElement)) end

	if source == self.m_KartMarker then
		if hitElement.vehicle then return end

		-- dev  --> create a gui like highscore gui to show toptimes and start time race
		--hitElement:triggerEvent("questionBox", _("Möchtest du ein Zeitrennen starten?", hitElement), "startKartTimeRace")
		hitElement:triggerEvent("showKartGUI")
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
				end
			elseif self.m_Players[hitElement].state == "Running" then
				if #self.m_Players[hitElement].markers == #self.m_Markers then
					-- get last toptimedatas to calc delta time
					local toptimeData = self.m_Toptimes:getToptimeFromPlayer(hitElement:getId())
					local oldToptime = toptimeData.time

					local lapTime = getTickCount() - self.m_Players[hitElement].startTick
					self.m_Toptimes:addNewToptime(hitElement:getId(), lapTime)
					self.m_Players[hitElement].startTick = getTickCount()
					self.m_Players[hitElement].markers = {}
					self.m_Players[hitElement].laps = self.m_Players[hitElement].laps + 1

					local _, position = self.m_Toptimes:getToptimeFromPlayer(hitElement:getId())
					outputChatBox(("Current: %s // Delta: %.3f // Runde: %s // Toptime Position: %s"):format(lapTime, (lapTime - oldToptime)/1000, self.m_Players[hitElement].laps, position))
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

function Kart:startTimeRace()
	if isElement(client.kartVehicle) then
		destroyElement(client.kartVehicle)
	end

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

	self.m_Players[client] = {vehicle = vehicle, laps = 1, state = "Flying", markers = {}, startTick = getTickCount()}
end

function Kart:onKartDestroy()
	if self.m_Players[source.timeRacePlayer] then
		outputChatBox("kill")
		self.m_Players[source.timeRacePlayer] = nil
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
