-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionGUI.lua
-- *  PURPOSE:     Faction Menu GUI class
-- *
-- ****************************************************************************
FactionGUI = inherit(GUIForm)
inherit(Singleton, FactionGUI)
FactionGUI.DiplomacyColors = {
	[1] = Color.Green,
	[2] = Color.White,
	[3] = Color.Red,
}
function FactionGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	self.m_GangwarAreas = {}
	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:close() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Accent):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	self.m_Leader = false

	-- Tab: Allgemein
	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")
	self.m_tabAllgemein = tabAllgemein
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Fraktion:", tabAllgemein)
	self.m_FactionNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.06, _"Rang:", tabAllgemein)
	self.m_FactionRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.1, self.m_Width*0.4, self.m_Height*0.06, "", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.06, _"Aktions-Status:", tabAllgemein)
	self.m_FactionNextActionLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.18, self.m_Width*0.7, self.m_Height*0.06, "", tabAllgemein)

--	self.m_FactionQuitButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Fraktion verlassen", tabAllgemein):setBackgroundColor(Color.Red):setBarEnabled(true)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.1, _"Kasse:", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, _"Inhalt:", tabAllgemein)
	self.m_FactionMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, "", tabAllgemein)
	--self.m_FactionMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.39, self.m_Width*0.27, self.m_Height*0.07, tabAllgemein):setCaption(_"Betrag")

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.25, self.m_Height*0.1, _"Funktionen:", tabAllgemein)
	self.m_FactionRespawnVehicleButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.3, self.m_Height*0.07, _"Fahrzeuge respawnen", tabAllgemein):setBarEnabled(true):setTooltip("Linksklick für sofortigen Respawn \nRechtsklick für angekündigten Respawn", "button", true)
	self.m_FactionRespawnVehicleButton.onLeftClick = bind(self.FactionRespawnVehicles, self, true)
	self.m_FactionRespawnVehicleButton.onRightClick = bind(self.FactionRespawnVehicles, self, false)

	self.m_LogButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.3, self.m_Height*0.07, _"Fraktions-Logs", tabAllgemein):setBarEnabled(true)
	self.m_LogButton.onLeftClick = bind(self.ShowLogs, self)
	self.m_ObjectListButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.8, self.m_Width*0.3, self.m_Height*0.07, _"platzierte Objekte", tabAllgemein):setBarEnabled(true)
	self.m_ObjectListButton.onLeftClick = bind(self.ShowObjectList, self)
	self.m_BindButton = GUIButton:new(self.m_Width*0.36, self.m_Height*0.6, self.m_Width*0.3, self.m_Height*0.07, _"Binds verwalten", tabAllgemein):setBarEnabled(true)
	self.m_BindButton.onLeftClick = function()
		if self.m_BindManageGUI then delete(self.m_BindManageGUI) end
		self:close()
		self.m_BindManageGUI = BindManageGUI:new("faction")
		self.m_BindManageGUI:addBackButton(function() FactionGUI:getSingleton():show() end)
	end

	self.m_EquipmentPermButton = GUIButton:new(self.m_Width*0.36, self.m_Height*0.7, self.m_Width*0.3, self.m_Height*0.07, _"Equipment-Rechte", tabAllgemein):setBarEnabled(true)
	self.m_EquipmentPermButton.onLeftClick = function()
		if self.m_EquipmentPermGUI then delete(self.m_EquipmentPermGUI) end
		self:close()
		self.m_EquipmentPermGUI = EquipmentOptionGUI:new()
		self.m_EquipmentPermGUI:addBackButton(function() FactionGUI:getSingleton():show() end)
	end

	self.m_AreaAlarmButton = GUIButton:new(self.m_Width*0.7, self.m_Height*0.6, self.m_Width*0.28, self.m_Height*0.07, _"Alarm (de-)aktivieren", tabAllgemein):setBarEnabled(true)
	self.m_AreaAlarmButton:setVisible(false)
	self.m_AreaAlarmButton:setEnabled(false)
	self.m_AreaAlarmButton.onLeftClick = function()
		triggerServerEvent("factionStateDeactivateAreaAlarm", localPlayer)
	end

	self.m_SkinChangeButton = GUIButton:new(self.m_Width*0.36, self.m_Height*0.8, self.m_Width*0.3, self.m_Height*0.07, _"Kleidung wechseln", tabAllgemein):setBarEnabled(true)
	self.m_SkinChangeButton.onLeftClick = function()
		self:close()
		triggerServerEvent("factionRequestSkinSelection", localPlayer)
	end

	local tabMitglieder = self.m_TabPanel:addTab(_"Mitglieder")
	self.m_tabMitglieder = tabMitglieder
	self.m_FactionPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.6, self.m_Height*0.8, tabMitglieder)
	self.m_FactionPlayersGrid:addColumn(_"", 0.06)
	self.m_FactionPlayersGrid:addColumn(_"", 0.06)
	self.m_FactionPlayersGrid:addColumn(_"Spieler", 0.4)
	self.m_FactionPlayersGrid:addColumn(_"Rang", 0.18)
	self.m_FactionPlayersGrid:addColumn(_"Aktivität", 0.27)
	self.m_FactionPlayersGrid:setSortable{"Spieler", "Rang", "Aktivität"}
	self.m_FactionPlayersGrid:setSortColumn(_"Rang", "down")

	self.m_FactionAddPlayerButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", tabMitglieder):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_FactionRemovePlayerButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.15, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", tabMitglieder):setBackgroundColor(Color.Red):setBarEnabled(true)
	self.m_FactionRankUpButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.25, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", tabMitglieder):setBarEnabled(true)
	self.m_FactionRankDownButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.35, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", tabMitglieder):setBarEnabled(true)
	self.m_FactionToggleLoanButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.45, self.m_Width*0.3, self.m_Height*0.07, _"Gehalt deaktivieren", tabMitglieder):setBarEnabled(true)
	self.m_FactionToggleWeaponButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.55, self.m_Width*0.3, self.m_Height*0.07, _"Waffen deaktivieren", tabMitglieder):setBarEnabled(true)
	self.m_FactionPlayerFileButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.65, self.m_Width*0.3, self.m_Height*0.07, _"Spielerakten", self.m_tabMitglieder)
	self.m_FactionForumSyncButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.75, self.m_Width*0.3, self.m_Height*0.07, _"Foren-Gruppen", self.m_tabMitglieder):setBarEnabled(true)
	self.m_FactionPlayerPermissionsButton = GUIButton:new(self.m_Width*0.64, self.m_Height*0.75, self.m_Width*0.3, self.m_Height*0.07, _"Rechte bearbeiten", self.m_tabMitglieder):setBarEnabled(true)
	self.m_FactionAddPlayerButton:setEnabled(false)
	self.m_FactionRemovePlayerButton:setEnabled(false)
	self.m_FactionRankUpButton:setEnabled(false)
	self.m_FactionRankDownButton:setEnabled(false)
	self.m_FactionToggleLoanButton:setEnabled(false)
	self.m_FactionToggleWeaponButton:setEnabled(false)
	self.m_FactionPlayerFileButton:setEnabled(false)
	self.m_FactionForumSyncButton:setVisible(false)
	self.m_FactionPlayerPermissionsButton:setEnabled(false)
	
	self.m_tabGangwar = self.m_TabPanel:addTab(_"Gangwar")

	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
