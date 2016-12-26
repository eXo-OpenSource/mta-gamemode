-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUITabPanel.lua
-- *  PURPOSE:     GUITabPanel class
-- *
-- ****************************************************************************
GUITabPanel = inherit(GUITabControl)

function GUITabPanel:constructor(posX, posY, width, height, parent)
	--checkArgs("GUITabControl:constructor", "number", "number", "number", "number")

	GUITabControl.constructor(self, posX, posY, width, height, parent)
end

function GUITabPanel:addTab(tabName)
	local tabButton = GUIButton:new(#self.m_Tabs * 110, 0, 110, 30, tabName or "", self)

	tabButton:setColor(Color.White)
	tabButton:setBackgroundColor(Color.Grey)
	tabButton:setFontSize(1)
	tabButton:setFont(VRPFont(26))

	local id = #self.m_Tabs+1
	tabButton.onLeftClick = function()
		-- self:setTab(id)

		-- for k, v in ipairs(self.m_Children) do
		-- 	if instanceof(v, GUIButton) then
		-- 		v:setColor(Color.White)
		-- 		v:setBackgroundColor(Color.Grey)
		-- 	end
		-- end

		-- tabButton:setColor(Color.Grey)
		-- tabButton:setBackgroundColor(Color.LightBlue)
		self:forceTab(id)
	end

	self.m_Tabs[id] = GUIElement:new(0, 30, self.m_Width, self.m_Height-30, self)
	self.m_Tabs[id].TabIndex = id
	self.m_Tabs[id].TabButton = tabButton
	if id ~= 1 then
		self.m_Tabs[id]:setVisible(false)
	else
		self.m_CurrentTab = 1
		tabButton:setColor(Color.Grey)
		tabButton:setBackgroundColor(Color.LightBlue)
	end

	return self.m_Tabs[id]
end

function GUITabPanel:drawThis()
	-- Draw the background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150) --[[tocolor(255, 255, 255, 40)]])

	-- Draw a seperator line
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + 30, self.m_Width, 2, Color.White)
end

function GUITabPanel:forceTab(tabId)
	if not self.m_Tabs[tabId] then return false end
	local tab = self.m_Tabs[tabId]
	self:setTab(tabId)

	for k, v in ipairs(self.m_Children) do
		if instanceof(v, GUIButton) then
			v:setColor(Color.White)
			v:setBackgroundColor(Color.Grey)
		end
	end

	tab.TabButton:setColor(Color.Grey)
	tab.TabButton:setBackgroundColor(Color.LightBlue)

	return tab
end
