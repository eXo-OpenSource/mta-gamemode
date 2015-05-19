-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SelfGUI.lua
-- *  PURPOSE:     Self menu GUI class
-- *
-- ****************************************************************************
SelfGUI = inherit(GUIForm)
inherit(Singleton, SelfGUI)

function SelfGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	self.m_CloseButton.onLeftClick = function() self:close() end

	-- Tab: Job
	local tabGeneral = self.m_TabPanel:addTab(_"Allgemein")
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.016, self.m_Width*0.3, self.m_Height*0.12, _"Allgemein", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.13, self.m_Width*0.25, self.m_Height*0.06, _"Spielzeit:", tabGeneral)
	self.m_PlayTimeLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.13, self.m_Width*0.4, self.m_Height*0.06, _"0 Stunde(n) 0 Minute(n)", tabGeneral)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.216, self.m_Width*0.25, self.m_Height*0.12, _"Job", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.25, self.m_Height*0.06, _"Aktueller Job:", tabGeneral)
	self.m_JobNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.33, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	self.m_JobQuitButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.39, self.m_Width*0.25, self.m_Height*0.06, _"Job kündigen", tabGeneral):setBackgroundColor(Color.Red)
	self.m_JobQuitButton:setFontSize(1.3)
	self.m_JobQuitButton.onLeftClick = bind(self.JobQuitButton_Click, self)

	-- Tab: Groups
	local tabGroups = self.m_TabPanel:addTab(_"Gruppen")
	self.m_TabGroups = tabGroups
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Gruppe:", tabGroups)
	self.m_GroupsNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupsNameChangeLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.1, self.m_Height*0.06, "(change)", tabGroups):setColor(Color.LightBlue)
	self.m_GroupsNameChangeLabel.onLeftClick = function() InputBox:new(_"Gruppennamen ändern", "Bitte gib einen neuen Name für deine Gruppe ein!", function (name) triggerServerEvent("groupChangeName", root, name) end) end
	self.m_GroupsNameChangeLabel.onHover = function () self.m_GroupsNameChangeLabel:setColor(Color.White) end
	self.m_GroupsNameChangeLabel.onUnhover = function () self.m_GroupsNameChangeLabel:setColor(Color.LightBlue) end
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabGroups)
	self.m_GroupsKarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.14, self.m_Width*0.25, self.m_Height*0.06, _"Gruppenrang:", tabGroups)
	self.m_GroupsRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.14, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupCreateButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Erstellen", true, tabGroups):setBarColor(Color.Green)
	self.m_GroupQuitButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.07, _"Verlassen", true, tabGroups):setBarColor(Color.Red)
	self.m_GroupDeleteButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.07, _"Löschen", true, tabGroups):setBarColor(Color.Red)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, _"Kasse:", tabGroups)
	self.m_GroupMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, "", tabGroups)
	self.m_GroupMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.27, self.m_Height*0.07, tabGroups):setCaption(_"Betrag")
	self.m_GroupMoneyDepositButton = VRPButton:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", true, tabGroups)
	self.m_GroupMoneyWithdrawButton = VRPButton:new(self.m_Width*0.56, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", true, tabGroups)
	self.m_GroupPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.4, self.m_Height*0.5, tabGroups)
	self.m_GroupPlayersGrid:addColumn(_"Spieler", 0.7)
	self.m_GroupPlayersGrid:addColumn(_"Rang", 0.3)
	self.m_GroupAddPlayerButton = VRPButton:new(self.m_Width*0.43, self.m_Height*0.4, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", true, tabGroups):setBarColor(Color.Green)
	self.m_GroupRemovePlayerButton = VRPButton:new(self.m_Width*0.43, self.m_Height*0.48, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", true, tabGroups):setBarColor(Color.Red)
	self.m_GroupRankUpButton = VRPButton:new(self.m_Width*0.43, self.m_Height*0.56, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", true, tabGroups)
	self.m_GroupRankDownButton = VRPButton:new(self.m_Width*0.43, self.m_Height*0.64, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", true, tabGroups)

	self.m_GroupInvitationsLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.06, _"Einladungen:", tabGroups)
	self.m_GroupInvitationsGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.6, tabGroups)
	self.m_GroupInvitationsGrid:addColumn(_"Name", 1)
	self.m_GroupInvitationsAcceptButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "✓", tabGroups):setBackgroundColor(Color.Green)
	self.m_GroupInvitationsDeclineButton = GUIButton:new(self.m_Width*0.225, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "✕", tabGroups):setBackgroundColor(Color.Red)

	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
	self.m_GroupCreateButton.onLeftClick = bind(self.GroupCreateButton_Click, self)
	self.m_GroupQuitButton.onLeftClick = bind(self.GroupQuitButton_Click, self)
	self.m_GroupDeleteButton.onLeftClick = bind(self.GroupDeleteButton_Click, self)
	self.m_GroupMoneyDepositButton.onLeftClick = bind(self.GroupMoneyDepositButton_Click, self)
	self.m_GroupMoneyWithdrawButton.onLeftClick = bind(self.GroupMoneyWithdrawButton_Click, self)
	self.m_GroupAddPlayerButton.onLeftClick = bind(self.GroupAddPlayerButton_Click, self)
	self.m_GroupRemovePlayerButton.onLeftClick = bind(self.GroupRemovePlayerButton_Click, self)
	self.m_GroupRankUpButton.onLeftClick = bind(self.GroupRankUpButton_Click, self)
	self.m_GroupRankDownButton.onLeftClick = bind(self.GroupRankDownButton_Click, self)
	self.m_GroupInvitationsAcceptButton.onLeftClick = bind(self.GroupInvitationsAcceptButton_Click, self)
	self.m_GroupInvitationsDeclineButton.onLeftClick = bind(self.GroupInvitationsDeclineButton_Click, self)
	addRemoteEvents{"groupRetrieveInfo", "groupInvitationRetrieve"}
	addEventHandler("groupRetrieveInfo", root, bind(self.Event_groupRetrieveInfo, self))
	addEventHandler("groupInvitationRetrieve", root, bind(self.Event_groupInvitationRetrieve, self))


	-- Tab: Vehicles
	local tabVehicles = self.m_TabPanel:addTab(_"Fahrzeuge")
	self.m_TabVehicles = tabVehicles
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Fahrzeuge:", tabVehicles)
	self.m_VehiclesGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.65, self.m_Height*0.6, tabVehicles)
	self.m_VehiclesGrid:addColumn(_"Name", 0.3)
	self.m_VehiclesGrid:addColumn(_"Standort", 0.7)
	self.m_VehicleGarages = GUILabel:new(self.m_Width*0.02, self.m_Height*0.75, self.m_Width*0.5, self.m_Height*0.06, _"Garage:", tabVehicles)
	self.m_VehicleHangar = GUILabel:new(self.m_Width*0.02, self.m_Height*0.81, self.m_Width*0.5, self.m_Height*0.06, _"Hangar: kein Hangar", tabVehicles)
	self.m_VehicleGarageUpgradeButton = VRPButton:new(self.m_Width*0.5, self.m_Height*0.75, self.m_Width*0.35, self.m_Height*0.07, _"Upgrade", true, tabVehicles)
	self.m_VehicleHangarButton = VRPButton:new(self.m_Width*0.5, self.m_Height*0.84, self.m_Width*0.35, self.m_Height*0.07, _"Hangar kaufen", true, tabVehicles)
	self.m_VehicleLocateButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.09, self.m_Width*0.28, self.m_Height*0.07, _"Orten", true, tabVehicles)
	self.m_VehicleRespawnButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.18, self.m_Width*0.28, self.m_Height*0.07, _"Respawn", true, tabVehicles)
	self.m_VehicleSellButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.27, self.m_Width*0.28, self.m_Height*0.07, _"Verkaufen", true, tabVehicles)

	self.m_VehicleGarageUpgradeButton.onLeftClick = bind(self.VehicleGarageUpgradeButton_Click, self)
	self.m_VehicleHangarButton.onLeftClick = bind(self.VehicleHangarButton_Click, self)
	self.m_VehicleLocateButton.onLeftClick = bind(self.VehicleLocateButton_Click, self)
	self.m_VehicleRespawnButton.onLeftClick = bind(self.VehicleRespawnButton_Click, self)
	self.m_VehicleSellButton.onLeftClick = bind(self.VehicleSellButton_Click, self)
	addRemoteEvents{"vehicleRetrieveInfo"}
	addEventHandler("vehicleRetrieveInfo", root, bind(self.Event_vehicleRetrieveInfo, self))

	-- Tab: Points
	local tabPoints = self.m_TabPanel:addTab(_"Punkte")
	self.m_TabPoints = tabPoints
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Punkte:", tabPoints):setColor(Color.Yellow)
	self.m_PointsLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "0", tabPoints):setColor(Color.Yellow)
	localPlayer:setPrivateSyncChangeHandler("Points", function(value) self.m_PointsLabel:setText(tostring(value)) end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabPoints)
	self.m_KarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.1, self.m_Width*0.4, self.m_Height*0.06, "+0", tabPoints)
	localPlayer:setPrivateSyncChangeHandler("KarmaLevel", function(value) self.m_KarmaLabel:setText(tostring(math.floor(value))) end)
	self.m_KarmaLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.1, self.m_Width*0.15, self.m_Height*0.06, "+ (400P)", tabPoints):setBackgroundColor(Color.Green)
	self.m_KarmaLevelButton.onLeftClick = function() triggerServerEvent("requestPointsToKarma", resourceRoot, true) end
	self.m_KarmaLevelButton = GUIButton:new(self.m_Width*0.55, self.m_Height*0.1, self.m_Width*0.15, self.m_Height*0.06, "- (400P)", tabPoints):setBackgroundColor(Color.Red)
	self.m_KarmaLevelButton.onLeftClick = function() triggerServerEvent("requestPointsToKarma", resourceRoot, false) end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.06, _"Waffenlevel:", tabPoints)
	self.m_WeaponLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.18, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getWeaponLevel(), tabPoints)
	self.m_WeaponLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.18, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getWeaponLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_WeaponLevelButton.onLeftClick = function() triggerServerEvent("requestWeaponLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("WeaponLevel", function(value)
		self.m_WeaponLevelLabel:setText(tostring(value))
		self.m_WeaponLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getWeaponLevel())))
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.26, self.m_Width*0.25, self.m_Height*0.06, _"Fahrzeuglevel:", tabPoints)
	self.m_VehicleLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.26, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getVehicleLevel(), tabPoints)
	self.m_VehicleLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.26, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_VehicleLevelButton.onLeftClick = function() triggerServerEvent("requestVehicleLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("VehicleLevel", function(value)
		self.m_VehicleLevelLabel:setText(tostring(value))
		self.m_VehicleLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())))
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.34, self.m_Width*0.25, self.m_Height*0.06, _"Skinlevel:", tabPoints)
	self.m_SkinLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.34, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getSkinLevel(), tabPoints)
	self.m_SkinLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.34, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_SkinLevelButton.onLeftClick = function() triggerServerEvent("requestSkinLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("SkinLevel", function(value)
		self.m_SkinLevelLabel:setText(tostring(value))
		self.m_SkinLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())))
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.42, self.m_Width*0.25, self.m_Height*0.06, _"Joblevel:", tabPoints)
	self.m_JobLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.42, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getJobLevel(), tabPoints)
	self.m_JobLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.42, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_JobLevelButton.onLeftClick = function() triggerServerEvent("requestJobLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("JobLevel", function(value)
		self.m_JobLevelLabel:setText(tostring(value))
		self.m_JobLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())))
	end)

	-- Tab: Settings
	local tabSettings = self.m_TabPanel:addTab(_"Einstellungen")
	self.m_TabSettings = tabSettings
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"HUD und Nametag", tabSettings)
	self.m_RadarChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.35, self.m_Height*0.07, tabSettings)
	self.m_RadarChange:addItem(_"Monochrom")
	self.m_RadarChange:addItem("GTA:SA")
	self.m_RadarChange.onChange = function(text, index) HUDRadar:getSingleton():setDesignSet(index) end
	self.m_RadarChange:setIndex(core:get("HUD", "RadarDesign") or 1, true)

	self.m_BlipCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.19, self.m_Width*0.35, self.m_Height*0.04, _"Blips anzeigen?", tabSettings)
	self.m_BlipCheckBox:setFont(VRPFont(25))
	self.m_BlipCheckBox:setFontSize(1)
	self.m_BlipCheckBox:setChecked(core:get("HUD", "drawBlips", true))
	self.m_BlipCheckBox.onChange = function (state)
		core:set("HUD", "drawBlips", state)
	end

	self.m_GangAreaCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.25, self.m_Width*0.35, self.m_Height*0.04, _"Gangareas anzeigen?", tabSettings)
	self.m_GangAreaCheckBox:setFont(VRPFont(25))
	self.m_GangAreaCheckBox:setFontSize(1)
	self.m_GangAreaCheckBox:setChecked(core:get("HUD", "drawGangAreas", true))
	self.m_GangAreaCheckBox.onChange = function (state)
		core:set("HUD", "drawGangAreas", state)
		HUDRadar:getSingleton():updateMapTexture()
	end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.32, self.m_Width*0.8, self.m_Height*0.07, _"Cursor Modus", tabSettings)
	self.m_RadarChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.39, self.m_Width*0.35, self.m_Height*0.07, tabSettings)
	self.m_RadarChange:addItem("Normal")
	self.m_RadarChange:addItem("Instant")
	self.m_RadarChange.onChange = function(text, index)
		core:getConfig():set("HUD", "CursorMode", index - 1)
		Cursor:setCursorMode(toboolean(index - 1))
	end
	self.m_RadarChange:setIndex(core:get("HUD", "CursorMode", 1) + 1, true)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.49, self.m_Width*0.8, self.m_Height*0.07, _"Tipps", tabSettings)
	self.m_EnableTippsBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.57, self.m_Width*0.35, self.m_Height*0.04, _"Tipps aktivieren?", tabSettings)
	self.m_EnableTippsBox:setFont(VRPFont(25))
	self.m_EnableTippsBox:setFontSize(1)
	self.m_EnableTippsBox:setChecked(core:get("Tipps", "enableTipps", true))
	localPlayer.m_showTipps = core:get("Tipps", "enableTipps", true) -- Todo: Find a better position
	self.m_EnableTippsBox.onChange = function (state)
		localPlayer.m_showTipps = state
		core:set("Tipps", "enableTipps", state)

		if not state then
			delete(TippManager:getSingleton())
		else
				if not TippManager:isInstantiated() then
					TippManager:new()
				end
		end
	end

	self.m_TippResetButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.64, self.m_Width*0.35, self.m_Height*0.07, _"Tipps zurücksetzen", tabSettings):setBackgroundColor(Color.Red):setFontSize(1.2)
	self.m_TippResetButton.onLeftClick = function ()
		if localPlayer.m_showTipps then
			self:close()
			QuestionBox:new(_"Wirklich fortfahren?\nDadurch werden alle Tipps erneut angezeigt!", function()
				core:set("Tipps", "lastTipp", 0)
				if not TippManager:isInstantiated() then
					TippManager:new()
				end
				SuccessBox:new(_"Tipps wurden erfolgreich zurückgesetzt!")

				self:open()
			end, function()
				self:open()
			end)
		else
			ErrorBox:new(_"Tipps wurden deaktiviert!")
		end
	end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.74, self.m_Width*0.8, self.m_Height*0.07, _"Tastenzuordnungen", tabSettings)
	self.m_KeyBindingsButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.82, self.m_Width*0.35, self.m_Height*0.07, _"Tastenzuordnungen ändern", tabSettings):setBackgroundColor(Color.Red):setFontSize(1.2)
	self.m_KeyBindingsButton.onLeftClick = function ()
		self:close()
		KeyBindings:new()
	end
