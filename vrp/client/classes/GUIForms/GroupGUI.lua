-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupGUI.lua
-- *  PURPOSE:     Group GUI class
-- *
-- ****************************************************************************
GroupGUI = inherit(GUIForm)
inherit(Singleton, GroupGUI)

function GroupGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-312.5, screenHeight/2-230, 625, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:close() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBarEnabled(false):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	-- Tab: Groups
	local tabGroups = self.m_TabPanel:addTab(_"Allgemein")
	self.m_TabGroups = tabGroups
	self.m_TypeLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Firma / Gang:", tabGroups)
	self.m_GroupsNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupsNameChangeLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.1, self.m_Height*0.06, _"(ändern)", tabGroups):setColor(Color.LightBlue)
	self.m_GroupsNameChangeLabel.onLeftClick = function()
		InputBox:new(_"Namen ändern", _("Bitte gib einen neuen Name für deine Firma / Gang ein! Dies kostet dich %d$!", GROUP_RENAME_COSTS), function (name) triggerServerEvent("groupChangeName", root, name) end)
		WarningBox:new(_"Achtung: Der Name ist nur alle 30 Tage änderbar!")
	end
	self.m_GroupsNameChangeLabel.onHover = function () self.m_GroupsNameChangeLabel:setColor(Color.White) end
	self.m_GroupsNameChangeLabel.onUnhover = function () self.m_GroupsNameChangeLabel:setColor(Color.LightBlue) end
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.06, _"Karma:", tabGroups)
	self.m_GroupsKarmaLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.14, self.m_Width*0.25, self.m_Height*0.06, _"Dein Rang:", tabGroups)
	self.m_GroupsRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.14, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupCreateLabel = GUILabel:new(self.m_Width*0.45, self.m_Height*0.14, self.m_Width*0.5, self.m_Height*0.06, _"Du kannst in der Stadthalle eine neue Firma oder Gang gründen!", tabGroups):setMultiline(true)
	self.m_GroupQuitButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.1, self.m_Width*0.3, self.m_Height*0.07, _"Verlassen", tabGroups):setBackgroundColor(Color.Red):setBarEnabled(true)
	self.m_GroupDeleteButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.18, self.m_Width*0.3, self.m_Height*0.07, _"Löschen", tabGroups):setBackgroundColor(Color.Red):setBarEnabled(true)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, _"Kasse:", tabGroups)
	self.m_GroupMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, "", tabGroups)
	--self.m_GroupMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.27, self.m_Height*0.07, tabGroups):setCaption(_"Betrag")
	--self.m_GroupMoneyDepositButton = GUIButton:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", tabGroups):setBarEnabled(true)
	--self.m_GroupMoneyWithdrawButton = GUIButton:new(self.m_Width*0.56, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", tabGroups):setBarEnabled(true)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.3, self.m_Width*0.25, self.m_Height*0.06, _"Payday:", tabGroups)
	self.m_GroupPayDayLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.3, self.m_Width*0.25, self.m_Height*0.06, "test", tabGroups)
	self.m_GroupPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.5, self.m_Height*0.5, tabGroups)
	self.m_GroupPlayersGrid:addColumn(_"", 0.06)
	self.m_GroupPlayersGrid:addColumn(_"Spieler", 0.49)
	self.m_GroupPlayersGrid:addColumn(_"Rang", 0.18)
	self.m_GroupPlayersGrid:addColumn(_"Aktivität", 0.27)

	self.m_GroupAddPlayerButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.4, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", tabGroups):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_GroupRemovePlayerButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.48, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", tabGroups):setBackgroundColor(Color.Red):setBarEnabled(true)
	self.m_GroupRankUpButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.56, self.m_Width*0.3, self.m_Height*0.07, _"Rang hoch", tabGroups):setBarEnabled(true)
	self.m_GroupRankDownButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.64, self.m_Width*0.3, self.m_Height*0.07, _"Rang runter", tabGroups):setBarEnabled(true)
	self.m_GroupToggleLoanButton = GUIButton:new(self.m_Width*0.6, self.m_Height*0.72, self.m_Width*0.3, self.m_Height*0.07, _"Gehalt deaktivieren", tabGroups):setBarEnabled(true)

	self.m_GroupInvitationsLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.06, _"Einladungen:", tabGroups)
	self.m_GroupInvitationsGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.6, tabGroups)
	self.m_GroupInvitationsGrid:addColumn(_"Name", 1)
	self.m_GroupInvitationsAcceptButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "✓", tabGroups):setBackgroundColor(Color.Green)
	self.m_GroupInvitationsDeclineButton = GUIButton:new(self.m_Width*0.225, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "✕", tabGroups):setBackgroundColor(Color.Red)

	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)
	self.m_GroupQuitButton.onLeftClick = bind(self.GroupQuitButton_Click, self)
	self.m_GroupDeleteButton.onLeftClick = bind(self.GroupDeleteButton_Click, self)
	--self.m_GroupMoneyDepositButton.onLeftClick = bind(self.GroupMoneyDepositButton_Click, self)
	--self.m_GroupMoneyWithdrawButton.onLeftClick = bind(self.GroupMoneyWithdrawButton_Click, self)
	self.m_GroupAddPlayerButton.onLeftClick = bind(self.GroupAddPlayerButton_Click, self)
	self.m_GroupRemovePlayerButton.onLeftClick = bind(self.GroupRemovePlayerButton_Click, self)
	self.m_GroupRankUpButton.onLeftClick = bind(self.GroupRankUpButton_Click, self)
	self.m_GroupRankDownButton.onLeftClick = bind(self.GroupRankDownButton_Click, self)
	self.m_GroupInvitationsAcceptButton.onLeftClick = bind(self.GroupInvitationsAcceptButton_Click, self)
	self.m_GroupInvitationsDeclineButton.onLeftClick = bind(self.GroupInvitationsDeclineButton_Click, self)
	self.m_GroupToggleLoanButton.onLeftClick = bind(self.GroupToggleLoanButton_Click, self)

	local tabVehicles = self.m_TabPanel:addTab(_"Fahrzeuge")
	self.m_TabVehicles = tabVehicles
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Fahrzeuge:", tabVehicles)
	self.m_VehiclesGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.65, self.m_Height*0.4, tabVehicles)
	self.m_VehiclesGrid:addColumn(_"Name", 0.3)
	self.m_VehiclesGrid:addColumn(_"Standort", 0.5)
	self.m_VehiclesGrid:addColumn(_"Steuer", 0.2)
	GUILabel:new(self.m_Width*0.695, self.m_Height*0.09, self.m_Width*0.28, self.m_Height*0.06, _"Optionen:", tabVehicles):setColor(Color.LightBlue)
	self.m_VehicleLocateButton = GUIButton:new(self.m_Width*0.695, self.m_Height*0.16, self.m_Width*0.28, self.m_Height*0.07, _"Orten", tabVehicles):setBarEnabled(true)
	self.m_VehicleRespawnButton = GUIButton:new(self.m_Width*0.695, self.m_Height*0.25, self.m_Width*0.28, self.m_Height*0.07, _"Respawn", tabVehicles):setBackgroundColor(Color.Orange):setBarEnabled(true)
	self.m_VehicleLocateButton.onLeftClick = bind(self.VehicleLocateButton_Click, self)
	self.m_VehicleRespawnButton.onLeftClick = bind(self.VehicleRespawnButton_Click, self)
	self.m_VehicleRemoveFromGroup = GUIButton:new(self.m_Width*0.695, self.m_Height*0.34, self.m_Width*0.28, self.m_Height*0.07, _"Fahrzeug entfernen", tabVehicles):setBackgroundColor(Color.Red):setBarEnabled(true)
	self.m_VehicleRemoveFromGroup.onLeftClick = bind(self.VehicleRemoveFromGroupButton_Click, self)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.53, self.m_Width*0.25, self.m_Height*0.06, _"Privat-Fahrzeuge:", tabVehicles)
	self.m_PrivateVehiclesGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.65, self.m_Height*0.31, tabVehicles)
	self.m_PrivateVehiclesGrid:addColumn(_"Name", 0.3)
	self.m_PrivateVehiclesGrid:addColumn(_"Standort", 0.5)
	self.m_PrivateVehiclesGrid:addColumn(_"Steuer", 0.2)
	GUILabel:new(self.m_Width*0.695, self.m_Height*0.6, self.m_Width*0.28, self.m_Height*0.06, _"Optionen:", tabVehicles):setColor(Color.LightBlue)


	self.m_VehicleConvertToGroupButton = GUIButton:new(self.m_Width*0.695, self.m_Height*0.67, self.m_Width*0.28, self.m_Height*0.14, _"Fahrzeug zur \nFirma/Gang hinzufügen", tabVehicles):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_VehicleConvertToGroupButton:setFont(VRPFont(25)):setFontSize(1)
	self.m_VehicleConvertToGroupButton.onLeftClick = bind(self.VehicleConvertToGroupButton_Click, self)
	--GUILabel:new(self.m_Width*0.02, self.m_Height*0.6, self.m_Width*0.4, self.m_Height*0.08, _"Fahrzeug-Info:", tabVehicles)



	local tabBusiness = self.m_TabPanel:addTab(_"Geschäfte")
	self.m_TabBusiness = tabBusiness
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Geschäfte:", tabBusiness)
	self.m_ShopsGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.09, self.m_Width*0.65, self.m_Height*0.78, tabBusiness)
	self.m_ShopsGrid:addColumn(_"Name", 0.4)
	self.m_ShopsGrid:addColumn(_"Standort", 0.4)
	self.m_ShopsGrid:addColumn(_"Kasse", 0.2)
	tabBusiness:setEnabled(false)

	GUIRectangle:new(self.m_Width*0.02, self.m_Height*0.87, self.m_Width*0.65, self.m_Height*0.005, Color.LightBlue, tabBusiness)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.875, self.m_Width*0.25, self.m_Height*0.06, _"Kasse(n) gesammt:", tabBusiness)
	self.m_ShopsMoneyLabel = GUILabel:new(self.m_Width*0.56, self.m_Height*0.875, self.m_Width*0.11, self.m_Height*0.06, _"0$", tabBusiness)
	GUILabel:new(self.m_Width*0.695, self.m_Height*0.09, self.m_Width*0.28, self.m_Height*0.06, _"Optionen:", tabBusiness):setColor(Color.LightBlue)
	self.m_ShopsLocate = GUIButton:new(self.m_Width*0.695, self.m_Height*0.16, self.m_Width*0.28, self.m_Height*0.07, _"Auf Karte anzeigen", tabBusiness):setBarEnabled(true)
	self.m_ShopsLocate.onLeftClick = bind(self.ShopLocateButton_Click, self)

	GUILabel:new(self.m_Width*0.695, self.m_Height*0.3, self.m_Width*0.28, self.m_Height*0.06, _"Informationen:", tabBusiness):setColor(Color.LightBlue)
	GUILabel:new(self.m_Width*0.695, self.m_Height*0.36, self.m_Width*0.28, self.m_Height*0.06, _"Name:", tabBusiness)
	self.m_ShopsNameLabel = GUILabel:new(self.m_Width*0.715, self.m_Height*0.42, self.m_Width*0.28, self.m_Height*0.06, "-", tabBusiness)
	GUILabel:new(self.m_Width*0.695, self.m_Height*0.49, self.m_Width*0.28, self.m_Height*0.06, _"Standort:", tabBusiness)
	self.m_ShopsPositionLabel = GUILabel:new(self.m_Width*0.715, self.m_Height*0.55, self.m_Width*0.28, self.m_Height*0.06, "-", tabBusiness)
	GUILabel:new(self.m_Width*0.695, self.m_Height*0.61, self.m_Width*0.28, self.m_Height*0.06, _"Letzter Raub:", tabBusiness)
	self.m_ShopsRobLabel = GUILabel:new(self.m_Width*0.715, self.m_Height*0.67, self.m_Width*0.28, self.m_Height*0.06, "-", tabBusiness)

	self.m_TabLogs = self.m_TabPanel:addTab(_"Logs")
	self.m_LeaderTab = false

	addRemoteEvents{"groupRetrieveInfo", "groupInvitationRetrieve", "groupRetriveBusinessInfo"}
	addEventHandler("groupRetrieveInfo", root, bind(self.Event_groupRetrieveInfo, self))
	addEventHandler("groupInvitationRetrieve", root, bind(self.Event_groupInvitationRetrieve, self))
	addEventHandler("vehicleRetrieveInfo", root, bind(self.Event_vehicleRetrieveInfo, self))
	addEventHandler("groupRetriveBusinessInfo", root, bind(self.Event_retriveBusinessInfo, self))
