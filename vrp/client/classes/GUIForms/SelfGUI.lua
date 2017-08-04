-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SelfGUI.lua
-- *  PURPOSE:     Self menu GUI class
-- *
-- ****************************************************************************
SelfGUI = inherit(GUIForm)
inherit(Singleton, SelfGUI)

SelfGUI.Stats = {
	--["AFK"] = {
	--		["text"] = "gesamte AFK-Zeit",
	--		["value"] = function(value)
	--			local hours, minutes = math.floor(value/60/60), (value - math.floor(value/60/60)*60)
	--			return hours.." Stunde(n)" ..minutes.." Minute(n)" end
	--		},
	["Driven"] = {
			["text"] = "Gefahrene Kilometer",
			["value"] = function(value) return math.floor(value/1000).." km" end
			},
	["Deaths"] = {
			["text"] = "Tode",
			["value"] = function(value) return value end
			},
	["Kills"] =	{
			["text"] = "Kills",
			["value"] = function(value) return value end
			},
	["FishCaught"] = {
			["text"] = "Fische gefangen",
			["value"] = function(value) return value end
			},
}

function SelfGUI:constructor()


	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	self.m_OpenWindows = {}

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:close() end

	-- Tab: Allgemein
	local tabGeneral = self.m_TabPanel:addTab(_"Allgemein")
	self.m_TabGeneral = tabGeneral
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.10, _"Allgemein", tabGeneral)


	if localPlayer:getRank() > 0 then
		self.m_AdminButton = VRPButton:new(self.m_Width-self.m_Width*0.29, self.m_Height*0.02, self.m_Width*0.27, self.m_Height*0.07, _"Adminmenü", true, tabGeneral):setBarColor(Color.Red)
		self.m_AdminButton.onLeftClick = bind(self.AdminButton_Click, self)
	end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.11, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabGeneral)
	self.m_GeneralKarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.11, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.17, self.m_Width*0.25, self.m_Height*0.06, _"Aktueller Job:", tabGeneral)
	self.m_JobNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.17, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	self.m_JobQuitButton = GUILabel:new(self.m_Width*0.7, self.m_Height*0.17, self.m_Width*0.25, self.m_Height*0.06, _"(Job kündigen)", tabGeneral):setColor(Color.Red)
	self.m_JobQuitButton.onHover = function () self.m_JobQuitButton:setColor(Color.White) end
	self.m_JobQuitButton.onUnhover = function () self.m_JobQuitButton:setColor(Color.Red) end
	self.m_JobQuitButton.onLeftClick = bind(self.JobQuitButton_Click, self)

	-- COMPANY
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, _"Unternehmen:", tabGeneral)
	self.m_CompanyNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.4, self.m_Height*0.06, "", tabGeneral)
	GUILabel:new(self.m_Width*0.05, self.m_Height*0.29, self.m_Width*0.4, self.m_Height*0.06, "Rang:", tabGeneral)
	self.m_CompanyRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.4, self.m_Height*0.06, "-", tabGeneral)
	self.m_CompanyEditLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.135, self.m_Height*0.06, _"(anzeigen)", tabGeneral):setColor(Color.LightBlue)
	self.m_CompanyEditLabel.onHover = function () self.m_CompanyEditLabel:setColor(Color.White) end
	self.m_CompanyEditLabel.onUnhover = function () self.m_CompanyEditLabel:setColor(Color.LightBlue) end
	self.m_CompanyEditLabel.onLeftClick = bind(self.CompanyMenuButton_Click, self)
	addRemoteEvents{"companyRetrieveInfo", "companyInvitationRetrieve"}
	addEventHandler("companyRetrieveInfo", root, bind(self.Event_companyRetrieveInfo, self))
	addEventHandler("companyInvitationRetrieve", root, bind(self.Event_CompanyInvitationRetrieve, self))

	-- FACTION
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.37, self.m_Width*0.25, self.m_Height*0.06, _"Aktuelle Fraktion:", tabGeneral)
	self.m_FactionNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.37, self.m_Width*0.64, self.m_Height*0.06, "", tabGeneral)
	GUILabel:new(self.m_Width*0.05, self.m_Height*0.43, self.m_Width*0.4, self.m_Height*0.06, "Rang:", tabGeneral)
	self.m_FactionRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.43, self.m_Width*0.4, self.m_Height*0.06, "-", tabGeneral)
	self.m_FactionMenuButton = GUILabel:new(self.m_Width*0.3, self.m_Height*0.37, self.m_Width*0.135, self.m_Height*0.06, _"(anzeigen)", tabGeneral):setColor(Color.LightBlue)
	self.m_FactionMenuButton.onHover = function () self.m_FactionMenuButton:setColor(Color.White) end
	self.m_FactionMenuButton.onUnhover = function () self.m_FactionMenuButton:setColor(Color.LightBlue) end

	self.m_FactionMenuButton:setVisible(false)
	self.m_FactionMenuButton.onLeftClick = bind(self.FactionMenuButton_Click, self)

	addRemoteEvents{"factionRetrieveInfo", "factionInvitationRetrieve"}
	addEventHandler("factionRetrieveInfo", root, bind(self.Event_factionRetrieveInfo, self))
	addEventHandler("factionInvitationRetrieve", root, bind(self.Event_factionInvitationRetrieve, self))

	-- GROUP
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.50, self.m_Width*0.25, self.m_Height*0.06, _"Firma / Gang:", tabGeneral)
	self.m_GroupNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.50, self.m_Width*0.35, self.m_Height*0.06, "", tabGeneral)
	GUILabel:new(self.m_Width*0.05, self.m_Height*0.56, self.m_Width*0.4, self.m_Height*0.06, "Rang:", tabGeneral)
	self.m_GroupRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.56, self.m_Width*0.4, self.m_Height*0.06, "-", tabGeneral)
	self.m_GroupMenuButton = GUILabel:new(self.m_Width*0.3, self.m_Height*0.50, self.m_Width*0.135, self.m_Height*0.06, _"(verwalten)", tabGeneral):setColor(Color.LightBlue)
	self.m_GroupMenuButton.onHover = function () self.m_GroupMenuButton:setColor(Color.White) end
	self.m_GroupMenuButton.onUnhover = function () self.m_GroupMenuButton:setColor(Color.LightBlue) end
	self.m_GroupMenuButton.onLeftClick = bind(self.GroupMenuButton_Click, self)
	--self.m_GroupInvitationsLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.8, self.m_Height*0.06, "", tabGeneral)
	--self.m_GroupInvitationsLabel:setVisible(false)

	addRemoteEvents{"groupRetrieveInfo", "groupInvitationRetrieve"}
	addEventHandler("groupRetrieveInfo", root, bind(self.Event_groupRetrieveInfo, self))
	addEventHandler("groupInvitationRetrieve", root, bind(self.Event_groupInvitationRetrieve, self))

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.65, self.m_Width*0.3, self.m_Height*0.10, _"Funktionen", tabGeneral)

	self.m_AdButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.75, self.m_Width*0.27, self.m_Height*0.07, _"Werbung schalten", true, tabGeneral)
	self.m_AdButton.onLeftClick = bind(self.AdButton_Click, self)

	self.m_TicketButton = VRPButton:new(self.m_Width*0.32, self.m_Height*0.75, self.m_Width*0.27, self.m_Height*0.07, _"Tickets", true, tabGeneral)
	self.m_TicketButton.onLeftClick = bind(self.TicketButton_Click, self)

	self.m_WarnButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.83, self.m_Width*0.27, self.m_Height*0.07, _"Warns anzeigen", true, tabGeneral)
	self.m_WarnButton.onLeftClick = function() self:close() WarnManagement:new(localPlayer) end

	self.m_AchievementButton = VRPButton:new(self.m_Width*0.32, self.m_Height*0.83, self.m_Width*0.27, self.m_Height*0.07, _"Achievements", true, tabGeneral)
	self.m_AchievementButton.onLeftClick = bind(self.AchievementButton_Click, self)

	self.m_ObjectOverviewButton = VRPButton:new(self.m_Width*0.62, self.m_Height*0.75, self.m_Width*0.27, self.m_Height*0.07, _"Platzierte Objekte", true, tabGeneral)
	self.m_ObjectOverviewButton.onLeftClick = function()
		triggerServerEvent("requestWorldItemListOfOwner", localPlayer, localPlayer:getPrivateSync("Id"), "player")
		self:close()
	end
	self.m_ShortMessageLog = VRPButton:new(self.m_Width*0.62, self.m_Height*0.83, self.m_Width*0.27, self.m_Height*0.07, _"Benachrichtigungen", true, tabGeneral)
	self.m_ShortMessageLog.onLeftClick = function()
		ShortMessageLogGUI:getSingleton():open()
		self:close()
	end

	-- Tab: Statistics
	local tabStatistics = self.m_TabPanel:addTab(_"Statistiken")
	self.m_TabStatistics = tabStatistics

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.10, _"Statistiken", self.m_TabStatistics)
	self.m_StatDescription = {}
	self.m_StatValue = {}

	self:loadStatistics()

	-- Tab: Vehicles
	local tabVehicles = self.m_TabPanel:addTab(_"Fahrzeuge")
	self.m_TabVehicles = tabVehicles
	self.m_VehiclesLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _("Fahrzeuge: (%d/%d)", 0, 0), tabVehicles)
	self.m_VehiclesGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.65, self.m_Height*0.6, tabVehicles)
	self.m_VehiclesGrid:addColumn(_"Name", 0.4)
	self.m_VehiclesGrid:addColumn(_"Standort", 0.6)
	self.m_VehicleGarages = GUILabel:new(self.m_Width*0.02, self.m_Height*0.75, self.m_Width*0.5, self.m_Height*0.06, _"Garage:", tabVehicles)
	self.m_VehicleGarageUpgradeButton = GUILabel:new(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleGarages:getText(), self.m_VehicleGarages:getFontSize(), self.m_VehicleGarages:getFont()) + 5, self.m_Height*0.75, self.m_Width*0.17, self.m_Height*0.06, _"(Kaufen: 0$)", tabVehicles):setColor(Color.LightBlue)
	self.m_VehicleGarageUpgradeButton.onHover = function () self.m_VehicleGarageUpgradeButton:setColor(Color.White) end
	self.m_VehicleGarageUpgradeButton.onUnhover = function () self.m_VehicleGarageUpgradeButton:setColor(Color.LightBlue) end
	--self.m_VehicleHangar = GUILabel:new(self.m_Width*0.02, self.m_Height*0.81, self.m_Width*0.5, self.m_Height*0.06, _"Hangar:", tabVehicles)
	--self.m_VehicleHangarButton = GUILabel:new(self.m_Width*0.02 + dxGetTextWidth(self.m_VehicleGarages:getText(), self.m_VehicleGarages:getFontSize(), self.m_VehicleGarages:getFont()) + 5, self.m_Height*0.81, self.m_Width*0.17, self.m_Height*0.06, _"(Kaufen: 0$)", tabVehicles):setColor(Color.LightBlue)
	--self.m_VehicleHangarButton.onHover = function () self.m_VehicleHangarButton:setColor(Color.White) end
	--self.m_VehicleHangarButton.onUnhover = function () self.m_VehicleHangarButton:setColor(Color.LightBlue) end
	self.m_VehicleLocateButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.09, self.m_Width*0.28, self.m_Height*0.07, _"Orten", true, tabVehicles)
	self.m_VehicleSellButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.18, self.m_Width*0.28, self.m_Height*0.07, _"an Server verkaufen", true, tabVehicles)
 	GUILabel:new(self.m_Width*0.695, self.m_Height*0.30, self.m_Width*0.28, self.m_Height*0.06, _"Respawnen:", tabVehicles):setColor(Color.LightBlue)
 	self.m_VehicleRespawnButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.37, self.m_Width*0.28, self.m_Height*0.07, _"in Garage", true, tabVehicles)
 	self.m_VehicleWorldRespawnButton = VRPButton:new(self.m_Width*0.695, self.m_Height*0.46, self.m_Width*0.28, self.m_Height*0.07, _"an Parkposition", true, tabVehicles)

	self.m_VehicleGarageUpgradeButton.onLeftClick = bind(self.VehicleGarageUpgradeButton_Click, self)
	--self.m_VehicleHangarButton.onLeftClick = bind(self.VehicleHangarButton_Click, self)
	self.m_VehicleLocateButton.onLeftClick = bind(self.VehicleLocateButton_Click, self)
	self.m_VehicleSellButton.onLeftClick = bind(self.VehicleSellButton_Click, self)
	self.m_VehicleRespawnButton.onLeftClick = bind(self.VehicleRespawnButton_Click, self)
	self.m_VehicleWorldRespawnButton.onLeftClick = bind(self.VehicleWorldRespawnButton_Click, self)
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
	--self.m_KarmaLevelButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.1, self.m_Width*0.15, self.m_Height*0.06, "+ (200P)", tabPoints):setBackgroundColor(Color.Green)
	--self.m_KarmaLevelButton.onLeftClick = function() triggerServerEvent("requestPointsToKarma", resourceRoot, true) end
	--self.m_KarmaLevelButton = GUIButton:new(self.m_Width*0.60, self.m_Height*0.1, self.m_Width*0.15, self.m_Height*0.06, "- (200P)", tabPoints):setBackgroundColor(Color.Red)
	--self.m_KarmaLevelButton.onLeftClick = function() triggerServerEvent("requestPointsToKarma", resourceRoot, false) end

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.06, _"Skinlevel:", tabPoints)
	self.m_SkinLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.18, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getSkinLevel(), tabPoints)
	self.m_SkinLevelButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.18, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_SkinLevelButton.onLeftClick = function() triggerServerEvent("requestSkinLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("SkinLevel", function(value)
		self.m_SkinLevelLabel:setText(_("%d/%d", value, MAX_SKIN_LEVEL))
		if value >= MAX_SKIN_LEVEL then
			self.m_SkinLevelButton:setText("Max. Level"):setEnabled(false)
		else
			self.m_SkinLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())))
		end
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.26, self.m_Width*0.25, self.m_Height*0.06, _"Fahrzeuglevel:", tabPoints)
	self.m_VehicleLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.26, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getVehicleLevel(), tabPoints)
	self.m_VehicleLevelButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.26, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_VehicleLevelButton.onLeftClick = function() triggerServerEvent("requestVehicleLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("VehicleLevel", function(value)
		self.m_VehicleLevelLabel:setText(_("%d/%d", value, MAX_VEHICLE_LEVEL))
		if value >= MAX_VEHICLE_LEVEL then
			self.m_VehicleLevelButton:setText("Max. Level"):setEnabled(false)
		else
			self.m_VehicleLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())))
		end
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.34, self.m_Width*0.25, self.m_Height*0.06, _"Joblevel:", tabPoints)
	self.m_JobLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.34, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getJobLevel(), tabPoints)
	self.m_JobLevelButton = GUIButton:new(self.m_Width*0.45, self.m_Height*0.34, self.m_Width*0.3, self.m_Height*0.06, ("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())), tabPoints):setBackgroundColor(Color.LightBlue)
	self.m_JobLevelButton.onLeftClick = function() triggerServerEvent("requestJobLevelUp", resourceRoot) end
	localPlayer:setPrivateSyncChangeHandler("JobLevel", function(value)
		self.m_JobLevelLabel:setText(_("%d/%d", value, MAX_JOB_LEVEL))
		if value >= MAX_JOB_LEVEL then
			self.m_JobLevelButton:setText("Max. Level"):setEnabled(false)
		else
			self.m_JobLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())))
		end
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.42, self.m_Width*0.25, self.m_Height*0.06, _"Waffenlevel:", tabPoints)
	self.m_WeaponLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.42, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getWeaponLevel(), tabPoints)
	GUILabel:new(self.m_Width*0.45, self.m_Height*0.42, self.m_Width*0.6, self.m_Height*0.06, "Trainiere dein Waffenlevel im LSPD", tabPoints)
	localPlayer:setPrivateSyncChangeHandler("WeaponLevel", function(value)
		self.m_WeaponLevelLabel:setText(_("%d/%d", value, MAX_WEAPON_LEVEL))
	end)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.5, self.m_Width*0.25, self.m_Height*0.06, _"Fischerlevel:", tabPoints)
	self.m_FishingLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.5, self.m_Width*0.4, self.m_Height*0.06, localPlayer:getWeaponLevel(), tabPoints)
	self.m_FishingLevelProgress = GUIProgressBar:new(self.m_Width*.45, self.m_Height*.5, self.m_Width*.3, self.m_Height*.06, tabPoints)
	self.m_FishingLevelStatLabel = GUILabel:new(self.m_Width*0.45, self.m_Height*0.5, self.m_Width*0.3, self.m_Height*0.06, (""):format(), tabPoints):setAlignX("center"):setColor(Color.LightGrey)
	localPlayer:setPrivateSyncChangeHandler("FishingSkill", function(value)
		if localPlayer:getPrivateSync("FishingLevel") < MAX_FISHING_LEVEL then
			self.m_FishingLevelLabel:setText(_("%d/%d", localPlayer:getPrivateSync("FishingLevel"), MAX_FISHING_LEVEL))
			self.m_FishingLevelProgress:setProgress(value/FISHING_LEVELS[localPlayer:getPrivateSync("FishingLevel") + 1]*100)
			self.m_FishingLevelStatLabel:setText(("%s / %s"):format(value, FISHING_LEVELS[localPlayer:getPrivateSync("FishingLevel") + 1]))
		else
			self.m_FishingLevelProgress:hide()
		end
	end)

	-- Tab: Settings
	local tabSettings = self.m_TabPanel:addTab(_"Einstellungen")
	self.m_TabSettings = tabSettings

	self.m_SettingsGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.6, tabSettings)
	self.m_SettingsGrid:addColumn(_"Einstellungen", 1)
	local SettingsTable = {"HUD", "Radar", "Spawn", "Nametag/Reddot", "Texturen", "Fahrzeuge", "Waffen", "Sonstiges"}
	local item
	for index, setting in pairs(SettingsTable) do
		item = self.m_SettingsGrid:addItem(setting)
		item.onLeftClick = function()
			self:onSettingChange(setting)
		end
	end


	self.m_ShaderButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.65, self.m_Width*0.3, self.m_Height*0.07, _"Shadereinstellungen", true, tabSettings)
	self.m_ShaderButton.onLeftClick = bind(self.ShaderButton_Click, self)

	local tourText = Tour:getSingleton():isActive() and _"Servertour beenden" or _"Servertour starten"
	self.m_ServerTour = VRPButton:new(self.m_Width*0.02, self.m_Height*0.73, self.m_Width*0.3, self.m_Height*0.07, tourText, true, tabSettings)
	self.m_ServerTour.onLeftClick = function()
		if not Tour:getSingleton():isActive() then
		QuestionBox:new(
			_("Möchtest du eine Servertour starten? Nach Abschluss erhältst du Erfahrung und eine kleine Belohnung! (Wenn der Mauszeiger nicht aktiv ist, drücke 'B')"),
			function() triggerServerEvent("tourStart", localPlayer, true) end)
			self:close()
		else
			triggerServerEvent("tourStop", localPlayer)
		end
	end
	self.m_ServerTour:setText(Tour:getSingleton():isActive() and _"Servertour beenden" or _"Servertour starten")

	self.m_KeyBindingsButton = VRPButton:new(self.m_Width*0.02, self.m_Height*0.81, self.m_Width*0.3, self.m_Height*0.07, _"Tastenzuordnungen", true, tabSettings)
	self.m_KeyBindingsButton.onLeftClick = bind(self.KeyBindsButton_Click, self)


	--[[ TODO: Do we require this?
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
	--]]


