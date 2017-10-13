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
	self.m_Tabs = {}
	GUIElement.constructor(self, posX, posY, width, height, parent)
end

function GUITabControl:setTab(id)
	if self.m_CurrentTab then
		self.m_Tabs[self.m_CurrentTab]:setVisible(false)
	end
	self.m_Tabs[id]:setVisible(true)
	self.m_CurrentTab = id

	if self.onTabChanged then
		self.onTabChanged(id)
	end

	return self
end

function GUITabControl:setTabCallback(id)
	return bind(GUITabControl.setTab, self, id)
end

function GUITabControl:getCurrentTab()
	return self.m_CurrentTab
end

function GUITabControl:addTab()
	self.m_Tabs[#self.m_Tabs+1] = GUIElement:new(0, 0, self.m_Width, self.m_Height, self):setVisible(false)
	return self[#self.m_Tabs]
end