--	self.m_FactionQuitButton.onLeftClick = bind(self.FactionQuitButton_Click, self)
	self.m_FactionAddPlayerButton.onLeftClick = bind(self.FactionAddPlayerButton_Click, self)
	self.m_FactionRemovePlayerButton.onLeftClick = bind(self.FactionRemovePlayerButton_Click, self)
	self.m_FactionRankUpButton.onLeftClick = bind(self.FactionRankUpButton_Click, self)
	self.m_FactionRankDownButton.onLeftClick = bind(self.FactionRankDownButton_Click, self)
	self.m_FactionToggleLoanButton.onLeftClick = bind(self.FactionToggleLoanButton_Click, self)
	self.m_FactionToggleWeaponButton.onLeftClick = bind(self.FactionToggleWeaponButton_Click, self)
	self.m_FactionPlayerFileButton.onLeftClick = bind(self.FactionPlayerFileButton_Click, self)
	self.m_FactionForumSyncButton.onLeftClick = bind(self.FactionForumSyncButton_Click, self)
	self.m_FactionPlayerPermissionsButton.onLeftClick = bind(self.factionPlayerPermissionsButton_Click, self)

	self.m_WeaponsName = {}
	self.m_WeaponsImage = {}
	self.m_WeaponsCheck = {}

	self.m_TabDiplomacy = self.m_TabPanel:addTab(_"Diplomatie")

	addRemoteEvents{"factionRetrieveInfo", "gangwarLoadArea", "factionRetrieveDiplomacy", "gangwarLoadAttackLog", "gangwarLoadTopList"}
	addEventHandler("factionRetrieveInfo", root, bind(self.Event_factionRetrieveInfo, self))
	addEventHandler("factionRetrieveDiplomacy", root, bind(self.Event_retrieveDiplomacy, self))
	addEventHandler("gangwarLoadArea", root, bind(self.Event_gangwarLoadArea, self))
	addEventHandler("gangwarLoadAttackLog", root, bind(self.Event_gangwarLoadAttackLog, self))
	addEventHandler("gangwarLoadTopList", root, bind(self.Event_gangwarLoadTopList, self))
end

function FactionGUI:destructor()
	GUIForm.destructor(self)
end

function FactionGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	triggerServerEvent("factionRequestInfo", root)
end

function FactionGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

function FactionGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_tabGangwar.TabIndex then
		self:loadGangwarTab()
	elseif tabId == self.m_TabDiplomacy.TabIndex then
		self:loadDiplomacyTab()
	else
		triggerServerEvent("factionRequestInfo", root)
	end
end

function FactionGUI:addLeaderTab()
	if self.m_Leader == false then
		self.m_TabLeader = self.m_TabPanel:addTab(_"Leader")
		self.m_FactionRangGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.6, self.m_TabLeader)
		self.m_FactionRangGrid:addColumn(_"Rang", 0.2)
		self.m_FactionRangGrid:addColumn(_"Name", 0.8)

		self.m_WeaponArea = GUIScrollableArea:new(250, 200, 340, 200, 340, 0, true, false, self.m_TabLeader, 200)
		self.m_WeaponArea:setVisible(false)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.06, _"Ausgewählter Rang:", self.m_TabLeader):setFont(VRPFont(30)):setColor(Color.Accent)
		self.m_LeaderRankName = GUILabel:new(self.m_Width*0.45, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, "", self.m_TabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Gehalt: (in $)", self.m_TabLeader):setFont(VRPFont(30)):setColor(Color.Accent)
		self.m_LeaderLoan = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.28, self.m_Width*0.2, self.m_Height*0.06, self.m_TabLeader)
		self.m_LeaderLoan:setNumeric(true, true)
		self.m_LeaderLoan:setVisible(false)

		self.m_SaveRank = GUIButton:new(self.m_Width*0.02, self.m_Height*0.66, self.m_Width*0.4, self.m_Height*0.07, _"Rang speichern", self.m_TabLeader):setBarEnabled(true)
		self.m_SaveRank.onLeftClick = bind(self.saveRank, self)
		self.m_SaveRank:setEnabled(false)

		self.m_ChangePermissions = GUIButton:new(self.m_Width*0.02, self.m_Height*0.75, self.m_Width*0.4, self.m_Height*0.07, _"Rechteverwaltung", self.m_TabLeader):setBarEnabled(true)
		self.m_ChangePermissions.onLeftClick = bind(self.openPermissionsGUI, self, "permission")
		self.m_ChangePermissions:setEnabled(false)

		self.m_ChangeActionPermissions = GUIButton:new(self.m_Width*0.02, self.m_Height*0.845, self.m_Width*0.4, self.m_Height*0.07, _"Aktionsstartberechtigungen", self.m_TabLeader):setBarEnabled(true)
		self.m_ChangeActionPermissions.onLeftClick = bind(self.openPermissionsGUI, self, "action")
		self.m_ChangeActionPermissions:setEnabled(false)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.35, self.m_Width*0.4, self.m_Height*0.06, _"Waffen:", self.m_TabLeader):setFont(VRPFont(30)):setColor(Color.Accent)

		self:refreshLeaderTab()

		self.m_Leader = true
	else
		self:refreshLeaderTab()
	end
