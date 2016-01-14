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
--	self.m_FactionInvitationsLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.02, self.m_Width*0.3, self.m_Height*0.06, _"Einladungen:", tabAllgemein)
--	self.m_FactionInvitationsGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.4, self.m_Height*0.6, tabAllgemein)
--	self.m_FactionInvitationsGrid:addColumn(_"Name", 1)
--	self.m_FactionInvitationsAcceptButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "✓", tabAllgemein):setBackgroundColor(Color.Green)
--	self.m_FactionInvitationsDeclineButton = GUIButton:new(self.m_Width*0.225, self.m_Height*0.7, self.m_Width*0.195, self.m_Height*0.06, "✕", tabAllgemein):setBackgroundColor(Color.Red)
	
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
--	self.m_FactionInvitationsAcceptButton.onLeftClick = bind(self.FactionInvitationsAcceptButton_Click, self)
--	self.m_FactionInvitationsDeclineButton.onLeftClick = bind(self.FactionInvitationsDeclineButton_Click, self)
	
	
	
--	addRemoteEvents{"factionRetrieveInfo", "factionInvitationRetrieve"}
	addRemoteEvents{"factionRetrieveInfo"}
	addEventHandler("factionRetrieveInfo", root, bind(self.Event_factionRetrieveInfo, self))
--	addEventHandler("factionInvitationRetrieve", root, bind(self.Event_factionInvitationRetrieve, self))
	
end

function FactionGUI:onShow()
	triggerServerEvent("factionRequestInfo", root)
end

function FactionGUI:TabPanel_TabChanged(tabId)
	triggerServerEvent("factionRequestInfo", root)
end

function FactionGUI:Event_factionRetrieveInfo(id, name, rank,money, players)
	--self:adjustFactionTab(rank or false)
	if id > 0 then
		local x, y = self.m_FactionNameLabel:getPosition()
		self.m_FactionNameLabel:setText(name)
		self.m_FactionRankLabel:setText(tostring(rank))
		self.m_FactionMoneyLabel:setText(tostring(money).."$")

		self.m_FactionPlayersGrid:clear()
		for playerId, info in pairs(players) do
			local item = self.m_FactionPlayersGrid:addItem(info.name, info.rank)
			item.Id = playerId
		end
	end
end

function FactionGUI:Event_factionInvitationRetrieve(factionId, name)
	ShortMessage:new(_("Du wurdest in die Gruppe '%s' eingeladen. Öffne das Spielermenü, um die Einladung anzunehmen", name))

	local item = self.m_FactionInvitationsGrid:addItem(name)
	item.FactionId = factionId
end

function FactionGUI:adjustFactionTab(rank)
	local isInFaction = rank ~= false

	for k, element in ipairs(self.m_tabAllgemein:getChildren()) do
		if element ~= self.m_FactionCreateButton then
			element:setVisible(isInFaction)
		end
	end
	self.m_FactionInvitationsLabel:setVisible(false)
	self.m_FactionInvitationsGrid:setVisible(false)
	self.m_FactionInvitationsAcceptButton:setVisible(false)
	self.m_FactionInvitationsDeclineButton:setVisible(false)

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
	else
		-- We're not in a faction, so show the invitation stuff
		self.m_FactionInvitationsLabel:setVisible(true)
		self.m_FactionInvitationsGrid:setVisible(true)
		self.m_FactionInvitationsAcceptButton:setVisible(true)
		self.m_FactionInvitationsDeclineButton:setVisible(true)
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

function FactionGUI:FactionInvitationsAcceptButton_Click()
	local selectedItem = self.m_FactionInvitationsGrid:getSelectedItem()
	if selectedItem then
		if selectedItem.FactionId then
			triggerServerEvent("factionInvitationAccept", resourceRoot, selectedItem.FactionId)
		end
		self.m_FactionInvitationsGrid:removeItemByItem(selectedItem)
	end
end

function FactionGUI:FactionInvitationsDeclineButton_Click()
	local selectedItem = self.m_FactionInvitationsGrid:getSelectedItem()
	if selectedItem then
		if selectedItem.FactionId then
			triggerServerEvent("factionInvitationDecline", resourceRoot, selectedItem.FactionId)
		end
		self.m_FactionInvitationsGrid:removeItemByItem(selectedItem)
	end
end