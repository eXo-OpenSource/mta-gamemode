-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/GasStation.lua
-- *  PURPOSE:     Gas station class
-- *
-- ****************************************************************************
GasStation = inherit(Object)

function GasStation:constructor(position)
	self.m_Marker = createMarker(position, "cylinder", 5, 255, 255, 0, 100)
	
	addEventHandler("onMarkerHit", self.m_Marker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension and getPedOccupiedVehicleSeat(hitElement) == 0 then
				hitElement:triggerEvent("gasStationGUIOpen")
			end
		end
	)
	addEventHandler("onMarkerLeave", self.m_Marker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				hitElement:triggerEvent("gasStationGUIClose")
			end
		end
	)
end

function GasStation.initializeAll()
	GasStation:new(Vector3(1937.5, -1773, 12.5))
end

addEvent("gasStationFill", true)
addEventHandler("gasStationFill", root,
	function()
		local vehicle = getPedOccupiedVehicle(client)
		if not vehicle then return end
		if not instanceof(vehicle, PermanentVehicle, true) then
			client:sendWarning(_("Nicht-permanente Fahrzeuge können nicht betankt werden!", client))
			return
		end
		
		if client:getMoney() > 10 then
			if vehicle:getFuel() <= 100-10 then
				vehicle:setFuel(vehicle:getFuel() + 10)
				client:takeMoney(10)
			else
				client:sendError(_("Dein Tank ist bereits voll", client))
			end
		else
			client:sendError(_("Du hast nicht genügend Geld!", client))
		end
	end
)
