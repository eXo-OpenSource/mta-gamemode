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

	-- Tab: Allgemein
	local tabGeneral = self.m_TabPanel:addTab(_"Allgemein")
	self.m_TabGeneral = tabGeneral
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.10, _"Allgemein", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.11, self.m_Width*0.25, self.m_Height*0.06, _"Spielzeit:", tabGeneral)
	self.m_PlayTimeLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.11, self.m_Width*0.4, self.m_Height*0.06, _"0 Stunde(n) 0 Minute(n)", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.17, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabGeneral)
	self.m_GeneralKarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.17, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, _"Unternehmen:", tabGeneral)
	self.m_CompanyNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	self.m_CompanyEditLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.125, self.m_Height*0.06, _"(anzeigen)", tabGeneral):setColor(Color.LightBlue)
	self.m_CompanyEditLabel.onHover = function () self.m_CompanyEditLabel:setColor(Color.White) end
	self.m_CompanyEditLabel.onUnhover = function () self.m_CompanyEditLabel:setColor(Color.LightBlue) end
	addRemoteEvents{"companyRetrieveInfo", "companyInvitationRetrieve"}
	addEventHandler("companyRetrieveInfo", root, bind(self.Event_companyRetrieveInfo, self))
	--addEventHandler("companyInvitationRetrieve", root, bind(self.Event_companyInvitationRetrieve, self))

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.06, _"Aktueller Job:", tabGeneral)
	self.m_JobNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	self.m_JobQuitButton = GUIButton:new(self.m_Width*0.7, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.06, _"Job kündigen", tabGeneral):setBackgroundColor(Color.Red)
	self.m_JobQuitButton:setFontSize(1.2)
	self.m_JobQuitButton.onLeftClick = bind(self.JobQuitButton_Click, self)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.25, self.m_Height*0.10, _"Fraktion", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.49, self.m_Width*0.25, self.m_Height*0.06, _"Aktuelle Fraktion:", tabGeneral)
	self.m_FactionNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.49, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	self.m_FactionMenuButton = GUILabel:new(self.m_Width*0.3, self.m_Height*0.49, self.m_Width*0.4, self.m_Height*0.06, _"(anzeigen)", tabGeneral):setColor(Color.LightBlue)
	self.m_FactionMenuButton.onHover = function () self.m_FactionMenuButton:setColor(Color.White) end
	self.m_FactionMenuButton.onUnhover = function () self.m_FactionMenuButton:setColor(Color.LightBlue) end
	--self.m_FactionMenuButton = GUIButton:new(self.m_Width*0.7, self.m_Height*0.49, self.m_Width*0.25, self.m_Height*0.06, _"Fraktions-Menü", tabGeneral):setBackgroundColor(Color.Blue)
	--self.m_FactionMenuButton:setFontSize(1.2)
	self.m_FactionMenuButton:setVisible(false)
	self.m_FactionMenuButton.onLeftClick = bind(self.FactionMenuButton_Click, self)
	self.m_FactionInvationLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.55, self.m_Width*0.8, self.m_Height*0.06, "", tabGeneral)
	self.m_FactionInvationLabel:setVisible(false)
	self.m_FactionInvitationsAcceptButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.195, self.m_Height*0.06, "✓", tabGeneral):setBackgroundColor(Color.Green)
	self.m_FactionInvitationsAcceptButton:setVisible(false)
	self.m_FactionInvitationsDeclineButton = GUIButton:new(self.m_Width*0.225, self.m_Height*0.6, self.m_Width*0.195, self.m_Height*0.06, "✕", tabGeneral):setBackgroundColor(Color.Red)
	self.m_FactionInvitationsDeclineButton:setVisible(false)
	self.m_FactionInvitationsAcceptButton.onLeftClick = bind(self.FactionInvitationsAcceptButton_Click, self)
	self.m_FactionInvitationsDeclineButton.onLeftClick = bind(self.FactionInvitationsDeclineButton_Click, self)
	addRemoteEvents{"factionRetrieveInfo", "factionInvitationRetrieve"}
	addEventHandler("factionRetrieveInfo", root, bind(self.Event_factionRetrieveInfo, self))
	addEventHandler("factionInvitationRetrieve", root, bind(self.Event_factionInvitationRetrieve, self))

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.9, self.m_Height*0.10, _"Private Firma / Gang:", tabGeneral)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.69, self.m_Width*0.25, self.m_Height*0.06, _"Firma / Gang:", tabGeneral)
	self.m_GroupNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.69, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	self.m_GroupMenuButton = GUILabel:new(self.m_Width*0.3, self.m_Height*0.69, self.m_Width*0.135, self.m_Height*0.06, _"(verwalten)", tabGeneral):setColor(Color.LightBlue)
	self.m_GroupMenuButton.onHover = function () self.m_GroupMenuButton:setColor(Color.White) end
	self.m_GroupMenuButton.onUnhover = function () self.m_GroupMenuButton:setColor(Color.LightBlue) end
	self.m_GroupMenuButton.onLeftClick = bind(self.GroupMenuButton_Click, self)
	self.m_GroupInvitationsLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.79, self.m_Width*0.8, self.m_Height*0.06, "", tabGeneral)
	self.m_GroupInvitationsLabel:setVisible(false)
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
	self.m_VehicleGarageUpgradeButton = GUILabel:new(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleGarages:getText(), self.m_VehicleGarages:getFontSize(), self.m_VehicleGarages:getFont()) + 5, self.m_Height*0.75, self.m_Width*0.17, self.m_Height*0.06, _"(Kaufen: 0$)", tabVehicles):setColor(Color.LightBlue)
	self.m_VehicleGarageUpgradeButton.onHover = function () self.m_VehicleGarageUpgradeButton:setColor(Color.White) end
	self.m_VehicleGarageUpgradeButton.onUnhover = function () self.m_VehicleGarageUpgradeButton:setColor(Color.LightBlue) end
	self.m_VehicleHangar = GUILabel:new(self.m_Width*0.02, self.m_Height*0.81, self.m_Width*0.5, self.m_Height*0.06, _"Hangar:", tabVehicles)
	self.m_VehicleHangarButton = GUILabel:new(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleGarages:getText(), self.m_VehicleGarages:getFontSize(), self.m_VehicleGarages:getFont()) + 5, self.m_Height*0.81, self.m_Width*0.17, self.m_Height*0.06, _"(Kaufen: 0$)", tabVehicles):setColor(Color.LightBlue)
	self.m_VehicleHangarButton.onHover = function () self.m_VehicleHangarButton:setColor(Color.White) end
	self.m_VehicleHangarButton.onUnhover = function () self.m_VehicleHangarButton:setColor(Color.LightBlue) end
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
	self.m_KarmaLevelButton = GUIButton:new(self.m_Width*0.4, self.m_Height*0.1, self.m_Width*0.15, self.m_Height*0.06, "+ (200P)", tabPoints):setBackgroundColor(Color.Green)
	self.m_KarmaLevelButton.onLeftClick = function() triggerServerEvent("requestPointsToKarma", resourceRoot, true) end
	self.m_KarmaLevelButton = GUIButton:new(self.m_Width*0.55, self.m_Height*0.1, self.m_Width*0.15, self.m_Height*0.06, "- (200P)", tabPoints):setBackgroundColor(Color.Red)
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
	self.m_RadarChange:setIndex(core:get("HUD", "CursorMode", 0) + 1, true)

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

	--[[GUILabel:new(self.m_Width*0.02, self.m_Height*0.74, self.m_Width*0.8, self.m_Height*0.07, _"Tastenzuordnungen", tabSettings)
	self.m_KeyBindingsButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.82, self.m_Width*0.35, self.m_Height*0.07, _"Tastenzuordnungen ändern", tabSettings):setBackgroundColor(Color.Red):setFontSize(1.2)
	self.m_KeyBindingsButton.onLeftClick = function ()
		self:close()
		KeyBindings:new()
	end]]
