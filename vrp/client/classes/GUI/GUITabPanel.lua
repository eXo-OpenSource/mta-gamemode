-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUITabPanel.lua
-- *  PURPOSE:     GUITabPanel class
-- *
-- ****************************************************************************
GUITabPanel = inherit(GUITabControl)

function GUITabPanel:constructor(posX, posY, width, height, parent)
	checkArgs("GUITabControl:constructor", "number", "number", "number", "number")
	GUITabControl.constructor(self, posX, posY, width, height, parent)

end

function GUITabPanel:addTab(tabName)
	local tabButton = VRPButton:new(#self * 100, 0, 100, 30, tabName or "", self)
	local id = #self+1
	tabButton.onLeftClick = function() self:setTab(id) end

	self[id] = GUIElement:new(0, 30, self.m_Width, self.m_Height-30, self)
	if id ~= 1 then
		self[id]:setVisible(false)
	else
		self.m_CurrentTab = 1
	end
	
	return self[#self]
end

function GUITabPanel:drawThis()
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(255, 255, 255, 40))
end
