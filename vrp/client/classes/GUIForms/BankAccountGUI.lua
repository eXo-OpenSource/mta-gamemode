-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BankAccountGUI.lua
-- *  PURPOSE:     Bank (ATM) GUI class
-- *
-- ****************************************************************************
BankAccountGUI = inherit(GUIForm)
inherit(Singleton, BankAccountGUI)

addRemoteEvents{"bankAccountGUIShow", "bankAccountGUIRefresh"}

function BankAccountGUI:constructor(name, depositEvent, withdrawEvent, additionalParameters)
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.35, screenHeight*0.4)

	self.m_DepositEvent = depositEvent
	self.m_WithdrawEvent = withdrawEvent
	self.m_AdditionalParameters = additionalParameters or {}

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, name.." Konto", true, true, self)
	self.m_HeaderImage = GUIImage:new(self.m_Width*0.01, self.m_Height*0.11, self.m_Width*0.98, self.m_Height*0.25, "files/images/Shops/BankHeader.png", self.m_Window)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.37, self.m_Width*0.25, self.m_Height*0.07, _"Kontostand:", self.m_Window):setColor(Color.Green)
	self.m_AccountBalanceLabel = GUILabel:new(self.m_Width*0.28, self.m_Height*0.37, self.m_Width*0.34, self.m_Height*0.07, "Lade...", self.m_Window)

	self.m_TabPanel = GUITabPanel:new(self.m_Width*0.02, self.m_Height*0.45, self.m_Width-2*self.m_Width*0.02, self.m_Height*0.52, self.m_Window)
	local tabWidth, tabHeight = self.m_TabPanel:getSize()

	self.m_TabWithdraw = self.m_TabPanel:addTab(_"Auszahlen")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Betrag:", self.m_TabWithdraw)
	self.m_WithdrawAmountEdit = GUIEdit:new(tabWidth*0.25, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabWithdraw)
	self.m_WithdrawAmountEdit:setNumeric(true, true)
	self.m_WithdrawButton = VRPButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Auszahlen", true, self.m_TabWithdraw)
	self.m_WithdrawButton.onLeftClick = bind(self.WithdrawButton_Click, self)

	self.m_TabDeposit = self.m_TabPanel:addTab(_"Einzahlen")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Betrag:", self.m_TabDeposit)
	self.m_DepositAmountEdit = GUIEdit:new(tabWidth*0.25, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabDeposit)
	self.m_DepositAmountEdit:setNumeric(true, true)
	self.m_DepositButton = VRPButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Einzahlen", true, self.m_TabDeposit)
	self.m_DepositButton.onLeftClick = bind(self.DepositButton_Click, self)

	addEventHandler("bankAccountGUIRefresh", root, function(amount)
		self.m_AccountBalanceLabel:setText(tostring(amount).."$")
	end)
end

addEventHandler("bankAccountGUIShow", root, function(name, depositEvent, withdrawEvent, ...)
	local additionalParameters = {...}
	BankAccountGUI:new(name, depositEvent, withdrawEvent, additionalParameters)
end)

function BankAccountGUI:WithdrawButton_Click()
	local amount = tonumber(self.m_WithdrawAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent(self.m_WithdrawEvent, root, amount, unpack(self.m_AdditionalParameters))
		self.m_WithdrawAmountEdit:setText("0")
	else
		ErrorBox:new(_"Bitte gib einen gültigen Wert ein!")
	end
end

function BankAccountGUI:DepositButton_Click()
	local amount = tonumber(self.m_DepositAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent(self.m_DepositEvent, root, amount, unpack(self.m_AdditionalParameters))
		self.m_DepositAmountEdit:setText("0")
	else
		ErrorBox:new(_"Bitte gib einen gültigen Wert ein!")
	end
end
