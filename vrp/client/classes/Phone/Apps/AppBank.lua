-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppBank.lua
-- *  PURPOSE:     AppBank app class
-- *
-- ****************************************************************************
AppBank = inherit(PhoneApp)

function AppBank:constructor()
	PhoneApp.constructor(self, "Bank", "IconBank.png")
end

function AppBank:onOpen(form)

	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)
	self.m_Tabs = {}
	self.m_Tabs["Info"] = self.m_TabPanel:addTab(_"Information", FontAwesomeSymbols.Info)
	GUILabel:new(10, 10, 240, 50, _"eXo-Bank", self.m_Tabs["Info"])
	GUILabel:new(10, 70, 240, 30, _"Kontostand:", self.m_Tabs["Info"])
	self.m_AccountBalanceLabel = GUILabel:new(10, 100, 240, 30, "", self.m_Tabs["Info"])


	self.m_Tabs["Transfer"] = self.m_TabPanel:addTab(_"Überweisen", FontAwesomeSymbols.Money)
	GUILabel:new(10, 10, 240, 50, _"eXo-Bank", self.m_Tabs["Transfer"])
	GUILabel:new(10, 70, 240, 30, _"Überweisen:", self.m_Tabs["Transfer"])

	GUILabel:new(10, 100, 240, 20, _"Betrag:", self.m_Tabs["Transfer"])
	self.m_TransferAmountEdit = GUIEdit:new(10, 120, 240, 30, self.m_Tabs["Transfer"])
	self.m_TransferAmountEdit:setNumeric(true, true)

	GUILabel:new(10, 155, 240, 20, _"An:", self.m_Tabs["Transfer"])
	self.m_TransferToEdit = GUIEdit:new(10, 175, 240, 30, self.m_Tabs["Transfer"])

	self.m_TransferButton = VRPButton:new(10, 210, 240, 30, _"Überweisen", true, self.m_Tabs["Transfer"])
	self.m_TransferButton.onLeftClick = bind(self.TransferButton_Click, self)

	GUILabel:new(10, 270, 120, 30, _"Spenden:", self.m_Tabs["Transfer"])
	local donate = {}
	donate["San News"] = VRPButton:new(10, 300, 117, 30, _"San News", true, self.m_Tabs["Transfer"]):setBarColor(Color.Green)
	donate["eXo Event-Team"] = VRPButton:new(135, 300, 117, 30, _"eXo Event-Team", true, self.m_Tabs["Transfer"]):setBarColor(Color.Yellow)

	for index, btn in pairs(donate) do
		btn.onLeftClick = function() self.m_TransferToEdit:setText(index) end
	end

	self.m_Tabs["Statements"] = self.m_TabPanel:addTab(_"Kontoauszug", FontAwesomeSymbols.List)
	local tab = self.m_Tabs["Statements"]
	self.m_StatementsBrowser = GUIWebView:new(0, 0, tab.m_Width, tab.m_Height-10, ("https://exo-reallife.de/ingame/vRPphone/apps/bank/index.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), true, tab)

	addEventHandler("bankMoneyBalanceRetrieve", root, bind(self.Event_OnMoneyReceive, self))
	triggerServerEvent("bankMoneyBalanceRequest", root)
end

function AppBank:Event_OnMoneyReceive(amount)
	self.m_AccountBalanceLabel:setText(_("%d$", amount))
end

function AppBank:TransferButton_Click()
	local amount = tonumber(self.m_TransferAmountEdit:getText())
	local toCharName = self.m_TransferToEdit:getText()
	if amount and amount > 0 then
		self.m_TransferAmountEdit:setText("0")
		triggerServerEvent("bankTransfer", root, toCharName, amount)
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end
