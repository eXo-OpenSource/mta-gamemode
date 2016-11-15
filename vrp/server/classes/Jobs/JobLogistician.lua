-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobLogistician.lua
-- *  PURPOSE:     Logistician job
-- *
-- ****************************************************************************
JobLogistician = inherit(Job)
local MONEY_PER_TRANSPORT = 500

function JobLogistician:constructor()
	Job.constructor(self)

	-- Create Cranes
	local Crane1 = Crane:new(2387.30, -2492.40, 19.6, 2387.30, -2625.60, 19.6)
	local Crane2 = Crane:new(-219.70, -269.30, 7.30, -219.70, -200.30, 7.30)

	self.m_Marker1 = self:createCraneMarker(Crane1, Vector3(2386.92, -2494.24, 13), Vector3(2387.60, -2490.87, 14.26), 0)
	self.m_Marker2 = self:createCraneMarker(Crane2, Vector3(-219.35, -268.77, 0.6), Vector3(-219.70, -270.80, 2.05), 0)

	self.m_VehicleSpawner1 = VehicleSpawner:new(2405.45, -2445.40, 13, {"DFT-30"}, 230, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner1.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner1:disable()

	self.m_VehicleSpawner2 = VehicleSpawner:new(-209.97, -273.92, 0.7, {"DFT-30"}, 180, bind(Job.requireVehicle, self))
	self.m_VehicleSpawner2.m_Hook:register(bind(self.onVehicleSpawn,self))
	self.m_VehicleSpawner2:disable()
end

function JobLogistician:start(player)
	self.m_VehicleSpawner1:toggleForPlayer(player, true)
	self.m_VehicleSpawner2:toggleForPlayer(player, true)
end

function JobLogistician:stop(player)
	self.m_VehicleSpawner1:toggleForPlayer(player, false)
	self.m_VehicleSpawner2:toggleForPlayer(player, false)
	if isElement(player.LogisticanContainer) then player.LogisticanContainer:destroy() end
	if player:getData("Logistician:Blip") then delete(player:getData("Logistician:Blip")) end
	player:setData("Logistician:TargetMarker", nil)
end

function JobLogistician:onVehicleSpawn(player,vehicleModel,vehicle)
	vehicle:setData("LogisticanVehicle", true)
	player:setData("Logistican:VehicleSpawn", vehicle:getPosition())
	addEventHandler("onElementDestroy", vehicle, bind(self.onVehicleDestroy, self))
	vehicle:addCountdownDestroy(10)
	vehicle.player = player
end

function JobLogistician:onVehicleDestroy()
	for key, obj in pairs(source:getAttachedElements()) do
		obj:destroy()
	end
	if source.player and isElement(source.player) then
		self:stop(source.player)
	end
end

function JobLogistician:setNewDestination(player, targetMarker, crane)

	local pos = targetMarker:getPosition()
	player:sendInfo(_("Ein Container wird aufgeladen! Bringe ihn nach %s!", player, getZoneName(pos)))
	-- Destroy the old waypoint blip and create a new one
	if player:getData("Logistician:Blip") then
		delete(player:getData("Logistician:Blip"))
	end

	local blip = Blip:new("Waypoint.png", pos.x, pos.y, player,9999)
	blip:setStreamDistance(10000)
	player:setData("Logistician:Blip", blip)

	player:setData("Logistician:TargetMarker", targetMarker)
	player:setData("Logistician:LastCrane", crane)
end

function JobLogistician:createCraneMarker(crane, pos, vehPos, vehRot)
	local marker = createMarker(pos, "cylinder", 3, 255, 255, 0, 127)
	marker:setData("Crane", crane)
	marker:setData("VehiclePosition", vehPos)
	marker:setData("VehicleRotation", Vector3(0, 0, vehRot))
	addEventHandler("onMarkerHit", marker, bind(self.onMarkerHit, self))
	return marker
end

function JobLogistician:onMarkerHit(hitElement, dim)
	if hitElement:getType() == "player" and dim then
		if hitElement:getOccupiedVehicle() and hitElement:getOccupiedVehicle():getData("LogisticanVehicle") == true then
			local veh = hitElement:getOccupiedVehicle()
			if source:getData("Crane") then
				local crane = source:getData("Crane")
				veh:setPosition(source:getData("VehiclePosition"))
				veh:setRotation(source:getData("VehicleRotation"))
				if crane:getVehicleAttachedContainer(veh) then
					if source == hitElement:getData("Logistician:TargetMarker") then
						crane:dropContainer(veh, hitElement, function() hitElement:giveMoney(MONEY_PER_TRANSPORT, "Logistiker Job") end)
					else
						hitElement:sendError(_("Du bist am falschen Kran!", hitElement))
					end
				else
					crane:loadContainer(veh, hitElement)
					if source == self.m_Marker1 then
						self:setNewDestination(hitElement, self.m_Marker2, crane)
					elseif source == self.m_Marker2 then
						self:setNewDestination(hitElement, self.m_Marker1, crane)
					else
						hitElement:sendError(_("Internal Error! Marker does not match", hitElement))
					end
				end
			else
				hitElement:sendError(_("Internal Error! No Crane settet to Marker!", hitElement))
			end
		else
			hitElement:sendError(_("Du sitzt in keinem Job Fahrzeug!", hitElement))
		end
	end
end


-- Crane class
Crane = inherit(Object)

function Crane:constructor(startX, startY, startZ, endX, endY, endZ, markerPos)
	self.m_StartX, self.m_StartY, self.m_StartZ = startX, startY, startZ -- position near truck
	self.m_EndX, self.m_EndY, self.m_EndZ = endX, endY, endZ -- position far away from truck
	self.m_Rotation = -math.deg(math.atan2(self.m_EndX-self.m_StartX, self.m_EndY-self.m_StartY))

	self.m_Object = createObject(3474, self.m_StartX, self.m_StartY, self.m_StartZ, 0, 0, self.m_Rotation)
	self.m_Tow = createObject(2917, self.m_StartX+0.5, self.m_StartY-0.7, self.m_StartZ+5, 0, 0, self.m_Rotation)
	--self.m_ColShape = createColSphere(self.m_StartX, self.m_StartY, self.m_StartZ, 10)
	self.m_Busy = false
end

function Crane:destructor()
	destroyElement(self.m_Object)
	destroyElement(self.m_Tow)
end

function Crane:dropContainer(vehicle, player, callback)
	if self.m_Busy then
		return false
	end
	self.m_Busy = true
	vehicle:setFrozen(true)
	-- First, roll down the tow
	self:rollTowDown(
		function()
			-- Grab the container
			local container = getAttachedElements(vehicle)[1]

			-- Detach it from the player's vehicle and attach it to the tow
			detachElements(container)
			attachElements(container, self.m_Tow, 0, 0, -4.1, 0, 0)
			vehicle:setFrozen(false)
			-- Roll up the tow
			self:rollTowUp(
				function()
					-- Move Crane to the "roll down platform"
					moveObject(self.m_Object, 10000, self.m_EndX, self.m_EndY, self.m_EndZ)

					-- Wait till we're at the target position
					setTimer(
						function()
							-- Roll down the tow
							self:rollTowDown(
								function()
									-- Destroy the container (behind a wall)
									destroyElement(container)

									self:rollTowUp(
										function()
											moveObject(self.m_Object, 10000, self.m_StartX, self.m_StartY, self.m_StartZ)
											if callback then callback() end

											setTimer(function() self.m_Busy = false end, 10000, 1)
										end
									)
								end
							)
						end, 10000, 1
					)
				end
			)
		end
	)
	return true
end

function Crane:loadContainer(vehicle, player, callback)
	if self.m_Busy then
		return false
	end
	self.m_Busy = true

	local container = createObject(math.random(2934, 2935), self.m_EndX, self.m_EndY-0.5, self.m_EndZ-4, 0, 0, self.m_Rotation)
	player.LogisticanContainer = container

	vehicle:setFrozen(true)
	-- Move Crane to the "container platform"
	moveObject(self.m_Object, 10000, self.m_EndX, self.m_EndY, self.m_EndZ)
	moveObject(self.m_Tow, 10000, self.m_EndX+0.5, self.m_EndY-0.7, self.m_EndZ+5)
	-- Wait till we're at the target position
	setTimer(
		function()
			-- Roll tow down
			self:rollTowDown(
				function()
					-- Attach container to tow and the roll up the tow
					attachElements(container, self.m_Tow, 0, 0, -4.1, 0, 0)

					self:rollTowUp(
						function()
							-- Move Crane to the start position
							moveObject(self.m_Object, 10000, self.m_StartX, self.m_StartY, self.m_EndZ)

							-- Wait till we're there
							setTimer(
								function()
									-- Roll tow down and load up the truck
									self:rollTowDown(
										function()
											detachElements(container, self.m_Tow)
											attachElements(container, vehicle, 0, -1.7, 1.1)
											vehicle:setFrozen(false)
											-- Roll up the tow a last time
											self:rollTowUp(
												function()
													if callback then callback() end
													self.m_Busy = false
												end
											)
										end
									)
								end, 10000, 1
							)
						end
					)
				end
			)
		end, 10000, 1
	)
	return true
end

function Crane:rollTowDown(callback)
	-- Detach from Crane
	local x, y, z = getElementPosition(self.m_Tow)
	detachElements(self.m_Tow, self.m_Object)
	setElementPosition(self.m_Tow, x, y, z)

	-- Roll down the tow
	moveObject(self.m_Tow, 3000, x, y, z-5)
	if callback then
		setTimer(function() attachElements(self.m_Tow, self.m_Object, 0, 0, 0) callback() end, 3000, 1)
	end
end

function Crane:rollTowUp(callback)
	-- Detach from Crane
	local x, y, z = getElementPosition(self.m_Tow)
	detachElements(self.m_Tow, self.m_Object)

	-- Roll up the tow
	moveObject(self.m_Tow, 3000, x, y, z+5)
	if callback then
		setTimer(function() attachElements(self.m_Tow, self.m_Object, 0, 0, 5) callback() end, 3000, 1)
	end
end

function Crane:getVehicleAttachedContainer(veh)
	for index, element in pairs(veh:getAttachedElements()) do
		if element:getModel() == 2934 or element:getModel() == 2935 then
			return element
		end
	end
	return false
end

function Crane:isBusy()
	return self.m_Busy
end

function Crane:getPosition()
	return self.m_StartX, self.m_StartY, self.m_StartZ
end
