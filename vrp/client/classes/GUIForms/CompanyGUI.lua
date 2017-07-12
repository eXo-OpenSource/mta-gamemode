-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/CompanyGUI.lua
-- *  PURPOSE:     Company Menu GUI class
-- *
-- ****************************************************************************
CompanyGUI = inherit(GUIForm)
inherit(Singleton, CompanyGUI)

function CompanyGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:close() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	self.m_LeaderTab = false
	self.m_LogTab = false

	-- Tab: Allgemein
	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")
	self.m_tabAllgemein = tabAllgemein
	self.m_CompanyNameLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.96, self.m_Height*0.10, "", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.12, self.m_Width*0.25, self.m_Height*0.06, _"Rang:", tabAllgemein)
	self.m_CompanyRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, "", tabAllgemein)
--	self.m_CompanyQuitButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Fraktion verlassen", true, tabAllgemein):setBarColor(Color.Red)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.1, _"Kasse:", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, _"Inhalt:", tabAllgemein)
	self.m_CompanyMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, "", tabAllgemein)
	--self.m_CompanyMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.39, self.m_Width*0.27, self.m_Height*0.07, tabAllgemein):setCaption(_"Betrag")
	--self.m_CompanyMoneyDepositButton = VRPButton:new(self.m_Width*0.3, self.m_Height*0.39, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", true, tabAllgemein)
	--self.m_CompanyMoneyWithdrawButton = VRPButton:new(self.m_Width*0.56, self.m_Height*0.39, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", true, tabAllgemein)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.25, self.m_Height*0.1, _"Funktionen:", tabAllgemein)
	self.m_CompanyRespawnVehicleButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.3, self.m_Height*0.07, _"Fahrzeuge respawnen", true, tabAllgemein)
	self.m_CompanyRespawnVehicleButton.onLeftClick = bind(self.CompanyRespawnVehicles, self)

	if localPlayer:getCompany():getId() == 3 then -- San News
		self.m_SanNewsToggleMsg = VRPButton:new(self.m_Width*0.02, self.m_Height*0.68, self.m_Width*0.3, self.m_Height*0.07, _"/sannews de/aktivieren", true, tabAllgemein)
		self.m_SanNewsToggleMsg.onLeftClick = bind(self.SanNewsToggleMessage, self)
	end

	local tabMitglieder = self.m_TabPanel:addTab(_"Mitglieder")
	self.m_CompanyPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.5, self.m_Height*0.8, tabMitglieder)
	self.m_CompanyPlayersGrid:addColumn(_"", 0.06)
	self.m_CompanyPlayersGrid:addColumn(_"Spieler", 0.44)
	self.m_CompanyPlayersGrid:addColumn(_"Rang", 0.18)
	self.m_CompanyPlayersGrid:addColumn(_"Aktivität", 0.27)
	self.m_CompanyAddPlayerButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", true, tabMitglieder):setBarColor(Color.Green)
	self.m_CompanyRemovePlayerButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.15, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", true, tabMitglieder):setBarColor(Color.Red)
	self.m_CompanyRankUpButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.25, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", true, tabMitglieder)
	self.m_CompanyRankDownButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.35, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", true, tabMitglieder)
	self.m_CompanyToggleActivityButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.45, self.m_Width*0.3, self.m_Height*0.07, _"Inaktiv setzen", true, tabMitglieder)


	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
