-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/GUI/GUICheckbox.lua
-- *  PURPOSE:     GUI checkbox wrapper
-- *
-- ****************************************************************************
GUICheckbox = inherit(GUIElement)

function GUICheckbox:constructor(posX, posY, width, height, text, relative, parent)
	self.m_Element = guiCreateCheckbox(posX, posY, width, height, text, relative, parent)
end

function GUICheckbox:setSelected(selected)
	return guiCheckBoxSetSelected(self.m_Element, selected)
end

function GUICheckbox:getSelected()
	return guiCheckBoxGetSelected(self.m_Element)
end