end

function SelfGUI:onShow()
	-- Update VehicleTab
	self:TabPanel_TabChanged(self.m_TabGeneral.TabIndex)
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
	if localPlayer:getKarma() then
		local karma = localPlayer:getKarma()
		self.m_GeneralKarmaLabel:setText(tostring(karma > 0 and "+"..karma or karma))
	end
end


function SelfGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabGeneral.TabIndex then
		triggerServerEvent("companyRequestInfo", root)
		triggerServerEvent("factionRequestInfo", root)
		triggerServerEvent("groupRequestInfo", root)
	elseif tabId == self.m_TabVehicles.TabIndex then
		triggerServerEvent("vehicleRequestInfo", root)
	end
end

function SelfGUI:adjustGeneralTab(name)
	local isInCompany = name ~= nil
	self.m_CompanyEditLabel:setVisible(isInCompany)
end

function SelfGUI:Event_companyRetrieveInfo(name)
	self:adjustGeneralTab(name)

	if name then
		self.m_CompanyNameLabel:setText(name)
		local x, y = self.m_CompanyNameLabel:getPosition()
		self.m_CompanyEditLabel:setPosition(x + dxGetTextWidth(name, self.m_CompanyNameLabel:getFontSize(), self.m_CompanyNameLabel:getFont()) + 10, y)
	else
		self.m_CompanyNameLabel:setText("-")
	end
end

function SelfGUI:JobQuitButton_Click()
	triggerServerEvent("jobQuit", root)
	self.m_JobNameLabel:setText("-")
	self.m_JobQuitButton:setVisible(false)
