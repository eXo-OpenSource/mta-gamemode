-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CacheArea3D.lua
-- *  PURPOSE:     Cached area 3D class
-- *
-- ****************************************************************************
CacheArea3D = inherit(CacheArea)

function CacheArea3D:constructor(posX, posY, posZ, rotX, rotY, rotZ, sawidth, saheight, resx, resy, containsGUIElements)
	CacheArea.constructor(self, 0, 0, resx, resy, containsGUIElements, true)
	self.m_3DX = posX;
	self.m_3DY = posY;
	self.m_3DZ = posZ;
	self.m_3DWidth = sawidth;
	self.m_3DHeight= saheight;
	
	self.m_RotY = rotY or 0
	self.m_RotX = rotX or 0
	self.m_RotZ = rotZ or 0
	
	
	-- There shall be no 0 nor 180 in rz (else: bugs)
	while self.m_RotZ > 360 do self.m_RotZ = self.m_RotZ-360 end
	while self.m_RotZ < 0 do self.m_RotZ = self.m_RotZ+360 end
	if self.m_RotZ == 0 then self.m_RotZ = 0.00001
	elseif self.m_RotZ == 180 then self.m_RotZ = 180.00001 
	end
	
end

function CacheArea3D:destructor()
	CacheArea.destructor(self)
end

function CacheArea3D:drawCached()
	if self.m_ChangedSinceLastFrame or not self.m_RenderTarget then
		if not self.m_RenderTarget then
			self.m_RenderTarget = dxCreateRenderTarget(self.m_Width, self.m_Height, true)
		end
		
		if not self.m_RenderTarget then
			-- We cannot create a render target
			-- This makes it impossible to render us
			return false
		end
		
		-- We got a render Target so go on and render to it
		dxSetRenderTarget(self.m_RenderTarget, true)
		
		-- Per definition we cannot have a drawThis method as only GUIElement instances
		-- may be cached (to avoid caching single texts / images etc.)
		
		-- Draw Children
		for k, v in ipairs(self.m_Children) do
			v:draw(true)
		end
		
		-- Restore render target
		dxSetRenderTarget(nil)
		self.m_ChangedSinceLastFrame = false
	end
	
	-- Render! :>
	local ex, ey, ez = getPointFromDistanceRotation3D(self.m_3DX, self.m_3DY-self.m_3DWidth/2, self.m_3DZ, self.m_RotX, self.m_RotY, self.m_RotZ, self.m_3DWidth/2)
	local sx, sy, sz = getPointFromDistanceRotation3D(self.m_3DX, self.m_3DY-self.m_3DWidth/2, self.m_3DZ, self.m_RotX, self.m_RotY, self.m_RotZ, -self.m_3DWidth/2)
	
	local fx, fy, fz = getPointFromDistanceRotation3D(self.m_3DX, self.m_3DY-self.m_3DWidth/2, self.m_3DZ, self.m_RotX, 0, 0, 1)
	
	dxDrawMaterialLine3D(sx, sy, sz, ex, ey, ez, self.m_RenderTarget, self.m_3DHeight, tocolor(255,255,255,255), fx, fy, fz)
	
	return true
end

function CacheArea:draw()
	-- Do not waste time in drawing invisible elements
	if not self.m_Visible then
		return
	end

	self:drawCached()
end
