-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIMouseMenu.lua
-- *  PURPOSE:     GUI label class
-- *
-- ****************************************************************************
GUIMouseMenu = inherit(GUIElement)

function GUIMouseMenu:constructor(posX, posY, width, height, parent)
	checkArgs("GUIMouseMenu:constructor", "number", "number", "number", "number")

	GUIElement.constructor(self, posX, posY, width, height, parent)
	
	self.m_Items   = {}
	self.m_Element = nil
end

function GUIMouseMenu:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(255, 0, 0, 200))
end

function GUIMouseMenu:addItem(text, callback)
	checkArgs("GUIMouseMenu:addItem", "string", "function")

	self.m_Height = (#self.m_Items+1)*30
	local item = GUIMouseMenuItem:new(0, 0 + #self.m_Items*35, self.m_Width, 35, text, self)
	item.onLeftClickDown = function(item) callback(item, self.m_Element) end
	
	table.insert(self.m_Items, item)
	
	return item
end

function GUIMouseMenu:setElement(element)
	self.m_Element = element
end
