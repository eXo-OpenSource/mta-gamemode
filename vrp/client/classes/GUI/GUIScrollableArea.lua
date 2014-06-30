-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIScrollable.lua
-- *  PURPOSE:     GUI scrollable super class
-- *
-- ****************************************************************************
GUIScrollableArea = inherit(GUIElement)

function GUIScrollableArea:constructor(posX, posY, width, height, documentWidth, documentHeight, verticalScrollbar, horizontalScrollbar, parent)
	GUIElement.constructor(self, posX, posY, width, height, parent)

	self.m_PageTarget = dxCreateRenderTarget(documentWidth, documentHeight, true)
	if dxSetTextureEdge then
		dxSetTextureEdge(self.m_PageTarget, "border", Color.Clear)
	end
	
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
	local refreshAbsolutePosition;
	refreshAbsolutePosition = function(element)
		for k, v in ipairs(element.m_Children) do
			v.m_AbsoluteX = element.m_AbsoluteX + v.m_PosX
			v.m_AbsoluteY = element.m_AbsoluteY + v.m_PosY
			refreshAbsolutePosition(v)
		end
	end
	local absx, absy = self.m_AbsoluteX, self.m_AbsoluteY
	self.m_AbsoluteX, self.m_AbsoluteY = -self.m_ScrollX, self.m_ScrollY
	refreshAbsolutePosition(self)
	
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
	self.m_AbsoluteX, self.m_AbsoluteY = absx, absy 
	refreshAbsolutePosition(self)
	
	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_DocumentWidth, self.m_DocumentHeight, self.m_PageTarget)
	dxDrawImageSection(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, 0, 0, self.m_Width, self.m_Height, self.m_PageTarget)
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
	return self
end

function GUIScrollableArea:getScrollPosition()
	return self.m_ScrollX, self.m_ScrollY
end

function GUIScrollableArea:resize(documentWidth, documentHeight)
	destroyElement(self.m_PageTarget)
	self.m_PageTarget = dxCreateRenderTarget(documentWidth, documentHeight, true)
	dxSetTextureEdge(self.m_PageTarget, "border", Color.Clear)
	
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
		self:setScrollPosition(self.m_ScrollX, self.m_ScrollY + 14)
	end
end

function GUIScrollableArea:onInternalMouseWheelDown()
	self:setScrollPosition(self.m_ScrollX, self.m_ScrollY - 14)
end
