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
	
	GUIRenderer.add3DGUI(self)
end

function CacheArea3D:destructor()
	GUIRenderer.remove3DGUI(self)
	CacheArea.destructor(self)
end

function CacheArea3D:setPosition(x, y, z)
	self.m_3DX = x
	self.m_3DY = y
	self.m_3DZ = z
	
	self:anyChange()
end

function CacheArea3D:setRotation(rx, ry, rz)
	self.m_RotX = rx
	self.m_RotY = ry
	self.m_RotZ = rz
	
	self:anyChange()
end

function CacheArea3D:getPosition()
	return self.m_3DX, self.m_3DY, self.m_3DZ
end

function CacheArea3D:getRotation()
	return self.m_RotX, self.m_RotY, self.m_RotZ
end

function CacheArea3D:anyChange()
	-- Kreisdefinition
	local mx,my,mz = self.m_3DX, self.m_3DY-self.m_3DWidth/2, self.m_3DZ
	
	-- Kreis im lokalen Raum mit r = 3DWidth / 2 um m
	local sx,sy,sz = getPointFromDistanceRotation3D(0, 0, 0, self.m_RotX, self.m_RotY, self.m_RotZ, self.m_3DWidth/2)
	local ex,ey,ez = getPointFromDistanceRotation3D(0, 0, 0, self.m_RotX, self.m_RotY, self.m_RotZ, -self.m_3DWidth/2)
	
	local px,py,pz = getPointFromDistanceRotation3D(0, 0, 0, self.m_RotX+90, self.m_RotY+90, self.m_RotZ, self.m_3DHeight/2)
	
	local fx = sy*pz - sz*py
	local fy = sz*px - sx*pz
	local fz = sx*py - sy*px
	
	
	sx,sy,sz=mx+sx,my+sy,mz+sz
	ex,ey,ez=mx+ex,my+ey,mz+ez
	fx,fy,fz=mx+fx,my+fy,mz+fz
	px,py,pz=mx+px,my+py,mz+pz
	
	self.m_LineStartX, self.m_LineStartY, self.m_LineStartZ = sx,sy,sz
	self.m_LineEndX, self.m_LineEndY, self.m_LineEndZ = ex, ey, ez
	self.m_FaceToX, self.m_FaceToY, self.m_FaceToZ = fx, fy, fz
	self.m_SecPosX, self.m_SecPosY, self.m_SecPosZ = px, py, pz
	
	-- propagate
	DxElement.anyChange(self)
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
	dxDrawMaterialLine3D(self.m_LineStartX, self.m_LineStartY, self.m_LineStartZ,
						self.m_LineEndX, self.m_LineEndY, self.m_LineEndZ,
						self.m_RenderTarget, self.m_3DHeight, tocolor(255,255,255,255), 
						self.m_FaceToX, self.m_FaceToY, self.m_FaceToZ)
	
	return true
end


function CacheArea3D:draw()
	-- Do not waste time in drawing invisible elements
	if not self.m_Visible then
		return
	end

	self:drawCached()
end
