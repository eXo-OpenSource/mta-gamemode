-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionGUI.lua
-- *  PURPOSE:     Faction Menu GUI class
-- *
-- ****************************************************************************
FactionGUI = inherit(GUIForm)
inherit(Singleton, FactionGUI)

function FactionGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	self.m_CloseButton.onLeftClick = function() self:close() end
	self.m_LeaderTab = false


	-- Tab: Allgemein
	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")
	self.m_tabAllgemein = tabAllgemein
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Fraktion:", tabAllgemein)
	self.m_FactionNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.06, _"Rang:", tabAllgemein)
	self.m_FactionRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.1, self.m_Width*0.4, self.m_Height*0.06, "", tabAllgemein)
--	self.m_FactionQuitButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Fraktion verlassen", true, tabAllgemein):setBarColor(Color.Red)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.1, _"Kasse:", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, _"Inhalt:", tabAllgemein)
	self.m_FactionMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, "", tabAllgemein)
	self.m_FactionMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.39, self.m_Width*0.27, self.m_Height*0.07, tabAllgemein):setCaption(_"Betrag")
	self.m_FactionMoneyDepositButton = VRPButton:new(self.m_Width*0.3, self.m_Height*0.39, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", true, tabAllgemein)
	self.m_FactionMoneyWithdrawButton = VRPButton:new(self.m_Width*0.56, self.m_Height*0.39, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", true, tabAllgemein)

	local tabMitglieder = self.m_TabPanel:addTab(_"Mitglieder")
	self.m_FactionPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.8, tabMitglieder)
	self.m_FactionPlayersGrid:addColumn(_"Spieler", 0.7)
	self.m_FactionPlayersGrid:addColumn(_"Rang", 0.3)
	self.m_FactionAddPlayerButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", true, tabMitglieder):setBarColor(Color.Green)
	self.m_FactionRemovePlayerButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.15, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", true, tabMitglieder):setBarColor(Color.Red)
	self.m_FactionRankUpButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.25, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", true, tabMitglieder)
	self.m_FactionRankDownButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.35, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", true, tabMitglieder)


	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
--	self.m_FactionQuitButton.onLeftClick = bind(self.FactionQuitButton_Click, self)
	self.m_FactionMoneyDepositButton.onLeftClick = bind(self.FactionMoneyDepositButton_Click, self)
	self.m_FactionMoneyWithdrawButton.onLeftClick = bind(self.FactionMoneyWithdrawButton_Click, self)
	self.m_FactionAddPlayerButton.onLeftClick = bind(self.FactionAddPlayerButton_Click, self)
	self.m_FactionRemovePlayerButton.onLeftClick = bind(self.FactionRemovePlayerButton_Click, self)
	self.m_FactionRankUpButton.onLeftClick = bind(self.FactionRankUpButton_Click, self)
	self.m_FactionRankDownButton.onLeftClick = bind(self.FactionRankDownButton_Click, self)

	self.m_WaffenRow = 0
	self.m_WaffenColumn = 0
	self.m_WaffenAnzahl = 0
	self.m_WeaponsName = {}
	self.m_WeaponsImage = {}
	self.m_WeaponsCheck = {}

	addRemoteEvents{"factionRetrieveInfo"}
	addEventHandler("factionRetrieveInfo", root, bind(self.Event_factionRetrieveInfo, self))
end

function FactionGUI:destructor()
	GUIForm.destructor(self)
end

function FactionGUI:onShow()
	triggerServerEvent("factionRequestInfo", root)
end

function FactionGUI:TabPanel_TabChanged(tabId)
	triggerServerEvent("factionRequestInfo", root)
end

function FactionGUI:addLeaderTab()
	if self.m_LeaderTab == false then
		local tabLeader = self.m_TabPanel:addTab(_"Leader")
		self.m_FactionRangGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.8, tabLeader)
		self.m_FactionRangGrid:addColumn(_"Rang", 0.2)
		self.m_FactionRangGrid:addColumn(_"Name", 0.8)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.06, _"ausgewählter Rang:", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderRankName = GUILabel:new(self.m_Width*0.45, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, "", tabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Gehalt: (in $)", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderLoan = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.28, self.m_Width*0.2, self.m_Height*0.06, tabLeader):setNumeric()
		GUILabel:new(self.m_Width*0.69, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Skin:", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)

		self.m_SkinVorschauBrowser = GUIWebView:new(self.m_Width*0.82, self.m_Height*0.01, self.m_Width*0.2, self.m_Height*0.4, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php", true, tabLeader)

		self.m_SkinChanger = GUIChanger:new(self.m_Width*0.69, self.m_Height*0.28, self.m_Width*0.16, self.m_Height*0.06, tabLeader)
		self.m_SkinChanger.onChange = function(text, index) self.m_SkinVorschauBrowser:loadURL("http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..text) end

		self.m_SaveRank = VRPButton:new(self.m_Width*0.69, self.m_Height*0.8, self.m_Width*0.3, self.m_Height*0.07, _"Rang Speichern", true, tabLeader)
		self.m_SaveRank.onLeftClick = bind(self.saveRank, self)
		self.m_SaveRank:setEnabled(false)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.35, self.m_Width*0.4, self.m_Height*0.06, _"Waffen:", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)

		for weaponID,v in pairs(self.m_validWeapons) do
			if v == true then
				self.m_WeaponsName[weaponID] = GUILabel:new(self.m_Width*0.45+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0.42+self.m_WaffenColumn*self.m_Height*0.2, self.m_Width*0.1, self.m_Height*0.05, getWeaponNameFromID(weaponID), tabLeader)
				self.m_WeaponsName[weaponID]:setAlignX("center")
				self.m_WeaponsImage[weaponID] = GUIImage:new(self.m_Width*0.45+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0.46+self.m_WaffenColumn*self.m_Height*0.2, self.m_Width*0.08, self.m_Width*0.08, WeaponIcons[weaponID], tabLeader)
				self.m_WeaponsCheck[weaponID] = GUICheckbox:new(self.m_Width*0.45+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0.58+self.m_WaffenColumn*self.m_Height*0.2, self.m_Width*0.12, self.m_Height*0.025, "aktiviert", tabLeader)
				self.m_WeaponsCheck[weaponID]:setFontSize(1)
				self.m_WaffenAnzahl = self.m_WaffenAnzahl+1
				if self.m_WaffenAnzahl == 4 or self.m_WaffenAnzahl == 8 then
					self.m_WaffenRow = 0
					self.m_WaffenColumn = self.m_WaffenColumn+1
				else
					self.m_WaffenRow = self.m_WaffenRow+1
				end

			end
		end

		for rank,name in pairs(self.m_RankNames) do
			local item = self.m_FactionRangGrid:addItem(rank, name)
			item.Id = rank
			item.onLeftClick = function()
				self.m_SelectedRank = rank
				self:onSelectRank(name,rank)
			end

			if rank == 1 then
				self.m_FactionRangGrid:onInternalSelectItem(item)
				item.onLeftClick()
			end
		end

		self.m_LeaderTab = true
	end
end

function FactionGUI:saveRank()
	if self.m_SelectedRank then
		local rankWeapons = self.m_rankWeapons[tostring(self.m_SelectedRank)]
		for weaponID = 0, 46 do
			if self.m_WeaponsCheck[weaponID] and self.m_WeaponsCheck[weaponID]:isChecked() == true then
				rankWeapons[tostring(weaponID)] = 1
			else
				rankWeapons[tostring(weaponID)] = 0
			end
		end

		triggerServerEvent("factionSaveRank",localPlayer,self.m_SelectedRank,self.m_SkinChanger:getIndex(),self.m_LeaderLoan:getText(),rankWeapons)
	end
end

function FactionGUI:onSelectRank(name,rank)
	self.m_LeaderRankName:setText(name.." - "..rank)
	self.m_LeaderLoan:setText(tostring(self.m_rankLoans[tostring(rank)]))
	self.m_SaveRank:setEnabled(true)

	for skinId,bool in pairs(self.m_skins) do
		if bool == true then
			self.m_SkinChanger:addItem(skinId)
		end
	end

	for weaponID,v in pairs(self.m_validWeapons) do
		if v == true then
			if self.m_rankWeapons[tostring(rank)][tostring(weaponID)] == 1 then
				self.m_WeaponsCheck[weaponID]:setChecked(true)
			else
				self.m_WeaponsCheck[weaponID]:setChecked(false)
			end
		end
	end

	self.m_SkinChanger:setSelectedItem(self.m_rankSkins[tostring(rank)])

end

function FactionGUI:Event_factionRetrieveInfo(id, name, rank,money, players,skins, rankNames,rankLoans,rankSkins,validWeapons,rankWeapons)
	--self:adjustFactionTab(rank or false)
	if id then
		if id > 0 then
			local x, y = self.m_FactionNameLabel:getPosition()
			self.m_RankNames = rankNames
			self.m_FactionNameLabel:setText(name)
			self.m_FactionRankLabel:setText(tostring(rank).." - "..rankNames[rank])
			self.m_FactionMoneyLabel:setText(tostring(money).."$")

			self.m_FactionPlayersGrid:clear()
			for playerId, info in pairs(players) do
				local item = self.m_FactionPlayersGrid:addItem(info.name, info.rank)
				item.Id = playerId
			end

			if rank >= FactionRank.Manager then
				self.m_skins = skins
				self.m_rankLoans = rankLoans
				self.m_rankSkins = rankSkins
				self.m_validWeapons = validWeapons
				self.m_rankWeapons = rankWeapons
				self:addLeaderTab()
			end
		end
	end
end

function FactionGUI:adjustFactionTab(rank)
	local isInFaction = rank ~= false

	for k, element in ipairs(self.m_tabAllgemein:getChildren()) do
		if element ~= self.m_FactionCreateButton then
			element:setVisible(isInFaction)
		end
	end

	if rank then
		if rank ~= FactionRank.Leader then
			self.m_FactionDeleteButton:setVisible(false)
		end
		if rank < FactionRank.Manager then
			self.m_FactionMoneyWithdrawButton:setVisible(false)
			self.m_FactionAddPlayerButton:setVisible(false)
			self.m_FactionRemovePlayerButton:setVisible(false)
			self.m_FactionRankUpButton:setVisible(false)
			self.m_FactionRankDownButton:setVisible(false)
		end
	end
end

function FactionGUI:FactionCreateButton_Click()
	FactionCreationGUI:new()
end

function FactionGUI:FactionMoneyDepositButton_Click()
	local amount = tonumber(self.m_FactionMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("factionDeposit", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function FactionGUI:FactionMoneyWithdrawButton_Click()
	local amount = tonumber(self.m_FactionMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("factionWithdraw", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function FactionGUI:FactionAddPlayerButton_Click()
	FactionInviteGUI:new()
end

function FactionGUI:FactionRemovePlayerButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("factionDeleteMember", root, selectedItem.Id)
	else
		ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online")
	end
end

function FactionGUI:FactionRankUpButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("factionRankUp", root, selectedItem.Id)
	end
end

function FactionGUI:FactionRankDownButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("factionRankDown", root, selectedItem.Id)
	end
end