end

function FactionGUI:refreshLeaderTab()
	for i = 0, 46 do
		if self.m_WeaponsName[i] then delete(self.m_WeaponsName[i]) end
		if self.m_WeaponsImage[i] then delete(self.m_WeaponsImage[i]) end
		if self.m_WeaponsCheck[i] then delete(self.m_WeaponsCheck[i]) end
	end
	self.m_WaffenAnzahl = 0
	self.m_WaffenRow = 0
	self.m_WaffenColumn = 0

	self.m_LeaderLoan:setVisible(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editLoan"))
	self.m_WeaponArea:setVisible(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editWeaponPermissions"))
	self.m_FactionPlayerFileButton:setEnabled(localPlayer:getPublicSync("FactionRank") >= FactionRank.Manager)
	--self.m_FactionForumSyncButton:setVisible(localPlayer:getPublicSync("FactionRank") >= FactionRank.Manager)
	self.m_ChangePermissions:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "changePermissions"))
	self.m_ChangeActionPermissions:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editActionPermissions"))

	self.m_WeaponArea:setScrollPosition(0,0)
	self.m_WeaponArea:clear()
	for weaponID, v in pairs(self.m_ValidWeapons) do
		if v == true then
			self.m_WeaponsName[weaponID] = GUILabel:new(self.m_Width*0.0+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0+self.m_WaffenColumn*self.m_Height*0.16, self.m_Width*0.16, self.m_Height*0.04, WEAPON_NAMES[weaponID], self.m_WeaponArea)
			self.m_WeaponsName[weaponID]:setAlignX("center")
			self.m_WeaponsImage[weaponID] = GUIImage:new(self.m_Width*0.03+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0.03+self.m_WaffenColumn*self.m_Height*0.16, self.m_Width*0.06, self.m_Width*0.06, FileModdingHelper:getSingleton():getWeaponImage(weaponID), self.m_WeaponArea)
			self.m_WeaponsCheck[weaponID] = GUICheckbox:new(self.m_Width*0.02+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0.13+self.m_WaffenColumn*self.m_Height*0.16, self.m_Width*0.12, self.m_Height*0.02, "aktiviert", self.m_WeaponArea)
			self.m_WeaponsCheck[weaponID]:setFontSize(1)
			self.m_WaffenAnzahl = self.m_WaffenAnzahl+1
			if self.m_WaffenAnzahl % 4 == 0 then
				self.m_WaffenRow = 0
				self.m_WaffenColumn = self.m_WaffenColumn+1
			else
				self.m_WaffenRow = self.m_WaffenRow+1
			end
			self.m_WeaponArea:resize(330, 50+self.m_WaffenColumn*90)
		end
	end

	self.m_FactionRangGrid:clear()
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
end

function FactionGUI:saveRank()
	if self.m_SelectedRank then
		local rankWeapons = self.m_RankWeapons[tostring(self.m_SelectedRank)]
		for weaponID = 0, 46 do
			if self.m_WeaponsCheck[weaponID] and self.m_WeaponsCheck[weaponID]:isChecked() == true then
				rankWeapons[tostring(weaponID)] = 1
			else
				rankWeapons[tostring(weaponID)] = 0
			end
		end

		triggerServerEvent("factionSaveRank",localPlayer,self.m_SelectedRank,self.m_LeaderLoan:getText(),rankWeapons)
	end
end

function FactionGUI:onSelectRank(name,rank)
	self.m_LeaderRankName:setText(name.." - "..rank)
	self.m_LeaderLoan:setText(tostring(self.m_RankLoans[tostring(rank)]))
	self.m_SaveRank:setEnabled(true)

	for weaponID,v in pairs(self.m_ValidWeapons) do
		if v == true then
			if self.m_RankWeapons[tostring(rank)][tostring(weaponID)] == 1 then
				self.m_WeaponsCheck[weaponID]:setChecked(true)
			else
				self.m_WeaponsCheck[weaponID]:setChecked(false)
			end
		end
	end
end

