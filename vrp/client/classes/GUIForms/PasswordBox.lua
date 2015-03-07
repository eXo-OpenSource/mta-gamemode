-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PasswordBox.lua
-- *  PURPOSE:     Password box class
-- *
-- ****************************************************************************
PasswordBox = inherit(GUIForm)

function PasswordBox:constructor(password, yesCallback, noCallback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.18/2, screenWidth*0.4, screenHeight*0.18)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Passwort", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.15, "Bitte gebe das Passwort ein:", self.m_Window):setFont(VRPFont(self.m_Height*0.17))
	self.m_PasswordEdit = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.37, self.m_Width*0.98, self.m_Height*0.2, self.m_Window)
	self.m_PasswordEdit:setMasked("*")
	self.m_YesButton = GUIButton:new(self.m_Width*0.1, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.2, _"Bestägigen", self.m_Window):setBackgroundColor(Color.Green)
	self.m_NoButton = GUIButton:new(self.m_Width*0.55, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.2, _"Abbrechen", self.m_Window):setBackgroundColor(Color.Red)

	self.m_YesButton.onLeftClick = function()
		if yesCallback and self.m_PasswordEdit:getText() == password then
			yesCallback()
		else
			ErrorBox:new(_"Das eingegebene Passwort ist falsch!")
		end

		delete(self)
	end
	self.m_NoButton.onLeftClick = function()
		if noCallback then
			noCallback()
		end
		delete(self)
	end
end

addEvent("passwordBox", true)
addEventHandler("passwordBox", root,
	function(password, yesEvent, noEvent, ...)
		local additionalParameters = {...}
		PasswordBox:new(password,
			function()
				if yesEvent then
					triggerServerEvent(yesEvent, root, unpack(additionalParameters))
				end
			end,
			function()
				if noEvent then
					triggerServerEvent(noEvent, root, unpack(additionalParameters))
				end
			end
		)
	end
)