-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InputBox.lua
-- *  PURPOSE:     Generic input box class
-- *
-- ****************************************************************************
InputBox = inherit(GUIForm)

function InputBox:constructor(title, text, callback, integerOnly)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.18/2, screenWidth*0.4, screenHeight*0.18)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.17, text, self.m_Window)
	self.m_EditBox = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.4, self.m_Width*0.98, self.m_Height*0.2, self.m_Window)
	if integerOnly then	self.m_EditBox:setNumeric(true, true) end

	self.m_SubmitButton = VRPButton:new(self.m_Width*0.01, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.2, _"Bestätigen", true, self.m_Window):setBarColor(Color.Green)

	if callback then
		self.m_SubmitButton.onLeftClick = function() if callback then callback(self.m_EditBox:getText()) end delete(self) end
	end
end

function InputBox:setServerTrigger(callback, additionalParameters)
	self.m_SubmitButton.onLeftClick =
		function()
			if callback then
				triggerServerEvent(callback, localPlayer, self.m_EditBox:getText(), unpack(additionalParameters))
			end
			delete(self)
		end
end


addEvent("inputBox", true)
addEventHandler("inputBox", root,
	function(title, text, callback, ...)
		local additionalParameters = {...}
		local inputBox = InputBox:new(title, text)
		inputBox:setServerTrigger(callback, additionalParameters)
	end
)