function FactionGUI:loadGangwarTab()
	if self.m_GangAreasGrid then delete(self.m_GangAreasGrid) end
	self.m_GangAreasGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.85, self.m_tabGangwar)
	self.m_GangAreasGrid:addColumn(_"Gangwar-Info", 0.7)
	self.m_GangAreasOverviewItem = self.m_GangAreasGrid:addItem(_"Übersicht")
	self.m_GangAreasOverviewItem.onLeftClick = function() self:onGangwarItemSelect(self.m_GangAreasOverviewItem) end
	self.m_GangAttackLogItem = self.m_GangAreasGrid:addItem(_"Attack-Log")
	self.m_GangAttackLogItem.onLeftClick = function() self:onGangwarItemSelect(self.m_GangAttackLogItem) end
	self.m_GangAttackBestLog = self.m_GangAreasGrid:addItem(_"Bestenliste")
	self.m_GangAttackBestLog.onLeftClick = function() self:onGangwarItemSelect(self.m_GangAttackBestLog) end
	self.m_GangAreasGrid:addItemNoClick(_"Gebiete")
	self.m_GangwarAreas = {}
	triggerServerEvent("gangwarGetAreas", localPlayer)
	self.m_GangAreasGrid:onInternalSelectItem(self.m_GangAreasOverviewItem)
	self:onGangwarItemSelect(self.m_GangAreasOverviewItem)
end

function FactionGUI:loadDiplomacyTab()
	if not self.m_DiplomacyLoaded then

		self.m_DiplomacyGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.43, self.m_TabDiplomacy)
		self.m_DiplomacyGrid:addColumn(_"Fraktion", 1)

		self.m_DiplomacyOutHead = GUILabel:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.46, self.m_Height*0.08, _"Diplomatische Anfragen:", self.m_TabDiplomacy)
		self.m_DiplomacyRequestGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.5, self.m_Height*0.3, self.m_TabDiplomacy)
		self.m_DiplomacyRequestGrid:addColumn(_"Fraktion", 0.35)
		self.m_DiplomacyRequestGrid:addColumn(_"Typ", 0.65)

		self.m_DiplomacyRequestText = GUILabel:new(self.m_Width*0.54, self.m_Height*0.6, self.m_Width*0.44, self.m_Height*0.06, "", self.m_TabDiplomacy):setMultiline(true)

		self.m_DiplomacyPermissionLabels = {
			["vehicles"] = GUILabel:new(self.m_Width*0.34, self.m_Height*0.39, self.m_Width*0.44, self.m_Height*0.05, "", self.m_TabDiplomacy),
			["weapons"] = GUILabel:new(self.m_Width*0.34, self.m_Height*0.44, self.m_Width*0.44, self.m_Height*0.05, "", self.m_TabDiplomacy)
		}
		self.m_DiplomacyPermissionChangeLabels = {
			["vehicles"] = GUILabel:new(self.m_Width*0.75, self.m_Height*0.39, self.m_Width*0.23, self.m_Height*0.05, "", self.m_TabDiplomacy),
			["weapons"] = GUILabel:new(self.m_Width*0.75, self.m_Height*0.44, self.m_Width*0.23, self.m_Height*0.05, "", self.m_TabDiplomacy)
		}
		for index, label in pairs(self.m_DiplomacyPermissionChangeLabels) do
			label:setColor(Color.Accent)
			label.onHover = function () label:setColor(Color.White) end
			label.onUnhover = function () label:setColor(Color.Accent) end
			label.onLeftClick = function()
				if self.m_DiplomacySelected == localPlayer:getFaction():getId() then
					triggerServerEvent("factionChangePermission", root, index)
				end
			end
		end

		local item
		for Id, faction in pairs(FactionManager.Map) do
			if faction:isEvilFaction() then
				item = self.m_DiplomacyGrid:addItem(faction:getShortName())
				item.Id = faction:getId()
				item.onLeftClick = function() triggerServerEvent("factionRequestDiplomacy", root, faction:getId()) end
				if faction == localPlayer:getFaction() then
					self.m_DiplomacyGrid:onInternalSelectItem(item)
				end
			end
		end

		self.m_DiplomacyLoaded = true
	end

	triggerServerEvent("factionRequestDiplomacy", root, localPlayer:getFaction():getId())
end

