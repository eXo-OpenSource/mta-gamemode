-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Kart.lua
-- *  PURPOSE:     Kart-Track class
-- *
-- ****************************************************************************

Kart = inherit(Singleton)

function Kart:constructor()
	self.m_RentMarker = createMarker(1311.1, 141.6, 19.5, "cylinder", 1, 255, 125, 0, 125)

	--[[Trackmarkers:
		<marker id="marker (cylinder) (3)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1290.5996" posY="65.90039" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
		<marker id="marker (cylinder) (4)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1326.9" posY="132.7" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
		<marker id="marker (cylinder) (5)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1386.6" posY="105.9" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
		<marker id="marker (cylinder) (6)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1332.8" posY="118.2" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
		<marker id="marker (cylinder) (7)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1359.3" posY="50.3" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
		<marker id="marker (cylinder) (8)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1328.4" posY="88.1" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
		<marker id="marker (cylinder) (9)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1317.1" posY="62.2" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
		<marker id="marker (cylinder) (10)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1380.8" posY="61.9" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
		<marker id="marker (cylinder) (11)" type="cylinder" color="#0000FF32" size="11" interior="0" dimension="0" alpha="255" posX="1309.7" posY="122.1" posZ="21.2" rotX="0" rotY="0" rotZ="0"></marker>
	--]]

	--PED:     <ped id="ped (2)" dimension="0" model="64" interior="0" rotZ="147.252" alpha="255" posX="1311.8" posY="143.10001" posZ="20.7" rotX="0" rotY="0"></ped>
end

--[[

	NOTES:
		Features:
					Zeitrennen - Gegen die Uhr, mit möglicher einblendung eines Ghost-Drivers - Highscore für Rundenzeit

					Eventrennen - San News kann Event rennen starten. HUD mit Platzierung für jeden Spieler - Einstellbare Runden anzahl
									Benachrichtigung für die ersten 5 Plätze an die San News

		Sonstiges:
					Bei Runden, abfrage ob alle Marker durchfahren werden, damit nicht gecheatet wird
]]
