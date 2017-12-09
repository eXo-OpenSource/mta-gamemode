ItemDoor = inherit(GUIForm)
inherit(Singleton, ItemDoor)

local instance = nil
addEvent("promptDoorOption", true)
addEventHandler("promptDoorOption", localPlayer,
	function(id)
		if not instance then
			instance = ItemDoor:new(id)
		else 
			instance:setIdLabel( id )
		end
	end
)


function ItemDoor:constructor( id )
	GUIForm.constructor(self, screenWidth/2-(350/2)/2, 300, 350, 130, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Keypad", true, false, self)
	GUIRectangle:new(0, 30, self.m_Width, self.m_Height, tocolor(10, 0, 0, 150), self.m_Window)	
	self.m_DoorCode = GUIEdit:new(0,40,self.m_Width, 40, self.m_Window):setColorRGB(0, 60, 0, 255):setNumeric(true, true):setFont(VRPFont(20, Fonts.Digital))
	self.m_AcceptButton = GUIButton:new(350/2 - 120, 90, 90, 30, FontAwesomeSymbols.Close, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(140, 0, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_AcceptButton.onLeftClick = bind(self.closeForm, self)
	self.m_DeclineButton = GUIButton:new(350/2+30, 90, 90, 30, FontAwesomeSymbols.Accept, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(0, 140, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_DeclineButton.onLeftClick = bind(self.submitForm, self)
	self:setIdLabel( id ) 
end

function ItemDoor:setIdLabel( id ) 
	if self.m_Window then 
		self.m_Window:setTitleBarText ( "Gehört zu Keypad #"..id )
	end
end

function ItemDoor:destructor()
	GUIForm.destructor(self)
	instance = nil
end

function ItemDoor:closeForm() 
	delete(self)
end

function ItemDoor:submitForm() 
	local text = self.m_DoorCode:getText()
	if #text > 0 and tonumber(text) then 
		triggerServerEvent("onDoorLinkChange", localPlayer, tonumber(text))
		delete(self)
	end
end