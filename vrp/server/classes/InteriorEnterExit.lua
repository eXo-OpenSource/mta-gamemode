-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/InteriorEnterExit.lua
-- * PURPOSE: Interior enter/exit helper
-- *
-- ****************************************************************************
InteriorEnterExit = inherit(Object)

function InteriorEnterExit:constructor(entryPosition, interiorPosition, enterRotation, exitRotation, interiorInterior, interiorDimension, enterInterior, enterDimension)
	self.m_Locked = 0 -- || 0 = unlocked, 1 = entry-locked; 2 = exit-locked; -1 any locked
	InteriorEnterExitManager.Map[#InteriorEnterExitManager.Map+1] = self
	self.m_Id = #InteriorEnterExitManager.Map

	self.m_EnterMarker = createMarker(Vector3(entryPosition.x, entryPosition.y, entryPosition.z-1), "cylinder", 1.2, 255, 255, 255, 200)
	self.m_EnterMarker:setInterior(enterInterior or 0)

	ElementInfo:new(self.m_EnterMarker, "Eingang", 1.2, "Walking", true)
	--local colEnter = createColSphere(Vector3(entryPosition.x, entryPosition.y, entryPosition.z-0.8), 2)
	--colEnter:setInterior(enterInterior or 0)
	--colEnter:setDimension(enterDimension or 0)

	self.m_EnterMarker:setDimension(enterDimension or 0)
	self.m_ExitMarker = createMarker(Vector3(interiorPosition.x, interiorPosition.y, interiorPosition.z-1), "cylinder", 1.2, 255, 255, 255, 200)
	--local colExit = createColSphere(Vector3(interiorPosition.x, interiorPosition.y, interiorPosition.z-0.8), 2)

	ElementInfo:new(self.m_ExitMarker, "Ausgang", 1.2, "Walking", true)

  	self.m_ExitMarker:setInterior(interiorInterior or 0)
  	self.m_ExitMarker:setDimension(interiorDimension or 0)
	--colExit:setInterior(interiorId)
	--colExit:setDimension(dimension)

	self.m_EntranceData =  {interiorPosition, enterRotation, interiorInterior or 0, interiorDimension or 0}
	self.m_ExitData = {entryPosition, exitRotation, enterInterior or 0, enterDimension or 0}
	--[[addEventHandler("onColShapeHit", colEnter,
	function(hitElement, matchingDimension)
		if getElementType(hitElement) == "player" and hitElement:getDimension() == source:getDimension() and not isPedInVehicle(hitElement) then
			if hitElement:getInterior() == source:getInterior() then
				hitElement.m_LastEnterExit = {self.m_Id, "enter"}
				hitElement:triggerEvent("onTryEnterExit", self.m_EnterMarker, "Eingang")
			end
		end
	end
)

	addEventHandler("onColShapeHit", colExit,
	function(hitElement, matchingDimension)
		if getElementType(hitElement) == "player" and hitElement:getDimension() == source:getDimension() then
			if hitElement:getInterior() == source:getInterior() then
				hitElement.m_LastEnterExit = {self.m_Id, "exit"}
				hitElement:triggerEvent("onTryEnterExit", self.m_ExitMarker, "Ausgang")
			end
		end
	end
)	]]

	triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "ColshapeStreamer:registerColshape", resourceRoot, {entryPosition.x, entryPosition.y, entryPosition.z+0.2}, self.m_EnterMarker, "enterexit", self.m_Id, 2, "InteriorEnterExit:onEnterColHit", "InteriorEnterExit:onEnterColLeave")
	triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "ColshapeStreamer:registerColshape", resourceRoot, {interiorPosition.x, interiorPosition.y, interiorPosition.z+0.2}, self.m_ExitMarker, "enterexit", self.m_Id, 2, "InteriorEnterExit:onExitColHit", "InteriorEnterExit:onExitColLeave")

end

function InteriorEnterExit:setCustomText(enter, exit)
	self.m_EntryText = enter
	self.m_ExitText = exit
end

function InteriorEnterExit:enter(player)
	if self.m_Locked == 0 or self.m_Locked == 2 then
		self:teleport(player, "enter", unpack(self.m_EntranceData))
	else
		player:sendInfo(_("Der Eingang ist verschlossen!", client))
	end
