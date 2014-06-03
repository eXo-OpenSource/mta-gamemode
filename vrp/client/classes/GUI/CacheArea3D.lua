-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CacheArea3D.lua
-- *  PURPOSE:     Cached area 3D class
-- *
-- ****************************************************************************
CacheArea3D = inherit(CacheArea)

function CacheArea3D:constructor(startX, startY, startZ, endX, endY, endZ, normX, normY, normZ, saheight, resx, resy, containsGUIElements)
	self.m_3DStart = Vector(startX, startY, startZ)
	self.m_3DEnd = Vector(endX, endY, endZ)

	self.m_3DWidth = (self.m_3DStart - self.m_3DEnd):norm()
	self.m_3DHeight= saheight;
	self.m_Normal = Vector(normX, normY, normZ)
	
	self.m_Middle = self.m_3DStart  + (self.m_3DEnd -self.m_3DStart) / 2
	
	local norm2 = (self.m_3DEnd - self.m_3DStart):crossP(self.m_Normal)
	self.m_SecPos = self.m_Middle + norm2/norm2:norm() * saheight/2
 
	
	self.m_ResX = resx
	self.m_ResY = resy
	
	CacheArea.constructor(self, 0, 0, resx, resy, containsGUIElements, true)	
	GUIRenderer.add3DGUI(self)
end

function CacheArea3D:destructor()
	GUIRenderer.remove3DGUI(self)
	CacheArea.destructor(self)
end

function CacheArea3D:setPosition(startX, startY, startZ, endX, endY, endZ)
	self.m_3DStart = Vector(startX, startY, startZ)
	self.m_3DEnd = Vector(endX, endY, endZ)
	self.m_3DWidth = (self.m_3DStart - self.m_3DEnd):norm()
	self.m_Middle = self.m_3DStart  + (self.m_3DEnd -self.m_3DStart) / 2
	local norm2 = (self.m_3DEnd - self.m_3DStart):crossP(self.m_Normal)
	self.m_SecPos = self.m_Middle + norm2/norm2:norm() * saheight/2
	
	self:anyChange()
end

function CacheArea3D:performMouse(vecMouse3D, mouse1, mouse2, A, B, C, D)
	-- Eckpunkte berechnen
	
	-- Mittelpunkt berechnen
	local mid = self.m_Middle
	
	local dirX = mid - self.m_3DStart 
	local dirY = mid - self.m_SecPos 
	
	local A = mid - dirX - dirY
	local B = mid - dirX + dirY
	local C = mid + dirX - dirY
	local D = mid + dirX + dirY
	
	local P = vecMouse3D
	local AC = C - A
	local AB = B - A
	local AP = P - A
	
	local x = AP:dotP(AB / AB:norm())
	local y = AP:dotP(AC / AC:norm())
	
	
	local cx = y / self.m_3DWidth * self.m_ResX
	local cy = x / self.m_3DHeight* self.m_ResY

	if cx > self.m_ResX or cx < 0 then
		self:unhoverChildren()
		return 
	end
	if cy > self.m_ResY or cy < 0 then
		self:unhoverChildren()
		return 
	end
	
	for k, v in pairs(self.m_Children) do
		v:performChecks(mouse1, mouse2, cx, cy)
	end
end

function CacheArea3D:unhoverChildren()
	for k, v in pairs(self.m_Children) do
		if v.m_Hover then
			if v.onUnhover		  then v:onUnhover()         end
			if v.onInternalUnhover then v:onInternalUnhover() end
			v.m_Hover = false
		end
		CacheArea3D.unhoverChildren(v)
	end
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
	face = self.m_Middle + self.m_Normal
	
	dxDrawMaterialLine3D(self.m_3DStart.X, self.m_3DStart.Y, self.m_3DStart.Z,
						self.m_3DEnd.X, self.m_3DEnd.Y, self.m_3DEnd.Z,
						self.m_RenderTarget, self.m_3DHeight, tocolor(255,255,255,255), 
						face.X, face.Y, face.Z)
	
	return true
end


function CacheArea3D:draw()
	-- Do not waste time in drawing invisible elements
	if not self.m_Visible then
		return
	end

	self:drawCached()
end
