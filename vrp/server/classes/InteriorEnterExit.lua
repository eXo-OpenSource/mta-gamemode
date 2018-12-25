-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/InteriorEnterExit.lua
-- * PURPOSE: Interior enter/exit helper
-- *
-- ****************************************************************************
InteriorEnterExit = inherit(Object)

function InteriorEnterExit:constructor(entryPosition, interiorPosition, enterRotation, exitRotation, interiorId, dimension, enterInterior, enterDimension)
	
	InteriorEnterExitManager.Map[#InteriorEnterExitManager.Map+1] = self
	self.m_Id = #InteriorEnterExitManager.Map
	
	self.m_EnterMarker = createMarker(Vector3(entryPosition.x, entryPosition.y, entryPosition.z-1), "cylinder", 1.5, 255, 255, 255, 200)
	self.m_EnterMarker:setInterior(enterInterior or 0)
	ElementInfo:new(self.m_EnterMarker, "Eingang", 1.2, "Walking", true)
	
	self.m_EnterMarker:setDimension(enterDimension or 0)
  self.m_ExitMarker = createMarker(Vector3(interiorPosition.x, interiorPosition.y, interiorPosition.z-1), "cylinder", 1.5, 255, 255, 255, 200)
	ElementInfo:new(self.m_ExitMarker, "Ausgang", 1.2, "Walking", true)

  interiorId = interiorId or 0
  dimension = dimension or 0
  self.m_ExitMarker:setInterior(interiorId)
  self.m_ExitMarker:setDimension(dimension)

	self.m_EntranceData =  {interiorPosition, enterRotation, interiorId, dimension}
	self.m_ExitData = {entryPosition, exitRotation, enterInterior or 0, enterDimension or 0}

	addEventHandler("onMarkerHit", self.m_EnterMarker,
    function(hitElement, matchingDimension)
      if getElementType(hitElement) == "player" and matchingDimension and not isPedInVehicle(hitElement) then
				hitElement.m_LastEnterExit = {self.m_Id, "enter"}
				hitElement:triggerEvent("onTryEnterExit", self.m_EnterMarker)
      end
    end
  )

   addEventHandler("onMarkerHit", self.m_ExitMarker,
    function(hitElement, matchingDimension)
      if getElementType(hitElement) == "player" and matchingDimension then
				hitElement.m_LastEnterExit = {self.m_Id, "exit"}
				hitElement:triggerEvent("onTryEnterExit", self.m_ExitMarker)
      end
    end
  )
	
end

function InteriorEnterExit:enter(player)
	self:teleport(player, "enter", unpack(self.m_EntranceData))
end

function InteriorEnterExit:exit(player)
	self:teleport(player, "exit", unpack(self.m_EntranceData))
end

function InteriorEnterExit:setMarkerType(type)
	self.m_ExitMarker:setType(type)
	self.m_EnterMarker:setType(type)
end

function InteriorEnterExit:destructor()
	if isElement(self.m_EnterMarker) then self.m_EnterMarker:destroy() end
	if isElement(self.m_ExitMarker) then self.m_ExitMarker:destroy() end
end

function InteriorEnterExit:teleport(player, type, pos, rotation, interior, dimension)
	if player.LastPort and not timestampCoolDown(player.LastPort, 4) then
		return
	end



	fadeCamera(player,false,1,0,0,0)
	setElementFrozen(player, true)
	setTimer(
		function()
			if not isElement(player) then return end
			setElementInterior(player,interior, pos)
			player:setRotation(0, 0, rotation)
			player:setPosition(pos)
			setElementDimension(player,dimension)
			player:setCameraTarget(player)
			fadeCamera(player, true)
			
			setTimer(function() --map glitch fix
				setElementFrozen( player, false)
				player:triggerEvent("checkNoDm")
			end, 1000, 1)

			if type == "enter" then
				if self.m_EnterEvent then self.m_EnterEvent(player) end
			elseif type == "exit" then
				if self.m_ExitEvent then self.m_ExitEvent(player) end
			end
		end, 1500, 1
	)

	player.LastPort = getRealTime().timestamp

end

function InteriorEnterExit:getEnterMarker()
  return self.m_EnterMarker
end

function InteriorEnterExit:getExitMarker()
  return self.m_ExitMarker
end

function InteriorEnterExit:addEnterEvent(event)
	self.m_EnterEvent = event
end

function InteriorEnterExit:addExitEvent(event)
	self.m_ExitEvent = event
end