end

function GroupGUI:onShow()
	self:TabPanel_TabChanged()

	SelfGUI:getSingleton():addWindow(self)
end

function GroupGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

function GroupGUI:TabPanel_TabChanged(tabId)
	if tabId == self.m_TabBusiness.TabIndex then
		triggerServerEvent("groupRequestBusinessInfo", root)
	elseif tabId == self.m_TabLogs.TabIndex then
		local url = ("https://exo-reallife.de/ingame/logs/groupLogs.php?groupType=%s&groupId=%d"):format("group", self.m_Id)
		if not self.m_LogGUI then
			self.m_LogGUI = LogGUI:new(self.m_TabLogs, url)
		else
			self.m_LogGUI:updateLog()
		end
	else
		triggerLatentServerEvent("groupRequestInfo", root)
	end
end

function GroupGUI:Event_groupRetrieveInfo(id, name, rank, money, playTime, players, karma, type, rankNames, rankLoans, vehicles, tuningEnabled)
	self:adjustGroupTab(rank or false)

	if id then
		self.m_Id = id
		local karma = math.floor(karma)
		local nextPayDay = 60 - (playTime % 60)
		local x, y = self.m_GroupsNameLabel:getPosition()
		self.m_TuningEnabled = tuningEnabled
		self.m_GroupsNameChangeLabel:setPosition(x + dxGetTextWidth(name, self.m_GroupsNameLabel:getFontSize(), self.m_GroupsNameLabel:getFont()) + 10, y)
		self.m_GroupsNameLabel:setText(name)
		self.m_GroupsKarmaLabel:setText(tostring(karma > 0 and "+"..karma or karma))
		self.m_GroupsRankLabel:setText(rankNames[tostring(rank)])
		self.m_GroupMoneyLabel:setText(toMoneyString(money))
		self.m_GroupPayDayLabel:setText(_("in %s Minuten", nextPayDay))
		self.m_GroupCreateLabel:setVisible(false)
		self.m_TypeLabel:setText(type..":")
		self.m_VehicleConvertToGroupButton:setText(_("Fahrzeug zur\n%s hinzufügen", type))

		players = sortPlayerTable(players, "playerId", function(a, b) return a.rank > b.rank end)

		self.m_GroupPlayersGrid:clear()
		for _, info in ipairs(players) do
			local activitySymbol = info.loanEnabled == 1 and FontAwesomeSymbols.Calender_Check or FontAwesomeSymbols.Calender_Time
			local item = self.m_GroupPlayersGrid:addItem(activitySymbol, info.name, info.rank, tostring(info.activity).." h")
			item:setColumnFont(1, FontAwesome(20), 1):setColumnColor(1, info.loanEnabled == 1 and Color.Green or Color.Red)
			item.Id = info.playerId

			item.onLeftClick =
			function()
				self.m_GroupToggleLoanButton:setText(("Gehalt %saktivieren"):format(info.loanEnabled == 1 and "de" or ""))
			end
		end
		if rank >= GroupRank.Manager then
			self.m_RankNames = rankNames
			self.m_RankLoans = rankLoans
			self:addLeaderTab()
			self:refreshRankGrid()

			-- Update options
			local text = tuningEnabled and _"aktiviert" or _"deaktiviert"
			local x, y = self.m_VehicleTuningStatus:getPosition()
			self.m_VehicleTuningStatus:setText(text)
			self.m_VehicleTuningStatusChange:setPosition(x + dxGetTextWidth(text, self.m_VehicleTuningStatus:getFontSize(), self.m_VehicleTuningStatus:getFont()) + 10, y)
			self.m_TypeLabelLeader:setText(type)
			local x, y = self.m_TypeLabelLeader:getPosition()
			self.m_TypeChange:setPosition(x + dxGetTextWidth(type, self.m_TypeLabelLeader:getFontSize(), self.m_TypeLabelLeader:getFont()) + 10, y)
		end

		-- Group Vehicles
		self.m_VehiclesGrid:clear()
		if vehicles then
			for vehId, vehicleInfo  in pairs(vehicles) do
				local element, positionType = unpack(vehicleInfo)
				local position = _"Unbekannt"

				if positionType == VehiclePositionType.World then
					local x, y, z = getElementPosition(element)
					position = getZoneName(x, y, z, false)
				elseif positionType == VehiclePositionType.Mechanic then
					position = "Autohof"
				end

				local item = self.m_VehiclesGrid:addItem(element:getName(), position, ("%d$"):format(math.floor(element:getTax()) or 0))

				item.VehicleElement = element
				item.PositionType = positionType
			end
		end

		-- Enabled for private companies the business tab
		if type == "Firma" then
			self.m_TabBusiness:setEnabled(true)
		end
	else
		self.m_GroupCreateLabel:setVisible(true)
	end
