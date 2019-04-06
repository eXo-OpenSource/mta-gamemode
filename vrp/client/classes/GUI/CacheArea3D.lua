-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/CacheArea3D.lua
-- *  PURPOSE:     Cached area 3D class
-- *
-- ****************************************************************************
CacheArea3D = inherit(CacheArea)

function CacheArea3D:constructor(startPos, endPos, normal, saheight, resx, resy, containsGUIElements, follow)
	self.m_3DStart = startPos
	self.m_3DEnd = endPos

	self.m_3DWidth = (self.m_3DStart - self.m_3DEnd).length
	self.m_3DHeight= saheight
	self.m_Normal = normal
	self.m_Follow = follow

	self.m_Middle = self.m_3DStart  + (self.m_3DEnd -self.m_3DStart) / 2

	local norm2 = (self.m_3DEnd - self.m_3DStart):cross(self.m_Normal)
	self.m_SecPos = self.m_Middle + norm2/norm2.length * saheight/2

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
	self.m_3DStart = Vector3(startX, startY, startZ)
	self.m_3DEnd = Vector3(endX, endY, endZ)
	self.m_3DWidth = (self.m_3DStart - self.m_3DEnd).length
	self.m_Middle = self.m_3DStart  + (self.m_3DEnd -self.m_3DStart) / 2
	local norm2 = (self.m_3DEnd - self.m_3DStart):cross(self.m_Normal)
	self.m_SecPos = self.m_Middle + norm2/norm2.length * saheight/2

	self:anyChange()
end

function CacheArea3D:performMouse(vecMouse3D, mouse1, mouse2, A, B, C, D)
	-- Calculate center
	local mid = self.m_Middle

	-- Calculate direction vectors
	local dirX = mid - self.m_SecPos
	local dirY = mid - self.m_3DStart

	-- Calculate corners
	--[[
		A------C
		|  mid |
		B------D
	]]
	A = mid - dirX - dirY
	B = mid - dirX + dirY
	C = mid + dirX - dirY
	D = mid + dirX + dirY

	-- Calculate direction vectors based upon the plane's origin (A)
	local P = vecMouse3D
	local AC = C - A
	local AB = B - A
	local AP = P - A

	-- Translate world coordinates to plane coordinates
	local x = AP:dot(AC / AC.length)
	local y = AP:dot(AB / AB.length)

	-- Translate plane coordinates into pixel coordinates
	local cx = x / self.m_3DHeight * self.m_ResX
	local cy = y / self.m_3DWidth* self.m_ResY

	-- Check if we have a collision
	if cx > self.m_ResX or cx < 0 then
		self:unhoverChildren()
		return
	end
	if cy > self.m_ResY or cy < 0 then
		self:unhoverChildren()
		return
	end

	-- Process children
	for k, v in pairs(self.m_Children) do
		v:performChecks(mouse1, mouse2, cx, cy)
	end
end

function CacheArea3D:performChecks()
	-- Disable 2D checks
	return false
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
			dxSetTextureEdge(self.m_RenderTarget, "clamp")
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
	local face = self.m_Middle + self.m_Normal

	dxDrawMaterialLine3D(self.m_3DStart.x, self.m_3DStart.y, self.m_3DStart.z,
						self.m_3DEnd.x, self.m_3DEnd.y, self.m_3DEnd.z,
						self.m_RenderTarget, self.m_3DHeight, tocolor(255,255,255,255),
						self.m_Follow and getElementPosition(localPlayer) or face.x, face.y, face.z)

	return true
end


function CacheArea3D:draw()
	-- Do not waste time in drawing invisible elements
	if not self.m_Visible then
		return
	end

	self:drawCached()
end