end

function SelfGUI:onShow()
	-- Update VehicleTab & GroupTab
	self:TabPanel_TabChanged(self.m_TabGroups.TabIndex)
	self:TabPanel_TabChanged(self.m_TabVehicles.TabIndex)

	-- Initialize all the stuff
	self.m_WeaponLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getWeaponLevel())))
	self.m_VehicleLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())))
	self.m_SkinLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())))
	self.m_JobLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())))

	local hours, minutes = math.floor(localPlayer:getPlayTime()/60), (localPlayer:getPlayTime() - math.floor(localPlayer:getPlayTime()/60)*60)
	self.m_PlayTimeLabel:setText(_("%s Stunde(n) %s Minute(n)", hours, minutes))

	if localPlayer:getJob() then
		self.m_JobNameLabel:setText(localPlayer:getJob():getName())
		self.m_JobQuitButton:setVisible(true)
	else
		self.m_JobNameLabel:setText("-")
		self.m_JobQuitButton:setVisible(false)
	end
end

function SelfGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabGroups.TabIndex then
		triggerServerEvent("groupRequestInfo", root)
	elseif tabId == self.m_TabVehicles.TabIndex then
		triggerServerEvent("vehicleRequestInfo", root)
	end
end

function SelfGUI:JobQuitButton_Click()
	triggerServerEvent("jobQuit", root)
	self.m_JobNameLabel:setText("-")
	self.m_JobQuitButton:setVisible(false)
