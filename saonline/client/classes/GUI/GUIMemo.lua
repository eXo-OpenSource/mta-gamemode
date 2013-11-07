-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIMemo.lua
-- *  PURPOSE:     GUI memo class
-- *
-- ****************************************************************************
GUIMemo = inherit(CGUIElement)
inherit(GUIColorable, GUIMemo)
inherit(GUIFontContainer, GUIMemo)
inherit(GUIScrollableArea, GUIMemo)

--- Creates a new GUI multi line edit box instance
-- @param posX The X-position (relative to parent)
-- @param posY The Y-position (relative to parent)
-- @param width The width of the box
-- @param height The height of the box
-- @param text Predefined text
-- @param (parent) Optional parent
function GUIMemo:constructor(posX, posY, width, height, text, parent)
	checkArgs("GUIMemo:constructor", "number", "number", "number", "number", "string")

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIScrollableArea.constructor(self, self.m_Width + 100, self.m_Height)
	--GUIFontContainer.constructor(self, "", 1)
	--GUIColorable.constructor(self, tocolor(0, 0, 0, 127))

	self.m_pLabel = CGUILabel(0, 0, width, height, text, self)
end

function GUIMemo:drawThis()
	GUIScrollableArea.drawThis(self)

	dxSetBlendMode("modulate_add")

	dxDrawImage(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, "files/images/GUI/editbox.png")

	dxSetBlendMode("blend")
end

function GUIMemo:onInternalLeftClick()
	GUIInputControl.setFocus(self)
end

