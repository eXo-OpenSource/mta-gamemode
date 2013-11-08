-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/CacheArea.lua
-- *  PURPOSE:     Cached area class
-- *
-- ****************************************************************************
CacheArea = inherit(DxElement)

function CacheArea:constructor(posX, posY, width, height, containsGUIElements, cachingEnabled)
	DxElement.constructor(self, posX, posY, width, height)

	GUIRenderer.addRef(self)
	
	self.m_TimeoutCounter = 0
	self.m_ContainsGUIElements = containsGUIElements
	self:setCachingEnabled(cachingEnabled == nil and true or cachingEnabled)
end

function CacheArea:destructor()
	if self.m_RenderTarget and isElement(self.m_RenderTarget) then
		destroyElement(self.m_RenderTarget)
	end
	DxElement.destructor(self)
	GUIRenderer.removeRef(self)
end

function CacheArea:updateArea()
	self.m_ChangedSinceLastFrame = true
	
	-- Go up the tree
	if self.m_Parent then self.m_Parent:anyChange() end
end

function CacheArea:anyChange()
	return self:updateArea()
end

function CacheArea:drawCached()
	if self.m_ChangedSinceLastFrame or not self.m_RenderTarget then
		if not self.m_RenderTarget then
			self.m_RenderTarget = dxCreateRenderTarget(self.m_Width, self.m_Height, true)
		end
		
		if not self.m_RenderTarget then
			-- We cannot cache (probably video memory low)
			-- Just draw normally and retry next frame
			-- and increment the timeout counter
			self.m_TimeoutCounter = self.m_TimeoutCounter + 1
			
			-- Turn caching after 5 retries of | Todo: Try to re-enable caching later
			if self.m_TimeoutCounter >= 5 then
				self:setCachingEnabled(false)
				self.m_TimeoutCounter = 0
				outputDebugString("Caching has been disabled due to low video memory")
			end
			
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
	dxSetBlendMode("add")
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_RenderTarget)
	dxSetBlendMode("blend")
	
	return true
end

function CacheArea:draw(incache)
	-- Do not waste time in drawing invisible elements
	if self.m_Visible == false then
		return
	end

	if self.m_CachingEnabled and not incache then
		if self:drawCached() then return end
	end
	
	-- Draw Children
	for k, v in ipairs(self.m_Children) do
		if v.draw then v:draw(incache) end
	end
end

function CacheArea:performChecks()
	-- Update GUI children
	for k, v in ipairs(self.m_Children) do
		if v.update then
			v:update()
		end
	end
end

function CacheArea:setCachingEnabled(state)
	if not self.m_CachingEnabled and state then
		-- We have to adjust the position as the rendertarget is relative itself
		for k, v in ipairs(self.m_Children) do
			v:setPosition(v.m_PosX - self.m_PosX, v.m_PosY - self.m_PosY)
		end
		
		-- Create our renderTarget
		self.m_RenderTarget = dxCreateRenderTarget(self.m_Width, self.m_Height, true)
		
		-- Add references
		local children = self.m_Children
		while children and #children > 0 do
			for k, v in ipairs(children) do
				v.m_CacheArea = self
			end
			children = children.m_Children
		end
		
	elseif self.m_CachingEnabled and not state then
		-- Do the recent steps in reverse
		for k, v in ipairs(self.m_Children) do
			v:setPosition(v.m_PosX + self.m_PosX, v.m_PosY + self.m_PosY)
		end
		
		-- Destroy the renderTarget to clear it
		if self.m_RenderTarget and isElement(self.m_RenderTarget) then destroyElement(self.m_RenderTarget) end
		
		-- Remove references
		local children = self.m_Children
		while children and #children > 0 do
			for k, v in ipairs(children) do
				v.m_CacheArea = nil
			end
			children = children.m_Children
		end
	end
	self.m_CachingEnabled = state
	self:anyChange()
end