end

function SelfGUI:onShow()
	-- Update VehicleTab
	self:TabPanel_TabChanged(self.m_TabGeneral.TabIndex)
	self:TabPanel_TabChanged(self.m_TabVehicles.TabIndex)

	-- Initialize all the stuff
	if localPlayer:getJobLevel() >= MAX_JOB_LEVEL then
		self.m_JobLevelButton:setText("Max. Level"):setEnabled(false)
	else
		self.m_JobLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getJobLevel())))
	end
	if localPlayer:getSkinLevel() >= MAX_SKIN_LEVEL then
		self.m_SkinLevelButton:setText("Max. Level"):setEnabled(false)
	else
		self.m_SkinLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getSkinLevel())))
	end
	if localPlayer:getVehicleLevel() >= MAX_VEHICLE_LEVEL then
		self.m_VehicleLevelButton:setText("Max. Level"):setEnabled(false)
	else
		self.m_VehicleLevelButton:setText(("+ (%sP)"):format(calculatePointsToNextLevel(localPlayer:getVehicleLevel())))
	end

	local hours, minutes = math.floor(localPlayer:getPlayTime()/60), (localPlayer:getPlayTime() - math.floor(localPlayer:getPlayTime()/60)*60)
	self.m_PlayTimeLabel:setText(_("%s Stunde(n) %s Minute(n)", hours, minutes))
	self.m_AFKTimeLabel:setText(_("%s Minute(n)", math.floor((localPlayer.m_AFKTime + localPlayer.m_CurrentAFKTime)/60/1000)))


	local x, y = self.m_JobNameLabel:getPosition()
	if localPlayer:getJob() then
		self.m_JobNameLabel:setText(localPlayer:getJob():getName())
		self.m_JobQuitButton:setPosition(x + dxGetTextWidth(self.m_JobNameLabel:getText(), self.m_JobQuitButton:getFontSize(), self.m_JobQuitButton:getFont()) + 10, y)
		self.m_JobQuitButton:setVisible(true)
	else
		self.m_JobNameLabel:setText("-")
		self.m_JobQuitButton:setPosition(x + dxGetTextWidth(self.m_JobNameLabel:getText(), self.m_JobQuitButton:getFontSize(), self.m_JobQuitButton:getFont()) + 10, y)
		self.m_JobQuitButton:setVisible(false)
	end
	if localPlayer:getKarma() then
		local karma = localPlayer:getKarma()
		self.m_GeneralKarmaLabel:setText(tostring(karma > 0 and "+"..karma or karma))
	end
	if ShortMessageLogGUI:getSingleton():isVisible() then
		ShortMessageLogGUI:getSingleton():hide()
	end
