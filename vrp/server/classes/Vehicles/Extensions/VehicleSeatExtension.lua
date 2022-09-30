-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Vehicles/Extensions/VehicleSeat.lua
-- *  PURPOSE:     Vehicle seat class
-- *
-- ****************************************************************************
VehicleSeatExtension = inherit(Object) --gets inherited from vehicle to provide methods to vehicle object

function VehicleSeatExtension:initVehicleSeatExtension()
	self.m_SeatExtensionCol = createColSphere(0, 0, 0, 3)
	self.m_SeatExtensionCol:attach(self, VEHICLE_SEAT_EXTENSION_DOOR_OFFSET[self:getModel()])

	self.m_SeatExtensionPassengers = {}
	--self.m_SeatExtensionUsedSeats = {}
	self.m_hasSeatExtension = true

	if self:getModel() == 519 then
		self.m_ShamalInterior = self:initShamalExtension()
	end

	self.m_SeatExtensionEnterExit = bind(self.vsePressEnterExitKey, self)
	self.m_SeatExtensionVehicleStartEnter = bind(self.Event_vseVehicleStartEnter, self)
	self.m_SeatExtensionVehicleExplode = bind(self.Event_vseVehicleExplode, self)
	self.m_SeatExtensionVehicleDestroy = bind(self.Event_vseVehicleDestroy, self)
	self.m_SeatExtensionColShapeHit = bind(self.Event_vseColShapeHit, self)
	self.m_SeatExtensionColShapeLeave = bind(self.Event_vseColShapeLeave, self)
	addEventHandler("onVehicleStartEnter", self, self.m_SeatExtensionVehicleStartEnter)
	addEventHandler("onVehicleExplode", self, self.m_SeatExtensionVehicleExplode)
	addEventHandler("onElementDestroy", self, self.m_SeatExtensionVehicleDestroy)
	addEventHandler("onColShapeHit", self.m_SeatExtensionCol, self.m_SeatExtensionColShapeHit)
	addEventHandler("onColShapeLeave", self.m_SeatExtensionCol, self.m_SeatExtensionColShapeLeave)
end

function VehicleSeatExtension:delVehicleSeatExtension()
	self:vseRemoveAttachedPlayers()
	self.m_SeatExtensionPassengers = nil
	self:setData("VSE:Passengers", self.m_SeatExtensionPassengers, true)
	self.m_hasSeatExtension = nil

	removeEventHandler("onVehicleStartEnter", self, self.m_SeatExtensionVehicleStartEnter)
	removeEventHandler("onVehicleExplode", self, self.m_SeatExtensionVehicleExplode)
	removeEventHandler("onElementDestroy", self, self.m_SeatExtensionVehicleDestroy)
	removeEventHandler("onColShapeHit", self.m_SeatExtensionCol, self.m_SeatExtensionColShapeHit)
	removeEventHandler("onColShapeLeave", self.m_SeatExtensionCol, self.m_SeatExtensionColShapeLeave)
	self.m_SeatExtensionCol:detach()
	self.m_SeatExtensionCol:destroy()
end

function VehicleSeatExtension:vsePressEnterExitKey(player, key, keystate, enter)
	if player:isDead() then return end
	if player.vehicle then return end 
	if self:isBroken() then return end
	if player:getData("isTasered") then return end

	if self:getSpeed() > 15 then return player:sendWarning(_("Dieses Fahrzeug ist zu schnell!", player)) end
	self:vseEnterExit(player, enter)
end

function VehicleSeatExtension:Event_vseColShapeHit(hitElement, matchingDim)
	if hitElement.type ~= "player" then return end 

	if self:getMaxPassengers() == 0 or self:getOccupant(1) then
		bindKey(hitElement, "g", "down", self.m_SeatExtensionEnterExit, true)
	end
end

