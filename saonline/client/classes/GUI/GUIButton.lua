-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/GUI/GUIButton.lua
-- *  PURPOSE:     GUI button wrapper
-- *
-- ****************************************************************************
GUIButton = inherit(GUIElement)

function GUIButton:constructor(posX, posY, width, height, text, relative, parent)
	self.m_Element = guiCreateButton(posX, posY, width, height, text, relative, parent)
end

