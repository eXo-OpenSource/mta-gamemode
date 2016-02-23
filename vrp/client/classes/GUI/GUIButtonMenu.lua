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
	self.m_Window = GUIWindow:new(0, 0 ,self.m_Width ,self.m_Height ,text , true, true, self)
	self.m_Window:setCloseOnClose(true)
	self.m_Items   = {}
	self.m_Element = nil
end

function GUIButtonMenu:addItem(text, color, callback)
	self.m_Height = (#self.m_Items+1)*45+80
	self.m_Window:setSize(self.m_Width, self.m_Height)
	--self:setPosition(screenWidth/2-(self.m_Width/2), screenHeight/2-(self.m_Height/2))

	local item
	if callback then
		item = GUIButton:new(30, 50 + #self.m_Items*45, self.m_Width - 60, 40, text, self)
		item:setBackgroundColor(color):setFont(VRPFont(28)):setFontSize(1)
		item.onLeftClick = function(item) callback(item, self.m_Element) end
	end

	table.insert(self.m_Items, item)

	return item
end