function VehicleSeatExtension:Event_vseColShapeLeave(leaveElement, matchingDim)
	if leaveElement.type ~= "player" then return end 

	unbindKey(leaveElement, "g", "down", self.m_SeatExtensionEnterExit)
end

function VehicleSeatExtension:Event_vseVehicleStartEnter(player)
	if not table.find(self.m_SeatExtensionPassengers, player) then
		unbindKey(player, "g", "down", self.m_SeatExtensionEnterExit)
	else
		cancelEvent()
	end
end

function VehicleSeatExtension:Event_vseVehicleExplode()
	for i, passenger in pairs(self.m_SeatExtensionPassengers) do
		if passenger:getData("SE:InShamal") then
			self:seEnterExitInterior(passenger, false)
		end
		self:vseEnterExit(passenger, false)
		passenger:kill()
	end
end

function VehicleSeatExtension:vseEnterExit(player, state)
	if state == true then
		if not self:isLocked() then
			if #self.m_SeatExtensionPassengers < VEHICLE_MAX_PASSENGER[self:getModel()] then
				if not table.find(self.m_SeatExtensionPassengers, player) then
					--[[if VEHICLE_SEAT_EXTENSION_SEAT_OFFSET[self:getModel()] then
						local freeSeat = self:vseGetFreeSeat()
						player:setAnimation("PED", "SEAT_down", -1, false, false, false, true)
						player:attach(self, VEHICLE_SEAT_EXTENSION_SEAT_OFFSET[freeSeat])
						self.m_SeatExtensionUsedSeats[player] = freeSeat
					else]]
						player:attach(self)
						player:setAlpha(0)
					--end
					player:setCameraTarget(self)
					table.insert(self.m_SeatExtensionPassengers, player)
					self:setData("VSE:Passengers", self.m_SeatExtensionPassengers, true)
					player:setData("VSE:IsPassenger", true, true)
					player:setData("VSE:Vehicle", self, true)
					setTimer(function() bindKey(player, "g", "down", self.m_SeatExtensionEnterExit, false) end, 250, 1)
				else
					player:sendError(_("Du kannst nicht 2x einsteigen o.O", player))
				end
			else
				player:sendInfo(_("Das Flugzeug ist voll.", player))
			end
		else
			player:sendError(_("Das Flugzeug ist abgeschlossen!", player))
		end
	elseif state == "death" then
		table.removevalue(self.m_SeatExtensionPassengers, player)
		self:setData("VSE:Passengers", self.m_SeatExtensionPassengers, true)
		player:setData("VSE:IsPassenger", nil, true)
		player:setData("VSE:Vehicle", nil, true)
	else
	--[[if VEHICLE_SEAT_EXTENSION_SEAT_OFFSET[self:getModel()] then
			self.m_SeatExtensionUsedSeats[player] = nil
		end]]

		local pos = self.m_SeatExtensionCol:getPosition()
		player:detach(self)
		player:setPosition(pos.x, pos.y, pos.z - 1)
		player:setAlpha(255)
		player:setCameraTarget()
		unbindKey(player, "g", "down", self.m_SeatExtensionEnterExit)
		table.removevalue(self.m_SeatExtensionPassengers, player)
		self:setData("VSE:Passengers", self.m_SeatExtensionPassengers, true)
		player:setData("VSE:IsPassenger", nil, true)
		player:setData("VSE:Vehicle", nil, true)
	end
end

function VehicleSeatExtension:Event_vseVehicleDestroy()
	self.m_SeatExtensionCol:destroy()
end

function VehicleSeatExtension:hasSeatExtension()
	return self.m_hasSeatExtension
end

function VehicleSeatExtension:vseRemoveAttachedPlayers()
	for i, v in pairs(self.m_SeatExtensionPassengers) do
		self:vseEnterExit(v, false)
	end 
end


--[[function VehicleSeatExtension:vseGetFreeSeat()
	local i = 0
	repeat
		i = i + 1
	until not table.find(self.m_SeatExtensionUsedSeats, i)

	return i
end]]