function FactionGUI:Event_retrieveDiplomacy(sourceId, diplomacy, permissions, requests)
	self.m_DiplomacySelected = sourceId

	local factionId, status, currentDiplomacy, text, color, new, qText

	if self.m_DiplomacyLabels then
		for index, label in pairs(self.m_DiplomacyLabels) do
			delete(label)
		end
	end

	self.m_DiplomacyLabels = {}
	self.m_DiplomacyLabels["Current"] = GUILabel:new(self.m_Width*0.34, self.m_Height*0.05, self.m_Width*0.5, self.m_Height*0.08, _("Diplomatie der %s", FactionManager:getSingleton():getFromId(sourceId):getShortName()), self.m_TabDiplomacy)

	if self.m_DiplomacySelected == localPlayer:getFaction():getId() then
		for index, label in pairs(self.m_DiplomacyPermissionChangeLabels) do
			label:setText(_"(ändern)")
		end
	else
		for index, label in pairs(self.m_DiplomacyPermissionChangeLabels) do
			label:setText("")
		end
	end

	local y = self.m_Height*0.13

	for index, data in pairs(diplomacy) do
		factionId, status = unpack(data)
		if factionId ~= sourceId then
			text = _("%s - %s", FactionManager:getSingleton():getFromId(factionId):getShortName(), FACTION_DIPLOMACY[status])
			self.m_DiplomacyLabels[factionId] = GUILabel:new(self.m_Width*0.34, y, self.m_Width*0.5, self.m_Height*0.06, text, self.m_TabDiplomacy)
			self.m_DiplomacyLabels[factionId]:setColor(FactionGUI.DiplomacyColors[status])
			y = y + self.m_Height*0.06


			self.m_DiplomacyPermissionLabels["vehicles"]:setText(_("BND darf %sFahrzeuge verwenden", table.find(permissions, "vehicles") and "" or "keine "))
			self.m_DiplomacyPermissionLabels["weapons"]:setText(_("BND darf %sWaffen nehmen", table.find(permissions, "weapons") and "" or "keine "))

			if factionId == localPlayer:getFaction():getId() then
				currentDiplomacy = status
			end
		end
	end

	if self.m_DiplomacyButtons then
		for index, button in pairs(self.m_DiplomacyButtons) do
			delete(button)
		end
	end
	self.m_DiplomacyButtons = {}
	local btnData = {
		[FACTION_DIPLOMACY["Verbündet"]] = {
			[1] = {_"Bündnis kündigen", Color.Yellow, FACTION_DIPLOMACY["Waffenstillstand"], "Möchtest du das Bündnis mit der Fraktion %s kündigen?"},
			[2] = {_"Krieg erklären", Color.Red, FACTION_DIPLOMACY["im Krieg"], "Möchtest du der Fraktion %s den Krieg erklären?"},
		},
		[FACTION_DIPLOMACY["Waffenstillstand"]] = {
			[1] = {_"Bündnis anbieten", Color.Green, FACTION_DIPLOMACY["Verbündet"], "Möchtest du der Fraktion %s ein Bündnis anbieten?"},
			[2] = {_"Krieg erklären", Color.Red, FACTION_DIPLOMACY["im Krieg"], "Möchtest du der Fraktion %s den Krieg erklären?"},
		},
		[FACTION_DIPLOMACY["im Krieg"]] = {
			[1] = {_"Bündnis anbieten", Color.Green, FACTION_DIPLOMACY["Verbündet"], "Möchtest du der Fraktion %s ein Bündnis anbieten?"},
			[2] = {_"Waffenstillstand anbieten", Color.Yellow, FACTION_DIPLOMACY["Waffenstillstand"], "Möchtest du der Fraktion %s einen Waffenstillstand anbieten?"},
		}
	}
	if localPlayer:getFaction():isEvilFaction() and currentDiplomacy then
		qText = {}
		new = {}
		text, color, new[1], qText[1] = unpack(btnData[currentDiplomacy][1])
		self.m_DiplomacyButtons[1] = GUIButton:new(self.m_Width*0.66, self.m_Height*0.13, self.m_Width*0.32, self.m_Height*0.07, text, self.m_TabDiplomacy):setBackgroundColor(color)
		self.m_DiplomacyButtons[1].onLeftClick = function()
			QuestionBox:new(_(qText[1], FactionManager:getSingleton():getFromId(sourceId):getShortName()),
				function() 	triggerServerEvent("factionChangeDiplomacy", localPlayer, sourceId, new[1]) end
			)
		end
		text, color, new[2], qText[2] = unpack(btnData[currentDiplomacy][2])
		self.m_DiplomacyButtons[2] = GUIButton:new(self.m_Width*0.66, self.m_Height*0.21, self.m_Width*0.32, self.m_Height*0.07, text, self.m_TabDiplomacy):setBackgroundColor(color)
		self.m_DiplomacyButtons[2].onLeftClick = function()
			QuestionBox:new(_(qText[2], FactionManager:getSingleton():getFromId(sourceId):getShortName()),
				function() 	triggerServerEvent("factionChangeDiplomacy", localPlayer, sourceId, new[2]) end
			)
		end

		self:onDiplomacyRequestItemSelect()
	end


	self.m_DiplomacyRequestGrid:clear()
	if requests then
		self.m_DiplomacyRequestGrid:addItemNoClick("Eingehend", "")
		for index, data in pairs(requests) do
			if data["target"] == localPlayer:getFaction():getId() then
				item = self.m_DiplomacyRequestGrid:addItem(FactionManager.Map[data["source"]]:getShortName(), FACTION_DIPLOMACY_REQUEST[data["status"]])
				item.onLeftClick = function()
					self:onDiplomacyRequestItemSelect(index, data)
				end
			end
		end
		self.m_DiplomacyRequestGrid:addItemNoClick("Ausgehend", "")

		for index, data in pairs(requests) do
			if data["source"] == localPlayer:getFaction():getId() then
				item = self.m_DiplomacyRequestGrid:addItem(FactionManager.Map[data["target"]]:getShortName(), FACTION_DIPLOMACY_REQUEST[data["status"]])
				item.onLeftClick = function()
					self:onDiplomacyRequestItemSelect(index, data)
				end
			end
		end
	end
end

function FactionGUI:onDiplomacyRequestItemSelect(id, data)
	if not id then
		self.m_DiplomacyRequestText:setText("")
		if self.m_DiplomacyRequestButtons then
			for index, button in pairs(self.m_DiplomacyRequestButtons) do
				delete(button)
			end
		end
		return
	end
	self.m_DiplomacyRequestText:setText(_("%s der %s an die %s\nvom %s Uhr", FACTION_DIPLOMACY_REQUEST[data["status"]], FactionManager.Map[data["source"]]:getShortName(), FactionManager.Map[data["target"]]:getShortName(), getOpticalTimestamp(data["timestamp"])))
	if self.m_DiplomacyRequestButtons then
		for index, button in pairs(self.m_DiplomacyRequestButtons) do
			delete(button)
		end
	end
	self.m_DiplomacyRequestButtons = {}
	if data["source"] == localPlayer:getFaction():getId() then
		self.m_DiplomacyRequestButtons["Remove"] = GUIButton:new(self.m_Width*0.54, self.m_Height*0.81, self.m_Width*0.32, self.m_Height*0.07, "Zurückziehen", self.m_TabDiplomacy):setBackgroundColor(Color.Red)
		self.m_DiplomacyRequestButtons["Remove"].onLeftClick = function()
			triggerServerEvent("factionDiplomacyAnswer", localPlayer, id, "remove")
		end
	else
		self.m_DiplomacyRequestButtons["Accept"] = GUIButton:new(self.m_Width*0.54, self.m_Height*0.81, self.m_Width*0.21, self.m_Height*0.07, "Annehmen", self.m_TabDiplomacy):setBackgroundColor(Color.Green)
		self.m_DiplomacyRequestButtons["Accept"].onLeftClick = function()
			triggerServerEvent("factionDiplomacyAnswer", localPlayer, id, "accept")
		end
		self.m_DiplomacyRequestButtons["Decline"] = GUIButton:new(self.m_Width*0.77, self.m_Height*0.81, self.m_Width*0.21, self.m_Height*0.07, "Ablehnen", self.m_TabDiplomacy):setBackgroundColor(Color.Red)
		self.m_DiplomacyRequestButtons["Decline"].onLeftClick = function()
			triggerServerEvent("factionDiplomacyAnswer", localPlayer, id, "decline")
		end
	end