end

function GroupGUI:Event_vehicleRetrieveInfo(vehiclesInfo)
	if vehiclesInfo then
		self.m_PrivateVehiclesGrid:clear()
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
			local item = self.m_PrivateVehiclesGrid:addItem(element:getName(), positionType, ("%d$"):format(element:getTax() or 0))
			item.VehicleId = vehicleId
			item.VehicleElement = element
			item.PositionType = vehicleInfo[2]
		end
	end
end

function GroupGUI:Event_groupInvitationRetrieve(groupId, name)
	local item = self.m_GroupInvitationsGrid:addItem(name)
	item.GroupId = groupId
end

function GroupGUI:adjustGroupTab(rank)
	local isInGroup = rank ~= false

	for k, element in ipairs(self.m_TabGroups:getChildren()) do
		if element ~= self.m_GroupCreateLabel then
			element:setVisible(isInGroup)
		end
	end
	self.m_GroupInvitationsLabel:setVisible(false)
	self.m_GroupInvitationsGrid:setVisible(false)
	self.m_GroupInvitationsAcceptButton:setVisible(false)
	self.m_GroupInvitationsDeclineButton:setVisible(false)

	if rank then
		if rank == GroupRank.Leader then
			self.m_GroupDeleteButton:setVisible(true)
		else
			self.m_GroupDeleteButton:setVisible(false)
		end
		if rank < GroupRank.Manager then
			--self.m_GroupMoneyWithdrawButton:setVisible(false)
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
		self.m_TabVehicles:setVisible(false)
		self.m_TabLogs:setVisible(false)
		if self.m_LeaderTab then
			self.m_TabLeader:setVisible(false)
		end
	end