end

function SelfGUI:onHide()

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

function SelfGUI:loadStatistics()
	local i = 0
	GUILabel:new(self.m_Width*0.02, self.m_Height*(0.11+i*0.06), self.m_Width*0.3, self.m_Height*0.06, _"Spielzeit:", self.m_TabStatistics)
	self.m_PlayTimeLabel = GUILabel:new(self.m_Width*0.4, self.m_Height*0.11, self.m_Width*0.4, self.m_Height*0.06, _"0 Stunde(n) 0 Minute(n)", self.m_TabStatistics)
	i = i+1
	GUILabel:new(self.m_Width*0.02, self.m_Height*(0.11+i*0.06), self.m_Width*0.3, self.m_Height*0.06, _"Aktuelle AFK-Zeit:", self.m_TabStatistics)
	self.m_AFKTimeLabel = GUILabel:new(self.m_Width*0.4, self.m_Height*(0.11+i*0.06), self.m_Width*0.4, self.m_Height*0.06, _"0 Minute(n)", self.m_TabStatistics)
	i = i+1

	local value
	for index, data in pairs(SelfGUI.Stats) do
		value = localPlayer:getStatistics(index) or " - "
		self.m_StatDescription[index] = GUILabel:new(self.m_Width*0.02, self.m_Height*(0.11+i*0.06), self.m_Width*0.3, self.m_Height*0.06, _("%s:", data["text"]), self.m_TabStatistics)
		self.m_StatValue[index] = GUILabel:new(self.m_Width*0.4, self.m_Height*(0.11+i*0.06), self.m_Width*0.4, self.m_Height*0.06, data["value"](value), self.m_TabStatistics)

		localPlayer:setPrivateSyncChangeHandler("Stat_"..index, function(value)
			self.m_StatValue[index]:setText(tostring(data["value"](value)))
		end)

		i = i+1
	end
end

function SelfGUI:Event_companyRetrieveInfo(id, name, rank, __, __, __, rankNames)
	self:adjustGeneralTab(name)

	if name then
		self.m_CompanyNameLabel:setText(name)
		self.m_CompanyRankLabel:setText(rankNames[rank])

		if rank >= 5 then
			self.m_CompanyEditLabel:setText(_"(verwalten)")
		else
			self.m_CompanyEditLabel:setText(_"(anzeigen)")
		end
		local x, y = self.m_CompanyNameLabel:getPosition()
		self.m_CompanyEditLabel:setPosition(x + dxGetTextWidth(self.m_CompanyNameLabel:getText(), self.m_CompanyNameLabel:getFontSize(), self.m_CompanyNameLabel:getFont()) + 10, y)
	else
		self.m_CompanyNameLabel:setText("-")
		self.m_CompanyRankLabel:setText("-")
	end