--	self.m_CompanyQuitButton.onLeftClick = bind(self.CompanyQuitButton_Click, self)
	--self.m_CompanyMoneyDepositButton.onLeftClick = bind(self.CompanyMoneyDepositButton_Click, self)
	--self.m_CompanyMoneyWithdrawButton.onLeftClick = bind(self.CompanyMoneyWithdrawButton_Click, self)
	self.m_CompanyAddPlayerButton.onLeftClick = bind(self.CompanyAddPlayerButton_Click, self)
	self.m_CompanyRemovePlayerButton.onLeftClick = bind(self.CompanyRemovePlayerButton_Click, self)
	self.m_CompanyRankUpButton.onLeftClick = bind(self.CompanyRankUpButton_Click, self)
	self.m_CompanyRankDownButton.onLeftClick = bind(self.CompanyRankDownButton_Click, self)
	self.m_CompanyToggleActivityButton.onLeftClick = bind(self.CompanyToggleActivityButton_Click, self)

	self.m_TabLogs = self.m_TabPanel:addTab(_"Logs")

	addRemoteEvents{"companyRetrieveInfo", "companyRetrieveLog"}
	addEventHandler("companyRetrieveInfo", root, bind(self.Event_companyRetrieveInfo, self))
	addEventHandler("companyRetrieveLog", root, bind(self.Event_companyRetrieveLog, self))
end

function CompanyGUI:destructor()
	GUIForm.destructor(self)
end

function CompanyGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	triggerServerEvent("companyRequestInfo", root)
end

function CompanyGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

function CompanyGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabLogs.TabIndex then
		triggerServerEvent("companyRequestLog", root)
	else
		triggerServerEvent("companyRequestInfo", root)
	end
end

function CompanyGUI:Event_companyRetrieveLog(players, logs)
	if not self.m_LogGUI then
		self.m_LogGUI = LogGUI:new(self.m_TabLogs, logs, players)
	else
		self.m_LogGUI:updateLog(players, logs)
	end
end

