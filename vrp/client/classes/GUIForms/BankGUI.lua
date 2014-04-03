-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BankGUI.lua
-- *  PURPOSE:     Bank (ATM) GUI class
-- *
-- ****************************************************************************
BankGUI = inherit(GUIForm)
addEvent("bankMoneyBalanceRetrieve", true)

function BankGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.3, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Bank ATM", true, true, self)
	self.m_HeaderImage = GUIImage:new(self.m_Width*0.01, self.m_Height*0.11, self.m_Width*0.98, self.m_Height*0.25, "files/images/BankHeader.png", self.m_Window)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.37, self.m_Width*0.25, self.m_Height*0.07, _"Kontostand:", self.m_Window):setFont(VRPFont(20)):setColor(Color.Green)
	self.m_AccountBalanceLabel = GUILabel:new(self.m_Width*0.28, self.m_Height*0.37, self.m_Width*0.34, self.m_Height*0.07, "Loading...", self.m_Window):setFont(VRPFont(20)):setColor(Color.Red)
	triggerServerEvent("bankMoneyBalanceRequest", root)
	addEventHandler("bankMoneyBalanceRetrieve", root, function(amount) self.m_AccountBalanceLabel:setText(tostring(amount).."$") end)
	
	self.m_TabPanel = GUITabPanel:new(self.m_Width*0.02, self.m_Height*0.45, self.m_Width-2*self.m_Width*0.02, self.m_Height*0.52, self.m_Window)
	local tabWidth, tabHeight = self.m_TabPanel:getSize()
	
	self.m_TabWithdraw = self.m_TabPanel:addTab(_"Auszahlen")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Betrag:", self.m_TabWithdraw):setFont(VRPFont(20))
	self.m_WithdrawAmountEdit = GUIEdit:new(tabWidth*0.2, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabWithdraw)
	self.m_WithdrawButton = GUIButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Auszahlen", self.m_TabWithdraw)
	self.m_WithdrawButton.onLeftClick = bind(self.WithdrawButton_Click, self)
	
	self.m_TabDeposit = self.m_TabPanel:addTab(_"Einzahlen")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Betrag:", self.m_TabDeposit):setFont(VRPFont(20))
	self.m_DepositAmountEdit = GUIEdit:new(tabWidth*0.2, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabDeposit)
	self.m_DepositButton = GUIButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Einzahlen", self.m_TabDeposit)
	self.m_DepositButton.onLeftClick = bind(self.DepositButton_Click, self)
	
	self.m_TabTransfer = self.m_TabPanel:addTab(_"Überweisen")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Empfänger:", self.m_TabTransfer):setFont(VRPFont(20))
	self.m_TransferToEdit = GUIEdit:new(tabWidth*0.2, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabTransfer)
	GUILabel:new(tabWidth*0.03, tabHeight*0.28, tabWidth*0.15, tabHeight*0.15, _"Betrag:", self.m_TabTransfer):setFont(VRPFont(20))
	self.m_TransferAmountEdit = GUIEdit:new(tabWidth*0.2, tabHeight*0.28, tabWidth*0.5, tabHeight*0.15, self.m_TabTransfer)
	self.m_TransferButton = GUIButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Überweisen", self.m_TabTransfer)
	self.m_TransferButton.onLeftClick = bind(self.WithdrawButton_Click, self)
end

function BankGUI:WithdrawButton_Click()
	local amount = tonumber(self.m_WithdrawAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("bankWithdraw", root, amount)
		self.m_WithdrawAmountEdit:setText("0")
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function BankGUI:DepositButton_Click()
	local amount = tonumber(self.m_DepositAmountEdit:getText())
	if amount and amount > 0 then
		triggerServerEvent("bankDeposit", root, amount)
		self.m_DepositAmountEdit:setText("0")
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function BankGUI:TransferButton_Click()
	local amount = tonumber(self.m_TransferAmountEdit:getText())
	local toCharName = self.m_TransferToEdit:getText()
	if amount and amount > 0 then
		triggerServerEvent("bankTransfer", root, toCharName, amount)
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end
