-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIVerticalScrollbar.lua
-- *  PURPOSE:     GUI vertical scrollbar class
-- *
-- ****************************************************************************
GUIVerticalScrollbar = inherit(GUIScrollbar)

function GUIVerticalScrollbar:constructor(posX, posY, width, height, parent)
	self.m_CursorMoveHandler = bind(GUIVerticalScrollbar.Event_onClientCursorMove, self)
end

function GUIVerticalScrollbar:onInternalLeftClickDown()
	local scrollerY = self.m_ScrollPosition * (self.m_Height - self.m_ScrollerSize)

	-- Is the cursor on top of the slider?
	if self:isCursorWithinBox(0, scrollerY, self.m_Width, scrollerY + self.m_ScrollerSize) then
		-- Attach moving event
		addEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
		self.m_Scrolling = true
	end
end

function GUIVerticalScrollbar:onInternalLeftClick()
	if self.m_Scrolling then
		self.m_Scrolling = false

		-- Remove cursor move handler
		removeEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
		self.m_CursorOffset = nil
	end
end

function GUIVerticalScrollbar:Event_onClientCursorMove(_, _, cursorX, cursorY)
	if not isCursorShowing() then
		self:onInternalLeftClick()
		return
	end

	local absoluteX, absoluteY = self:getPosition(true)
	local scrollerY = absoluteY + self.m_ScrollPosition * (self.m_Height - self.m_ScrollerSize)

	local offset = cursorY - scrollerY
	self.m_CursorOffset = self.m_CursorOffset or offset

	local newY = cursorY - self.m_CursorOffset - absoluteY

	if newY < self.m_Height - self.m_ScrollerSize then
		self:setScrollPosition(newY / (self.m_Height - self.m_ScrollerSize))

		-- Call scroll handler
		if self.m_ScrollHandler then
			self.m_ScrollHandler(self:getScrollPosition())
		end
	end
end

function GUIVerticalScrollbar:drawThis()
	-- Draw scroller
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, Color.PrimaryNoClick)
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + self.m_ScrollPosition * (self.m_Height - self.m_ScrollerSize), self.m_Width, self.m_ScrollerSize)

	-- Draw scroll bar (rectangle)
	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/scrollbar.png")

	-- Draw scrollbar element
	--dxDrawImage(self.m_AbsoluteX + GUI_SCROLLBAR_ELEMENT_MARGIN, self.m_AbsoluteY + GUI_SCROLLBAR_ELEMENT_MARGIN + self.m_ScrollPosition * self.m_Height, self.m_Width - 2*GUI_SCROLLBAR_ELEMENT_MARGIN, 49, "files/images/GUI/scrollbar_element.png")
end
