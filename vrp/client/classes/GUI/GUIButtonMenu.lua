-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIButtonMenu.lua
-- *  PURPOSE:     GUIButtonMenu class
-- *
-- ****************************************************************************
GUIButtonMenu = inherit(GUIForm)

function GUIButtonMenu:constructor(text)
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(150/2), 300, 300)
	self.m_Window = GUIWindow:new(0, 0 ,300 ,500 ,text , true, true, self)
	self.m_Items   = {}
	self.m_Element = nil
end

function GUIButtonMenu:drawThis()
	-- Draw background
	--dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 220)) -- tocolor(255, 0, 0, 200)
end

function GUIButtonMenu:addItem(text, color, callback)
	self.m_Height = (#self.m_Items+1)*45+50
	local item
	if callback then
		item = GUIButton:new(30, 50 + #self.m_Items*45, self.m_Width - 60, 35, text, self)
		item:setBackgroundColor(color):setFont(VRPFont(28)):setFontSize(1)
		item.onLeftClick = function(item) callback(item, self.m_Element) delete(self) end
	end

	table.insert(self.m_Items, item)

	return item
end

function GUIButtonMenu:setElement(element)
	self.m_Element = element
end

function GUIButtonMenu:getElement()
	return self.m_Element
end
