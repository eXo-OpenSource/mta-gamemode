-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Interior/InteriorManager.lua
-- *  PURPOSE:     Manages custom interiors 
-- *
-- ****************************************************************************

InteriorManager = inherit(Singleton)
InteriorManager.Map = {}
InteriorManager.MapByName = {}
addRemoteEvents {"VehicleInterior:enter", "VehicleInterior:exit"}

function InteriorManager:constructor() 
	self.m_CurrentDimension = 1
	self.m_CurrentInterior = 20
end

function InteriorManager:add(instance)
	InteriorManager.Map[instance] = true
	if not InteriorManager.MapByName[instance:getName()] then InteriorManager.MapByName[instance:getName()] = {} end 
	table.insert(InteriorManager.MapByName[instance:getName()], instance)
	self:autoPlace(instance)
end

function InteriorManager:remove(instance) 
	InteriorManager.Map[instance] = nil
	if InteriorManager.MapByName[instance:getName()] then 
		local found = table.find( InteriorManager.MapByName[instance:getName()], instance)
		if found then 
			table.remove( InteriorManager.MapByName[instance:getName()], found)
		end
	end
end

function InteriorManager:getMapCount(name) 
	return (not InteriorManager.MapByName[name] and 0) or #InteriorManager.MapByName[name]
end

function InteriorManager:autoPlace(instance) 
	local min, max = instance:getBounding()
	if not self.m_MaxX then 
		self.m_MaxX = DYNAMIC_INTERIOR_GRID_START_X
	end
	if not self.m_CurrentY then 
		self.m_CurrentY = DYNAMIC_INTERIOR_GRID_START_Y 
		self.m_MaxY = self.m_CurrentY + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE
	end
	if self.m_MaxY < (self.m_CurrentY + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE) then 
		self.m_MaxY = self.m_CurrentY + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE
	end
	local nextMaxX = self.m_MaxX + (max.x - min.x)  + DYNAMIC_INTERIOR_EDGE_TOLERANCE
	if nextMaxX > DYNAMIC_INTERIOR_GRID_END_X then 
		self.m_MaxX = DYNAMIC_INTERIOR_GRID_START_X 
		self.m_CurrentY = self.m_MaxY
		if self.m_MaxY > DYNAMIC_INTERIOR_GRID_END_Y then 
			self.m_MaxX = DYNAMIC_INTERIOR_GRID_START_X 
			self.m_CurrentY = DYNAMIC_INTERIOR_GRID_START_Y 
			self.m_MaxY = self.m_CurrentY + (max.y-min.y) + DYNAMIC_INTERIOR_EDGE_TOLERANCE
			self.m_CurrentDimension = self.m_CurrentDimension + 1
			if self.m_CurrentDimension > DYNAMIC_INTERIOR_MAX_DIMENSION then 
				self.m_CurrentDimension = 1
				self.m_CurrentInterior = self.m_CurrentInterior + 1
			end
		end
	else 
		self.m_MaxX = nextMaxX
	end
	self.m_MaxX = math.floor(self.m_MaxX) 
	self.m_MaxY = math.floor(self.m_MaxY)
	instance:move(Vector3(self.m_MaxX, self.m_MaxY, 2000))
	instance:setDimension(self.m_CurrentDimension)
	instance:setInterior(self.m_CurrentInterior)
end

function InteriorManager:destructor()
 
end