end

function GroupGUI:GroupQuitButton_Click()
	QuestionBox:new(_"Möchtest du deine Firma/Gang wirklich verlassen?", function()
		triggerServerEvent("groupQuit", root)
	end)
end

function GroupGUI:GroupDeleteButton_Click()
	QuestionBox:new(_"Möchtest du deine Firma/Gang wirklich löschen\n Es werden keine Kosten erstattet!", function()
		triggerServerEvent("groupDelete", root)
	end)
end

function GroupGUI:GroupMoneyDepositButton_Click()
	local amount = tonumber(self.m_GroupMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("groupDeposit", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function GroupGUI:GroupMoneyWithdrawButton_Click()
	local amount = tonumber(self.m_GroupMoneyAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("groupWithdraw", root, amount)
	else
		ErrorBox:new(_"Bitte gebe einen gültigen Betrag ein!")
	end
end

function GroupGUI:GroupAddPlayerButton_Click()
	InviteGUI:new(
		function(player)
			triggerServerEvent("groupAddPlayer", root, player)
		end,"group"
	)
end

function GroupGUI:GroupRemovePlayerButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupDeleteMember", root, selectedItem.Id)
	else
		ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online")
	end
end

function GroupGUI:GroupRankUpButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupRankUp", root, selectedItem.Id)
	end
end

function GroupGUI:GroupRankDownButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupRankDown", root, selectedItem.Id)
	end
end

function GroupGUI:GroupInvitationsAcceptButton_Click()
	local selectedItem = self.m_GroupInvitationsGrid:getSelectedItem()
	if selectedItem then
		if selectedItem.GroupId then
			triggerServerEvent("groupInvitationAccept", resourceRoot, selectedItem.GroupId)
		end
		self.m_GroupInvitationsGrid:removeItemByItem(selectedItem)
		self.m_GroupInvitationsGrid:clear()
	end
end

function GroupGUI:GroupInvitationsDeclineButton_Click()
	local selectedItem = self.m_GroupInvitationsGrid:getSelectedItem()
	if selectedItem then
		if selectedItem.GroupId then
			triggerServerEvent("groupInvitationDecline", resourceRoot, selectedItem.GroupId)
		end
		self.m_GroupInvitationsGrid:removeItemByItem(selectedItem)
		self.m_GroupInvitationsGrid:clear()
	end
end

function GroupGUI:addLeaderTab()
	if self.m_LeaderTab == false then
		local tabLeader = self.m_TabPanel:addTab(_"Leader")
		self.m_TabLeader = tabLeader
		self.m_FactionRangGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.025, self.m_Width*0.4, self.m_Height*0.95, tabLeader)
		self.m_FactionRangGrid:addColumn(_"Rang", 0.2)
		self.m_FactionRangGrid:addColumn(_"Name", 0.8)

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.05, self.m_Width*0.4, self.m_Height*0.06, _"Rangname:", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderRankName = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.12, self.m_Width*0.4, self.m_Height*0.06, tabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.2, self.m_Width*0.4, self.m_Height*0.06, _"Gehalt: (in $)", tabLeader):setFont(VRPFont(30)):setColor(Color.LightBlue)
		self.m_LeaderLoan = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.28, self.m_Width*0.1, self.m_Height*0.06, tabLeader)
		self.m_LeaderLoan:setNumeric(true, true)

		self.m_SaveRank = GUIButton:new(self.m_Width*0.69, self.m_Height*0.28, self.m_Width*0.3, self.m_Height*0.06, _"Rang speichern", tabLeader):setBarEnabled(true)
		self.m_SaveRank.onLeftClick = bind(self.saveRank, self)
		self.m_SaveRank:setEnabled(false)

		GUIRectangle:new(self.m_Width*0.45, self.m_Height*0.36, self.m_Width*0.525, 2, Color.LightBlue, tabLeader)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.38, self.m_Width*0.4, self.m_Height*0.09, _"Optionen:", tabLeader):setColor(Color.LightBlue)
		GUILabel:new(self.m_Width*0.45, self.m_Height*0.48, self.m_Width*0.4, self.m_Height*0.06, _"Fahrzeug-Tuning:", tabLeader)
		self.m_VehicleTuningStatus = GUILabel:new(self.m_Width*0.7, self.m_Height*0.48, self.m_Width*0.4, self.m_Height*0.06, "", tabLeader)
		self.m_VehicleTuningStatusChange = GUILabel:new(self.m_Width*0.7, self.m_Height*0.48, self.m_Width*0.4, self.m_Height*0.06, _"(ändern)", tabLeader):setColor(Color.LightBlue)
		self.m_VehicleTuningStatusChange.onLeftClick = function () triggerServerEvent("groupUpdateVehicleTuning", root) end
		self.m_VehicleTuningStatusChange.onHover = function () self.m_VehicleTuningStatusChange:setColor(Color.White) end
		self.m_VehicleTuningStatusChange.onUnhover = function () self.m_VehicleTuningStatusChange:setColor(Color.LightBlue) end

		GUILabel:new(self.m_Width*0.45, self.m_Height*0.55, self.m_Width*0.4, self.m_Height*0.06, _"Typ:", tabLeader)
		self.m_TypeLabelLeader = GUILabel:new(self.m_Width*0.7, self.m_Height*0.55, self.m_Width*0.4, self.m_Height*0.06, "", tabLeader)
		self.m_TypeChange = GUILabel:new(self.m_Width*0.7, self.m_Height*0.55, self.m_Width*0.4, self.m_Height*0.06, _"(ändern)", tabLeader):setColor(Color.LightBlue)
		self.m_TypeChange.onLeftClick = function ()
			local newType = localPlayer:getGroupType() == "Firma" and "Gang" or "Firma"
			QuestionBox:new(_("Möchtest du wirklich deine %s in eine %s umwandeln? Kosten: 20.000$", localPlayer:getGroupType(), newType),
			    function() 	triggerServerEvent("groupChangeType", root) end
			)
		end
		self.m_TypeChange.onHover = function () self.m_TypeChange:setColor(Color.White) end
		self.m_TypeChange.onUnhover = function () self.m_TypeChange:setColor(Color.LightBlue) end

		self.m_BindButton = GUIButton:new(self.m_Width*0.45, self.m_Height*62, self.m_Width*0.3, self.m_Height*0.07, _"Binds verwalten", tabLeader):setBarEnabled(true)
		self.m_BindButton.onLeftClick = function()
			if self.m_BindManageGUI then delete(self.m_BindManageGUI) end
			self:close()
			self.m_BindManageGUI = BindManageGUI:new("group")
			self.m_BindManageGUI:addBackButton(function() GroupGUI:getSingleton():show() end)
		end


		self:refreshRankGrid()
		self.m_LeaderTab = true
	end
