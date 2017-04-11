TownhallInfoGUI = inherit(GUIForm)
inherit(Singleton, TownhallInfoGUI)

function TownhallInfoGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	--self.m_CloseButton.onHover = function () self.m_CloseButton:setColor(Color.LightRed) end
	--self.m_CloseButton.onUnhover = function () self.m_CloseButton:setColor(Color.White) end
	self.m_CloseButton.onLeftClick = function() self:close() end

	-- Jobs
	local tabJobs = self.m_TabPanel:addTab(_"Jobs")
	self.m_TabJobs = tabJobs

	-- Aktivitäten
	local tabActivities = self.m_TabPanel:addTab(_"Aktivitäten")
	self.m_TabActivities = tabActivities

	-- Gangs
	local tabGangs = self.m_TabPanel:addTab(_"Gangs")
	self.m_TabGangs = tabGangs

	-- Inventar/Items
	local tabInventory = self.m_TabPanel:addTab(_"Inventar")
	self.m_TabInventory = tabInventory

	-- Info
	local tabInfo = self.m_TabPanel:addTab(_"Info")
	self.m_TabInfo = tabInfo
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.31, self.m_Height*0.10, _"Informationen", tabInfo)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.11, self.m_Width*0.25, self.m_Height*0.06, _"Build:", tabInfo)
	GUILabel:new(self.m_Width*0.3, self.m_Height*0.11, self.m_Width*0.4, self.m_Height*0.06, Version:getSingleton():getVersion(), tabInfo)
end

function TownhallInfoGUI:onShow()

end

function TownhallInfoGUI:openTab(tab)
	if not self:isVisible() then
		self:show()
	end
	if tab == 1 then
		self.m_TabJobs.TabButton.onLeftClick()
	elseif tab == 2 then
		self.m_TabActivities.TabButton.onLeftClick()
	elseif tab == 3 then
		self.m_TabGangs.TabButton.onLeftClick()
	elseif tab == 4 then
		self.m_TabInventory.TabButton.onLeftClick()
	end
end
