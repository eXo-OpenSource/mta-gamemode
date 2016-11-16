-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/InteriorEnterExit.lua
-- * PURPOSE: Interior enter/exit helper
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
      if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) then
        fadeCamera(hitElement,false,1,0,0,0)
        setElementFrozen( hitElement, true)
		setTimer(
			function()
				hitElement:setRotation(0, 0, enterRotation)
				hitElement:setPosition(interiorPosition + hitElement.matrix.forward*2)
				hitElement:setInterior(interiorId)
				hitElement:setDimension(dimension)
				hitElement:setCameraTarget(hitElement)

				fadeCamera( hitElement, true,1)
				hitElement:setFrozen(false)
			end, 1500, 1
		)
		setTimer(
			function()

			end, 2500, 1
		)
        triggerEvent("onElementInteriorChange", hitElement, interiorId)
        triggerEvent("onElementDimensionChange", hitElement, dimension)
      end
    end
  )

  addEventHandler("onMarkerHit", self.m_ExitMarker,
    function(hitElement, matchingDimension)
      if getElementType(hitElement) == "player" and matchingDimension then
        fadeCamera(hitElement,false,1,0,0,0)
        setElementFrozen( hitElement, true)
		setTimer(
			function()
				hitElement:setInterior(0, entryPosition)
				hitElement:setRotation(0, 0, exitRotation)
				hitElement:setPosition(entryPosition + hitElement.matrix.forward*2)
				hitElement:setDimension(0)
				hitElement:setCameraTarget(hitElement)

				fadeCamera(hitElement, true)
				hitElement:setFrozen(false)
			end, 1500, 1
		)
		setTimer(
			function()

			end, 2500, 1
		)

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
