-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIScrollbar.lua
-- *  PURPOSE:     GUI scrollbar base class
-- *
-- ****************************************************************************

GUIScrollbar = inherit(GUIElement)
GUI_SCROLLBAR_ELEMENT_MARGIN = 2

function GUIScrollbar:constructor()
	error "Please use CGUIHorizontalScrollbar or CGUIVerticalScrollbar"
end

function GUIScrollbar:derived_constructor(posX, posY, width, height, parent)
	checkArgs("GUIScrollbar:derived_constructor", "number", "number", "number", "number")
	
	GUIElement.constructor(self, posX, posY, width, height, parent)

	self.m_Color = tocolor(0, 0, 0, 200)
	self.m_ScrollPosition = 0
	self.m_Scrolling = false
end

function GUIScrollbar:setScrollHandler(handler)
	self.m_ScrollHandler = handler
end

function GUIScrollbar:getScrollPosition()
	return self.m_ScrollPosition
end

function GUIScrollbar:isScrolling()
	return self.m_Scrolling
end

function GUIScrollbar:setScrollPosition(scrollPos)
	if scrollPos >= 0 and scrollPos <= 1 then
		self.m_ScrollPosition = scrollPos
		self:anyChange()
		return true
	end
	return false
end
