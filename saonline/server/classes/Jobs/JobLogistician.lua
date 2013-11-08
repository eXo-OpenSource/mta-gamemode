-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        server/classes/Jobs/JobLogistician.lua
-- *  PURPOSE:     Logistician job
-- *
-- ****************************************************************************
JobLogistician = inherit(Job)

function JobLogistician:constructor()
	Job.constructor(self)
	
	-- Create crans
	local cran = Cran:new(10, 0, 9, 60, 80, 9)
	addCommandHandler("drop",
		function()
			cran:dropContainer(getPedOccupiedVehicle(getRandomPlayer()))
		end
	)
	addCommandHandler("logistic",
		function(player)
			self:start(player)
		end
	)
	addCommandHandler("down", function() cran:rollTowDown() end)
	addCommandHandler("up", function() cran:rollTowUp() end)
	
	-- Initialize map, create markers etc.
end

function JobLogistician:start(player)
	local vehicle = createVehicle(578, 0, 0, 4)
	local container = createObject(2934, 0, 0, 0)
	attachElements(container, vehicle, 0, -1.7, 1.1)
	warpPedIntoVehicle(player, vehicle)
end


-- Cran class
Cran = inherit(Object)

function Cran:constructor(startX, startY, startZ, endX, endY, endZ)
	self.m_StartX, self.m_StartY, self.m_StartZ = startX, startY, startZ -- position near truck
	self.m_EndX, self.m_EndY, self.m_EndZ = endX, endY, endZ -- position far away from truck
	self.m_Rotation = -math.deg(math.atan2(self.m_EndX-self.m_StartX, self.m_EndY-self.m_StartY))
	
	self.m_Object = createObject(3474, self.m_StartX, self.m_StartY, self.m_StartZ, 0, 0, self.m_Rotation)
	self.m_Tow = createObject(2917, self.m_StartX+0.5, self.m_StartY-0.7, self.m_StartZ+5, 0, 0, self.m_Rotation)
end

function Cran:dropContainer(vehicle)
	-- First, roll down the tow
	self:rollTowDown(
		function()
			-- Grab the container
			local container = getAttachedElements(vehicle)[1]
			
			-- Detach it from the player's vehicle and attach it to the tow
			detachElements(container)
			attachElements(container, self.m_Tow, 0, 0, -4.1, 0, 0, 180)
			
			-- Roll up the tow
			self:rollTowUp(
				function()
					-- Move cran to the "roll down platform"
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
end

function Cran:rollTowDown(callback)
	-- Detach from cran
	local x, y, z = getElementPosition(self.m_Tow)
	detachElements(self.m_Tow, self.m_Object)
	setElementPosition(self.m_Tow, x, y, z)

	-- Roll down the tow
	moveObject(self.m_Tow, 3000, x, y, z-5)
	if callback then
		setTimer(function() attachElements(self.m_Tow, self.m_Object, 0, 0, 0) callback() end, 3000, 1)
	end
end

function Cran:rollTowUp(callback)
	-- Detach from cran
	local x, y, z = getElementPosition(self.m_Tow)
	detachElements(self.m_Tow, self.m_Object)
	
	-- Roll up the tow
	moveObject(self.m_Tow, 3000, x, y, z+5)
	if callback then
		setTimer(function() attachElements(self.m_Tow, self.m_Object, 0, 0, 5) callback() end, 3000, 1)
	end
end
