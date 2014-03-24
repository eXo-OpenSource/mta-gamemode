-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InteriorEnterExit.lua
-- *  PURPOSE:     Interior enter/exit helper
-- *
-- ****************************************************************************
InteriorEnterExit = inherit(Object)

function InteriorEnterExit:constructor(entryPosition, interiorPosition, interiorId, dimension)
	self.m_EnterMarker = createMarker(entryPosition.X, entryPosition.Y, entryPosition.Z, "corona", 2, 255, 255, 255, 200)
	self.m_ExitMarker = createMarker(interiorPosition.X, interiorPosition.Y, interiorPosition.Z, "corona", 2, 255, 255, 255, 200)
	setElementInterior(self.m_ExitMarker, interiorId)
	
	dimension = dimension or 0
	setElementDimension(self.m_ExitMarker, dimension)
	
	addEventHandler("onMarkerHit", self.m_EnterMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				setElementInterior(hitElement, interiorId, interiorPosition.X, interiorPosition.Y, interiorPosition.Z)
				setElementDimension(hitElement, dimension)
				setTimer(function() hitElement.m_DontTeleport = false end, 500, 1) -- Todo: this is a temp fix
			end
		end
	)
	addEventHandler("onMarkerHit", self.m_ExitMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension  and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				setElementInterior(hitElement, 0, entryPosition.X, entryPosition.Y, entryPosition.Z)
				setElementDimension(hitElement, 0)
				setTimer(function() hitElement.m_DontTeleport = false end, 500, 1) -- Todo: this is a temp fix
			end
		end
	)
end

function InteriorEnterExit:getEnterMarker()
	return self.m_EnterMarker
end

function InteriorEnterExit:getExitMarker()
	return self.m_ExitMarker
end
