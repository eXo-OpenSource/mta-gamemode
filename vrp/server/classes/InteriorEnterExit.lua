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
    	self:teleport(hitElement, interiorPosition, enterRotation, interiorId, dimension)
      end
    end
  )

   addEventHandler("onMarkerHit", self.m_ExitMarker,
    function(hitElement, matchingDimension)
      if getElementType(hitElement) == "player" and matchingDimension then
	  	self:teleport(hitElement, entryPosition, exitRotation, 0, 0)
      end
    end
  )

end

function InteriorEnterExit:teleport(player, pos, rotation, interior, dimension)
	if player.LastPort and not timestampCoolDown(player.LastPort, 4) then
		return
	end

	fadeCamera(player,false,1,0,0,0)
	setElementFrozen(player, true)
	setTimer(
		function()
			player:setInterior(interior, pos)
			player:setRotation(0, 0, rotation)
			player:setPosition(pos)
			player:setDimension(dimension)
			player:setCameraTarget(player)

			fadeCamera(player, true)
			player:setFrozen(false)
		end, 1500, 1
	)

	--triggerEvent("onElementInteriorChange", player, interior)
	--triggerEvent("onElementDimensionChange", player, dimension)
	player.LastPort = getRealTime().timestamp

end

function InteriorEnterExit:getEnterMarker()
  return self.m_EnterMarker
end

function InteriorEnterExit:getExitMarker()
  return self.m_ExitMarker
end
