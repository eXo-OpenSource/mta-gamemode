-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PasswordChangeGUI.lua
-- *  PURPOSE:     PasswordChangeGUI
-- *
-- ****************************************************************************
PasswordChangeGUI = inherit(GUIForm)

function PasswordChangeGUI:constructor()
	GUIForm.constructor(self, screenWidth/2 - 400/2, screenHeight/2 - 245/2, 400, 245)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Passwort ändern", true, true, self)
	GUILabel:new(10, 40, 180, 30, "Altes Passwort:", self.m_Window)
	GUIRectangle:new(10, 80, 380, 2, Color.Accent, self.m_Window)
	GUILabel:new(10, 90, 180, 30, "Neues Passwort:", self.m_Window)
	GUILabel:new(10, 125, 180, 30, "Wiederholung:", self.m_Window)

	self.m_OldPassword = GUIEdit:new(210, 40, 180, 30, self.m_Window):setMasked("*")
	self.m_NewPassword1 = GUIEdit:new(210, 90, 180, 30, self.m_Window):setMasked("*")
	self.m_NewPassword1.onChange = function() self:validate() end
	self.m_NewPassword2 = GUIEdit:new(210, 125, 180, 30, self.m_Window):setMasked("*")
	self.m_NewPassword2.onChange = function() self:validate() end

	self.m_Error = GUILabel:new(10, 160, 380, 30, "", self.m_Window):setColor(Color.Red)

	self.m_SubmitButton = GUIButton:new(10, 195, 380, 40, _"Bestätigen", self.m_Window):setBackgroundColor(Color.Accent):setBarEnabled(true)
	self.m_SubmitButton:setEnabled(false)
	self.m_SubmitButton.onLeftClick = function()
		triggerServerEvent("passwordChange", localPlayer, self.m_OldPassword:getText(), self.m_NewPassword1:getText(), self.m_NewPassword2:getText())
	end

	addRemoteEvents{"passwordChangeSuccess"}
	addEventHandler("passwordChangeSuccess", root, function()
		delete(self)
	end)
end

function PasswordChangeGUI:validate()
	if #self.m_NewPassword1:getText() >= 5 then
		if self.m_NewPassword1:getText() == self.m_NewPassword2:getText() then
			self.m_Error:setText("")
			self.m_SubmitButton:setEnabled(true)
		else
			self.m_Error:setText("Die Passwörter sind nicht identisch!")
			self.m_SubmitButton:setEnabled(false)
		end
	else
		self.m_Error:setText("Passwort zu kurz! Mindestens 5 Zeichen!")
		self.m_SubmitButton:setEnabled(false)
	end
end
