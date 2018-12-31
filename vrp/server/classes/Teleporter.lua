-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/Teleporter.lua
-- * PURPOSE: Instant Teleport (useful for teleporting within same interior)
-- *
-- ****************************************************************************
Teleporter = inherit(Object)

function Teleporter:constructor(entryPosition, interiorPosition, enterRotation, exitRotation, interiorId, dimension, enterInterior, enterDimension)
	self.m_EnterMarker = createPickup(entryPosition, 3, 1318, 0)
	self.m_EnterMarker:setInterior(enterInterior or 0)
	self.m_EnterMarker:setDimension(enterDimension or 0)
  self.m_ExitMarker = createPickup(interiorPosition, 3, 1318, 0)
	self.m_FadeEffect = false
  interiorId = interiorId or 0
  dimension = dimension or 0
  self.m_ExitMarker:setInterior(interiorId)
  self.m_ExitMarker:setDimension(dimension)

	self.m_EntryPosition = entryPosition
	self.m_EnterRotation = exitRotation
	self.m_EnterInterior = enterInterior
	self.m_EnterDimension = enterDimension

	self.m_InteriorPosition = interiorPosition
	self.m_InteriorRotation = enterRotation
	self.m_Dimension = dimension
	self.m_InteriorId = interiorId

  addEventHandler("onPickupUse", self.m_EnterMarker,
    function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and source:getDimension()==hitElement:getDimension() then
				hitElement.m_Teleporter = {self, source, "enter"}
				if not hitElement.LastPort or (getRealTime().timestamp - hitElement.LastPort)  > 2 then
					hitElement:sendInfo("Drücke F zum Betreten!", 2000)
					hitElement:setPublicSync("TeleporterPickup", source)
				end
      end
    end
  )

   addEventHandler("onPickupUse", self.m_ExitMarker,
    function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and source:getDimension()==hitElement:getDimension() then
				hitElement.m_Teleporter = {self, source, "exit"}
				if not hitElement.LastPort or (getRealTime().timestamp - hitElement.LastPort)  > 2 then
					hitElement:sendInfo("Drücke F zum Betreten!", 2000)
					hitElement:setPublicSync("TeleporterPickup", source)
				end
      end
    end
  )
	TeleportManager:getSingleton().Map[self] = true
end

function Teleporter:setFade(bool) 
	self.m_FadeEffect = bool
end

function Teleporter:destructor()
	if isElement(self.m_EnterMarker) then self.m_EnterMarker:destroy() end
	if isElement(self.m_ExitMarker) then self.m_ExitMarker:destroy() end
	TeleportManager.Map[self] = nil
end

function Teleporter:teleport(player, type, pos, rotation, interior, dimension)
	if self.m_ConditionFunction and not self.m_ConditionFunction(player) then
		return
	end
	if player.LastPort and not timestampCoolDown(player.LastPort, 1) then
		return
	end
	if self.m_FadeEffect then 
		fadeCamera(player,false,1,0,0,0)
	end
	toggleAllControls(player, false)
	setElementFrozen(player, true)
	setTimer(
		function()
			if not isElement(player) then return end
			setElementInterior(player,interior, pos)
			player:setRotation(0, 0, rotation)
			player:setPosition(pos)
			setElementDimension(player,dimension)
			player:setCameraTarget(player)
			if self.m_FadeEffect then 
				fadeCamera(player, true)
			end
			setTimer(function() --map glitch fix
				setElementFrozen( player, false)
				toggleAllControls(player, true)
				player:triggerEvent("checkNoDm")
			end, self.m_FadeEffect and 1000 or 300, 1)

			if type == "enter" then
				if self.m_EnterEvent then self.m_EnterEvent(player) end
			elseif type == "exit" then
				if self.m_ExitEvent then self.m_ExitEvent(player) end
			end
		end, self.m_FadeEffect and 1500 or 300, 1
	)

	player.LastPort = getRealTime().timestamp

end

function Teleporter:setCondition(func)
	self.m_ConditionFunction = func
end

function Teleporter:getEnterMarker()
  return self.m_EnterMarker
end

function Teleporter:getExitMarker()
  return self.m_ExitMarker
end

function Teleporter:addEnterEvent(event)
	self.m_EnterEvent = event
end

function Teleporter:addExitEvent(event)
	self.m_ExitEvent = event
end