end

function InteriorEnterExit:exit(player)
	if self.m_Locked == 0  or self.m_Locked == 1 then
		self:teleport(player, "exit", unpack(self.m_ExitData))
	else
		player:sendInfo(_("Der Ausgang ist verschlossen!", client))
	end
end

function InteriorEnterExit:setEntryLocked() self.m_Locked = 1 end
function InteriorEnterExit:setExitLocked() self.m_Locked = 2 end
function InteriorEnterExit:setLocked(bool) self.m_Locked = bool and -1 or 0 end

function InteriorEnterExit:setMarkerType(type)
	self.m_ExitMarker:setType(type)
	self.m_EnterMarker:setType(type)
end

function InteriorEnterExit:destructor()
	if isElement(self.m_EnterMarker) then self.m_EnterMarker:destroy() end
	if isElement(self.m_ExitMarker) then self.m_ExitMarker:destroy() end
	triggerClientEvent(PlayerManager:getSingleton():getReadyPlayers(), "ColshapeStreamer:deleteColshape", resourceRoot, "enterexit", self.m_Id)
	InteriorEnterExitManager.Map[self.m_Id] = nil
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

			if getDistanceBetweenPoints3D(player:getPosition(), type == "enter" and self.m_EnterMarker:getPosition() or self.m_ExitMarker:getPosition()) > 15 then
				fadeCamera(player, true)
				setElementFrozen(player, false)
				player:sendError("Fehler beim Teleportieren! Du bist zu weit vom Marker entfernt!")
				return
			end
			setElementDimension(player,dimension)
			setElementInterior(player,interior, pos)
			player:setRotation(0, 0, rotation)
			player:setPosition(pos)
			player:setCameraTarget(player)
			player:setGhostMode(true)
			fadeCamera(player, true)

			setTimer(function() --map glitch fix
				if isElement(player) then --check if player maybe went offline
					setElementFrozen(player, false)
					player:triggerEvent("checkNoDm")
				end
			end, 1000, 1)

			setTimer(function() --remove ghostmode
				if isElement(player) then --check if player maybe went offline
					player:setGhostMode(false)
				end
			end, 5000, 1)

			if type == "enter" then
				if self.m_EnterEvent then self.m_EnterEvent(player) end
			elseif type == "exit" then
				if self.m_ExitEvent then self.m_ExitEvent(player) end
			end
		end, 1500, 1
	)

	player.LastPort = getRealTime().timestamp
	player.LastPortType = type

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

function InteriorEnterExit:onEnterColHit(hitElement)
	if getElementType(hitElement) == "player" and hitElement:getDimension() == source:getDimension() and not isPedInVehicle(hitElement) then
		if hitElement:getInterior() == source:getInterior() then
			hitElement.m_LastEnterExit = {self.m_Id, "enter"}
			hitElement:triggerEvent("onTryEnterExit", self.m_EnterMarker, self.m_EntryText or "Eingang")
		end
	end
end

function InteriorEnterExit:onExitColHit(hitElement)
	if getElementType(hitElement) == "player" and hitElement:getDimension() == source:getDimension() then
		if hitElement:getInterior() == source:getInterior() then
			hitElement.m_LastEnterExit = {self.m_Id, "exit"}
			hitElement:triggerEvent("onTryEnterExit", self.m_ExitMarker, self.m_ExitText or "Ausgang")
		end
	end
end

function InteriorEnterExit:onEnterColLeave(leaveElement)
	if getElementType(leaveElement) == "player" and leaveElement:getDimension() == source:getDimension() and not isPedInVehicle(leaveElement) then
		if leaveElement:getInterior() == source:getInterior() then
			if not leaveElement:isInGhostMode() then
				return
			end

			if leaveElement.LastPortType == "exit" then
				leaveElement:setGhostMode(false)
			end
		end
	end
end

function InteriorEnterExit:onExitColLeave(leaveElement)
	if getElementType(leaveElement) == "player" and leaveElement:getDimension() == source:getDimension() then
		if leaveElement:getInterior() == source:getInterior() then
			if not leaveElement:isInGhostMode() then
				return
			end

			if leaveElement.LastPortType == "enter" then
				leaveElement:setGhostMode(false)
			end
		end
	end
end
