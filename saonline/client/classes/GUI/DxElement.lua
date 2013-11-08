-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/DxElement.lua
-- *  PURPOSE:     Dx element super class
-- *
-- ****************************************************************************
DxElement = inherit(Object)

function DxElement:constructor(posX, posY, width, height, parent)
	self.m_Parent = parent
	if not parent and not instanceof(self, CacheArea) then
		self.m_Parent = GUIRenderer.cacheroot
	end
	
	if self.m_Parent then
		self.m_Parent.m_Children[#self.m_Parent.m_Children+1] = self
	end
	
	self.m_PosX   = posX
	self.m_PosY   = posY
	self.m_Width  = width
	self.m_Height = height
	self.m_Children = {}
	self.m_Visible = true
	self.m_Alpha = 255
	
	-- Caching in Rendertargets
	self:anyChange()
	self.m_CurrentRenderTarget = false
	
	-- Find cache area if exists
	if self.m_Parent and instanceof(self.m_Parent, CacheArea) and self.m_Parent.m_CachingEnabled then
		self.m_CacheArea = self.m_Parent
	end
	if self.m_Parent and self.m_Parent.m_CacheArea and self.m_Parent.m_CacheArea.m_CachingEnabled then
		self.m_CacheArea = self.m_Parent.m_CacheArea
	end
	
	-- AbsX and AbsY
	self.m_AbsoluteX, self.m_AbsoluteY = self.m_PosX, self.m_PosY
	local lastElement = parent
	while lastElement do
		self.m_AbsoluteX = self.m_AbsoluteX + lastElement.m_PosX
		self.m_AbsoluteY = self.m_AbsoluteY + lastElement.m_PosY
		lastElement = lastElement.m_Parent
	end
	-- Ignore cache areas as rendertargets have their own offset position
	if self.m_CacheArea then
		self.m_AbsoluteX = self.m_AbsoluteX - self.m_CacheArea.m_AbsoluteX
		self.m_AbsoluteY = self.m_AbsoluteY - self.m_CacheArea.m_AbsoluteY
	end
end

function DxElement:destructor()
	if self.m_Parent then
		for k, v in pairs(self.m_Parent.m_Children) do
			if v == self then
				table.remove(self.m_Parent.m_Children, k)
			end
		end
	end
	self:anyChange()
end

function DxElement:anyChange()
	if self.m_CacheArea then
		return self.m_CacheArea:updateArea()
	end

	local cacheElement = self.m_Parent
	while cacheElement do
		-- Redraw everything in this area
		if cacheElement.updateArea then
			return cacheElement:updateArea()
		end
		cacheElement = cacheElement.m_Parent
	end
	return false
end

function DxElement:draw(incache)
	if self.m_Visible then
		-- Draw me
		if self.drawThis then
			self:drawThis(incache)
		end
		
		-- Draw children
		for k, v in ipairs(self.m_Children) do
			if v.m_Visible and v.draw then
				v:draw(incache)
			end
		end
	end
end

function DxElement:isVisible()
	return self.m_Visible
end

function DxElement:setVisible(visible)
	self.m_Visible = visible
	self:anyChange()
end

function DxElement:getChildren()
	return self.m_Children
end

function DxElement:getParent()
	return self.m_Parent
end

function DxElement:setParent(parent)
	-- Unlink from old parent first
	table.remove(self.m_Parent.m_Children, table.find(self.m_Parent.m_Children, self))

	-- Set the new parent element and link
	self.m_Parent = parent
	parent.m_Children[#self.m_Parent.m_Children+1] = self
	
	self:anyChange()
end

function DxElement:getPosition(isAbsolute)
	if not isAbsolute then
		return self.m_PosX, self.m_PosY
	end
	
	local absoluteX, absoluteY = self.m_AbsoluteX, self.m_AbsoluteY
	if self.m_CacheArea then
		absoluteX, absoluteY = absoluteX + self.m_CacheArea.m_AbsoluteX, absoluteY + self.m_CacheArea.m_AbsoluteY
	end
	return absoluteX, absoluteY
end

function DxElement:setPosition(posX, posY)
	local diffX, diffY = posX-self.m_PosX, posY-self.m_PosY
	self.m_PosX, self.m_PosY = posX, posY
	self.m_AbsoluteX, self.m_AbsoluteY = self.m_AbsoluteX + diffX, self.m_AbsoluteY + diffY
	
	local children = self.m_Children
	while children and #children > 0 do
		for k, v in ipairs(children) do
			v.m_AbsoluteX = v.m_AbsoluteX + diffX
			v.m_AbsoluteY = v.m_AbsoluteY + diffY
		end
		children = children.m_Children
	end

	self:anyChange()
end

function DxElement:isCursorWithinBox(x1, y1, x2, y2)
	local relCursorX, relCursorY = getCursorPosition()
	if not relCursorX then
		return false
	end

	local cursorX, cursorY = relCursorX * screenWidth, relCursorY * screenHeight
	if cursorX >= (self.m_AbsoluteX + x1) and cursorY >= (self.m_AbsoluteY + y1) and cursorX < (self.m_AbsoluteX + x2) and cursorY < (self.m_AbsoluteY + y2) then
		return true
	end

	return false
end

function DxElement:setAlpha(alpha)
	self.m_Alpha = alpha
	self:anyChange()
end

function DxElement:getAlpha()
	return self.m_Alpha
end
