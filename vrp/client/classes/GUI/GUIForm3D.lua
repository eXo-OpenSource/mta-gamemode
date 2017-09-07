-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIForm3D.lua
-- *  PURPOSE:     GUI 3D form class (base class)
-- *
-- ****************************************************************************
GUIForm3D = inherit(Object)
GUIForm3D.Map = {}

function GUIForm3D:constructor(position, rotation, size, resolution, streamdistance, follow)
	-- Calculate Euler angles from plane normals (since Euler angles are easier to handle than line pos + normals)
	self.m_StartPosition, self.m_EndPosition, self.m_Normal = math.getPlaneInfoFromEuler(position, rotation, size)
	self.m_CacheArea = false
	self.m_Resolution, self.m_Size = resolution, size
	self.m_Follow = follow

	-- Create streaming stuff
	self.m_StreamArea = createColSphere(position, streamdistance or 150)
	addEventHandler("onClientColShapeHit", self.m_StreamArea, bind(self.StreamArea_Hit, self))
	addEventHandler("onClientColShapeLeave", self.m_StreamArea, bind(self.StreamArea_Leave, self))

	-- Remove CacheArea3D immediately from the render queue (or do it already in CacheArea3D) a bit delayed
	nextframe(
		function()
			if self.m_StreamArea and isElement(self.m_StreamArea) and localPlayer:isWithinColShape(self.m_StreamArea) then
				self:StreamArea_Hit(localPlayer, true)
			end
		end
	)
	self.m_Id = #GUIForm3D.Map+1
	GUIForm3D.Map[self.m_Id] = self
end

function GUIForm3D:destructor()
	if self.m_Id and GUIForm3D.Map[self.m_Id] then
		GUIForm3D.Map[self.m_Id] = nil
	end

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
	if not self.m_CacheArea then
		self.m_CacheArea = CacheArea3D:new(self.m_StartPosition, self.m_EndPosition, self.m_Normal, self.m_Size.x, self.m_Resolution.x, self.m_Resolution.y, true, self.m_Follow)
		self:onStreamIn(self.m_CacheArea)
	end
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

function GUIForm3D.load()
	setTimer(function()
		for id, form in pairs(GUIForm3D.Map) do
			if form and form.m_StreamArea then
				if localPlayer:isWithinColShape(form.m_StreamArea) then
					form:StreamArea_Hit(localPlayer, true)
				end
			end
		end
	end, 3000, 1)
end

GUIForm3D.onStreamIn = pure_virtual