end

function FactionGUI:onGangwarItemSelect(item)
	if self.m_GangwarChart then delete(self.m_GangwarChart) end
	if self.m_AreaName then delete(self.m_AreaName) end
	if self.m_AreaOwner then delete(self.m_AreaOwner) end
	if self.m_LastAttack then delete(self.m_LastAttack) end
	if self.m_NextAttack then delete(self.m_NextAttack) end
	if self.m_Map then delete(self.m_Map) end
	if self.m_GangAttackLogGrid then delete(self.m_GangAttackLogGrid) end
	if self.m_GangAttackTab then delete(self.m_GangAttackTab) end
	if item == self.m_GangAreasOverviewItem then
		self.m_GangwarChart = GUIWebView:new(self.m_Width*0.35, self.m_Height*0.05, self.m_Width*0.64, self.m_Height*0.9, INGAME_WEB_PATH .. "/ingame/other/gangwar.php", true, self.m_tabGangwar)
	elseif item == self.m_GangAttackLogItem then
		self.m_GangAttackLogGrid = GUIGridList:new(self.m_Width*0.35, self.m_Height*0.05, self.m_Width*0.62, self.m_Height*0.85, self.m_tabGangwar)
		self.m_GangAttackLogGrid:addColumn(_"Gebiet", 0.3)
		self.m_GangAttackLogGrid:addColumn(_"Start", 0.3)
		self.m_GangAttackLogGrid:addColumn(_"Besitzer", 0.2)
		self.m_GangAttackLogGrid:addColumn(_"Angreif.", 0.2)
		if self.m_GangwarAttackLog then
			for i = 1, #self.m_GangwarAttackLog do
				self.m_GangAttackLogGrid:addItem(self.m_GangwarAttackLog[i][1]:sub(1, 15), getOpticalTimestamp(self.m_GangwarAttackLog[i][4]), self.m_GangwarAttackLog[i][3]:sub(1,5)..".", self.m_GangwarAttackLog[i][2]:sub(1,5)..".")
			end
		end
	elseif item == self.m_GangAttackBestLog then
		self.m_GangAttackTab = GUITabPanel:new(self.m_Width*0.35, self.m_Height*0.05, self.m_Width*0.62, self.m_Height*0.85, self.m_tabGangwar)
		local tabWidth, tabHeight = self.m_GangAttackTab:getSize()
		self.m_GangAttackDamageTab = self.m_GangAttackTab:addTab(_("Schaden"))
			self.m_GangAttackDamageGrid = GUIGridList:new(tabWidth*0.025, tabHeight*0.05, tabWidth*0.93, tabHeight*0.85, self.m_GangAttackDamageTab)
			self.m_GangAttackDamageGrid:addColumn(_"", 0.1)
			self.m_GangAttackDamageGrid:addColumn(_"Name", 0.6)
			self.m_GangAttackDamageGrid:addColumn(_"Damage", 0.3)
			if self.m_GangwarTopDamageTable then
				if self.m_GangwarLocalTopTable then
					if self.m_GangwarLocalTopTable[5] and self.m_GangwarLocalTopTable[2] then
						self.m_GangAttackDamageGrid:addItem( "#"..self.m_GangwarLocalTopTable[5], "- Du -", self.m_GangwarLocalTopTable[2] ):setColor(Color.Accent)
					end
				end
				for i = 1, #self.m_GangwarTopDamageTable do
					self.m_GangAttackDamageGrid:addItem( "#"..i,self.m_GangwarTopDamageTable[i][1], self.m_GangwarTopDamageTable[i][2] )
				end
			end
		self.m_GangAttackKillTab = self.m_GangAttackTab:addTab(_("Tötungen"))
			self.m_GangAttackKillGrid = GUIGridList:new(tabWidth*0.025, tabHeight*0.05, tabWidth*0.93, tabHeight*0.85, self.m_GangAttackKillTab)
			self.m_GangAttackKillGrid:addColumn(_"", 0.1)
			self.m_GangAttackKillGrid:addColumn(_"Name", 0.6)
			self.m_GangAttackKillGrid:addColumn(_"Kills", 0.3)
			if self.m_GangwarTopKillTable then
				if self.m_GangwarLocalTopTable then
					if self.m_GangwarLocalTopTable[6] and self.m_GangwarLocalTopTable[3] then
						self.m_GangAttackKillGrid:addItem( "#"..self.m_GangwarLocalTopTable[6], "- Du -", self.m_GangwarLocalTopTable[3] ):setColor(Color.Accent)
					end
				end
				for i = 1, #self.m_GangwarTopKillTable do
					self.m_GangAttackKillGrid:addItem( "#"..i, self.m_GangwarTopKillTable[i][1], self.m_GangwarTopKillTable[i][2] )
				end
			end
		self.m_GangAttackMVPTab = self.m_GangAttackTab:addTab(_("MVP"))
			self.m_GangAttackMVPGrid = GUIGridList:new(tabWidth*0.025, tabHeight*0.05, tabWidth*0.93, tabHeight*0.85, self.m_GangAttackMVPTab)
			self.m_GangAttackMVPGrid:addColumn(_"", 0.1)
			self.m_GangAttackMVPGrid:addColumn(_"Name", 0.6)
			self.m_GangAttackMVPGrid:addColumn(_"Sterne", 0.3)
			if self.m_GangwarTopMVPTable then
				if self.m_GangwarLocalTopTable then
					if self.m_GangwarLocalTopTable[7] and self.m_GangwarLocalTopTable[4] then
						self.m_GangAttackMVPGrid:addItem( "#"..self.m_GangwarLocalTopTable[7], "- Du -", self.m_GangwarLocalTopTable[4] ):setColor(Color.Accent)
					end
				end
				for i = 1, #self.m_GangwarTopKillTable do
					self.m_GangAttackMVPGrid:addItem( "#"..i, self.m_GangwarTopMVPTable[i][1], self.m_GangwarTopMVPTable[i][2] )
				end
			end
	else
		if item then
			self.m_AreaName = GUILabel:new(self.m_Width*0.35, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.08, item.name, self.m_tabGangwar)
			local ownerFaction = FactionManager:getSingleton():getFromId(item.owner)
			self.m_AreaOwner = GUILabel:new(self.m_Width*0.35, self.m_Height*0.14, self.m_Width*0.7, self.m_Height*0.06, _("Besitzer: %s", ownerFaction and ownerFaction:getName() or "-"), self.m_tabGangwar)
			self.m_LastAttack = GUILabel:new(self.m_Width*0.35, self.m_Height*0.21, self.m_Width*0.4, self.m_Height*0.06,_("Letzter Angriff: %s", getOpticalTimestamp(item.lastAttack)), self.m_tabGangwar)
			self.m_NextAttack = GUILabel:new(self.m_Width*0.35, self.m_Height*0.28, self.m_Width*0.4, self.m_Height*0.06,_("Nächster Angriff: %s", getOpticalTimestamp(item.lastAttack+(GANGWAR_ATTACK_PAUSE*UNIX_TIMESTAMP_24HRS))), self.m_tabGangwar)
			self.m_Map = GUIMiniMap:new(self.m_Width*0.35, self.m_Height*0.35, self.m_Width*0.62, self.m_Height*0.55, self.m_tabGangwar)
			self.m_Map:setMapPosition(item.posX, item.posY)
			self.m_Map:addBlip("Marker.png", item.posX, item.posY)
		end
	end
