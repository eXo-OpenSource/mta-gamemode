-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InputBox.lua
-- *  PURPOSE:     Generic input box class
-- *
-- ****************************************************************************
InputBox = inherit(GUIForm)

function InputBox:constructor(title, text, callback, integerOnly, offsetY)
	local offsetY = offsetY or 0

	GUIWindow.updateGrid()
	self.m_Width = grid("x", 21)
	self.m_Height = grid("y", 4 + offsetY)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)

	self.m_Label = GUIGridLabel:new(1, 1, 20, 1 + offsetY, text, self.m_Window)
	self.m_EditBox = GUIGridEdit:new(1, 2 + offsetY, 20, 1, self.m_Window)
	if integerOnly then	self.m_EditBox:setNumeric(true, true) end

	self.m_SubmitButton = GUIGridButton:new(1, 3 + offsetY, 7, 1, _"Bestätigen", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)

	if callback then
		self.m_SubmitButton.onLeftClick = function() if callback then callback(self.m_EditBox:getText()) end delete(self) end
	end

	--[[
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.18/2, screenWidth*0.4, screenHeight*0.18)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.17, text, self.m_Window)
	self.m_EditBox = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.4, self.m_Width*0.98, self.m_Height*0.2, self.m_Window)
	if integerOnly then	self.m_EditBox:setNumeric(true, true) end

	self.m_SubmitButton = GUIButton:new(self.m_Width*0.01, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.2, _"Bestätigen", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)

	if callback then
		self.m_SubmitButton.onLeftClick = function() if callback then callback(self.m_EditBox:getText()) end delete(self) end
	end
	]]
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

InputBoxWithCheckbox = inherit(GUIForm)

function InputBoxWithCheckbox:constructor(title, text, textCheckbox ,callback, integerOnly, offsetY)
	local offsetY = offsetY or 0

	GUIWindow.updateGrid()
	self.m_Width = grid("x", 21)
	self.m_Height = grid("y", 4 + offsetY)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)

	self.m_Label = GUIGridLabel:new(1, 1, 20, 1 + offsetY, text, self.m_Window)
	self.m_EditBox = GUIGridEdit:new(1, 2 + offsetY, 20, 1, self.m_Window)
	if integerOnly then	self.m_EditBox:setNumeric(true, true) end

	self.m_Checkbox = GUIGridCheckbox:new(8, 3 + offsetY, 1, 1, _(textCheckbox), self.m_Window)
	self.m_SubmitButton = GUIGridButton:new(1, 3 + offsetY, 6, 1, _"Bestätigen", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)

	if callback then
		self.m_SubmitButton.onLeftClick = function() if callback then callback(self.m_EditBox:getText(), self.m_Checkbox:isChecked()) end delete(self) end
	end
end