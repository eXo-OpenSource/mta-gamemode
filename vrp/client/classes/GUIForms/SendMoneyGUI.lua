-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SendMoneyGUI.lua
-- *  PURPOSE:     SendMoneyGUI class
-- *
-- ****************************************************************************
SendMoneyGUI = inherit(GUIForm)

function SendMoneyGUI:constructor(func, moneyAmount)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.2/2, screenHeight/2 - screenHeight*0.15/2, screenWidth*0.2, screenHeight*0.15)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Geld senden", true, true, self)
	GUILabel:new(self.m_Width*0.03, self.m_Height*0.31, self.m_Width*0.3, self.m_Height*0.25, _"Betrag:", self.m_Window)
	self.m_Edit = GUIEdit:new(self.m_Width*0.25, self.m_Height*0.32, self.m_Width*0.7, self.m_Height*0.2, self.m_Window):setText(moneyAmount or "0")
	self.m_SendMoneyButton = GUIButton:new(self.m_Width*0.15, self.m_Height*0.64, self.m_Width*0.7, self.m_Height*0.27, _"Senden", self.m_Window):setBackgroundColor(Color.Yellow):setBarEnabled(true)

	self.m_SendMoneyButton.onLeftClick = function()
		local amount = tonumber(self.m_Edit:getText())
		if amount and amount > 0 then
			if getPlayerMoney(localPlayer) >= amount then
				func(amount)
				delete(self)
			else
				ErrorBox:new(_"Du hast nicht genügend Geld!")
			end
		else
			ErrorBox:new(_"Bitte gib eine gültige Zahl ein!")
		end
	end
end