end

function FactionGUI:Event_gangwarLoadArea(name, position, owner, lastAttack, isAttackable)
	self.m_GangwarAreas[name] = {["name"] = name, ["posX"] = position[1], ["posY"] = position[2], ["posZ"] = posZ, ["owner"] = owner, ["lastAttack"] = lastAttack}

	local item = self.m_GangAreasGrid:addItem(name)
	if isAttackable then
		item:setColor(Color.Green)
	else
		item:setColor(Color.Red)
	end
	item.onLeftClick = function() self:onGangwarItemSelect(self.m_GangwarAreas[name]) end
end

function FactionGUI:Event_gangwarLoadAttackLog( aTable )
	self.m_GangwarAttackLog = aTable
end

function FactionGUI:Event_gangwarLoadTopList( damage, kills, mvp, localToplist)
	self.m_GangwarTopDamageTable = damage
	self.m_GangwarTopKillTable = kills
	self.m_GangwarTopMVPTable = mvp
	self.m_GangwarLocalTopTable = localToplist
	ShortMessage:new(_("Achtung! Deine eigenen Statistiken werden nur alle 30 Minuten aktualisiert (sofern nicht in den Top-Ten)!"), _"Bestenliste" , {180, 130, 0})
end

function FactionGUI:Event_factionRetrieveInfo(id, name, rank, money, players, actionStatus, rankNames, rankLoans, validWeapons, rankWeapons)
	--self:adjustFactionTab(rank or false)
	if id then
		if id > 0 then
			self.m_Id = id
			local x, y = self.m_FactionNameLabel:getPosition()
			self.m_RankNames = rankNames
			self.m_FactionNameLabel:setText(name)
			self.m_FactionRankLabel:setText(tostring(rank).." - "..rankNames[rank])
			self.m_FactionMoneyLabel:setText(tostring(money).."$")


			if actionStatus["current"] == false then
				if getRealTime().timestamp > actionStatus["next"] then
					self.m_FactionNextActionLabel:setText(_"bereits möglich")
					self.m_FactionNextActionLabel:setColor(Color.Green)
				else
					self.m_FactionNextActionLabel:setText(_("möglich um %s Uhr", getRealTime(actionStatus["next"]).hour..":"..getRealTime(actionStatus["next"]).minute))
					self.m_FactionNextActionLabel:setColor(Color.Red)
				end
			else
				self.m_FactionNextActionLabel:setText(_("%s läuft", actionStatus["current"]))
				self.m_FactionNextActionLabel:setColor(Color.Red)
			end

			self.m_FactionPlayersGrid:clear()
			for playerId, info in pairs(players) do
				local activitySymbol = info.loanEnabled == 1 and FontAwesomeSymbols.Calender_Check or FontAwesomeSymbols.Calender_Time
				local weaponSymbol = FontAwesomeSymbols.Gun
				local item = self.m_FactionPlayersGrid:addItem(activitySymbol, weaponSymbol, info.name, info.rank, tostring(info.activity).." h")
				local color = (getPlayerFromName(info.name) and getPlayerFromName(info.name):getPublicSync("Faction:Duty") and Color.Orange) or (getPlayerFromName(info.name) and Color.Accent) or Color.White
				item:setColumnFont(1, FontAwesome(20), 1):setColumnColor(1, info.loanEnabled == 1 and Color.Green or Color.Red)
				item:setColumnFont(2, FontAwesome(20), 1):setColumnColor(2, info.weaponEnabled == 1 and Color.Green or Color.Red)
				item:setColumnColor(3, color)
				item.Id = playerId
				item.Rank = info.rank

				item.onLeftClick =
					function()
						self.m_FactionToggleLoanButton:setText(("Gehalt %saktivieren"):format(info.loanEnabled == 1 and "de" or ""))
						self.m_FactionToggleWeaponButton:setText(("Waffen %saktivieren"):format(info.weaponEnabled == 1 and "de" or ""))
					end
			end

			if rank >= FactionRank.Manager or PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editLoan") or PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editWeaponPermissions") or PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editActionPermissions") then
				self.m_RankLoans = rankLoans
				self.m_ValidWeapons = validWeapons
				self.m_RankWeapons = rankWeapons
				self:addLeaderTab()
			end
			if localPlayer:getFaction():getId() == 3 then
				self.m_AreaAlarmButton:setVisible(true)
				self.m_AreaAlarmButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "toggleAreaAlarm"))
			else
				self.m_AreaAlarmButton:setVisible(false)
			end
			self.m_FactionAddPlayerButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "invite"))
			self.m_FactionRemovePlayerButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "uninvite"))
			self.m_FactionRankUpButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "changeRank"))
			self.m_FactionRankDownButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "changeRank"))
			self.m_FactionToggleLoanButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "toggleLoan"))
			self.m_FactionToggleWeaponButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "toggleWeapon"))
			self.m_FactionPlayerPermissionsButton:setEnabled(PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editWeaponPermissions") or PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editActionPermissions") or PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "changePermissions"))
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

