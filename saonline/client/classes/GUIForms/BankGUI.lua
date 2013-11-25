-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BankGUI.lua
-- *  PURPOSE:     Bank (ATM) GUI class
-- *
-- ****************************************************************************
BankGUI = inherit(GUIForm) -- 431 252

function BankGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.3, screenHeight*0.4)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Bank ATM", true, true, self)
	self.m_HeaderImage = GUIImage:new(self.m_Width*0.01, self.m_Height*0.11, self.m_Width*0.98, self.m_Height*0.25, "files/images/BankHeader.png", self.m_Window)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.37, self.m_Width*0.25, self.m_Height*0.15, _"Account balance:", 1, self.m_Window):setFont(VRPFont(20)):setColor(Color.Green)
	GUILabel:new(self.m_Width*0.26, self.m_Height*0.37, self.m_Width*0.34, self.m_Height*0.15, "1.000.000$", 1, self.m_Window):setFont(VRPFont(20)):setColor(Color.Red)
	
	self.m_TabPanel = GUITabPanel:new(self.m_Width*0.02, self.m_Height*0.45, self.m_Width-2*self.m_Width*0.02, self.m_Height*0.52, self.m_Window)
	local tabWidth, tabHeight = self.m_TabPanel:getSize()
	
	self.m_TabWithdraw = self.m_TabPanel:addTab(_"Withdraw")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Amount:", 1, self.m_TabWithdraw):setFont(VRPFont(20))
	self.m_WithdrawAmountEdit = GUIEdit:new(tabWidth*0.2, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabWithdraw)
	self.m_WithdrawButton = GUIButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Withdraw", self.m_TabWithdraw)
	
	self.m_TabDeposit = self.m_TabPanel:addTab(_"Deposit")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"Amount:", 1, self.m_TabDeposit):setFont(VRPFont(20))
	self.m_DepositAmountEdit = GUIEdit:new(tabWidth*0.2, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabDeposit)
	self.m_DepositButton = GUIButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Deposit", self.m_TabDeposit)
	
	self.m_TabTransfer = self.m_TabPanel:addTab(_"Transfer")
	GUILabel:new(tabWidth*0.03, tabHeight*0.07, tabWidth*0.15, tabHeight*0.15, _"To:", 1, self.m_TabTransfer):setFont(VRPFont(20))
	self.m_TransferToEdit = GUIEdit:new(tabWidth*0.2, tabHeight*0.07, tabWidth*0.5, tabHeight*0.15, self.m_TabTransfer)
	GUILabel:new(tabWidth*0.03, tabHeight*0.28, tabWidth*0.15, tabHeight*0.15, _"Amount:", 1, self.m_TabTransfer):setFont(VRPFont(20))
	self.m_TransferAmountEdit = GUIEdit:new(tabWidth*0.2, tabHeight*0.28, tabWidth*0.5, tabHeight*0.15, self.m_TabTransfer)
	self.m_TransferButton = GUIButton:new(tabWidth*0.03, tabHeight*0.55, tabWidth*0.7, tabHeight*0.2, _"Transfer", self.m_TabTransfer)
end

addCommandHandler("bank", function() BankGUI:new() end)
