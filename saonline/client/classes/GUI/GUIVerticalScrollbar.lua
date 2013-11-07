-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIVerticalScrollbar.lua
-- *  PURPOSE:     GUI vertical scrollbar class
-- *
-- ****************************************************************************
GUIVerticalScrollbar = inherit(GUIScrollbar)

function GUIVerticalScrollbar:constructor(posX, posY, width, height, parent)
	self.m_CursorMoveHandler = bind(GUIVerticalScrollbar.Event_onClientCursorMove, self)
end

function GUIVerticalScrollbar:onInternalLeftClick()
	local scrollerX = self.m_AbsoluteX + GUI_SCROLLBAR_ELEMENT_MARGIN
	local scrollerY = self.m_AbsoluteY + GUI_SCROLLBAR_ELEMENT_MARGIN + self.m_ScrollPosition * self.m_Height

	-- Is the cursor on top of the slider?
	if self:isCursorWithinBox(GUI_SCROLLBAR_ELEMENT_MARGIN, scrollerY - self.m_AbsoluteY + GUI_SCROLLBAR_ELEMENT_MARGIN, 13, scrollerY - self.m_AbsoluteY + GUI_SCROLLBAR_ELEMENT_MARGIN + 49) then
		-- Attach moving event
		addEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
		self.m_Scrolling = true
	end
end

function GUIVerticalScrollbar:onInternalLeftClickUp()
	if self.m_Scrolling then
		self.m_Scrolling = false
		
		-- Remove cursor move handler
		removeEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
		self.m_CursorOffset = nil
	end
end

function GUIVerticalScrollbar:Event_onClientCursorMove(_, _, cursorX, cursorY)
	local currentY = self.m_ScrollPosition * self.m_Height
	local cursorOffY = cursorY - self.m_AbsoluteY
	local diff = cursorOffY - currentY
	self.m_CursorOffset = self.m_CursorOffset or diff
	local newY = currentY + diff - self.m_CursorOffset
	
	if newY < self.m_Height-49-GUI_SCROLLBAR_ELEMENT_MARGIN then
		self:setScrollPosition(newY / self.m_Height)

		-- Call scroll handler
		if self.m_ScrollHandler then
			self.m_ScrollHandler(self:getScrollPosition())
		end 
	end
end

function GUIVerticalScrollbar:drawThis()
	-- Draw scroll bar (rectangle)
	--dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/scrollbar.png")

	-- Draw scrollbar element
	--dxDrawImage(self.m_AbsoluteX + GUI_SCROLLBAR_ELEMENT_MARGIN, self.m_AbsoluteY + GUI_SCROLLBAR_ELEMENT_MARGIN + self.m_ScrollPosition * self.m_Height, self.m_Width - 2*GUI_SCROLLBAR_ELEMENT_MARGIN, 49, "files/images/GUI/scrollbar_element.png")
end
