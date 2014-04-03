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
	self.m_CloseButton.onHover = function(btn) btn:setColor(Color.Red) end
	self.m_CloseButton.onUnhover = function(btn) btn:setColor(Color.White) end
	self.m_CloseButton.onLeftClick = function() self:hide() end
	
	-- Tab: Info
	-- Todo
	local tabInfo = self.m_TabPanel:addTab(_"Info")
	
	-- Tab: Job
	local tabJob = self.m_TabPanel:addTab(_"Job")
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Aktueller Job:", tabJob)
	self.m_JobNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabJob)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.06, _"Level:", tabJob)
	self.m_JobLevelLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.06, "1", tabJob) -- Todo
	self.m_JobQuitButton = GUIButton:new(self.m_Width*0.02, self.m_Height * 0.4, self.m_Width*0.35, self.m_Height*0.07, _"Job kündigen", tabJob):setBackgroundColor(Color.Red)
	
	self.m_JobQuitButton.onLeftClick = bind(self.JobQuitButton_Click, self)
	
	-- Tab: Achievements
	-- Todo
	local tabAchievements = self.m_TabPanel:addTab(_"Erfolge")
	
	-- Tab: Groups
	local tabGroups = self.m_TabPanel:addTab(_"Gruppen")
	self.m_TabGroups = tabGroups
	local color = Color.White
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.06, _"Gruppe:", tabGroups)
	self.m_GroupsNameLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.02, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.25, self.m_Height*0.06, _"Gruppenrang:", tabGroups)
	self.m_GroupsRankLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.06, "", tabGroups)
	self.m_GroupCreateButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.02, self.m_Width*0.25, self.m_Height*0.07, _"Erstellen", tabGroups):setBackgroundColor(Color.Green)
	self.m_GroupQuitButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.1, self.m_Width*0.25, self.m_Height*0.07, _"Verlassen", tabGroups):setBackgroundColor(Color.Red)
	self.m_GroupDeleteButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.18, self.m_Width*0.25, self.m_Height*0.07, _"Löschen", tabGroups):setBackgroundColor(Color.Red)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.05, _"Kasse:", tabGroups)
	self.m_GroupMoneyLabel = GUILabel:new(self.m_Width*0.3, self.m_Height*0.23, self.m_Width*0.25, self.m_Height*0.06, "", tabGroups)
	self.m_GroupMoneyAmountEdit = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.27, self.m_Height*0.07, tabGroups):setCaption(_"Betrag")
	self.m_GroupMoneyDepositButton = VRPButton:new(self.m_Width*0.3, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Einzahlen", true, tabGroups)
	self.m_GroupMoneyWithdrawButton = VRPButton:new(self.m_Width*0.56, self.m_Height*0.29, self.m_Width*0.25, self.m_Height*0.07, _"Auszahlen", true, tabGroups)
	self.m_GroupPlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.4, self.m_Width*0.4, self.m_Height*0.5, tabGroups)
	self.m_GroupPlayersGrid:addColumn(_"Spieler", 0.7)
	self.m_GroupPlayersGrid:addColumn(_"Rang", 0.3)
	self.m_GroupAddPlayerButton = GUIButton:new(self.m_Width*0.43, self.m_Height*0.4, self.m_Width*0.3, self.m_Height*0.07, _"Spieler hinzufügen", tabGroups):setBackgroundColor(Color.Green)
	self.m_GroupRemovePlayerButton = GUIButton:new(self.m_Width*0.43, self.m_Height*0.48, self.m_Width*0.3, self.m_Height*0.07, _"Spieler rauswerfen", tabGroups):setBackgroundColor(Color.Red)
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
	
	addEvent("groupRetrieveInfo", true)
	addEvent("groupInvitationRetrieve", true)
	addEventHandler("groupRetrieveInfo", root, bind(self.Event_groupRetrieveInfo, self))
	addEventHandler("groupInvitationRetrieve", root, bind(self.Event_groupInvitationRetrieve, self))
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
	if tabId == 3 then
		triggerServerEvent("groupRequestInfo", root)
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
	ShortMessage:new(_("Du wurdest in die Gruppe '%s' eingeladen. Öffne dein Handy, um die Einladung zu bestätigen", name))
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
