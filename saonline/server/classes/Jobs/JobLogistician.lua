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
	local Crane = Crane:new(5, -100, 8, 36, 15, 8)
	addCommandHandler("drop",
		function(player)
			if player:getJob() == self then
				Crane:dropContainer(getPedOccupiedVehicle(player), function() player:giveMoney(MONEY_PER_TRANSPORT) end)
			else
				player:sendMessage("You are not employed as logistician", 255, 0, 0)
			end
		end
	)
	addCommandHandler("load",
		function(player)
			if player:getJob() == self then
				Crane:loadContainer(getPedOccupiedVehicle(player))
			else
				player:sendMessage("You are not employed as logistician", 255, 0, 0)
			end
		end
	)
	addCommandHandler("down", function() Crane:rollTowDown() end)
	addCommandHandler("up", function() Crane:rollTowUp() end)
	
	-- Initialize map, create markers etc.
end

function JobLogistician:start(player)
	local vehicle = createVehicle(578, 0, 0, 4)
	local container = createObject(2934, 0, 0, 0)
	attachElements(container, vehicle, 0, -1.7, 1.1)
	warpPedIntoVehicle(player, vehicle)
end

function JobLogistician:setNewDestination(player)
	-- Get random Crane
	local Crane = self.m_Cranes[math.random(1, #self.m_Cranes)]
	local x, y, z = Crane:getPosition()
	
	-- Destroy the old waypoint blip and create a new one
	if player:getData("LogisticianBlip") then
		destroyElement(player:getData("LogisticianBlip"))
	end
	local blip = createBlip(x, y, z, 41)
	player:setData("Logistician:Blip", blip)
	
	--todo
	player:setData("Logistician:Crane", Crane)
end


-- Crane class
Crane = inherit(Object)

function Crane:constructor(startX, startY, startZ, endX, endY, endZ, createContainers)
	self.m_StartX, self.m_StartY, self.m_StartZ = startX, startY, startZ -- position near truck
	self.m_EndX, self.m_EndY, self.m_EndZ = endX, endY, endZ -- position far away from truck
	self.m_Rotation = -math.deg(math.atan2(self.m_EndX-self.m_StartX, self.m_EndY-self.m_StartY))
	
	self.m_Object = createObject(3474, self.m_StartX, self.m_StartY, self.m_StartZ, 0, 0, self.m_Rotation)
	self.m_Tow = createObject(2917, self.m_StartX+0.5, self.m_StartY-0.7, self.m_StartZ+5, 0, 0, self.m_Rotation)
	--self.m_ColShape = createColSphere(self.m_StartX, self.m_StartY, self.m_StartZ, 10)
	self.m_Busy = false
	
	-- Create container (decoration)
	self.m_Containers = {}
	if createContainers or createContainers == nil then
		for k, v in ipairs(Crane.ContainerData) do
			local model, x, y, z, rotation = unpack(v)
			x, y, z = getPositionFromCoordinatesOffset(self.m_EndX, self.m_EndY, self.m_EndZ, 0, 0, self.m_Rotation, x, y, z)
			local object = createObject(model, x, y, z, 0, 0, self.m_Rotation+rotation)
			setElementFrozen(object, true)
			table.insert(self.m_Containers, object)
		end
	end
end

function Crane:destructor()
	destroyElement(self.m_Object)
	destroyElement(self.m_Tow)
	
	for k, object in ipairs(self.m_Containers) do
		destroyElement(object)
	end
end

function Crane:dropContainer(vehicle, callback)
	if self.m_Busy then
		return false
	end
	self.m_Busy = true

	-- First, roll down the tow
	self:rollTowDown(
		function()
			-- Grab the container
			local container = getAttachedElements(vehicle)[1]
			
			-- Detach it from the player's vehicle and attach it to the tow
			detachElements(container)
			attachElements(container, self.m_Tow, 0, 0, -4.1, 0, 0)
			
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

function Crane:loadContainer(vehicle, callback)
	if self.m_Busy then
		return false
	end
	self.m_Busy = true
	
	local container = createObject(math.random(2934, 2935), self.m_EndX, self.m_EndY-0.5, self.m_EndZ-4, 0, 0, self.m_Rotation)
	
	-- Move Crane to the "container platform"
	moveObject(self.m_Object, 10000, self.m_EndX, self.m_EndY, self.m_EndZ)
	
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

function Crane:isBusy()
	return self.m_Busy
end

function Crane:getPosition()
	return self.m_StartX, self.m_StartY, self.m_StartZ
end

Crane.ContainerData = {
	{2932, 7.100, 6.200, -5.400, 0.0},
	{2934, 0.300, 7.300, -5.400, -270.0},
	{2935, 0.300, 10.400, -5.400, -270.0},
	{2932, 0.300, 9.200, -2.500, -270.0},
	{2932, -6.400, -5.100, -5.400, 0.0},
	{2935, 7.100, -1.000, -5.400, -180.0},
	{2935, -6.400, 2.300, -5.400, -180.0},
	{2935, -6.400, -1.600, -2.500, -180.0},
	{2934, 7.100, 4.600, -2.500, -180.0},
	{2932, 0.100, -8.100, -5.500, -270.0},
	{2934, 0.100, -8.100, -2.600, -270.0},
	{2932, 7.100, -2.600, -2.500, 0.0},
	{2935, 7.000, -8.100, -5.400, -180.0},
	{2932, -6.400, 9.500, -5.400, 0.0},
	{2934, -6.400, 5.600, -2.500, -180.0}
}