end

function SelfGUI:Event_groupRetrieveInfo(name, rank, money, players, karma)
	self:adjustGroupTab(rank or false)

	if name then
		local karma = math.floor(karma)
		local x, y = self.m_GroupsNameLabel:getPosition()
		self.m_GroupsNameChangeLabel:setPosition(x + dxGetTextWidth(name, self.m_GroupsNameLabel:getFontSize(), self.m_GroupsNameLabel:getFont()) + 10, y)
		self.m_GroupsNameLabel:setText(name)
		self.m_GroupsKarmaLabel:setText(tostring(karma > 0 and "+"..karma or karma))
		self.m_GroupsRankLabel:setText(GroupRank[rank])
		self.m_GroupMoneyLabel:setText(tostring(money).."$")

		self.m_GroupPlayersGrid:clear()
		for playerId, info in pairs(players) do
			local item = self.m_GroupPlayersGrid:addItem(info.name, info.rank)
			item.Id = playerId
		end
	end
end

function SelfGUI:Event_groupInvitationRetrieve(groupId, name)
	ShortMessage:new(_("Du wurdest in die Gruppe '%s' eingeladen. Öffne das Spielermenü, um die Einladung anzunehmen", name))

	local item = self.m_GroupInvitationsGrid:addItem(name)
	item.GroupId = groupId
