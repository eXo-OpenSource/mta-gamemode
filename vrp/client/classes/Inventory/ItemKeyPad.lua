ItemKeyPad = inherit(GUIForm)
inherit(Singleton, ItemKeyPad)

local instance = nil
addEvent("promptKeyPad", true)
addEventHandler("promptKeyPad", localPlayer,
	function(id, object)
		if not instance then
			instance = ItemKeyPad:new(id, object)
		else
			instance:setIdLabel(id)
			instance:setObject(object)
		end
	end
)

addEvent("playKeyPadSound", true)
addEventHandler("playKeyPadSound", root,
	function(object, sound)
		local x,y,z = getElementPosition(object)
		setSoundMaxDistance(playSound3D("files/audio/Items/"..sound..".ogg", x, y, z), 30)
	end
)

function ItemKeyPad:constructor(id, object)
	self.m_Object = object
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 9)
	self.m_Height = grid("y", 3)

	GUIForm.constructor(self, screenWidth/2-(350/2)/2, 300, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Keypad", true, false, self)
	--GUIGridRectangle:new(0, 0, 9, 4, tocolor(10, 0, 0, 150), self.m_Window)
	self.m_KeyPadCode = GUIGridEdit:new(1,1,8,1, self.m_Window):setColorRGB(0, 60, 0, 255):setNumeric(true, true):setMaxLength(5):setMasked("*"):setFont(VRPFont(20, Fonts.Digital))
	self.m_AcceptButton = GUIGridButton:new(1, 2, 4, 1, FontAwesomeSymbols.Close, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(140, 0, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_AcceptButton.onLeftClick = bind(self.closeForm, self)
	self.m_DeclineButton = GUIGridButton:new(5, 2, 4, 1,  FontAwesomeSymbols.Accept, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(0, 140, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_DeclineButton.onLeftClick = bind(self.submitForm, self)
	self:setIdLabel( id )
end

function ItemKeyPad:setIdLabel(id)
	if self.m_Window then
		self.m_Window:setTitleBarText(string.format("Keypad #%s", id))
	end
end

function ItemKeyPad:setObject(object)
	if self.m_Window then
		self.m_Object = object
	end
end

function ItemKeyPad:destructor()
	GUIForm.destructor(self)
	instance = nil
end

function ItemKeyPad:closeForm()
	delete(self)
end

function ItemKeyPad:submitForm()
	local text = self.m_KeyPadCode:getText()
	if #text == 5 then
		triggerServerEvent("onKeyPadSubmit", self.m_Object, text)
		delete(self)
	end
end
