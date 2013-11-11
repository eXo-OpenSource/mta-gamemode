-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUITabPanel.lua
-- *  PURPOSE:     GUI Tab Panel
-- *  NOTE:		   You can access individual tabs by using Tabpanel[Tabid]
-- *
-- ****************************************************************************

GUITabPanel = inherit(GUIElement)

function GUITabPanel:constructor(posX, posY, width, height, parent)
	checkArgs("GUITabPanel:constructor", "number", "number", "number", "number")
	self.m_CurrentTab = false
	
	GUIElement.constructor(self, posX, posY, width, height, parent)
end

function GUITabPanel:setTab(id)
	if self.m_CurrentTab then
		self[self.m_CurrentTab]:hide()
	end
	self[id]:show()
	self.m_CurrentTab = id
	
	return self
end

function GUITabPanel:setTabCallback(id)
	return bind(GUITabPanel.setTab, self, id)
end

function GUITabPanel:getCurrentTab()
	return self.m_CurrentTab
end

function GUITabPanel:addTab()
	self[#self+1] = GUIElement:new(0, 0, self.m_Width, self.m_Height, self)
	return self[#self.m_Tabs]
end