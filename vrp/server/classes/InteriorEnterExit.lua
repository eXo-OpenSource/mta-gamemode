-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/InteriorEnterExit.lua
-- *  PURPOSE:     Interior enter/exit helper
-- *
-- ****************************************************************************
InteriorEnterExit = inherit(Object)

function InteriorEnterExit:constructor(entryPosition, interiorPosition, enterRotation, exitRotation, interiorId, dimension, isRed)
	self.m_EnterMarker = createMarker(entryPosition, "corona", 1.5, 255, 255, 255, 200)
	self.m_ExitMarker = createMarker(interiorPosition, "corona", 1.5, 255, 255, 255, 200)
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
				fadeCamera(hitElement,false,1,0,0,0)
				setElementFrozen( hitElement, true)
				setTimer( function() hitElement:setInterior(interiorId) end,1500,1)
				setTimer( function() hitElement:setPosition(interiorPosition) end, 1500,1)
				setTimer( function() fadeCamera( hitElement, true,1) end, 2500,1)
				setTimer( function() hitElement:setDimension(dimension) end, 1500,1)
				setTimer( function() hitElement:setRotation(0, 0, enterRotation) end, 1500,1)
				setTimer( function() hitElement:setCameraTarget(hitElement) end, 1500,1)
				setTimer(function() setElementFrozen( hitElement, false) end, 2500,1)
				setTimer(function() hitElement.m_DontTeleport = false end, 2500, 1) -- Todo: this is a temp fix
				triggerEvent("onElementInteriorChange", hitElement, interiorId)
				triggerEvent("onElementDimensionChange", hitElement, dimension)
			end
		end
	)
	addEventHandler("onMarkerHit", self.m_ExitMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension  and not hitElement.m_DontTeleport then
				hitElement.m_DontTeleport = true
				fadeCamera(hitElement,false,1,0,0,0)
				setElementFrozen( hitElement, true)
				setTimer( function() hitElement:setInterior(0, entryPosition.x, entryPosition.y, entryPosition.z) end,1500,1)
				setTimer(function() hitElement:setPosition(entryPosition) end,1500,1)
				setTimer( function() fadeCamera( hitElement, true,1) end, 2500,1)
				setTimer( function() hitElement:setDimension(0) end, 1500,1)
				setTimer( function() hitElement:setRotation(0, 0, exitRotation) end, 1500,1)
				setTimer( function() hitElement:setCameraTarget(hitElement) end, 1500,1)
				setTimer(function() setElementFrozen( hitElement, false) end, 2500,1)
				setTimer(function() hitElement.m_DontTeleport = false end, 2500, 1) -- Todo: this is a temp fix
				triggerEvent("onElementInteriorChange", hitElement, 0)
				triggerEvent("onElementDimensionChange", hitElement, 0)
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
