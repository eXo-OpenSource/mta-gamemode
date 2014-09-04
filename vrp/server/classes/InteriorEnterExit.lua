-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InteriorEnterExit.lua
-- *  PURPOSE:     Interior enter/exit helper
-- *
-- ****************************************************************************
InteriorEnterExit = inherit(Object)

function InteriorEnterExit:constructor(entryPosition, interiorPosition, enterRotation, exitRotation, interiorId, dimension)
	self.m_EnterMarker = createMarker(entryPosition.X, entryPosition.Y, entryPosition.Z, "corona", 2, 255, 255, 255, 200)
	self.m_ExitMarker = createMarker(interiorPosition.X, interiorPosition.Y, interiorPosition.Z, "corona", 2, 255, 255, 255, 200)
	
	interiorId = interiorId or 0
	dimension = dimension or 0
	setElementInterior(self.m_ExitMarker, interiorId)
	setElementDimension(self.m_ExitMarker, dimension)
	
	addEventHandler("onMarkerHit", self.m_EnterMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				setElementInterior(hitElement, interiorId)
				setElementPosition(hitElement, interiorPosition.X, interiorPosition.Y, interiorPosition.Z)
				setElementDimension(hitElement, dimension)
				setElementRotation(hitElement, 0, 0, enterRotation)
				setCameraTarget(hitElement, hitElement)
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
				setElementRotation(hitElement, 0, 0, exitRotation)
				setCameraTarget(hitElement, hitElement)
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

function InteriorEnterExit:initializeAll()
	-- Note: Some may not here
	local data = {
		{1554.8, -1675.7, 16, 246.7, 63, 1003.64, 0, 90, 6},
	}
	
	for k, info in ipairs(data) do
		InteriorEnterExit:new(Vector(info[1], info[2], info[3]), Vector(info[4], info[5], info[6]), info[7], info[8], info[9], info[10])
	end
end
