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

function GUITabPanel:addTab(tabName, small)
	local height = small and 20 or 30
	local tabButton = GUIButton:new(#self.m_Tabs * 110, 0, 110, height, tabName or "", self):setBarEnabled(false)

	tabButton:setColor(Color.White)
	tabButton:setBackgroundColor(Color.Primary)
	tabButton:setFontSize(1)
	tabButton:setFont(VRPFont(25))

	local tabStripe = GUIRectangle:new(0, height-2, 110, 2, Color.Clear, tabButton)

	local id = #self.m_Tabs+1
	tabButton.onLeftClick = function()
		self:forceTab(id)
	end

	self.m_Tabs[id] = GUIElement:new(0, height, self.m_Width, self.m_Height-height, self)
	self.m_Tabs[id].TabIndex = id
	self.m_Tabs[id].TabButton = tabButton
	self.m_Tabs[id].TabAccentStripe = tabStripe
	if id ~= 1 then
		self.m_Tabs[id]:setVisible(false)
	else
		self.m_CurrentTab = 1
		tabStripe:setColor(Color.Accent)
	end

	self.m_Tabs[id].setEnabled = function(instance, enabled)
		instance.TabButton:setEnabled(enabled, true)
		if enabled then
			if self.m_Tabs[self.m_CurrentTab] ~= instance then
				instance.TabButton:setBackgroundColor(Color.Grey)
			else
				instance.TabButton:setColor(Color.Grey)
				instance.TabButton:setBackgroundColor(Color.LightBlue)
			end
		end
	end
	return self.m_Tabs[id]
end

function GUITabPanel:resizeTabs()
	local count = #self.m_Tabs
	for id, instance in pairs(self.m_Tabs) do
		self.m_Tabs[id].TabButton:setPosition(self.m_Width/count*(id-1))
		self.m_Tabs[id].TabButton:setSize(self.m_Width/count)
		self.m_Tabs[id].TabAccentStripe:setSize(self.m_Width/count)
	end
end

function GUITabPanel:drawThis()
	-- Draw the background
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150) --[[tocolor(255, 255, 255, 40)]])
end

function GUITabPanel:forceTab(tabId)
	if not self.m_Tabs[tabId] then return false end
	local tab = self.m_Tabs[tabId]
	self:setTab(tabId)

	for k, v in pairs(self.m_Tabs) do
		if k == tabId then -- set active
			v.TabAccentStripe:setColor(Color.Accent)
		else -- set inactive
			v.TabAccentStripe:setColor(Color.Clear)
		end
	end

	return tab
end

function GUITabPanel:updateGrid()
	grid("reset", true)
	grid("offset", 0)
end