end

function GroupGUI:saveRank()
	if self.m_SelectedRank then
		triggerServerEvent("groupSaveRank",localPlayer,self.m_SelectedRank,self.m_LeaderRankName:getText(),self.m_LeaderLoan:getText())
	end
end

function GroupGUI:refreshRankGrid()
	self.m_FactionRangGrid:clear()
	-- Todo: tempfix
	local tab = {}
	for i, v in pairs(self.m_RankNames) do
		tab[tonumber(i)+1] = v
	end
	for rank, name in ipairs(tab) do
		local rank = rank - 1

		local item = self.m_FactionRangGrid:addItem(rank, name)
		item.Id = rank
		item.onLeftClick = function()
			self.m_SelectedRank = rank
			self:onSelectRank(name,rank)
		end

		if rank == self.m_SelectedRank then
			self.m_FactionRangGrid:onInternalSelectItem(item)
			item.onLeftClick()
		end
	end
end

function GroupGUI:onSelectRank(name,rank)
	self.m_LeaderRankName:setText(tostring(self.m_RankNames[tostring(rank)]))
	self.m_LeaderLoan:setText(tostring(self.m_RankLoans[tostring(rank)]))
	self.m_SaveRank:setEnabled(true)
end

function GroupGUI:VehicleRespawnButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	triggerServerEvent("vehicleRespawn", item.VehicleElement)
end

