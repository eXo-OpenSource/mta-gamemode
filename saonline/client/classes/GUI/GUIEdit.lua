-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/GUI/GUIEdit.lua
-- *  PURPOSE:     GUI edit wrapper
-- *
-- ****************************************************************************
GUIEdit = inherit(GUIElement)

function GUIEdit:constructor(posX, posY, width, height, text, relative, parent)
	self.m_Element = guiCreateEdit(posX, posY, width, height, text, relative, parent)
end

function GUIEdit:setMasked(status)
	return guiEditSetMasked(self.m_Element, status)
end

function GUIEdit:setMaxLength(length)
	return guiEditSetMaxLength(self.m_Element, length)
end

function GUIEdit:setCaretIndex(index)
	return guiEditSetCaretIndex(self.m_Element, index)
end
