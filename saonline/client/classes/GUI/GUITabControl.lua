-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUITabControl.lua
-- *  PURPOSE:     GUI Tab Control
-- *  NOTE:		   You can access individual tabs by using Tabpanel[Tabid]
-- *
-- ****************************************************************************

GUITabControl = inherit(GUIElement)

function GUITabControl:constructor(posX, posY, width, height, parent)
	checkArgs("GUITabControl:constructor", "number", "number", "number", "number")
	self.m_CurrentTab = false
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
end

function GUITabControl:setTab(id)
	if self.m_CurrentTab then
		self[self.m_CurrentTab]:setVisible(false)
	end
	self[id]:setVisible(true)
	self.m_CurrentTab = id
	
	return self
end

function GUITabControl:setTabCallback(id)
	return bind(GUITabControl.setTab, self, id)
end

function GUITabControl:getCurrentTab()
	return self.m_CurrentTab
end

function GUITabControl:addTab()
	self[#self+1] = GUIElement:new(0, 0, self.m_Width, self.m_Height, self):setVisible(false)
	return self[#self]
end