end

function SelfGUI:GroupMenuButton_Click()
	self:close()
	GroupGUI:getSingleton():open()
end

function SelfGUI:FactionMenuButton_Click()
	self:close()
	FactionGUI:getSingleton():open()
end

function SelfGUI:Event_factionRetrieveInfo(id, name, rank)
	if rank and rank > 0 then
		self.m_FactionNameLabel:setText(_("%s - Rang: %d", name, rank))
		self.m_FactionInvationLabel:setVisible(false)
		self.m_FactionMenuButton:setVisible(true)
		self.m_InvationFactionId = 0

		if rank >= 5 then
			self.m_FactionMenuButton:setText(_"(verwalten)")
		else
			self.m_FactionMenuButton:setText(_"(anzeigen)")
		end
		local x, y = self.m_FactionNameLabel:getPosition()
		self.m_FactionMenuButton:setPosition(x + dxGetTextWidth(_("%s - Rang: %d", name, rank), self.m_FactionNameLabel:getFontSize(), self.m_FactionNameLabel:getFont()) + 10, y)
	else
		self.m_FactionNameLabel:setText(_"- keine Fraktion -")
		self.m_FactionInvationLabel:setVisible(true)
		self.m_FactionMenuButton:setVisible(false)

		if self.m_InvationFactionId and self.m_InvationFactionId > 0 then
			self.m_FactionInvationLabel:setVisible(true)
			self.m_FactionInvitationsAcceptButton:setVisible(true)
			self.m_FactionInvitationsDeclineButton:setVisible(true)
		end
	end
end

function SelfGUI:Event_factionInvitationRetrieve(factionId, name)
	if factionId > 0 then
		ShortMessage:new(_("Du wurdest in die Fraktion '%s' eingeladen. Öffne das Spielermenü, um die Einladung anzunehmen", name))
		self.m_FactionInvationLabel:setVisible(true)
		self.m_FactionInvitationsAcceptButton:setVisible(true)
		self.m_FactionInvitationsDeclineButton:setVisible(true)
		self.m_FactionInvationLabel:setText("Du wurdest in die Fraktion \""..name.."\" eingeladen!")
		self.m_InvationFactionId = factionId
	end
end


function SelfGUI:Event_groupInvitationRetrieve(groupId, name)
	ShortMessage:new(_("Du wurdest in die Gruppe '%s' eingeladen. Öffne das Spielermenü, um die Einladung anzunehmen", name))
	self.m_GroupInvitationsLabel:setText("Du hast Einladungen in private Firmen/Gangs, öffne das Menü um diese anzunehmen!")
	self.m_GroupInvitationsLabel:setVisible(true)
	self.m_InvationGroupId = groupId

end

function SelfGUI:Event_groupRetrieveInfo(name, rank)
	if rank and rank > 0 then
		self.m_GroupNameLabel:setText(_("%s - Rang: %s", name, GroupRank[rank]))
		self.m_GroupInvitationsLabel:setVisible(false)
		self.m_InvationGroupId = 0

		local x, y = self.m_GroupNameLabel:getPosition()
		self.m_GroupMenuButton:setPosition(x + dxGetTextWidth(_("%s - Rang: %s", name, GroupRank[rank]), self.m_GroupNameLabel:getFontSize(), self.m_GroupNameLabel:getFont()) + 10, y)
	else
		self.m_GroupNameLabel:setText(_"- keine Firma/Gang -")
		self.m_GroupInvitationsLabel:setVisible(true)

		if self.m_InvationGroupId and self.m_InvationGroupId > 0 then
			self.m_GroupInvitationsLabel:setVisible(true)
		end
	end
end

function SelfGUI:FactionInvitationsAcceptButton_Click()
	if self.m_InvationFactionId then
		triggerServerEvent("factionInvitationAccept", resourceRoot, self.m_InvationFactionId)
		self.m_FactionInvationLabel:setVisible(false)
		self.m_FactionInvitationsAcceptButton:setVisible(false)
		self.m_FactionInvitationsDeclineButton:setVisible(false)
		self.m_FactionInvationLabel:setText("")
		self.m_InvationFactionId = 0
	end
end

function SelfGUI:FactionInvitationsDeclineButton_Click()
	if self.m_InvationFactionId then
		triggerServerEvent("factionInvitationDecline", resourceRoot, self.m_InvationFactionId)
		self.m_FactionInvationLabel:setVisible(false)
		self.m_FactionInvitationsAcceptButton:setVisible(false)
		self.m_FactionInvitationsDeclineButton:setVisible(false)
		self.m_FactionInvationLabel:setText("")
		self.m_InvationFactionId = 0
	end
end



