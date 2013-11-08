-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIScrollable.lua
-- *  PURPOSE:     GUI scrollable super class
-- *
-- ****************************************************************************
GUIScrollableArea = inherit(GUIElement)

function GUIScrollableArea:constructor(posX, posY, width, height, documentWidth, documentHeight, verticalScrollbar, horizontalScrollbar, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)

	self.m_PageTarget = dxCreateRenderTarget(documentWidth, documentHeight, true)
	
	self.m_ScrollX = 0
	self.m_ScrollY = 0
	self.m_DocumentWidth = documentWidth
	self.m_DocumentHeight = documentHeight
	self.m_ChangedSinceLastFrame = true
	
	if verticalScrollbar or horizontalScrollbar then
		self:createScrollbars(verticalScrollbar, horizontalScrollbar)
	end
end

function GUIScrollableArea:draw(incache)
	if self.m_Visible == false then
		return
	end
	
	-- Absolute X = Real X for drawing on the render target
	for k, v in ipairs(self.m_Children) do
		v.m_AbsoluteX = v.m_PosX - self.m_ScrollX
		v.m_AbsoluteY = v.m_PosY + self.m_ScrollY
	end
	
	-- Draw Children to render Target
	dxSetRenderTarget(self.m_PageTarget, true)
	
	-- Draw Self
	if self.drawThis then self:drawThis(incache) end
	
	-- Draw children
	for k, v in ipairs(self.m_Children) do
		if v.draw then v:draw(incache) end
	end
	dxSetRenderTarget(self.m_CacheArea.m_RenderTarget or nil)
	
	-- Recreate AbsoluteX for the update() method to allow mouse actions
	for k, v in pairs(self.m_Children) do
		v.m_AbsoluteX = self.m_AbsoluteX + v.m_PosX - self.m_ScrollX
		v.m_AbsoluteY = self.m_AbsoluteY + v.m_PosY + self.m_ScrollY
	end
	
	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_DocumentWidth, self.m_DocumentHeight, self.m_PageTarget)
end

function GUIScrollableArea:setScrollPosition(x, y)
	self.m_ScrollX = x
	self.m_ScrollY = y
	
	if self.m_VerticalScrollbar then
		self.m_VerticalScrollbar:setScrollPosition(self.m_ScrollY / self.m_Height)
	end
	
	if self.m_HorizontalScrollbar then
		self.m_HorizontalScrollbar:setScrollPosition(self.m_ScrollX / self.m_Width)
	end
	
	self:anyChange()
end

function GUIScrollableArea:getScrollPosition()
	return self.m_ScrollX, self.m_ScrollY
end

function GUIScrollableArea:resize(documentWidth, documentHeight)
	destroyElement(self.m_PageTarget)
	self.m_PageTarget = dxCreateRenderTarget(documentWidth, documentHeight, true)
	self.m_DocumentWidth, self.m_DocumentHeight = documentWidth, documentHeight
	self:anyChange()
end

function GUIScrollableArea:createScrollbars(verticalScrollbar, horizontalScrollbar)
	if verticalScrollbar then
		self.m_VerticalScrollbar = GUIVerticalScrollbar:new(self.m_PosX + self.m_Width - 20, 0, 20, self.m_Height, self)
	end
end

function GUIScrollableArea:onInternalMouseWheelUp()
	if (self.m_ScrollY) >= 0 then
		self.m_ScrollY = 0
	else
		self:setScrollPosition(self.m_ScrollX, self.m_ScrollY + 8)
	end
end

function GUIScrollableArea:onInternalMouseWheelDown()
	self:setScrollPosition(self.m_ScrollX, self.m_ScrollY - 8)
end
