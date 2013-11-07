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
	
	self.m_Items = {}
end

function GUIMouseMenu:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(255, 0, 0, 200))
end

function GUIMouseMenu:addItem(text, callback)
	checkArgs("GUIMouseMenu:addItem", "string", "function")

	self.m_Height = (#self.m_Items+1)*30
	local item = GUIMouseMenuItem:new(0, 0 + #self.m_Items*30, self.m_Width, 30, text, self)
	item.onLeftClick = callback
	
	table.insert(self.m_Items, item)
	
	return item
end