function SelfGUI:Event_vehicleRetrieveInfo(vehiclesInfo, garageType, hangarType)
	if vehiclesInfo then
		self.m_VehiclesGrid:clear()
		for vehicleId, vehicleInfo in pairs(vehiclesInfo) do
			local element, positionType = unpack(vehicleInfo)
			local x, y, z = getElementPosition(element)
			if positionType == VehiclePositionType.World then
				positionType = getZoneName(x, y, z, false)
			elseif positionType == VehiclePositionType.Garage then
				positionType = _"Garage"
			elseif positionType == VehiclePositionType.Mechanic then
				positionType = _"Autohof"
			elseif positionType == VehiclePositionType.Hangar then
				positionType = _"Hangar"
			else
				positionType = _"Unbekannt"
			end
			local item = self.m_VehiclesGrid:addItem(element:getName(), positionType)
			item.VehicleId = vehicleId
			item.VehicleElement = element
			item.PositionType = (
				(vehicleInfo[2] == VehiclePositionType.World and VehiclePositionType.World) or
				(vehicleInfo[2] == VehiclePositionType.Garage and VehiclePositionType.Garage) or
				(vehicleInfo[2] == VehiclePositionType.Hangar and VehiclePositionType.Hangar) or
				(vehicleInfo[2] == VehiclePositionType.Mechanic and VehiclePositionType.Mechanic)
			)
		end
	end

	if garageType then
		localPlayer.m_GarageType = garageType
		self.m_VehicleGarages:setText(_(GARAGE_UPGRADES_TEXTS[garageType]))

		local price = GARAGE_UPGRADES_COSTS[garageType + 1] or "-"
		if localPlayer.m_GarageType == 0 then
			self.m_VehicleGarageUpgradeButton:setText(_("(Kaufen: %s$)", price))
		else
			self.m_VehicleGarageUpgradeButton:setText(_("(Upgrade: %s$)", price))
		end
		self.m_VehicleGarageUpgradeButton:setPosition(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleGarages:getText(), self.m_VehicleGarages:getFontSize(), self.m_VehicleGarages:getFont()) + 5, self.m_Height*0.75)
		self.m_VehicleGarageUpgradeButton:setSize(dxGetTextWidth(self.m_VehicleGarageUpgradeButton:getText(), self.m_VehicleGarageUpgradeButton:getFontSize(), self.m_VehicleGarageUpgradeButton:getFont()), self.m_Height*0.06)
	end

	if hangarType then
		localPlayer.m_HangarType = hangarType
		self.m_VehicleHangar:setText(_(HANGAR_UPGRADES_TEXTS[hangarType]))

		local price = HANGAR_UPGRADES_COSTS[hangarType + 1] or "-"
		if localPlayer.m_HangarType == 0 then
			self.m_VehicleHangarButton:setText(_("(Kaufen: %s$)", price))
		else
			self.m_VehicleHangarButton:setText(_("(Upgrade: %s$)", price))
		end
		self.m_VehicleHangarButton:setPosition(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleHangar:getText(), self.m_VehicleHangar:getFontSize(), self.m_VehicleHangar:getFont()) + 5, self.m_Height*0.81)
		self.m_VehicleHangarButton:setSize(dxGetTextWidth(self.m_VehicleHangarButton:getText(), self.m_VehicleHangarButton:getFontSize(), self.m_VehicleHangarButton:getFont()), self.m_Height*0.06)
	end
end

function SelfGUI:VehicleGarageUpgradeButton_Click()
	triggerServerEvent("vehicleUpgradeGarage", root)
end

function SelfGUI:VehicleHangarButton_Click()
	if localPlayer:getRank() >= RANK.Developer then
		triggerServerEvent("vehicleUpgradeHangar", root)
	else
		outputChatBox("Not implemented!", 255, 0, 0)
	end
end

function SelfGUI:VehicleLocateButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	if item.PositionType == VehiclePositionType.World then
		local x, y, z = getElementPosition(item.VehicleElement)
		local blip = Blip:new("Waypoint.png", x, y)
		setTimer(function() HUDRadar:getSingleton():removeBlip(blip) end, 5000, 1)

		ShortMessage:new(_("Dieses Fahrzeug befindet sich in %s!\n(Siehe Blip auf der Karte)", getZoneName(x, y, z, false)))
	elseif item.PositionType == VehiclePositionType.Garage then
 		ShortMessage:new(_"Dieses Fahrzeug befindet sich in deiner Garage!")
	elseif item.PositionType == VehiclePositionType.Mechanic then
		ShortMessage:new(_"Dieses Fahrzeug befindet sich im Autohof (Mechanic Base)!")
	elseif item.PositionType == VehiclePositionType.Hangar then
		ShortMessage:new(_"Dieses Flugzeug befindet sich im Hangar!")
	else
		ErrorBox:new(_"Es ist ein interner Fehler aufgetreten!")
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