function FactionGUI:FactionAddPlayerButton_Click()
	InviteGUI:new(
		function(player)
			triggerServerEvent("factionAddPlayer", root, player)
		end,"faction"
	)
end

function FactionGUI:FactionForumSyncButton_Click()
	-- triggerServerEvent("factionForumSync", root)
	self:close()
	ForumPermissionsGUI:new("faction", localPlayer:getFaction().m_Id)
end

function FactionGUI:FactionRemovePlayerButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		self:close()

		HistoryUninviteGUI:new(function(internal, external)
			triggerServerEvent("factionDeleteMember", root, selectedItem.Id, internal, external)
		end)
	else
		ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online")
	end
end

function FactionGUI:FactionRankUpButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		if selectedItem.Rank + 1 == FactionRank.Leader and localPlayer:getPublicSync("FactionRank") == FactionRank.Leader  then
			QuestionBox:new("Bist du sicher, dass du den Spieler befördern und deinen Leaderposten abgeben möchtest?", 
				function()
					triggerServerEvent("factionRankUp", root, selectedItem.Id, true)
				end,
				function()
					return
				end, false, false
			)
		else
			triggerServerEvent("factionRankUp", root, selectedItem.Id, false)
		end
	end
end

function FactionGUI:FactionRankDownButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("factionRankDown", root, selectedItem.Id)
	end
end

function FactionGUI:FactionToggleLoanButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("factionToggleLoan", root, selectedItem.Id)
	end
end

function FactionGUI:FactionToggleWeaponButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("factionToggleWeapon", root, selectedItem.Id)
	end
end

function FactionGUI:FactionPlayerFileButton_Click()
	self:close()
	HistoryPlayerGUI:new(FactionGUI)
end

function FactionGUI:FactionRespawnVehicles(instant)
	triggerServerEvent("factionRespawnVehicles", root, instant)
end

function FactionGUI:ShowObjectList()
	self:close()
	triggerServerEvent("requestWorldItemListOfOwner", localPlayer, localPlayer:getFaction():getId(), "faction")
end

function FactionGUI:ShowLogs()
	self:close()
	local url = (INGAME_WEB_PATH .. "/ingame/logs/groupLogs.php?groupType=%s&groupId=%d"):format("faction", self.m_Id)
	self.m_LogGUI = LogGUI:new(nil, url)
	self.m_LogGUI:addBackButton(function() FactionGUI:getSingleton():show() end)
end

function FactionGUI:openPermissionsGUI(type)
	RankPermissionsGUI:new(type, "faction")
end

function FactionGUI:factionPlayerPermissionsButton_Click()
	local selectedItem = self.m_FactionPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then

		self.m_PermissionsManagmentGUI = GUIButtonMenu:new(_("Rechteverwaltung"))
		if PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "changePermissions") then
		self.m_PermissionsManagmentGUI:addItem(_"Rechte bearbeiten", Color.Accent,
			function()
				PlayerPermissionsGUI:new("permission", selectedItem.Rank, "faction", selectedItem.Id)
			end)
		end
		if PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editActionPermissions") then
			self.m_PermissionsManagmentGUI:addItem(_"Aktionsrechte bearbeiten", Color.Accent,
			function()
				PlayerPermissionsGUI:new("action", selectedItem.Rank, "faction", selectedItem.Id)
			end)
		end
		if PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "editWeaponPermissions") then
			self.m_PermissionsManagmentGUI:addItem(_"Waffenrechte bearbeiten", Color.Accent,
			function()
				PlayerPermissionsGUI:new("weapon", selectedItem.Rank, "faction", selectedItem.Id)
			end)
		end
	end
end