end

function SelfGUI:JobQuitButton_Click()
	triggerServerEvent("jobQuit", root)
	self.m_JobNameLabel:setText("-")
	self.m_JobQuitButton:setVisible(false)
	localPlayer:giveAchievement(26)
end

function SelfGUI:CompanyMenuButton_Click()
	self:close()
	CompanyGUI:getSingleton():open()
end

function SelfGUI:GroupMenuButton_Click()
	self:close()
	GroupGUI:getSingleton():open()
end

function SelfGUI:FactionMenuButton_Click()
	self:close()
	FactionGUI:getSingleton():open()
end

function SelfGUI:TicketButton_Click()
	self:close()
	TicketGUI:getSingleton():open()
end

function SelfGUI:AdminButton_Click()
	self:close()
	triggerServerEvent("openAdminGUI", localPlayer)
end

function SelfGUI:AchievementButton_Click()
	self:close()
	AchievementGUI:getSingleton():open()
end

function SelfGUI:AdButton_Click()
	self:close()
	AdvertisementBox:getSingleton():open()
end


function SelfGUI:KeyBindsButton_Click()
	self:close()
	KeyBindings:getSingleton():open()
end

function SelfGUI:ShaderButton_Click()
	self:close()
	ShaderPanel:getSingleton():open()
end

function SelfGUI:Event_factionRetrieveInfo(id, name, rank, __, __, __, rankNames)
	if rank then
		local faction = FactionManager:getSingleton():getFromId(id)
		self.m_FactionNameLabel:setText(faction:getName())
		self.m_FactionRankLabel:setText(rankNames[rank])
		self.m_FactionMenuButton:setVisible(true)
		self.m_InvationFactionId = 0

		if rank >= 5 then
			self.m_FactionMenuButton:setText(_"(verwalten)")
		else
			self.m_FactionMenuButton:setText(_"(anzeigen)")
		end
		local x, y = self.m_FactionNameLabel:getPosition()
		self.m_FactionMenuButton:setPosition(x + dxGetTextWidth(self.m_FactionNameLabel:getText(), self.m_FactionNameLabel:getFontSize(), self.m_FactionNameLabel:getFont()) + 10, y)
	else
		self.m_FactionNameLabel:setText(_"- keine Fraktion -")
		self.m_FactionRankLabel:setText("-")
		self.m_FactionMenuButton:setVisible(false)
	end
end

function SelfGUI:Event_factionInvitationRetrieve(factionId, name)
	if factionId > 0 then
		--ShortMessage:new(_("Du wurdest in die Fraktion \"%s\" eingeladen. Einladung im Dashboard!", name))
		Phone:getSingleton():getDashboard():addNotification(name, _("Du wurdest in die Fraktion \"%s\" eingeladen!", name), NOTIFICATION_TYPE_INVATION, bind(self.FactionInvitationsAcceptButton_Click, self, factionId), bind(self.FactionInvitationsDeclineButton_Click, self, factionId))
	end
end

function SelfGUI:FactionInvitationsAcceptButton_Click(factionId)
	if factionId then
		triggerServerEvent("factionInvitationAccept", resourceRoot, factionId)
	end
end

function SelfGUI:FactionInvitationsDeclineButton_Click(factionId)
	if factionId then
		triggerServerEvent("factionInvitationDecline", resourceRoot, factionId)
	end
end

function SelfGUI:Event_CompanyInvitationRetrieve(companyId, name)
	if companyId > 0 then
		--ShortMessage:new(_("Du wurdest in das Unternehmen \"%s\" eingeladen. Einladung im Dashboard!", name))
		Phone:getSingleton():getDashboard():addNotification(name, _("Du wurdest in das Unternehmen  \"%s\" eingeladen!", name), NOTIFICATION_TYPE_INVATION, bind(self.CompanyInvitationsAcceptButton_Click, self, companyId), bind(self.CompanyInvitationsDeclineButton_Click, self, companyId))
	end
end

function SelfGUI:CompanyInvitationsAcceptButton_Click(companyId)
	if companyId then
		triggerServerEvent("companyInvitationAccept", resourceRoot, companyId)
	end
end

function SelfGUI:CompanyInvitationsDeclineButton_Click()
	if companyId then
		triggerServerEvent("companyInvitationDecline", resourceRoot, companyId)
	end
end

function SelfGUI:Event_groupInvitationRetrieve(groupId, name)
	if groupId > 0 then
		Phone:getSingleton():getDashboard():addNotification(name, _("Du wurdest in die Gruppe \"%s\" eingeladen!", name), NOTIFICATION_TYPE_INVATION, bind(self.GroupInvitationsAcceptButton_Click, self, groupId), bind(self.GroupInvitationsDeclineButton_Click, self, groupId))
	end
end

function SelfGUI:GroupInvitationsAcceptButton_Click(groupId)
	if groupId then
		triggerServerEvent("groupInvitationAccept", resourceRoot, groupId)
	end
end

function SelfGUI:GroupInvitationsDeclineButton_Click(groupId)
	if groupId then
		triggerServerEvent("groupInvitationDecline", resourceRoot, groupId)
	end
end


function SelfGUI:Event_groupRetrieveInfo(name, rank, __, __, __, __, rankNames)
	local x, y = self.m_GroupNameLabel:getPosition()
	if rank and rank >= 0 then
		self.m_GroupNameLabel:setText(name)
		self.m_GroupRankLabel:setText(rankNames[tostring(rank)])
		self.m_GroupMenuButton:setVisible(true)
		self.m_HasGroupInvation = false

		if rank >= 5 then
			self.m_GroupMenuButton:setText(_"(verwalten)")
		else
			self.m_GroupMenuButton:setText(_"(anzeigen)")
		end
		self.m_GroupMenuButton:setPosition(x + dxGetTextWidth(name, self.m_GroupNameLabel:getFontSize(), self.m_GroupNameLabel:getFont()) + 10, y)
	else
		self.m_GroupNameLabel:setText(_"- keine Firma/Gang -")
		self.m_GroupRankLabel:setText("-")
		self.m_GroupMenuButton:setVisible(false)
		--self.m_GroupMenuButton:setPosition(x + dxGetTextWidth(_("- keine Firma/Gang -"), self.m_GroupNameLabel:getFontSize(), self.m_GroupNameLabel:getFont()) + 10, y)
	end
end

