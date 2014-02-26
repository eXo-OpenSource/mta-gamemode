-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CacheArea3D.lua
-- *  PURPOSE:     Cached area class
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
	
	if rotX and rotX ~= 0 then outputDebug("Warning - CacheArea3D rotation X not implemented") end
	if rotY and rotY ~= 0 then outputDebug("Warning - CacheArea3D rotation Y not implemented") end
	
	self.m_RotZ = rotZ
	
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
	local sx, sy, sz = self.m_3DX, self.m_3DY, self.m_3DZ;
	local ex, ey = getPointFromDistanceRotation(sx, sy, self.m_3DWidth, self.m_RotZ)
	local ez = sz
	
	-- face towards shall be the normal of the line
	-- ax + by + cz = 0
	-- c is always 0 since ez = sz
	local a = ex - sx
	local b = ey - sy
	-- ax + by = 0
	-- y shall be 1
	-- thus:
	-- ax + b = 0
	-- x + b/a = 0
	-- x = -b/a
	local x = -b/a
	
	local fx, fy, fz = x, 1, 0
	
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
