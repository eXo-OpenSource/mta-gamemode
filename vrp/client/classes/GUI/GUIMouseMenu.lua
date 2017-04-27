-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
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
	--dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 220)) -- tocolor(255, 0, 0, 200)
end

function GUIMouseMenu:addItem(text, callback)
	self.m_Height = (#self.m_Items+1)*35
	local item
	if callback then
		item = GUIMouseMenuItem:new(0, 0 + #self.m_Items*35, self.m_Width, 35, text, self)
		item.onLeftClick = function(item) callback(item, self.m_Element) delete(self) end
	else
		item = GUIMouseMenuNoClickItem:new(0, 0 + #self.m_Items*35, self.m_Width, 35, text, self)
	end

	table.insert(self.m_Items, item)

	return item
end

function GUIMouseMenu:adjustWidth()
	local maxWidth = 0

	for _, v in pairs(self.m_Items) do
		if v:getTextWidth() > maxWidth then
			maxWidth = v:getTextWidth()
		end
	end

	for _, v in pairs(self.m_Items) do
		v:setSize(maxWidth)
	end
end

function GUIMouseMenu:setElement(element)
	self.m_Element = element
end

function GUIMouseMenu:getElement()
	return self.m_Element
end
