-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Kart.lua
-- *  PURPOSE:     Kart-Track class
-- *
-- ****************************************************************************
Kart = inherit(Singleton)

Kart.Markers = {
	[1] = createMarker(1290.5996, 65.90039, 21.2, "cylinder", 11),
	[2] = createMarker(1326.9, 132.7, 21.2, "cylinder", 11),
	[3] = createMarker(1386.6, 105.9, 21.2, "cylinder", 11),
	[4] = createMarker(1332.8, 118.2, 21.2, "cylinder", 11),
	[5] = createMarker(1359.3, 50.3, 21.2, "cylinder", 11),
	[6] = createMarker(1328.4, 88.1, 21.2, "cylinder", 11),
	[7] = createMarker(1317.1, 62.2, 21.2, "cylinder", 11),
	[8] = createMarker(1380.8, 61.9, 21.2, "cylinder", 11),
	[9] = createMarker(1309.7, 122.1, 21.2, "cylinder", 11),
}

Kart.Spawns = {}

function Kart:constructor()
	self.m_KartMarker = createMarker(1311.1, 141.6, 19.8, "cylinder", 1, 255, 125, 0, 125)
	self.m_Ped = createPed(64, 1311.8, 143.10001, 20.7, 147.252)
	self.m_Toptimes = Toptimes:new("Kartmap")

	self.m_Players = {}

	for _, v in pairs(Kart.Markers) do
		v:setAlpha(0)
	end

	addEventHandler("onMarkerHit", root, bind(Kart.markerHit, self))
end

function Kart:markerHit(hitElement, matchingDimension)
	if not matchingDimension then return end
	if hitElement.type ~= "player" then return end

	if source == self.m_KartMarker then
		-- dev (show gui)
		local vehicle = TemporaryVehicle.create(571, 1310.445, 123.184, 20.518, 155.144)
		hitElement:warpIntoVehicle(vehicle)
		vehicle:setEngineState(true)

		self.m_Players[hitElement] = {vehicle = vehicle, laps = 0, state = "Flying"}
	end

	for k, v in pairs(Kart.Markers) do
		if v == source then
			if self.m_Players[hitElement] and self.m_Players[hitElement].state ~= "Flying" then
				outputChatBox("Hit: " .. k)
			end
		end
	end
	--client:triggerEvent("questionBox", _("Möchtest du ein Zeitrennen starten?", client), "event")
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
