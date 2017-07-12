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
	[3] = Color.Orange,
	[4] = Color.Red,
}
function FactionGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:close() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
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

--	self.m_FactionQuitButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Fraktion verlassen", true, tabAllgemein):setBarColor(Color.Red)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.1, _"Kasse:", tabAllgemein)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, _"Inhalt:", tabAllgemein)
	self.m_FactionMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, "", tabAllgemein)
	--self.m_FactionMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.39, self.m_Width*0.27, self.m_Height*0.07, tabAllgemein):setCaption(_"Betrag")

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.25, self.m_Height*0.1, _"Funktionen:", tabAllgemein)
	self.m_FactionRespawnVehicleButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.3, self.m_Height*0.07, _"Fahrzeuge respawnen", true, tabAllgemein)
	self.m_FactionRespawnVehicleButton.onLeftClick = bind(self.FactionRespawnVehicles, self)
	self.m_LogButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.3, self.m_Height*0.07, _"Fraktions-Logs", true, tabAllgemein)
	self.m_LogButton.onLeftClick = bind(self.ShowLogs, self)
	self.m_ObjectListButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.8, self.m_Width*0.3, self.m_Height*0.07, _"platzierte Objekte", true, tabAllgemein)
	self.m_ObjectListButton.onLeftClick = bind(self.ShowObjectList, self)

	local tabMitglieder = self.m_TabPanel:addTab(_"Mitglieder")
	self.m_FactionPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.5, self.m_Height*0.8, tabMitglieder)
	self.m_FactionPlayersGrid:addColumn(_"Spieler", 0.55)
	self.m_FactionPlayersGrid:addColumn(_"Rang", 0.18)
	self.m_FactionPlayersGrid:addColumn(_"Aktivität", 0.27)
	self.m_FactionAddPlayerButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", true, tabMitglieder):setBarColor(Color.Green)
	self.m_FactionRemovePlayerButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.15, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", true, tabMitglieder):setBarColor(Color.Red)
	self.m_FactionRankUpButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.25, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", true, tabMitglieder)
	self.m_FactionRankDownButton = VRPButton:new(self.m_Width*0.6, self.m_Height*0.35, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", true, tabMitglieder)

	self.m_tabGangwar = self.m_TabPanel:addTab(_"Gangwar")

	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
--	self.m_FactionQuitButton.onLeftClick = bind(self.FactionQuitButton_Click, self)
	self.m_FactionAddPlayerButton.onLeftClick = bind(self.FactionAddPlayerButton_Click, self)
	self.m_FactionRemovePlayerButton.onLeftClick = bind(self.FactionRemovePlayerButton_Click, self)
	self.m_FactionRankUpButton.onLeftClick = bind(self.FactionRankUpButton_Click, self)
	self.m_FactionRankDownButton.onLeftClick = bind(self.FactionRankDownButton_Click, self)


	self.m_WeaponsName = {}
	self.m_WeaponsImage = {}
	self.m_WeaponsCheck = {}

	self.m_TabDiplomacy = self.m_TabPanel:addTab(_"Diplomatie")

	addRemoteEvents{"factionRetrieveInfo", "factionRetrieveLog", "gangwarLoadArea", "factionRetrieveDiplomacy"}
	addEventHandler("factionRetrieveInfo", root, bind(self.Event_factionRetrieveInfo, self))
	addEventHandler("factionRetrieveLog", root, bind(self.Event_factionRetrieveLog, self))
	addEventHandler("factionRetrieveDiplomacy", root, bind(self.Event_retrieveDiplomacy, self))


	addEventHandler("gangwarLoadArea", root, bind(self.Event_gangwarLoadArea, self))


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

function FactionGUI:Event_factionRetrieveLog(players, logs)
	if not self.m_LogGUI then
		self.m_LogGUI = LogGUI:new(nil, logs, players)
		self.m_LogGUI:addBackButton(function() FactionGUI:getSingleton():show() self.m_LogGUI = nil end)
	else
		self.m_LogGUI:updateLog(players, logs)
	end
end

function FactionGUI:addLeaderTab()
	if self.m_Leader == false then
		self.m_TabLeader = self.m_TabPanel:addTab(_"Leader")
		self.m_FactionRangGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.8, self.m_TabLeader)
		self.m_FactionRangGrid:addColumn(_"Rang", 0.2)
		self.m_FactionRangGrid:addColumn(_"Name", 0.8)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.06, _"Ausgewählter Rang:", self.m_TabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderRankName = GUILabel:new(self.m_Width*0.45, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, "", self.m_TabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Gehalt: (in $)", self.m_TabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderLoan = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.28, self.m_Width*0.2, self.m_Height*0.06, self.m_TabLeader)
		self.m_LeaderLoan:setNumeric(true, true)
		self.m_SkinLabel = GUILabel:new(self.m_Width*0.69, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Skin:", self.m_TabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)

		self.m_SkinPreviewBrowser = GUIWebView:new(self.m_Width*0.82, self.m_Height*0.01, self.m_Width*0.2, self.m_Height*0.4, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php", true, self.m_TabLeader)

		self.m_SkinChanger = GUIChanger:new(self.m_Width*0.69, self.m_Height*0.28, self.m_Width*0.16, self.m_Height*0.06, self.m_TabLeader)
		self.m_SkinChanger.onChange = function(text, index) self.m_SkinPreviewBrowser:loadURL("http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..text) end

		if self.m_Id == 4 then -- If Rescue
			self.m_SkinLabel:setVisible(false)
			self.m_SkinChanger:setVisible(false)
			self.m_SkinPreviewBrowser:setVisible(false)
		end

		self.m_SaveRank = VRPButton:new(self.m_Width*0.69, self.m_Height*0.8, self.m_Width*0.3, self.m_Height*0.07, _"Rang speichern", true, self.m_TabLeader)
		self.m_SaveRank.onLeftClick = bind(self.saveRank, self)
		self.m_SaveRank:setEnabled(false)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.35, self.m_Width*0.4, self.m_Height*0.06, _"Waffen:", self.m_TabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)

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

	for weaponID,v in pairs(self.m_ValidWeapons) do
		if v == true then
			self.m_WeaponsName[weaponID] = GUILabel:new(self.m_Width*0.43+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0.4+self.m_WaffenColumn*self.m_Height*0.16, self.m_Width*0.16, self.m_Height*0.04, WEAPON_NAMES[weaponID], self.m_TabLeader)
			self.m_WeaponsName[weaponID]:setAlignX("center")
			self.m_WeaponsImage[weaponID] = GUIImage:new(self.m_Width*0.46+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0.43+self.m_WaffenColumn*self.m_Height*0.16, self.m_Width*0.06, self.m_Width*0.06, WeaponIcons[weaponID], self.m_TabLeader)
			self.m_WeaponsCheck[weaponID] = GUICheckbox:new(self.m_Width*0.45+self.m_WaffenRow*self.m_Width*0.14, self.m_Height*0.53+self.m_WaffenColumn*self.m_Height*0.16, self.m_Width*0.12, self.m_Height*0.02, "aktiviert", self.m_TabLeader)
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

		triggerServerEvent("factionSaveRank",localPlayer,self.m_SelectedRank,self.m_SkinChanger:getIndex(),self.m_LeaderLoan:getText(),rankWeapons)
	end
end

function FactionGUI:onSelectRank(name,rank)
	self.m_LeaderRankName:setText(name.." - "..rank)
	self.m_LeaderLoan:setText(tostring(self.m_RankLoans[tostring(rank)]))
	self.m_SaveRank:setEnabled(true)

	for skinId,bool in pairs(self.m_skins) do
		if bool == true then
			self.m_SkinChanger:addItem(skinId)
		end
	end

	for weaponID,v in pairs(self.m_ValidWeapons) do
		if v == true then
			if self.m_RankWeapons[tostring(rank)][tostring(weaponID)] == 1 then
				self.m_WeaponsCheck[weaponID]:setChecked(true)
			else
				self.m_WeaponsCheck[weaponID]:setChecked(false)
			end
		end
	end

	self.m_SkinChanger:setSelectedItem(self.m_RankSkins[tostring(rank)])

end

function FactionGUI:loadGangwarTab()
	if self.m_GangAreasGrid then delete(self.m_GangAreasGrid) end
	self.m_GangAreasGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.85, self.m_tabGangwar)
	self.m_GangAreasGrid:addColumn(_"Gebiet", 0.7)
	self.m_GangAreasOverviewItem = self.m_GangAreasGrid:addItem(_"Übersicht")
	self.m_GangAreasOverviewItem.onLeftClick = function() self:onGangwarItemSelect(self.m_GangAreasOverviewItem) end
	self.m_GangAreasGrid:addItemNoClick(_"Gebiete")
	self.m_GangwarAreas = {}
	triggerServerEvent("gangwarGetAreas", localPlayer)
	self.m_GangAreasGrid:onInternalSelectItem(self.m_GangAreasOverviewItem)
	self:onGangwarItemSelect(self.m_GangAreasOverviewItem)
end

function FactionGUI:loadDiplomacyTab()
	if not self.m_DiplomacyLoaded then

		self.m_DiplomacyGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.35, self.m_Height*0.85, self.m_TabDiplomacy)
		self.m_DiplomacyGrid:addColumn(_"Fraktion", 1)

		local item
		for Id, faction in pairs(FactionManager.Map) do
			if faction:isEvilFaction() then
				item = self.m_DiplomacyGrid:addItem(faction:getShortName())
				item.Id = faction:getId()
				item.onLeftClick = function() triggerServerEvent("factionRequestDiplomacy", root, faction:getId()) end
			end
		end
		self.m_DiplomacyLoaded = true
	end
end

function FactionGUI:Event_retrieveDiplomacy(sourceId, diplomacy)
	self.m_DiplomacySelected = sourceId

	local factionId, status, currentDiplomacy

	if self.m_DiplomacyLabels then
		for index, label in pairs(self.m_DiplomacyLabels) do
			delete(label)
		end
	end

	self.m_DiplomacyLabels = {}
	self.m_DiplomacyLabels["Current"] = GUILabel:new(self.m_Width*0.39, self.m_Height*0.05, self.m_Width*0.5, self.m_Height*0.08, _("Diplomatie der %s", FactionManager:getSingleton():getFromId(sourceId):getShortName()), self.m_TabDiplomacy)

	local y = self.m_Height*0.13
	local text

	for index, data in pairs(diplomacy) do
		factionId, status = unpack(data)
		if factionId ~= sourceId then
			text = _("%s - %s", FactionManager:getSingleton():getFromId(factionId):getShortName(), FACTION_DIPLOMACY[status])
			self.m_DiplomacyLabels[factionId] = GUILabel:new(self.m_Width*0.39, y, self.m_Width*0.5, self.m_Height*0.06, text, self.m_TabDiplomacy)
			self.m_DiplomacyLabels[factionId]:setColor(FactionGUI.DiplomacyColors[status])
			y = y + self.m_Height*0.06
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

	if localPlayer:getFaction():isEvilFaction() and currentDiplomacy then
		if currentDiplomacy == FACTION_DIPLOMACY["Verbündet"] then
			self.m_DiplomacyButtons[1] = VRPButton:new(self.m_Width*0.38, self.m_Height*0.83, self.m_Width*0.28, self.m_Height*0.07, _"Bündnis kündigen", true, self.m_TabDiplomacy):setBarColor(Color.Yellow)
			self.m_DiplomacyButtons[2] = VRPButton:new(self.m_Width*0.70, self.m_Height*0.83, self.m_Width*0.28, self.m_Height*0.07, _"Krieg erklären", true, self.m_TabDiplomacy):setBarColor(Color.Red)
		elseif currentDiplomacy == FACTION_DIPLOMACY["Waffenstillstand"] then
			self.m_DiplomacyButtons[1] = VRPButton:new(self.m_Width*0.39, self.m_Height*0.83, self.m_Width*0.28, self.m_Height*0.07, _"Bündnis anbieten", true, self.m_TabDiplomacy):setBarColor(Color.Green)
			self.m_DiplomacyButtons[2] = VRPButton:new(self.m_Width*0.70, self.m_Height*0.83, self.m_Width*0.28, self.m_Height*0.07, _"Krieg erklären", true, self.m_TabDiplomacy):setBarColor(Color.Red)
		else
			self.m_DiplomacyButtons[1] = VRPButton:new(self.m_Width*0.39, self.m_Height*0.83, self.m_Width*0.28, self.m_Height*0.07, _"Bündnis anbieten", true, self.m_TabDiplomacy):setBarColor(Color.Green)
			self.m_DiplomacyButtons[2] = VRPButton:new(self.m_Width*0.70, self.m_Height*0.83, self.m_Width*0.28, self.m_Height*0.07, _"Waffenstillstand anbieten", true, self.m_TabDiplomacy):setBarColor(Color.Yellow)
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

	if item == self.m_GangAreasOverviewItem then
		self.m_GangwarChart = GUIWebView:new(self.m_Width*0.35, self.m_Height*0.05, self.m_Width*0.64, self.m_Height*0.9, "http://exo-reallife.de/ingame/other/gangwar.php", true, self.m_tabGangwar)
	else
		if item then
			self.m_AreaName = GUILabel:new(self.m_Width*0.35, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.08, item.name, self.m_tabGangwar)
			local ownerFaction = FactionManager:getSingleton():getFromId(item.owner)
			self.m_AreaOwner = GUILabel:new(self.m_Width*0.35, self.m_Height*0.14, self.m_Width*0.7, self.m_Height*0.06, _("Besitzer: %s", ownerFaction and ownerFaction:getName() or "-"), self.m_tabGangwar)
			self.m_LastAttack = GUILabel:new(self.m_Width*0.35, self.m_Height*0.21, self.m_Width*0.4, self.m_Height*0.06,_("Letzter Angriff: %s", getOpticalTimestamp(item.lastAttack)), self.m_tabGangwar)
			self.m_NextAttack = GUILabel:new(self.m_Width*0.35, self.m_Height*0.28, self.m_Width*0.4, self.m_Height*0.06,_("Nächster Angriff: %s", getOpticalTimestamp(item.lastAttack+(GANGWAR_ATTACK_PAUSE*UNIX_TIMESTAMP_24HRS))), self.m_tabGangwar)
			self.m_Map = GUIMiniMap:new(self.m_Width*0.35, self.m_Height*0.35, self.m_Width*0.62, self.m_Height*0.55, self.m_tabGangwar)
			self.m_Map:setPosition(item.posX, item.posY)
			self.m_Map:addBlip("Waypoint.png", item.posX, item.posY)
		end
	end
end

function FactionGUI:Event_gangwarLoadArea(name, position, owner, lastAttack)
	self.m_GangwarAreas[name] = {["name"] = name, ["posX"] = position[1], ["posY"] = position[2], ["posZ"] = posZ, ["owner"] = owner, ["lastAttack"] = lastAttack}

	local item = self.m_GangAreasGrid:addItem(name)
	item.onLeftClick = function() self:onGangwarItemSelect(self.m_GangwarAreas[name]) end
end

function FactionGUI:Event_factionRetrieveInfo(id, name, rank, money, players, skins, rankNames,rankLoans,rankSkins,validWeapons,rankWeapons, actionStatus)
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

			players = sortPlayerTable(players, "playerId", function(a, b) return a.rank > b.rank end)

			self.m_FactionPlayersGrid:clear()
			for _, info in ipairs(players) do
				local item = self.m_FactionPlayersGrid:addItem(info.name, info.rank, tostring(info.activity).." h")
				item.Id = info.playerId
			end

			if rank >= FactionRank.Manager then
				self.m_skins = skins
				self.m_RankLoans = rankLoans
				self.m_RankSkins = rankSkins
				self.m_ValidWeapons = validWeapons
				self.m_RankWeapons = rankWeapons
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

function FactionGUI:FactionAddPlayerButton_Click()
	InviteGUI:new(
		function(player)
			triggerServerEvent("factionAddPlayer", root, player)
		end,"faction"
	)
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

function FactionGUI:FactionRespawnVehicles()
	triggerServerEvent("factionRespawnVehicles", root)
end

function FactionGUI:ShowObjectList()
	self:close()
	triggerServerEvent("requestWorldItemListOfOwner", localPlayer, localPlayer:getFaction():getId(), "faction")
end

function FactionGUI:ShowLogs()
	self:close()
	triggerServerEvent("factionRequestLog", root)
end

