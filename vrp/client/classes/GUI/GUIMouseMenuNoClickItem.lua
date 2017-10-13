-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMouseMenuNoClickItem.lua
-- *  PURPOSE:     GUI mouse menu item class
-- *
-- ****************************************************************************
GUIMouseMenuNoClickItem = inherit(GUIMouseMenuItem)

function GUIMouseMenuNoClickItem:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUIMouseMenuNoClickItem:constructor", "number", "number", "number", "number")

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIFontContainer.constructor(self, text, 1, VRPFont(self.m_Height))
	GUIColorable.constructor(self, tocolor(0, 0, 0, 220))

	self.m_IconFont = FontAwesome(self.m_Height*0.75)
	self.m_TextColor = Color.Red
end

function GUIMouseMenuNoClickItem:drawThis()
	-- Draw background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)

	-- Draw item text
	if self.m_Icon then
		dxDrawText(self.m_Icon, self.m_AbsoluteX + 10, self.m_AbsoluteY + 8, self.m_AbsoluteX + 5 + self.m_Height, self.m_Height - 6, self.m_TextColor, self.m_FontSize, self.m_IconFont)
		dxDrawText(self.m_Text, self.m_AbsoluteX + 5 + self.m_Height, self.m_AbsoluteY + 3, self.m_Width - 10 - self.m_Width/10, self.m_Height - 6, self.m_TextColor, self.m_FontSize, self.m_Font)
	else
		dxDrawText(self.m_Text, self.m_AbsoluteX + 5, self.m_AbsoluteY + 3, self.m_Width - 10, self.m_Height - 6, self.m_TextColor, self.m_FontSize, self.m_Font)
	end
end
