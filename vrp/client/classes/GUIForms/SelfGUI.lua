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
	self.m_CloseButton.onLeftClick = function() self:hide() end
	
	-- Tab: Info
	local tabInfo = self.m_TabPanel:addTab(_"Allgemein")
	-- Todo: Job
	-- Todo: Achievements
	
	-- Tab: Job
	local tabJob = self.m_TabPanel:addTab(_"Job")
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Aktueller Job:", tabJob)
	self.m_JobNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabJob)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.06, _"Level:", tabJob)
	self.m_JobLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.06, "1", tabJob) -- Todo
	self.m_JobQuitButton = GUIButton:new(self.m_Width*0.02, self.m_Height * 0.4, self.m_Width*0.35, self.m_Height*0.07, _"Job kündigen", tabJob):setBackgroundColor(Color.Red)
	
	self.m_JobQuitButton.onLeftClick = bind(self.JobQuitButton_Click, self)
	
	-- Tab: Groups
	local tabGroups = self.m_TabPanel:addTab(_"Gruppen")
	self.m_TabGroups = tabGroups
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Gruppe:", tabGroups)
	self.m_GroupsNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.06, _"Gruppenrang:", tabGroups)
	self.m_GroupsRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupCreateButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Erstellen", true, tabGroups):setBarColor(Color.Green)
	self.m_GroupQuitButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.07, _"Verlassen", true, tabGroups):setBarColor(Color.Red)
	self.m_GroupDeleteButton = VRPButton:new(self.m_Width*0.74, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.07, _"Löschen", true, tabGroups):setBarColor(Color.Red)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.05, _"Kasse:", tabGroups)
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
	self.m_VehicleGarages = GUILabel:new(self.m_Width*0.02, self.m_Height*0.75, self.m_Width*0.5, self.m_Height*0.06, _"Garage: Luxus Garage (10 Slots)", tabVehicles)
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
	
	-- Tab: Settings
	local tabSettings = self.m_TabPanel:addTab(_"Einstellungen")
	self.m_TabSettings = tabSettings
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.8, self.m_Height*0.07, _"HUD und Nametag", tabSettings)
	self.m_RadarChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.35, self.m_Height*0.07, tabSettings)
	self.m_RadarChange:addItem(_"Monochrom")
	self.m_RadarChange:addItem(_"GTA:SA")
	self.m_RadarChange.onChange = function(text, index) HUDRadar:getSingleton():setDesignSet(index) end
	self.m_RadarChange:setIndex(core:getConfig():get("HUD", "RadarDesign") or 1, true)
end

function SelfGUI:onShow()
	-- Initialize all the stuff
	if localPlayer:getJob() then
		self.m_JobNameLabel:setText(localPlayer:getJob():getName())
		self.m_JobLevelLabel:setText("1") -- Todo
	else
		self.m_JobNameLabel:setText("-")
		self.m_JobLevelLabel:setText("-") -- Todo
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
	self.m_JobLevelLabel:setText("-")
end

function SelfGUI:Event_groupRetrieveInfo(name, rank, money, players)
	self:adjustGroupTab(rank or false)
	
	if name then
		self.m_GroupsNameLabel:setText(name)
		self.m_GroupsRankLabel:setText(tostring(rank))
		self.m_GroupMoneyLabel:setText(tostring(money).."$")
		
		self.m_GroupPlayersGrid:clear()
		for playerId, info in pairs(players) do
			local item = self.m_GroupPlayersGrid:addItem(info.name, info.rank)
			item.Id = playerId
		end
	end
end

function SelfGUI:Event_groupInvitationRetrieve(groupId, name)
	ShortMessage:new(_("Du wurdest in die Gruppe '%s' eingeladen. Öffne dein Handy, um die Einladung anzunehmen", name))
	Phone:getSingleton():getAppByClass(AppDashboard):addNotification(
		_("Möchtest du die Einladung der Gruppe %s annehmen?", name),
		function()
			triggerServerEvent("groupInvitationAccept", root, groupId)
		end,
		function()
			triggerServerEvent("groupInvitationDecline", root, groupId)
		end
	)
end

function SelfGUI:adjustGroupTab(rank)
	local isInGroup = rank ~= false
	
	for k, element in ipairs(self.m_TabGroups:getChildren()) do
		if element ~= self.m_GroupCreateButton then
			element:setVisible(isInGroup)
		end
	end
	
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

function SelfGUI:Event_vehicleRetrieveInfo(vehiclesInfo, garageType)
	if vehiclesInfo then
		self.m_VehiclesGrid:clear()
		for vehicleId, vehicleInfo in pairs(vehiclesInfo) do
			local element, inGarage = unpack(vehicleInfo)
			local x, y, z = getElementPosition(element)
			local item = self.m_VehiclesGrid:addItem(getVehicleName(element), inGarage and _"Garage" or getZoneName(x, y, z, false))
			item.VehicleId = vehicleId
			item.VehicleElement = element
			item.VehicleInGarage = inGarage
		end
	end
	if garageType then
		local texts = {[1] = _"Garage: Standard Garage (3 Slots)", [2] = _"Garage: Komfortable Garage (6 Slots)", [3] = _"Garage: Luxus Garage (10 Slots)"}
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
		WarnungBox:new(_"Bitte wähle ein Fahrzeug aus!")
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
		WarnungBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	
	triggerServerEvent("vehicleRespawn", item.VehicleElement)
end

function SelfGUI:VehicleSellButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		WarnungBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	
	triggerServerEvent("vehicleSell", item.VehicleElement)
end