function GroupGUI:VehicleConvertToGroupButton_Click()
	local item = self.m_PrivateVehiclesGrid:getSelectedItem()
	if not item then
		ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	if item.PositionType == VehiclePositionType.Garage then
		ErrorBox:new(_"Das Fahrzeug darf sich nicht in der Garage befinden!")
		return
	end
	if item.PositionType == VehiclePositionType.Mechanic then
		ErrorBox:new(_"Das Fahrzeug darf sich nicht im Autohof befinden!")
		return
	end

	QuestionBox:new(_"Möchtest du das Fahrzeug wirklich in die Firma setzen?" .. (not self.m_TuningEnabled and "\nACHTUNG: Deine Firma hat keine Tunings aktiviert! Alle Tunings werden entfernt!" or ""), function()
		triggerServerEvent("groupConvertVehicle", localPlayer, item.VehicleElement)
	end)
end

function GroupGUI:VehicleRemoveFromGroupButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end
	if item.PositionType == VehiclePositionType.Garage then
		ErrorBox:new(_"Das Fahrzeug darf sich nicht in der Garage befinden!")
		return
	end
	if item.PositionType == VehiclePositionType.Mechanic then
		ErrorBox:new(_"Das Fahrzeug darf sich nicht im Autohof befinden!")
		return
	end

	QuestionBox:new(_"Möchtest du das Fahrzeug wirklich aus der Firma entfernen?",
		function()
			triggerServerEvent("groupRemoveVehicle", localPlayer, item.VehicleElement)
		end
	)
