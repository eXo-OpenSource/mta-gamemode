-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIScrollbar.lua
-- *  PURPOSE:     GUI scrollbar base class
-- *
-- ****************************************************************************
GUIScrollbar = inherit(GUIElement)
inherit(GUIColorable, GUIScrollbar)
GUI_SCROLLBAR_ELEMENT_MARGIN = 2

function GUIScrollbar:constructor()
	error "Please use GUIHorizontalScrollbar or CGUIVerticalScrollbar"
end

function GUIScrollbar:virtual_constructor(posX, posY, width, height, parent)
	checkArgs("GUIScrollbar:virtual_constructor", "number", "number", "number", "number")

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self, Color.LightBlue)

	self.m_Color = tocolor(0, 0, 0, 200)
	self.m_ScrollPosition = 0
	self.m_Scrolling = false
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

		if self.onInternalScroll then
			self:onInternalScroll(scrollPos)
		end
		if self.onScroll then
			self:onScroll(scrollPos)
		end
		return self
	end
	return self
end