end

function SelfGUI:adjustGroupTab(rank)
	local isInGroup = rank ~= false

	for k, element in ipairs(self.m_TabGroups:getChildren()) do
		if element ~= self.m_GroupCreateButton then
			element:setVisible(isInGroup)
		end
	end
	self.m_GroupInvitationsLabel:setVisible(false)
	self.m_GroupInvitationsGrid:setVisible(false)
	self.m_GroupInvitationsAcceptButton:setVisible(false)
	self.m_GroupInvitationsDeclineButton:setVisible(false)

	if rank then
		if rank ~= GroupRank.Leader then
			self.m_GroupDeleteButton:setVisible(false)
		end
		if rank < GroupRank.Manager then
			self.m_GroupMoneyWithdrawButton:setVisible(false)
			self.m_GroupAddPlayerButton:setVisible(false)
			self.m_GroupRemovePlayerButton:setVisible(false)
			self.m_GroupRankUpButton:setVisible(false)
			self.m_GroupRankDownButton:setVisible(false)
		end
	else
		-- We're not in a group, so show the invitation stuff
		self.m_GroupInvitationsLabel:setVisible(true)
		self.m_GroupInvitationsGrid:setVisible(true)
		self.m_GroupInvitationsAcceptButton:setVisible(true)
		self.m_GroupInvitationsDeclineButton:setVisible(true)
	end
