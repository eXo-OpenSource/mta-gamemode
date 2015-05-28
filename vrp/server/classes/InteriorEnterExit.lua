-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InteriorEnterExit.lua
-- *  PURPOSE:     Interior enter/exit helper
-- *
-- ****************************************************************************
InteriorEnterExit = inherit(Object)

function InteriorEnterExit:constructor(entryPosition, interiorPosition, enterRotation, exitRotation, interiorId, dimension, isRed)
	self.m_EnterMarker = createMarker(entryPosition, "corona", 2, 255, 255, 255, 200)
	self.m_ExitMarker = createMarker(interiorPosition, "corona", 2, 255, 255, 255, 200)
	if isRed then -- Debug code
		self.m_EnterMarker:setColor(255, 0, 0, 200)
		self.m_ExitMarker:setColor(255, 0, 0, 200)
	end

	interiorId = interiorId or 0
	dimension = dimension or 0
	self.m_ExitMarker:setInterior(interiorId)
	self.m_ExitMarker:setDimension(dimension)

	addEventHandler("onMarkerHit", self.m_EnterMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				setElementInterior(hitElement, interiorId)
				setElementPosition(hitElement, interiorPosition.x, interiorPosition.y, interiorPosition.z)
				setElementDimension(hitElement, dimension)
				setElementRotation(hitElement, 0, 0, enterRotation)
				setTimer(function() hitElement.m_DontTeleport = false end, 500, 1) -- Todo: this is a temp fix
			end
		end
	)
	addEventHandler("onMarkerHit", self.m_ExitMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension  and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				setElementInterior(hitElement, 0, entryPosition.x, entryPosition.y, entryPosition.z)
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
