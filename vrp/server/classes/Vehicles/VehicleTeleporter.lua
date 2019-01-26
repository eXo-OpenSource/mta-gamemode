-- ****************************************************************************
-- *
-- * PROJECT: vRoleplay
-- * FILE: server/classes/VehicleTeleporter.lua
-- * PURPOSE: Interior enter/exit helper
-- *
-- ****************************************************************************
VehicleTeleporter = inherit(Object)

function VehicleTeleporter:constructor(entryPosition, exitPosition, enterRotation, exitRotation, interiorId, dimension, marker, radius, customOffset)
	local vectorMarkerOffset = customOffset or Vector3(0, 0, 7.5)

	self.m_EnterMarker = createMarker(entryPosition - vectorMarkerOffset, marker or "cylinder", radius or 10, 58, 186, 242, 100)
	self.m_ExitMarker = createMarker(exitPosition - vectorMarkerOffset, marker or "cylinder", radius or 10, 58, 186, 242, 100)

	self.m_EnterNoCollisionArea = createColSphere(entryPosition, radius or 10)
	self.m_EnterNoCollisionArea:setData("NonCollisionArea", {players = true}, true)
	self.m_ExitNoCollisionArea = createColSphere(exitPosition, radius or 10)
	self.m_ExitNoCollisionArea:setData("NonCollisionArea", {players = true}, true)

	interiorId = interiorId or 0
	dimension = dimension or 0
	self.m_ExitMarker:setInterior(interiorId)
	self.m_ExitMarker:setDimension(dimension)
	self.m_ExitNoCollisionArea:setInterior(interiorId)
	self.m_ExitNoCollisionArea:setDimension(dimension)

	self.m_CancelExitWhileTeleportingEvent = bind(VehicleTeleporter.Event_CancelExitWhileTeleporting, self)

	addEventHandler("onMarkerHit", self.m_EnterMarker,
		function(hitElement, matchingDimension)
			if getElementType(hitElement) == "player" and matchingDimension then
				self:teleport(hitElement, "enter", exitPosition, enterRotation, interiorId, dimension, source)
			end
		end
	)

	addEventHandler("onMarkerHit", self.m_ExitMarker,
	function(hitElement, matchingDimension)
		if getElementType(hitElement) == "player" and matchingDimension then
			self:teleport(hitElement, "exit", entryPosition, exitRotation, 0, 0, source)
		end
	end
  	)

end

function VehicleTeleporter:destructor()
	if isElement(self.m_EnterMarker) then self.m_EnterMarker:destroy() end
    if isElement(self.m_ExitMarker) then self.m_ExitMarker:destroy() end
    if isElement(self.m_EnterNoCollisionArea) then self.m_EnterNoCollisionArea:destroy() end
	if isElement(self.m_ExitNoCollisionArea) then self.m_ExitNoCollisionArea:destroy() end
end

function VehicleTeleporter:teleport(player, type, pos, rotation, interior, dimension, marker)
	local vehicle
	local isVehicle
	if getPedOccupiedVehicleSeat(player) == 0 then
		vehicle = player.vehicle
		isVehicle = true
	end
	if not self:isValidPort(player, isVehicle, vehicle) then return false end
	if player.LastPort and not timestampCoolDown(player.LastPort, 4) then
		return
	end
	if isVehicle and not vehicle:isLandVehicle() then
		player:sendError("Du kannst diesen Eingang nur zu Fuß oder mit Bodenfahrzeugen benutzen.")
		return
    end

	fadeCamera(player,false,1,0,0,0)
	if vehicle then
		self:cancelExitingForOccupants(vehicle, true)
		vehicle:toggleHandBrake(player, true)
	end

	setTimer(
		function()
			if not self:isValidPort(player, isVehicle, vehicle) then return false end


			if (player.position - marker.position).length < 20 then
				player:setInterior(interior)
				player:setDimension(dimension)
				player:setCameraTarget(player)
				if vehicle then
					vehicle:setPosition(pos + vehicle:getBaseHeight(true))
					vehicle:setRotation(rotation)
					vehicle:setInterior(interior)
					vehicle:setDimension(dimension)
					vehicle:setFrozen(true)
					for seat, occ in pairs(getVehicleOccupants(vehicle)) do
						if seat > 0 then
							occ:setInterior(interior)
							occ:setDimension(dimension)
							occ:setCameraTarget(occ)
						end
					end
				else
					player:setFrozen(true)
					player:setPosition(pos + Vector3(0, 0, 1))
					player:setRotation(rotation)
				end
			else
				player:sendWarning(_("Du musst im Marker bleiben!", player))
			end
			fadeCamera(player, true)

			setTimer(function() --map glitch fix
				if not self:isValidPort(player, isVehicle, vehicle) then return false end
				setElementFrozen( player, false)
				if vehicle then
					self:cancelExitingForOccupants(vehicle, false)
					vehicle:toggleHandBrake(player, false)
					vehicle:setFrozen(false)
					for seat, occ in pairs(getVehicleOccupants(vehicle)) do
						if seat > 0 then
							occ:triggerEvent("checkNoDm")
							occ:setFrozen(false)
						end
					end
				end
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

function VehicleTeleporter:isValidPort(player, isVehicle, vehicle)
	if not isVehicle then
		return (isElement(player) and getElementType(player) == "player")
	else
		return (isElement(player) and getElementType(player) == "player") and (isElement(vehicle) and getElementType(vehicle) == "vehicle")
	end
end

function VehicleTeleporter:cancelExitingForOccupants(vehicle, state)
	if not (isElement(vehicle) and getElementType(vehicle) == "vehicle") then return end
	local occs = vehicle:getOccupants()
	if occs then
		for i,occ in pairs(occs) do
			if state and not isEventHandlerAdded("onVehicleStartExit", vehicle, self.m_CancelExitWhileTeleportingEvent) then
				addEventHandler("onVehicleStartExit", vehicle, self.m_CancelExitWhileTeleportingEvent)
				occ:triggerEvent("setCanBeKnockedOffBike", false)
			elseif not state and isEventHandlerAdded("onVehicleStartExit", vehicle, self.m_CancelExitWhileTeleportingEvent) then
				removeEventHandler("onVehicleStartExit", vehicle, self.m_CancelExitWhileTeleportingEvent)
				occ:triggerEvent("setCanBeKnockedOffBike", true)
			end
		end
	end
end

function VehicleTeleporter:Event_CancelExitWhileTeleporting()
	cancelEvent()
end

function VehicleTeleporter:getEnterMarker()
  return self.m_EnterMarker
end

function VehicleTeleporter:getExitMarker()
  return self.m_ExitMarker
end

function VehicleTeleporter:addEnterEvent(event)
	self.m_EnterEvent = event
end

function VehicleTeleporter:addExitEvent(event)
	self.m_ExitEvent = event
end