end

function SelfGUI:GroupCreateButton_Click()
	GroupCreationGUI:new()
end

function SelfGUI:GroupQuitButton_Click()
	triggerServerEvent("groupQuit", root)
end

function SelfGUI:GroupDeleteButton_Click()
	triggerServerEvent("groupDelete", root)
end

function SelfGUI:GroupMoneyDepositButton_Click()
	local amount = tonumber(self.m_GroupMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("groupDeposit", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function SelfGUI:GroupMoneyWithdrawButton_Click()
	local amount = tonumber(self.m_GroupMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("groupWithdraw", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function SelfGUI:GroupAddPlayerButton_Click()
	GroupInviteGUI:new()
end

function SelfGUI:GroupRemovePlayerButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupDeleteMember", root, selectedItem.Id)
	else
		ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online")
	end
end

function SelfGUI:GroupRankUpButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupRankUp", root, selectedItem.Id)
	end
end

function SelfGUI:GroupRankDownButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupRankDown", root, selectedItem.Id)
	end
end

function SelfGUI:GroupInvitationsAcceptButton_Click()
	local selectedItem = self.m_GroupInvitationsGrid:getSelectedItem()
	if selectedItem then
		if selectedItem.GroupId then
			triggerServerEvent("groupInvitationAccept", resourceRoot, selectedItem.GroupId)
		end
		self.m_GroupInvitationsGrid:removeItemByItem(selectedItem)
	end
end

function SelfGUI:GroupInvitationsDeclineButton_Click()
	local selectedItem = self.m_GroupInvitationsGrid:getSelectedItem()
	if selectedItem then
		if selectedItem.GroupId then
			triggerServerEvent("groupInvitationDecline", resourceRoot, selectedItem.GroupId)
		end
		self.m_GroupInvitationsGrid:removeItemByItem(selectedItem)
	end
end

function SelfGUI:Event_vehicleRetrieveInfo(vehiclesInfo, garageType)
	if vehiclesInfo then
		self.m_VehiclesGrid:clear()
		for vehicleId, vehicleInfo in pairs(vehiclesInfo) do
			local element, positionType = unpack(vehicleInfo)
			local x, y, z = getElementPosition(element)
			if positionType == VehiclePositionType.World then
				positionType = getZoneName(x, y, z, false)
			elseif positionType == VehiclePositionType.Garage then
				positionType = _"Garage"
			else
				positionType = _"Autohof"
			end
			local item = self.m_VehiclesGrid:addItem(getVehicleName(element), positionType)
			item.VehicleId = vehicleId
			item.VehicleElement = element
			item.VehicleInGarage = inGarage
		end
	end

	self.m_VehicleGarageUpgradeButton:setText(_"Upgrade")
	if garageType then
		localPlayer.m_GarageType = garageType
		if garageType == 0 then
			self.m_VehicleGarageUpgradeButton:setText(_"Garage kaufen")
		end

		local texts = {[0] = _"Garage: keine Garage (0 Slots)", [1] = _"Garage: Standard Garage (3 Slots)", [2] = _"Garage: Komfortable Garage (6 Slots)", [3] = _"Garage: Luxus Garage (10 Slots)"}
		self.m_VehicleGarages:setText(texts[garageType])
	end
end

function SelfGUI:VehicleGarageUpgradeButton_Click()
	triggerServerEvent("vehicleUpgradeGarage", root)
end

function SelfGUI:VehicleHangarButton_Click()
	outputChatBox("Not implemented!", 255, 0, 0)
end

function SelfGUI:VehicleLocateButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	if not item.VehicleInGarage then
		local x, y = getElementPosition(item.VehicleElement)
		local blip = Blip:new("Waypoint.png", x, y)
		setTimer(function() HUDRadar:getSingleton():removeBlip(blip) end, 5000, 1)
	else
		ShortMessage:new(_"Dieses Fahrzeug befindet sich in deiner Garage!")
	end
end

function SelfGUI:VehicleRespawnButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	--[[if localPlayer:getGarageType() == 0 then
		ErrorBox:new(_"Du besitzt keine gültige Garage!")
		return
	end]]

	triggerServerEvent("vehicleRespawn", item.VehicleElement)
end

function SelfGUI:VehicleSellButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	triggerServerEvent("vehicleSell", item.VehicleElement)
end