function CompanyGUI:addLeaderTab()
	if self.m_LeaderTab == false then
		local tabLeader = self.m_TabPanel:addTab(_"Leader")
		self.m_CompanyRangGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.8, tabLeader)
		self.m_CompanyRangGrid:addColumn(_"Rang", 0.2)
		self.m_CompanyRangGrid:addColumn(_"Name", 0.8)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.06, _"Ausgewählter Rang:", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderRankName = GUILabel:new(self.m_Width*0.45, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, "", tabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Gehalt: (in $)", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderLoan = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.28, self.m_Width*0.2, self.m_Height*0.06, tabLeader):setNumeric(true, true)
		GUILabel:new(self.m_Width*0.69, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Skin:", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)

		self.m_SkinVorschauBrowser = GUIWebView:new(self.m_Width*0.82, self.m_Height*0.01, self.m_Width*0.2, self.m_Height*0.4, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php", true, tabLeader)

		self.m_SkinChanger = GUIChanger:new(self.m_Width*0.69, self.m_Height*0.28, self.m_Width*0.16, self.m_Height*0.06, tabLeader)
		self.m_SkinChanger.onChange = function(text, index) self.m_SkinVorschauBrowser:loadURL("http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..text) end

		self.m_SaveRank = VRPButton:new(self.m_Width*0.69, self.m_Height*0.8, self.m_Width*0.3, self.m_Height*0.07, _"Rang speichern", true, tabLeader)
		self.m_SaveRank.onLeftClick = bind(self.saveRank, self)
		self.m_SaveRank:setEnabled(false)

		for rank,name in pairs(self.m_RankNames) do
			local item = self.m_CompanyRangGrid:addItem(rank, name)
			item.Id = rank
			item.onLeftClick = function()
				self.m_SelectedRank = rank
				self:onSelectRank(name,rank)
			end

			if rank == 1 then
				self.m_CompanyRangGrid:onInternalSelectItem(item)
				item.onLeftClick()
			end
		end

		self.m_LeaderTab = true
	end
end

function CompanyGUI:saveRank()
	if self.m_SelectedRank then
		triggerServerEvent("companySaveRank",localPlayer,self.m_SelectedRank,self.m_SkinChanger:getIndex(),self.m_LeaderLoan:getText())
	end
end

function CompanyGUI:onSelectRank(name,rank)
	self.m_LeaderRankName:setText(name.." - "..rank)
	self.m_LeaderLoan:setText(tostring(self.m_RankLoans[tostring(rank)]))
	self.m_SaveRank:setEnabled(true)

	for skinId,bool in pairs(self.m_skins) do
		if bool == true then
			self.m_SkinChanger:addItem(skinId)
		end
	end

	self.m_SkinChanger:setSelectedItem(self.m_RankSkins[tostring(rank)])

end

function CompanyGUI:Event_companyRetrieveInfo(id, name, rank, money, players, skins, rankNames, rankLoans, rankSkins)
	--self:adjustCompanyTab(rank or false)
	if id then
		if id > 0 then
			local x, y = self.m_CompanyNameLabel:getPosition()
			self.m_RankNames = rankNames
			self.m_CompanyNameLabel:setText(name)
			self.m_CompanyRankLabel:setText(tostring(rank).." - "..rankNames[rank])
			self.m_CompanyMoneyLabel:setText(tostring(money).."$")

			players = sortPlayerTable(players, "playerId", function(a, b) return a.rank > b.rank end)

			self.m_CompanyPlayersGrid:clear()
			for _, info in ipairs(players) do
				local activitySymbol = info.isActive == 1 and FontAwesomeSymbols.Calender_Check or FontAwesomeSymbols.Calender_Time
				local item = self.m_CompanyPlayersGrid:addItem(activitySymbol, info.name, info.rank, tostring(info.activity).." h")
				item:setColumnFont(1, FontAwesome(20), 1):setColumnColor(1, info.isActive == 1 and Color.Green or Color.Red)
				item.Id = info.playerId
			end

			if rank >= CompanyRank.Manager then
				self.m_skins = skins
				self.m_RankLoans = rankLoans
				self.m_RankSkins = rankSkins
				self:addLeaderTab()
			end
		end
	end
end

function CompanyGUI:adjustCompanyTab(rank)
	local isInCompany = rank ~= false

	for k, element in ipairs(self.m_tabAllgemein:getChildren()) do
		if element ~= self.m_CompanyCreateButton then
			element:setVisible(isInCompany)
		end
	end

	if rank then
		if rank ~= CompanyRank.Leader then
			self.m_CompanyDeleteButton:setVisible(false)
		end
		if rank < CompanyRank.Manager then
			self.m_CompanyMoneyWithdrawButton:setVisible(false)
			self.m_CompanyAddPlayerButton:setVisible(false)
			self.m_CompanyRemovePlayerButton:setVisible(false)
			self.m_CompanyRankUpButton:setVisible(false)
			self.m_CompanyRankDownButton:setVisible(false)
		end
	end
end

function CompanyGUI:CompanyCreateButton_Click()
	CompanyCreationGUI:new()
end

function CompanyGUI:CompanyMoneyDepositButton_Click()
	local amount = tonumber(self.m_CompanyMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("companyDeposit", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function CompanyGUI:CompanyMoneyWithdrawButton_Click()
	local amount = tonumber(self.m_CompanyMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("companyWithdraw", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function CompanyGUI:CompanyAddPlayerButton_Click()
	InviteGUI:new(
		function(player)
			triggerServerEvent("companyAddPlayer", root, player)
		end,"company"
	)
end

function CompanyGUI:CompanyRemovePlayerButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("companyDeleteMember", root, selectedItem.Id)
	else
		ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online")
	end
end

function CompanyGUI:CompanyRankUpButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("companyRankUp", root, selectedItem.Id)
	end
end

function CompanyGUI:CompanyRankDownButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("companyRankDown", root, selectedItem.Id)
	end
end

function CompanyGUI:CompanyToggleActivityButton_Click()
	local selectedItem = self.m_CompanyPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("companyToggleActivity", root, selectedItem.Id)
	end
end

function CompanyGUI:CompanyRespawnVehicles()
	triggerServerEvent("companyRespawnVehicles", root)
end

function CompanyGUI:SanNewsToggleMessage()
	triggerServerEvent("sanNewsToggleMessage", root)
end
