-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIForm3D.lua
-- *  PURPOSE:     GUI 3D form class (base class)
-- *
-- ****************************************************************************
GUIForm3D = inherit(CacheArea3D)

function GUIForm3D:constructor(position, rotation, size, resolution, streamdistance)
	-- Calculate Euler angles from plain normals (since Euler angles are easier to handle than line pos + normals)
	local startpos, endpos, normal = math.getPlainInfoFromEuler(position, rotation, size)
	
	CacheArea3D.constructor(self, startpos, endpos, normal, math.abs(endpos.y-startpos.y), resolution.x, resolution.y, true)
	
	-- Remove CacheArea3D immediately from the render queue (or do it already in CacheArea3D)
	GUIRenderer.remove3DGUI(self)
	
	self.m_StreamArea = createColSphere(position, streamdistance or 150)
	addEventHandler("onClientColShapeHit", self.m_StreamArea, bind(self.StreamArea_Hit, self))
	addEventHandler("onClientColShapeLeave", self.m_StreamArea, bind(self.StreamArea_Leave, self))
end

function GUIForm3D:destructor()
	CacheArea3D.destructor(self)
end

function GUIForm3D:StreamArea_Hit(hitElement, matchingDimension)
	if hitElement ~= localPlayer or not matchingDimension then
		return
	end
	
	-- Dynamically add the 3D GUI to the renderer
	GUIRenderer.add3DGUI(self)
end

function GUIForm3D:StreamArea_Leave(hitElement, matchingDimension)
	if hitElement ~= localPlayer or not matchingDimension then
		return
	end
	
	-- Dynamically add the 3D GUI to the renderer
	GUIRenderer.remove3DGUI(self)
end
