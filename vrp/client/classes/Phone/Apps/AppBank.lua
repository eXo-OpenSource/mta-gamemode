-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppBank.lua
-- *  PURPOSE:     AppBank app class
-- *
-- ****************************************************************************
AppBank = inherit(PhoneApp)
AppBank.ATMs = {} -- gets loaded in core

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
	self.m_LocateATMsButton = GUIButton:new(10, self.m_Tabs["Info"].m_Height-50, 240, 30, _"Bankautomat finden", self.m_Tabs["Info"]):setBarEnabled(false)
	self.m_LocateATMsButton.onLeftClick = bind(self.LocateATMsClick, self)

	self.m_Tabs["Transfer"] = self.m_TabPanel:addTab(_"Überweisen", FontAwesomeSymbols.Money)
	GUILabel:new(10, 10, 240, 50, _"eXo-Bank", self.m_Tabs["Transfer"])
	GUILabel:new(10, 70, 240, 30, _"Überweisen:", self.m_Tabs["Transfer"])

	GUILabel:new(10, 100, 240, 20, _"Empfänger:", self.m_Tabs["Transfer"])
	self.m_TransferToEdit = GUIEdit:new(10, 120, 240, 30, self.m_Tabs["Transfer"])

	GUILabel:new(10, 155, 240, 20, _"Grund:", self.m_Tabs["Transfer"])
	self.m_TransferPurposeEdit = GUIEdit:new(10, 175, 240, 30, self.m_Tabs["Transfer"])

	GUILabel:new(10, 210, 240, 20, _"Betrag:", self.m_Tabs["Transfer"])
	self.m_TransferAmountEdit = GUIEdit:new(10, 230, 240, 30, self.m_Tabs["Transfer"])
	self.m_TransferAmountEdit:setNumeric(true, true)

	self.m_TransferButton = GUIButton:new(10, 265, 240, 30, _"Überweisen", self.m_Tabs["Transfer"]):setBarEnabled(false)
	self.m_TransferButton.onLeftClick = bind(self.TransferButton_Click, self)

	GUILabel:new(10, 320, 120, 30, _"Spenden:", self.m_Tabs["Transfer"])
	local donate = {}
	donate["San News"] = GUIButton:new(10, 350, 117, 30, _"San News", self.m_Tabs["Transfer"]):setBackgroundColor(Color.Orange):setFontSize(.9)
	donate["eXo Event-Team"] = GUIButton:new(135, 350, 117, 30, _"eXo Event-Team", self.m_Tabs["Transfer"]):setBackgroundColor(Color.Green):setFontSize(.9)

	for index, btn in pairs(donate) do
		btn.onLeftClick = function() self.m_TransferToEdit:setText(index) end
	end

	self.m_Tabs["Statements"] = self.m_TabPanel:addTab(_"Kontoauszug", FontAwesomeSymbols.List)
	local tab = self.m_Tabs["Statements"]
	self.m_StatementsBrowser = GUIWebView:new(0, 0, tab.m_Width, tab.m_Height-10, (INGAME_WEB_PATH .. "/ingame/vRPphone/apps/bank/index.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), true, tab)

	addEventHandler("bankMoneyBalanceRetrieve", root, bind(self.Event_OnMoneyReceive, self))
	triggerServerEvent("bankMoneyBalanceRequest", root)
end

function AppBank:Event_OnMoneyReceive(amount)
	self.m_AccountBalanceLabel:setText(toMoneyString(amount))
end

function AppBank:TransferButton_Click()
	local amount = tonumber(self.m_TransferAmountEdit:getText())
	local toCharName = self.m_TransferToEdit:getText()
	local purpose = self.m_TransferPurposeEdit:getText()
	if amount and amount > 0 then
		self.m_TransferAmountEdit:setText("0")
		triggerServerEvent("bankTransfer", root, toCharName, amount, purpose)
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function AppBank:LocateATMsClick()
	if localPlayer:getInterior() ~= 0 then WarningBox:new(_"Bitte gehe nach draußen, um die Automaten anzuzeigen.") return end
	if self.m_ATMsLocated then
		for i,v in pairs(self.m_ATMBlips) do
			v:delete()
		end
		self.m_ATMBlips = nil
		self.m_LocateATMsButton:setText(_"Bankautomat finden")
	else
		self.m_LocateATMsButton:setText(_"Markierungen entfernen")
		self.m_ATMBlips = {}
		local ATMsCloseToPlayer = {}
		local position = localPlayer.position
		table.sort(AppBank.ATMs, function(a, b)
			return getDistanceBetweenPoints3D(a.position, position) < getDistanceBetweenPoints3D(b.position, position)
		end)

		for i = 1, 3 do
			local obj = AppBank.ATMs[i]
			local blip = Blip:new("Bank.png", obj.position.x, obj.position.y, 9999, BLIP_COLOR_CONSTANTS.Green)
			blip:setDisplayText("Bankautomat")
			table.insert(self.m_ATMBlips, blip)
		end
		InfoBox:new(_"Bankautomaten in der Nähe von dir wurden auf der Karte markiert.")
	end
	self.m_ATMsLocated = not self.m_ATMsLocated
end
