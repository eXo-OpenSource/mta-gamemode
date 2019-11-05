-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/InteriorEnterExit.lua
-- * PURPOSE: Interior enter/exit helper
-- *
-- ****************************************************************************
InteriorEnterExit = inherit(Object)

function InteriorEnterExit:constructor(entryPosition, interiorPosition, enterRotation, exitRotation, interiorId, dimension, enterInterior, enterDimension)
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

  interiorId = interiorId or 0
  dimension = dimension or 0
  self.m_ExitMarker:setInterior(interiorId)
  self.m_ExitMarker:setDimension(dimension)
	--colExit:setInterior(interiorId)
	--colExit:setDimension(dimension)

	self.m_EntranceData =  {interiorPosition, enterRotation, interiorId, dimension}
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
	
	for key, player in ipairs(getElementsByType("player")) do
		if player:isLoggedIn() then
			player:triggerEvent("ColshapeStreamer:registerColshape", {entryPosition.x, entryPosition.y, entryPosition.z+0.2}, self.m_EnterMarker, "enterexit", self.m_Id, 2, "InteriorEnterExit:onEnterColHit")
			player:triggerEvent("ColshapeStreamer:registerColshape", {interiorPosition.x, interiorPosition.y, interiorPosition.z+0.2}, self.m_ExitMarker, "enterexit", self.m_Id, 2, "InteriorEnterExit:onEnterColHit")
		end
	end
end

function InteriorEnterExit:enter(player)
	if self.m_Locked == 0 or self.m_Locked == 2 then
		if not self:getInterior() then
			self:teleport(player, "enter", unpack(self.m_EntranceData))
		else 
			self:getInterior():enter(player)
		end
		if self.m_EnterEvent then self.m_EnterEvent(player) end
	else 
		player:sendInfo(_("Der Eingang ist verschlossen!", client))
	end
end

function InteriorEnterExit:exit(player)
	if self.m_Locked == 0  or self.m_Locked == 1 then
		if not self:getInterior() then
			self:teleport(player, "exit", unpack(self.m_ExitData))
		else 
			self:getInterior():exit(player)
		end
		if self.m_ExitEvent then self.m_ExitEvent(player) end
	else 
		player:sendInfo(_("Der Ausgang ist verschlossen!", client))
	end
end

function InteriorEnterExit:setEntryLocked() self.m_Locked = 1 end
function InteriorEnterExit:setExitLocked() self.m_Locked = 2 end
function InteriorEnterExit:setLocked(bool) self.m_Locked = bool and -1 or 0 end
function InteriorEnterExit:setInterior(instance)
	assert(instance and type(instance) == "table", "Bad argument #1 @InteriorEnterExit.setInterior")
	self.m_Interior = instance
end

function InteriorEnterExit:setMarkerType(type)
	self.m_ExitMarker:setType(type)
	self.m_EnterMarker:setType(type)
end

function InteriorEnterExit:destructor()
	if isElement(self.m_EnterMarker) then self.m_EnterMarker:destroy() end
	if isElement(self.m_ExitMarker) then self.m_ExitMarker:destroy() end
	triggerClientEvent("ColshapeStreamer:deleteColshape", root, "enterexit", self.m_Id)
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
			setElementDimension(player,dimension)
			setElementInterior(player,interior, pos)
			player:setRotation(0, 0, rotation)
			player:setPosition(pos)
			player:setCameraTarget(player)
			fadeCamera(player, true)
			
			setTimer(function() --map glitch fix
				setElementFrozen( player, false)
				player:triggerEvent("checkNoDm")
			end, 1000, 1)

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

function InteriorEnterExit:getInterior() 
	return self.m_Interior
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
			hitElement:triggerEvent("onTryEnterExit", self.m_EnterMarker, "Eingang")
		end
	end
end

function InteriorEnterExit:onExitColHit(hitElement)
	if getElementType(hitElement) == "player" and hitElement:getDimension() == source:getDimension() then
		if hitElement:getInterior() == source:getInterior() then
			hitElement.m_LastEnterExit = {self.m_Id, "exit"}
			hitElement:triggerEvent("onTryEnterExit", self.m_ExitMarker, "Ausgang")
		end
	end
end