function SelfGUI:Event_vehicleRetrieveInfo(vehiclesInfo, garageType, hangarType)
	if vehiclesInfo then
		self.m_VehiclesGrid:clear()
		local vehInfo = {}
		for vehicleId, vehicleInfo in pairs(vehiclesInfo) do
			table.insert(vehInfo, {vehicleId, vehicleInfo})
		end
		table.sort(vehInfo, function (a, b) return (a[2][2] < b[2][2]) end)
		for i, vehicleInfo in ipairs(vehInfo) do
			local vehicleId, vehicleInfo = unpack(vehicleInfo)
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
			elseif positionType == VehiclePositionType.Harbor then
				positionType = _"Hafen"
			else
				positionType = _"Unbekannt"
			end
			local item = self.m_VehiclesGrid:addItem(element:getName(), positionType)
			item.VehicleId = vehicleId
			item.VehicleElement = element
			item.PositionType = vehicleInfo[2]
		end
	end

	local max = math.floor(MAX_VEHICLES_PER_LEVEL * localPlayer:getVehicleLevel())
	self.m_VehiclesLabel:setText(_("Fahrzeuge: (%d/%d)", #self.m_VehiclesGrid:getItems() or 0, max or 0))

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

	--[[
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
	]]
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

		if not isVehicleBlown(item.VehicleElement) then
			local x, y, z = getElementPosition(item.VehicleElement)
			local blip = Blip:new("Marker.png", x, y, 9999, {200, 0, 0})
			blip:setZ(z)
		--[[if localPlayer has Item:'Find.dat.Car+' then]] -- TODO: add this item!
				ShortMessage:new(_("Dieses Fahrzeug befindet sich in %s!\n(Klicke hier um das Blip auf der Map zu löschen!)", getZoneName(x, y, z, false)), "Fahrzeugortung", Color.DarkLightBlue, -1, false, false, Vector2(x, y), {{path="Marker.png", pos=Vector2(x, y)}})
					.m_Callback = function (this)
						if blip then
							delete(blip)
						end
						delete(this)
					end
			--else
				--setTimer(function () delete(blip) end, 5000, 1)
			--ShortMessage:new(_("Dieses Fahrzeug befindet sich in %s!\n(Siehe Blip auf der Karte)", getZoneName(x, y, z, false)), "Fahrzeugortung", Color.DarkLightBlue)
		--end
		else ShortMessage:new(_("Dieses Fahrzeug ist zerstört. Respawne es!"))
		end
	elseif item.PositionType == VehiclePositionType.Garage then
 		ShortMessage:new(_"Dieses Fahrzeug befindet sich in deiner Garage!", "Fahrzeugortung", Color.DarkLightBlue)
	elseif item.PositionType == VehiclePositionType.Mechanic then
		ShortMessage:new(_"Dieses Fahrzeug befindet sich im Autohof (Mechanic Base)!", "Fahrzeugortung", Color.DarkLightBlue)
	elseif item.PositionType == VehiclePositionType.Hangar then
		ShortMessage:new(_"Dieses Flugzeug befindet sich im Hangar!", "Fahrzeugortung", Color.DarkLightBlue)
	elseif item.PositionType == VehiclePositionType.Harbor then
		ShortMessage:new(_"Dieses Boot befindet sich im Industrie-Hafen (Logistik-Job)!", "Fahrzeugortung", Color.DarkLightBlue)
	else
		ErrorBox:new(_"Es ist ein interner Fehler aufgetreten!")
	end
end

function SelfGUI:VehicleWorldRespawnButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	triggerServerEvent("vehicleRespawnWorld", item.VehicleElement)
end

function SelfGUI:VehicleRespawnButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	triggerServerEvent("vehicleRespawn", item.VehicleElement, true)
end

function SelfGUI:VehicleSellButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarningBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	triggerServerEvent("vehicleSell", item.VehicleElement)
end

function SelfGUI:addWindow(instance)
	if not table.find(self.m_OpenWindows, instance) then
		table.insert(self.m_OpenWindows, instance)
	end
end

function SelfGUI:removeWindow(instance)
	local idx = table.find(self.m_OpenWindows, instance)
	if idx then
		table.remove(self.m_OpenWindows, idx)
	end
end

function SelfGUI:isBackgroundBlurred()
	return true
end

function SelfGUI:onSettingChange(setting)
	if self.m_SettingBG then delete(self.m_SettingBG) end
	self.m_SettingBG = GUIRectangle:new(self.m_Width*0.34, self.m_Height*0.02, self.m_Width*0.66, self.m_Height*0.96, tocolor(0, 0, 0, 0), self.m_TabSettings)



	if setting == "HUD" then
		GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"HUD / UI", self.m_SettingBG)

		self.m_UICheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.35, self.m_Height*0.04, _"UI aktivieren?", self.m_SettingBG)
		self.m_UICheckBox:setFont(VRPFont(25))
		self.m_UICheckBox:setFontSize(1)
		self.m_UICheckBox:setChecked(core:get("HUD", "showUI", true))
		self.m_UICheckBox.onChange = function (state)
			core:set("HUD", "showUI", state)
			HUDUI:getSingleton():setEnabled(state)
		end

		self.m_ChatCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.15, self.m_Width*0.35, self.m_Height*0.04, _"Chat aktivieren?", self.m_SettingBG)
		self.m_ChatCheckBox:setFont(VRPFont(25))
		self.m_ChatCheckBox:setFontSize(1)
		self.m_ChatCheckBox:setChecked(isChatVisible())
		self.m_ChatCheckBox.onChange = function (state) showChat(state) end

		self.m_HelpBarCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.21, self.m_Width*0.35, self.m_Height*0.04, _"Hilfeleiste", self.m_SettingBG)
		self.m_HelpBarCheckBox:setFont(VRPFont(25))
		self.m_HelpBarCheckBox:setFontSize(1)
		self.m_HelpBarCheckBox:setChecked(core:get("HUD", "showHelpBar", true))
		self.m_HelpBarCheckBox.onChange = function (state)
			core:set("HUD", "showHelpBar", state)
			HelpBar:getSingleton():toggle()
		end

		self.m_BNBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.27, self.m_Width*0.5, self.m_Height*0.04, _"Breaking News-Box (oben links)", self.m_SettingBG)
		self.m_BNBox:setFont(VRPFont(25))
		self.m_BNBox:setFontSize(1)
		self.m_BNBox:setChecked(core:get("HUD", "breakingNewsBox", true))
		self.m_BNBox.onChange = function (state)
			core:set("HUD", "breakingNewsBox", state)
		end

		self.m_BNChat = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.5, self.m_Height*0.04, _"Breaking News im Chat anzeigen", self.m_SettingBG)
		self.m_BNChat:setFont(VRPFont(25))
		self.m_BNChat:setFontSize(1)
		self.m_BNChat:setChecked(core:get("HUD", "breakingNewsInChat", false))
		self.m_BNChat.onChange = function (state)
			core:set("HUD", "breakingNewsInChat", state)
		end

		self.m_Paydaybox_r = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.39, self.m_Width*0.8, self.m_Height*0.04, _"Payday-Box an Bildschirmgröße anpassen", self.m_SettingBG)
			:setFont(VRPFont(25)):setFontSize(1)
		self.m_Paydaybox_r:setChecked(core:get("HUD", "paydayBox_relative", true))
		self.m_Paydaybox_r.onChange = function (state)
			core:set("HUD", "paydayBox_relative", state)
		end

		GUILabel:new(self.m_Width*0.02, self.m_Height*0.53, self.m_Width*0.8, self.m_Height*0.07, _"HUD / Design", self.m_SettingBG)

		local function updateDesignOptions(index)
			self.m_LifeArmor:setVisible(false)
			self.m_HUDScale:setVisible(false)
			self.m_ChartMargin:setVisible(false)
			self.m_ChartBlue:setVisible(false)
			self.m_ChartLabels:setVisible(false)
			self.m_ChartPoints:setVisible(false)
			self.m_ChartZone:setVisible(false)
			self.m_ChartSkin:setVisible(false)
			self.m_ChartHours:setVisible(false)
			if index == UIStyle.vRoleplay then
				self.m_LifeArmor:setVisible(true)
			elseif index == UIStyle.eXo then
				self.m_HUDScale:setVisible(true)
			elseif index == UIStyle.Chart then
				self.m_HUDScale:setVisible(true)
				self.m_ChartMargin:setVisible(true)
				self.m_ChartBlue:setVisible(true)
				self.m_ChartLabels:setVisible(true)
				self.m_ChartPoints:setVisible(true)
				self.m_ChartZone:setVisible(true)
				self.m_ChartSkin:setVisible(true)
				self.m_ChartHours:setVisible(true)
			end
		end

		self.m_UIChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.35, self.m_Height*0.07, self.m_SettingBG) --0.53
		for i, v in ipairs(UIStyle) do
			self.m_UIChange:addItem(v)
		end
		self.m_UIChange.onChange = function(text, index)
			core:set("HUD", "UIStyle", index)
			HUDUI:getSingleton():setUIMode(index)
			updateDesignOptions(index)
		end
		self.m_UIChange:setIndex(core:get("HUD", "UIStyle", UIStyle.Chart), true)

		self.m_LifeArmor = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.04, _"Leben/Weste am HUD", self.m_SettingBG)
		self.m_LifeArmor:setFont(VRPFont(25))
		self.m_LifeArmor:setFontSize(1)
		self.m_LifeArmor:setChecked(core:get("HUD", "defaultHealthArmor", true))
		self.m_LifeArmor.onChange = function (state)
			core:set("HUD", "defaultHealthArmor", state)
			HUDUI:getSingleton():toggleDefaultHealthArmor(state)
		end

		self.m_ChartMargin = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.04, _"Abstand zwischen Balken", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_ChartMargin:setChecked(core:get("HUD", "chartMargin", true))
		self.m_ChartMargin.onChange = function (state) core:set("HUD", "chartMargin", state) end

		self.m_ChartZone = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.76, self.m_Width*0.20, self.m_Height*0.04, _"Zone-Name", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_ChartZone:setChecked(core:get("HUD", "chartZoneVisible", true))
		self.m_ChartZone.onChange = function (state) core:set("HUD", "chartZoneVisible", state) end

		self.m_ChartSkin = GUICheckbox:new(self.m_Width*0.22, self.m_Height*0.76, self.m_Width*0.15, self.m_Height*0.04, _"Passbild", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_ChartSkin:setChecked(core:get("HUD", "chartSkinVisible", false))
		self.m_ChartSkin.onChange = function (state) core:set("HUD", "chartSkinVisible", state) end

		self.m_ChartBlue = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.82, self.m_Width*0.35, self.m_Height*0.04, _"blaues Farbschema", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_ChartBlue:setChecked(core:get("HUD", "chartColorBlue", false))
		self.m_ChartBlue.onChange = function (state) core:set("HUD", "chartColorBlue", state) end

		self.m_ChartLabels = GUICheckbox:new(self.m_Width*0.4, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.04, _"Beschriftungen", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_ChartLabels:setChecked(core:get("HUD", "chartLabels", true))
		self.m_ChartLabels.onChange = function (state) core:set("HUD", "chartLabels", state) end

		self.m_ChartPoints = GUICheckbox:new(self.m_Width*0.4, self.m_Height*0.76, self.m_Width*0.35, self.m_Height*0.04, _"Punkte / Level", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_ChartPoints:setChecked(core:get("HUD", "chartPointLevelVisible", true))
		self.m_ChartPoints.onChange = function (state) core:set("HUD", "chartPointLevelVisible", state) end

		self.m_ChartHours = GUICheckbox:new(self.m_Width*0.4, self.m_Height*0.82, self.m_Width*0.35, self.m_Height*0.04, _"Spielstunden", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_ChartHours:setChecked(core:get("HUD", "chartPlaytimeVisible", false))
		self.m_ChartHours.onChange = function (state) core:set("HUD", "chartPlaytimeVisible", state) end

		self.m_HUDScale = GUIHorizontalScrollbar:new(self.m_Width*0.4, self.m_Height*0.6, self.m_Width*0.25, self.m_Height*0.07, self.m_SettingBG)
		self.m_HUDScale:setScrollPosition( core:get("HUD","scaleScroll",0.75))
		self.m_HUDScale:setColor(Color.LightBlue)
		self.m_HUDScale:setText(_"HUD-Skalierung")

		local oldScale = 0.75
		self.m_HUDScale.onScroll = function()
			local scale = math.round(self.m_HUDScale:getScrollPosition(), 2);
			if scale ~= oldScale then
				HUDUI:getSingleton():setScale( scale );
				oldScale = scale
				core:set("HUD","scaleScroll",scale*0.75)
			end
		end

		updateDesignOptions(core:get("HUD", "UIStyle", UIStyle.Chart)) --only show items which are relevant for current UI

	elseif setting == "Radar" then

		local function updateDesignOptions(disable)
			local enabled = core:get("HUD", "showRadar", true) and not core:get("HUD", "GWRadar", false)
			self.m_BarsEnabled:setEnabled(enabled)
			self.m_ZoneName:setEnabled(enabled)
			if disable then
				self.m_RadarGWCheckBox:setEnabled(core:get("HUD", "showRadar", false))
			end
		end

		GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"HUD / Radar, Übersichtskarte", self.m_SettingBG)
		self.m_RadarChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.35, self.m_Height*0.07, self.m_SettingBG)
		for i, v in ipairs(RadarDesign) do
			self.m_RadarChange:addItem(v)
		end
		self.m_RadarChange.onChange = function(text, index)
			HUDRadar:getSingleton():setDesignSet(index)
		end
		local currentRadarIndex = core:get("HUD", "RadarDesign") or 1
		self.m_RadarChange.onChange("", currentRadarIndex)
		self.m_RadarChange:setIndex(currentRadarIndex, true)
		--0.09
		--0.06

		self.m_RadarCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.19, self.m_Width*0.35, self.m_Height*0.04, _"Radar aktivieren", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_RadarCheckBox:setChecked(core:get("HUD", "showRadar", true))
		self.m_RadarCheckBox.onChange = function (state)
			core:set("HUD", "showRadar", state)
			HUDRadar:getSingleton():setEnabled(state)
			updateDesignOptions(true)
		end

		self.m_RadarGWCheckBox = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.25, self.m_Width*0.5, self.m_Height*0.04, _"Standard-Radar (für Gangwar)", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_RadarGWCheckBox:setChecked(core:get("HUD", "GWRadar", false))
		self.m_RadarGWCheckBox.onChange = function (state)
			core:set("HUD", "GWRadar", state)
			HUDRadar:getSingleton():updateRadarType(state)
			updateDesignOptions()
		end

		self.m_BlipScale = GUIHorizontalScrollbar:new(self.m_Width*0.02, self.m_Height*0.31, self.m_Width*0.35, self.m_Height*0.07, self.m_SettingBG)
		self.m_BlipScale:setScrollPosition( core:get("HUD","blipScale", 1) - 0.5)
		self.m_BlipScale:setColor(Color.LightBlue)
		self.m_BlipScale:setText(_"Blipgröße")
		local oldScale = 0.5
		self.m_BlipScale.onScroll = function()
			local scale = math.round(self.m_BlipScale:getScrollPosition(), 2)
			if scale ~= oldScale then
				Blip.setScaleMultiplier(scale)
				oldScale = scale
			end
		end

		self.m_ColoredBlips = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.40, self.m_Width*0.35, self.m_Height*0.04, _"bunte Blips", self.m_SettingBG)
		self.m_ColoredBlips:setFont(VRPFont(25))
		self.m_ColoredBlips:setFontSize(1)
		self.m_ColoredBlips:setChecked(core:get("HUD", "coloredBlips", true))
		self.m_ColoredBlips.onChange = function (state)
			core:set("HUD", "coloredBlips", state)
		end

		self.m_ZoneName = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.46, self.m_Width*0.35, self.m_Height*0.04, _"Zone-Name im Radar", self.m_SettingBG)
		self.m_ZoneName:setFont(VRPFont(25))
		self.m_ZoneName:setFontSize(1)
		self.m_ZoneName:setChecked(core:get("HUD", "drawZone", true))
		self.m_ZoneName.onChange = function (state)
			core:set("HUD", "drawZone", state)
		end

		self.m_BarsEnabled = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.52, self.m_Width*0.5, self.m_Height*0.04, _"Statusleisten unter dem Radar", self.m_SettingBG)
		self.m_BarsEnabled:setFont(VRPFont(25))
		self.m_BarsEnabled:setFontSize(1)
		self.m_BarsEnabled:setChecked(core:get("HUD", "drawStatusBars", false))
		self.m_BarsEnabled.onChange = function (state)
			core:set("HUD", "drawStatusBars", state)
			HUDRadar:getSingleton():toggleStatusBars(state)
		end

		self.m_MapOpacity = GUIHorizontalScrollbar:new(self.m_Width*0.02, self.m_Height*0.58, self.m_Width*0.35, self.m_Height*0.07, self.m_SettingBG)
		self.m_MapOpacity:setScrollPosition(core:get("HUD","mapOpacity", 0.7))
		self.m_MapOpacity:setColor(Color.LightBlue)
		self.m_MapOpacity:setText(_"Karten-Transparenz")
		local oldScale = 0.7
		self.m_MapOpacity.onScroll = function()
			local scale = math.round(self.m_MapOpacity:getScrollPosition(), 2)
			if scale ~= oldScale then
				oldScale = scale
				core:set("HUD","mapOpacity", scale)
			end
		end

		updateDesignOptions(not core:get("HUD", "showRadar", true))
	elseif setting == "Spawn" then
		GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"Spawn", self.m_SettingBG)

		self.m_Default = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.35, self.m_Height*0.04, _"Letzter Standort", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_Noobspawn = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.17, self.m_Width*0.35, self.m_Height*0.04, _"Usertreff", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_FactionBase = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.24, self.m_Width*0.35, self.m_Height*0.04, _"Fraktionsbase", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_CompanyBase = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.31, self.m_Width*0.35, self.m_Height*0.04, _"Unternehmensbase", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_House = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.38, self.m_Width*0.35, self.m_Height*0.04, _"Haus", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)
		self.m_Vehicle = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.45, self.m_Width*0.35, self.m_Height*0.04, _"Wohnwagen/Boot", self.m_SettingBG):setFont(VRPFont(25)):setFontSize(1)

		self.m_FactionBase:setEnabled(localPlayer:getFaction() and true or false)
		self.m_CompanyBase:setEnabled(localPlayer:getCompany() and true or false)
		self.m_House:setEnabled(false)
		self.m_Vehicle:setEnabled(false)

		local SpawnIDToCheckbox = {[0] = self.m_Default, [1] = self.m_Noobspawn, [3] = self.m_FactionBase, [4] = self.m_CompanyBase, [5] = self.m_House, [6] = self.m_Vehicle}
		local uncheckAll = function() for _, checkbox in pairs(SpawnIDToCheckbox) do checkbox:setChecked(false) end end

		SpawnIDToCheckbox[localPlayer:getPrivateSync("SpawnLocation")]:setChecked(true)

		self.m_Default.onChange = function() uncheckAll() self.m_Default:setChecked(true) triggerServerEvent("onPlayerUpdateSpawnLocation", localPlayer, SPAWN_LOCATIONS.DEFAULT) end
		self.m_Noobspawn.onChange = function() uncheckAll() self.m_Noobspawn:setChecked(true) triggerServerEvent("onPlayerUpdateSpawnLocation", localPlayer, SPAWN_LOCATIONS.NOOBSPAWN) end
		self.m_FactionBase.onChange = function() uncheckAll() self.m_FactionBase:setChecked(true) triggerServerEvent("onPlayerUpdateSpawnLocation", localPlayer, SPAWN_LOCATIONS.FACTION_BASE) end
		self.m_CompanyBase.onChange = function() uncheckAll() self.m_CompanyBase:setChecked(true) triggerServerEvent("onPlayerUpdateSpawnLocation", localPlayer, SPAWN_LOCATIONS.COMPANY_BASE) end

		GUILabel:new(self.m_Width*0.02, self.m_Height*0.55, self.m_Width*0.7, self.m_Height*0.055, _"Nutze das Klicksystem bzw. das Hausmenü um den Spawnpunkt für ein Fahrzeug oder Haus festzulegen!", self.m_SettingBG)
	elseif setting == "Nametag/Reddot" then
		GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"Nametag", self.m_SettingBG)
		self.m_NametagChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.35, self.m_Height*0.07, self.m_SettingBG)
		self.m_NametagChange:addItem("An")
		self.m_NametagChange:addItem("Aus")
		self.m_NametagChange.onChange = function(text, index)
			core:set("HUD", "NametagStyle", index)
			if index == NametagStyle.Off then
				delete(Nametag:getSingleton())
			elseif index == NametagStyle.On then
				Nametag:new()
			end
		end
		self.m_NametagChange:setIndex(core:get("HUD", "NametagStyle", NametagStyle.On), true)

		self.m_Reddot = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.19, self.m_Width*0.35, self.m_Height*0.04, _"Rotpunkt aktivieren?", self.m_SettingBG)
		self.m_Reddot:setFont(VRPFont(25))
		self.m_Reddot:setFontSize(1)
		self.m_Reddot:setChecked(core:get("HUD", "reddot", false))
		self.m_Reddot.onChange = function (state)
			core:set("HUD", "reddot", state)
			HUDUI:getSingleton():toggleReddot(state)
		end
	elseif setting == "Texturen" then
		GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.9, self.m_Height*0.07, _"Fahrzeug-Textur Modus", self.m_SettingBG)
		self.m_TextureModeChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.55, self.m_Height*0.07, self.m_SettingBG)
		self.m_TextureModeChange:addItem("In der Nähe laden")
		self.m_TextureModeChange:addItem("Beim Joinen laden")
		self.m_TextureModeChange:addItem("Deaktiviert")
		self.m_TextureModeChange.onChange = function(text, index)
			core:set("Other", "TextureMode", index)
			self.m_InfoLabel:setText(_(TEXTURE_SYSTEM_HELP[index]))
			nextframe(function () TextureReplacer.changeLoadingMode(index) end)
		end

		self.m_InfoLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.19, self.m_Width*0.6, self.m_Height*0.055, _"", self.m_SettingBG)

		local currentMode = core:get("Other", "TextureMode", 1)
		self.m_TextureModeChange:setIndex(currentMode, true)
		self.m_InfoLabel:setText(_(TEXTURE_SYSTEM_HELP[currentMode]))
	elseif setting == "Sonstiges" then
		GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"Cursor Modus", self.m_SettingBG)
		self.m_RadarChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.35, self.m_Height*0.07, self.m_SettingBG)
		self.m_RadarChange:addItem("Normal")
		self.m_RadarChange:addItem("Instant")
		self.m_RadarChange.onChange = function(text, index)
			core:set("HUD", "CursorMode", index - 1)
			Cursor:setCursorMode(toboolean(index - 1))
		end
		self.m_RadarChange:setIndex(core:get("HUD", "CursorMode", 0) + 1, true)

		GUILabel:new(self.m_Width*0.02, self.m_Height*0.19, self.m_Width*0.8, self.m_Height*0.07, _"Sonstiges", self.m_SettingBG)

		self.m_SkinSpawn = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.26, self.m_Width*0.8, self.m_Height*0.04, _"Mit Fraktionsskin spawnen", self.m_SettingBG)
		self.m_SkinSpawn:setFont(VRPFont(25))
		self.m_SkinSpawn:setFontSize(1)
		self.m_SkinSpawn:setChecked(core:get("HUD", "spawnFactionSkin", true))
		self.m_SkinSpawn.onChange = function (bool)
			core:set("HUD", "spawnFactionSkin", bool)
			triggerServerEvent("switchSpawnWithFactionSkin",localPlayer, bool)
		end

		self.m_ShortMessageCTC = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.4, self.m_Height*0.04, _"ShortMessage-CTC aktivieren", self.m_SettingBG)
		self.m_ShortMessageCTC:setFont(VRPFont(25))
		self.m_ShortMessageCTC:setFontSize(1)
		self.m_ShortMessageCTC:setChecked(core:get("HUD", "shortMessageCTC", false))
		self.m_ShortMessageCTC.onChange = function (state)
			core:set("HUD", "shortMessageCTC", state)
		end

		self.m_ShortMessageCTCInfo = GUILabel:new(self.m_Width*0.42, self.m_Height*0.325, self.m_Width*0.03, self.m_Height*0.04, "(?)", self.m_SettingBG)
		self.m_ShortMessageCTCInfo:setFont(VRPFont(25))
		self.m_ShortMessageCTCInfo:setFontSize(1)
		self.m_ShortMessageCTCInfo:setColor(Color.LightBlue)
		self.m_ShortMessageCTCInfo.onHover = function () self.m_ShortMessageCTCInfo:setColor(Color.White) end
		self.m_ShortMessageCTCInfo.onUnhover = function () self.m_ShortMessageCTCInfo:setColor(Color.LightBlue) end
		self.m_ShortMessageCTCInfo.onLeftClick = function ()
			ShortMessage:new(_(HelpTexts.Settings.ShortMessageCTC), _(HelpTextTitles.Settings.ShortMessageCTC), nil, 25000)
		end

		self.m_HallelujaSound = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.40, self.m_Width*0.9, self.m_Height*0.04, _"Halleluja-Sound beim sterben", self.m_SettingBG)
		self.m_HallelujaSound:setFont(VRPFont(25))
		self.m_HallelujaSound:setFontSize(1)
		self.m_HallelujaSound:setChecked(core:get("Other", "HallelujaSound", true))
		self.m_HallelujaSound.onChange = function (state)
			core:set("Other", "HallelujaSound", state)
		end

		self.m_HitSound = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.47, self.m_Width*0.9, self.m_Height*0.04, _"Sound beim Treffen eines Spielers", self.m_SettingBG)
		self.m_HitSound:setFont(VRPFont(25))
		self.m_HitSound:setFontSize(1)
		self.m_HitSound:setChecked(core:get("Other", "HitSoundBell", true))
		self.m_HitSound.onChange = function (state)
			core:set("Other", "HitSoundBell", state)
		end

		--	self.m_StartIntro = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.47, self.m_Width*0.35, self.m_Height*0.04, _"Zeitbildschirm am Login", self.m_SettingBG)
		--	self.m_StartIntro:setFont(VRPFont(25))
		--	self.m_StartIntro:setFontSize(1)
		--	self.m_StartIntro:setChecked(core:get("HUD", "startScreen", true))
		--	self.m_StartIntro.onChange = function (state)
		--		core:set("HUD", "startScreen", state)
		--	end
	elseif setting == "Waffen" then
		GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"Welche Waffen sollen attached werden", self.m_SettingBG)

		self.m_UIMelee = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.12, self.m_Width*0.35, self.m_Height*0.04, _"Nahkampfwaffen", self.m_SettingBG)
		self.m_UIMelee:setFont(VRPFont(25))
		self.m_UIMelee:setFontSize(1)
		self.m_UIMelee:setChecked(core:get("W_ATTACH", "weapon0", true))
		setElementData(localPlayer,"W_A:w0", core:get("W_ATTACH", "weapon0", true))
		self.m_UIMelee.onChange = function (state)
			core:set("W_ATTACH", "weapon0", state)
			setElementData(localPlayer,"W_A:w0", state)
			triggerEvent("Weapon_Attach:recheckWeapons", localPlayer, 1)
		end

		self.m_UIPistols = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.19, self.m_Width*0.35, self.m_Height*0.04, _"Deagle/Pistole/Taser", self.m_SettingBG)
		self.m_UIPistols:setFont(VRPFont(25))
		self.m_UIPistols:setFontSize(1)
		self.m_UIPistols:setChecked(core:get("W_ATTACH", "weapon1", true))
		setElementData(localPlayer,"W_A:w1", core:get("W_ATTACH", "weapon1", true))
		self.m_UIPistols.onChange = function (state)
			core:set("W_ATTACH", "weapon1", state)
			setElementData(localPlayer,"W_A:w1", state)
			triggerEvent("Weapon_Attach:recheckWeapons", localPlayer, 2)
		end

		self.m_UIShotgun = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.26, self.m_Width*0.35, self.m_Height*0.04, _"Schrotflinten", self.m_SettingBG)
		self.m_UIShotgun:setFont(VRPFont(25))
		self.m_UIShotgun:setFontSize(1)
		self.m_UIShotgun:setChecked(core:get("W_ATTACH", "weapon2", true))
		setElementData(localPlayer,"W_A:w2", core:get("W_ATTACH", "weapon2", true))
		self.m_UIShotgun.onChange = function (state)
			core:set("W_ATTACH", "weapon2", state)
			setElementData(localPlayer,"W_A:w2", state)
			triggerEvent("Weapon_Attach:recheckWeapons", localPlayer, 3)
		end

		self.m_UISMG = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.35, self.m_Height*0.04, _"Mp5", self.m_SettingBG)
		self.m_UISMG:setFont(VRPFont(25))
		self.m_UISMG:setFontSize(1)
		self.m_UISMG:setChecked(core:get("W_ATTACH", "weapon3", true))
		setElementData(localPlayer,"W_A:w3", core:get("W_ATTACH", "weapon3", true))
		self.m_UISMG.onChange = function (state)
			core:set("W_ATTACH", "weapon3", state)
			setElementData(localPlayer,"W_A:w3", state)
			triggerEvent("Weapon_Attach:recheckWeapons", localPlayer, 4)
		end

		self.m_UISMG = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.35, self.m_Height*0.04, _"Mac-10/Tec-9", self.m_SettingBG)
		self.m_UISMG:setFont(VRPFont(25))
		self.m_UISMG:setFontSize(1)
		self.m_UISMG:setChecked(core:get("W_ATTACH", "weapon4", true))
		setElementData(localPlayer,"W_A:w4", core:get("W_ATTACH", "weapon4", true))
		self.m_UISMG.onChange = function (state)
			core:set("W_ATTACH", "weapon4", state)
			setElementData(localPlayer,"W_A:w4", state)
			triggerEvent("Weapon_Attach:recheckWeapons", localPlayer, 4)
		end

		self.m_UIKarabiner = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.47, self.m_Width*0.35, self.m_Height*0.04, _"M4/AK-47", self.m_SettingBG)
		self.m_UIKarabiner:setFont(VRPFont(25))
		self.m_UIKarabiner:setFontSize(1)
		self.m_UIKarabiner:setChecked(core:get("W_ATTACH", "weapon5", true))
		setElementData(localPlayer,"W_A:w5", core:get("W_ATTACH", "weapon5", true))
		self.m_UIKarabiner.onChange = function (state)
			core:set("W_ATTACH", "weapon5", state)
			setElementData(localPlayer,"W_A:w5", state)
			triggerEvent("Weapon_Attach:recheckWeapons", localPlayer, 5)
		end

		self.m_UIRifle = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.54, self.m_Width*0.35, self.m_Height*0.04, _"Country-Rifle", self.m_SettingBG)
		self.m_UIRifle:setFont(VRPFont(25))
		self.m_UIRifle:setFontSize(1)
		self.m_UIRifle:setChecked(core:get("W_ATTACH", "weapon6", true))
		setElementData(localPlayer,"W_A:w6", core:get("W_ATTACH", "weapon6", true))
		self.m_UIRifle.onChange = function (state)
			core:set("W_ATTACH", "weapon6", state)
			setElementData(localPlayer,"W_A:w6", state)
			triggerEvent("Weapon_Attach:recheckWeapons", localPlayer, 6)
		end


		self.m_UIAltKarabiner = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.68, self.m_Width*0.35, self.m_Height*0.04, _"Ak-47/M4 im Holster", self.m_SettingBG)
		self.m_UIAltKarabiner:setFont(VRPFont(25))
		self.m_UIAltKarabiner:setFontSize(1)
		self.m_UIAltKarabiner:setChecked(core:get("W_ATTACH", "alt_w5holst", false))
		setElementData(localPlayer,"W_A:alt_w5", core:get("W_ATTACH", "alt_w5holst", false))
		if core:get("W_ATTACH", "alt_w5holst", false) then triggerEvent("Weapon_Attach:recheckWeapons", localPlayer,5) end
		self.m_UIAltKarabiner.onChange = function (state)
			core:set("W_ATTACH",  "alt_w5holst", state)
			setElementData(localPlayer,"W_A:alt_w5", state)
			triggerEvent("Weapon_Attach:recheckWeapons", localPlayer,5)
		end
	elseif setting == "Fahrzeuge" then
		GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"Fahrzeuge", self.m_SettingBG)

		self.m_Indicators = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.12, self.m_Width*0.35, self.m_Height*0.04, _"Blinker", self.m_SettingBG)
			:setFont(VRPFont(25)):setFontSize(1)
		self.m_Indicators:setChecked(core:get("Vehicles", "Indicators", true))
		self.m_Indicators.onChange = function (bool)
			core:set("Vehicles", "Indicators", bool)
			Indicator:getSingleton():toggle()
		end

		self.m_Neon = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.19, self.m_Width*0.35, self.m_Height*0.04, _"Unterbodenbeleuchtung", self.m_SettingBG)
			:setFont(VRPFont(25)):setFontSize(1)
		self.m_Neon:setChecked(core:get("Vehicles", "Neon", true))
		self.m_Neon.onChange = function (bool)
			core:set("Vehicles", "Neon", bool)
			Neon.toggle(bool)
		end

		self.m_ELS = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.26, self.m_Width*0.35, self.m_Height*0.04, _"Rundumleuchten (ELS)", self.m_SettingBG)
			:setFont(VRPFont(25)):setFontSize(1)
		self.m_ELS:setChecked(core:get("Vehicles", "ELS", true))
		self.m_ELS.onChange = function (bool)
			core:set("Vehicles", "ELS", bool)
			ELSSystem:getSingleton():toggle(bool)
		end

		self.mCustomHorn = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.33, self.m_Width*0.35, self.m_Height*0.04, _"Spezialhupe", self.m_SettingBG)
			:setFont(VRPFont(25)):setFontSize(1)
		self.mCustomHorn:setChecked(core:get("Vehicles", "customHorn", true))
		self.mCustomHorn.onChange = function (bool)
			core:set("Vehicles", "customHorn", bool)
			if bool then
				for i,v in pairs(getElementsByType("vehicle", true)) do
					if v.m_HornSound then
						setSoundVolume(v.m_HornSound, 1)
					end
				end
			else
				for i,v in pairs(getElementsByType("vehicle", true)) do
					if v.m_HornSound then
						setSoundVolume(v.m_HornSound, 0)
					end
				end
			end
		end

		self.m_SeatbeltWarning = GUICheckbox:new(self.m_Width*0.02, self.m_Height*0.40, self.m_Width*0.35, self.m_Height*0.04, _"Warnton bei offnem Gurt", self.m_SettingBG)
			:setFont(VRPFont(25)):setFontSize(1)
		self.m_SeatbeltWarning:setChecked(core:get("Vehicles", "seatbeltWarning", true))
		self.m_SeatbeltWarning.onChange = function (bool)
			core:set("Vehicles", "seatbeltWarning", bool)
		end

	end
end