end

function GroupGUI:VehicleLocateButton_Click()
	local item = self.m_VehiclesGrid:getSelectedItem()
	if not item then
		ErrorBox:new(_"Bitte wähle ein Fahrzeug aus!")
		return
	end

	if item.PositionType == VehiclePositionType.World then
		local x, y, z = getElementPosition(item.VehicleElement)
		local blip = Blip:new("Marker.png", x, y, 9999, {200, 0, 0})
		local marker = createMarker(x, y, z + 2, "arrow", .6, 60, 255, 130)
		blip:setZ(z)
		--[[if localPlayer has Item:'Find.dat.Car+' then]] -- TODO: add this item!
		ShortMessage:new(_("Dieses Fahrzeug befindet sich in %s!\n(Siehe Blip auf der Karte)\n(Klicke hier, um das Blip zu löschen!)", getZoneName(x, y, z, false)), "Fahrzeugortung", Color.DarkLightBlue, -1)
		.m_Callback =
			function (this)
				if blip then delete(blip) end
				if isElement(marker) then marker:destroy() end
				delete(this)
			end
	elseif item.PositionType == VehiclePositionType.Mechanic then
		ShortMessage:new(_"Dieses Fahrzeug befindet sich im Autohof (Mechanic Base)!", "Fahrzeugortung", Color.DarkLightBlue)
	else
		ErrorBox:new(_"Es ist ein interner Fehler aufgetreten!")
	end
