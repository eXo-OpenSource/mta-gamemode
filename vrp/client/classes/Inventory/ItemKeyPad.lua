addEvent("promptKeyPad", true)
addEventHandler("promptKeyPad", root,
	function()
		if ItemKeyPad:isInstantiated() then
			delete(ItemKeyPad)
		end
		ItemKeyPad:new(state)
	end
)


ItemKeyPad = inherit(GUIForm)
inherit(Singleton, ItemKeyPad)

function ItemKeyPad:constructor(state)
	GUIForm.constructor(self, screenWidth/2-(350/2)/2, 300, 350, 130, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Keypad", true, false, self)
	GUIRectangle:new(0, 30, self.m_Width, self.m_Height, tocolor(0, 0, 0, 200), self.m_Window)
	self.m_KeyPadCode = GUIEdit:new(0,40,self.m_Width, 40, self.m_Window):setColorRGB(0, 60, 0, 255):setNumeric(true, true):setMaxLength(4):setMasked("*"):setFont(VRPFont(20, Fonts.Digital))
	self.m_AcceptButton = GUIButton:new(350/2 - 120, 90, 90, 30, FontAwesomeSymbols.Close, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(140, 0, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_AcceptButton.onLeftClick = bind(self.closeForm, self)
	self.m_DeclineButton = GUIButton:new(350/2+30, 90, 90, 30, FontAwesomeSymbols.Accept, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(0, 140, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_DeclineButton.onLeftClick = bind(self.submitForm, self)
end

function ItemKeyPad:closeForm() 
	delete(self)
end

function ItemKeyPad:submitForm() 
	local text = self.m_KeyPadCode:getText()
	if #text == 4 then 
		triggerServerEvent("onKeyPadSubmit", localPlayer, text)
		delete(self)
	end
end