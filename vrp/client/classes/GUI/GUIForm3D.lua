-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIForm3D.lua
-- *  PURPOSE:     GUI 3D form class (base class)
-- *
-- ****************************************************************************
GUIForm3D = inherit(Object)

function GUIForm3D:constructor(position, rotation, size, resolution, streamdistance)
	-- Calculate Euler angles from plain normals (since Euler angles are easier to handle than line pos + normals)
	self.m_StartPosition, self.m_EndPosition, self.m_Normal = math.getPlainInfoFromEuler(position, rotation, size)
	self.m_CacheArea = false
	self.m_Resolution, self.m_Size = resolution, size

	-- Create streaming stuff
	self.m_StreamArea = createColSphere(position, streamdistance or 150)
	addEventHandler("onClientColShapeHit", self.m_StreamArea, bind(self.StreamArea_Hit, self))
	addEventHandler("onClientColShapeLeave", self.m_StreamArea, bind(self.StreamArea_Leave, self))
	
	-- Remove CacheArea3D immediately from the render queue (or do it already in CacheArea3D) a bit delayed
	nextframe(
		function()
			if localPlayer:isWithinColShape(self.m_StreamArea) and not self.m_CacheArea then
				self.m_CacheArea = CacheArea3D:new(self.m_StartPosition, self.m_EndPosition, self.m_Normal, self.m_Size.x, self.m_Resolution.x, self.m_Resolution.y, true)
			end
		end
	)
end

function GUIForm3D:destructor()
	self.m_StreamArea:destroy()
	
	if self.m_CacheArea then
		delete(self.m_CacheArea)
	end
end

function GUIForm3D:StreamArea_Hit(hitElement, matchingDimension)
	if hitElement ~= localPlayer or not matchingDimension then
		return
	end

	-- Dynamically create cache area
	self.m_CacheArea = CacheArea3D:new(self.m_StartPosition, self.m_EndPosition, self.m_Normal, self.m_Size.x, self.m_Resolution.x, self.m_Resolution.y, true)
	self:onStreamIn(self.m_CacheArea)
end

function GUIForm3D:StreamArea_Leave(hitElement, matchingDimension)
	if hitElement ~= localPlayer or not matchingDimension then
		return
	end

	-- Dynamically delete cache area
	if self.m_CacheArea then
		delete(self.m_CacheArea)
		self.m_CacheArea = false
	end
end

function GUIForm3D:getSurface()
	return self.m_CacheArea
end

GUIForm3D.onStreamIn = pure_virtual
