-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InteriorEnterExit.lua
-- *  PURPOSE:     Interior enter/exit helper
-- *
-- ****************************************************************************
InteriorEnterExit = inherit(Object)

function InteriorEnterExit:constructor(entryPosition, interiorPosition, enterRotation, exitRotation, interiorId, dimension)
	self.m_EnterMarker = createMarker(entryPosition, "corona", 2, 255, 255, 255, 200)
	self.m_ExitMarker = createMarker(interiorPosition, "corona", 2, 255, 255, 255, 200)
	
	interiorId = interiorId or 0
	dimension = dimension or 0
	setElementInterior(self.m_ExitMarker, interiorId)
	setElementDimension(self.m_ExitMarker, dimension)
	
	addEventHandler("onMarkerHit", self.m_EnterMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) then
				setElementInterior(hitElement, interiorId, getAnglePosition(interiorPosition.x, interiorPosition.y, interiorPosition.z, 0, 0, 0, 2.5, enterRotation, 0))
				setElementDimension(hitElement, dimension)
				setElementRotation(hitElement, 0, 0, enterRotation)
				setCameraTarget(hitElement, hitElement)

				triggerClientEvent("HUDRadar:hideRadar", hitElement)
			end
		end
	)
	addEventHandler("onMarkerHit", self.m_ExitMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				setElementInterior(hitElement, 0, getAnglePosition(entryPosition.x, entryPosition.y, entryPosition.z, 0, 0, 0, 2.5, -exitRotation, 0))
				setElementDimension(hitElement, 0)
				setElementRotation(hitElement, 0, 0, exitRotation)
				setCameraTarget(hitElement, hitElement)

				triggerClientEvent("HUDRadar:showRadar", hitElement)
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

function InteriorEnterExit:initializeAll()
	-- Note: Some may not here
	local data = {
		{1554.8, -1675.7, 16, 246.7, 63, 1003.64, 0, 90, 6},
	}
	
	for k, info in ipairs(data) do
		InteriorEnterExit:new(Vector3(info[1], info[2], info[3]), Vector3(info[4], info[5], info[6]), info[7], info[8], info[9], info[10])
	end
end
