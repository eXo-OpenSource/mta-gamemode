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
				hitElement:setInterior(interiorId)
				hitElement:setPosition(interiorPosition)
				hitElement:setDimension(dimension)
				hitElement:setRotation(0, 0, enterRotation)
				hitElement:setCameraTarget(hitElement)
				setTimer(function() hitElement.m_DontTeleport = false end, 1000, 1) -- Todo: this is a temp fix
			end
		end
	)
	addEventHandler("onMarkerHit", self.m_ExitMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension  and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				hitElement:setInterior(0)
				hitElement:setPosition(entryPosition)
				hitElement:setDimension(0)
				hitElement:setRotation(0, 0, exitRotation)
				hitElement:setCameraTarget(hitElement)
				setTimer(function() hitElement.m_DontTeleport = false end, 1000, 1) -- Todo: this is a temp fix
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
