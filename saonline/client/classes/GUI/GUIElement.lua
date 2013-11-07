-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/GUI/GUIElement.lua
-- *  PURPOSE:     GUI element wrapper
-- *
-- ****************************************************************************
GUIElement = inherit(Object)

function GUIElement:setVisible(state)
	return guiSetVisible(self.m_Element, state)
end

function GUIElement:getVisible(state)
	return guiGetVisible(self.m_Element, state)
end

function GUIElement:setAlpha(alpha)
	return guiSetAlpha(self.m_Element, alpha)
end

function GUIElement:getAlpha()
	return guiGetAlpha(self.m_Element)
end

function GUIElement:setEnabled(state)
	return guiSetEnabled(self.m_Element, state)
end

function GUIElement:isEnabled()
	return guiGetEnabled(self.m_Element)
end