end

function GroupGUI:Event_retriveBusinessInfo(info)
	self.m_ShopsGrid:clear()
	self.m_ShopsNameLabel:setText("-")
	self.m_ShopsPositionLabel:setText("-")
	self.m_ShopsRobLabel:setText("-")

	local compMoney = 0
	for i, shop in pairs(info) do
		local item = self.m_ShopsGrid:addItem(shop.name, getZoneName(Vector3(shop.position)), toMoneyString(shop.money))
		item.ShopId = shop.id
		item.ShopName = shop.name
		item.LastRob = shop.lastRob
		item.Position = Vector3(shop.position)
		item.onLeftClick = function(item)
			self.m_ShopsNameLabel:setText(_(item.ShopName))
			self.m_ShopsPositionLabel:setText(_(getZoneName(item.Position)))
			self.m_ShopsRobLabel:setText(item.LastRob > 0 and getOpticalTimestamp(item.LastRob) or "-")
		end

		compMoney = compMoney + shop.money
	end

	self.m_ShopsMoneyLabel:setText(toMoneyString(compMoney))
end

function GroupGUI:ShopLocateButton_Click()
	local item = self.m_ShopsGrid:getSelectedItem()
	if not item then
		ErrorBox:new(_"Bitte wähle ein Geschäft aus!")
		return
	end

	local x, y, z = item.Position.x, item.Position.y, item.Position.z
	local blip = Blip:new("Marker.png", x, y, 9999, {200, 0, 0})
	blip:setZ(z)
	ShortMessage:new(_("Das Geschäft befindet sich in %s!\n(Siehe Blip auf der Karte)\n(Klicke hier um das Blip zu löschen!)", getZoneName(x, y, z, false)), item.ShopName, Color.DarkLightBlue, -1)
	.m_Callback = function (this)
		if blip then
			delete(blip)
		end
		delete(this)
	end
end

function GroupGUI:GroupToggleLoanButton_Click()
	local selectedItem = self.m_GroupPlayersGrid:getSelectedItem()
	if selectedItem and selectedItem.Id then
		triggerServerEvent("groupToggleLoan", root, selectedItem.Id)
	end
end
