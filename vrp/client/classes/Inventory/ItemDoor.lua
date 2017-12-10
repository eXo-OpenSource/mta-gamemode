ItemDoor = inherit(GUIForm)
inherit(Singleton, ItemDoor)

local instance = nil
addEvent("promptDoorOption", true)
addEventHandler("promptDoorOption", localPlayer,
	function(id, pos)
		if not instance then
			instance = ItemDoor:new(id, pos)
		else 
			instance:setIdLabel( id )
			instance:setPosLabel ( pos ) 
		end
	end
)


function ItemDoor:constructor( id, pos )
	GUIForm.constructor(self, screenWidth/2-(350/2)/2, 300, 350, 200, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Keypad", true, false, self)
	GUIRectangle:new(0, 30, self.m_Width, self.m_Height, tocolor(10, 0, 0, 150), self.m_Window)	
	self.m_CoordLabel = GUILabel:new(0,35, self.m_Width, 20, "Koordinate: "..pos[1].." , "..pos[2].." , "..pos[3], self.m_Window)
	self.m_DoorPosX = GUIEdit:new(2,60, self.m_Width*0.333 - 4, 40, self.m_Window):setColorRGB(0, 60, 0, 255):setNumeric(true, true):setFont(VRPFont(20, Fonts.Digital)):setCaption("X-Position")
	self.m_DoorPosY = GUIEdit:new(self.m_Width*0.333 + 2 ,60, self.m_Width*0.333 - 4, 40, self.m_Window):setColorRGB(0, 60, 0, 255):setNumeric(true, true):setFont(VRPFont(20, Fonts.Digital)):setCaption("Y-Position")
	self.m_DoorPosZ = GUIEdit:new(self.m_Width*0.666 + 2,60, self.m_Width*0.333 - 4, 40, self.m_Window):setColorRGB(0, 60, 0, 255):setNumeric(true, true):setFont(VRPFont(20, Fonts.Digital)):setCaption("Z-Position")
	self.m_EditKeyPadLink = GUIEdit:new(self.m_Width*0.15, 110, self.m_Width*0.3, 40, self.m_Window):setNumeric(true, true):setFont(VRPFont(20, Fonts.Digital)):setCaption("Keypad ID")
	self.m_EditModel = GUIEdit:new(self.m_Width*0.55, 110, self.m_Width*0.3, 40, self.m_Window):setNumeric(true, true):setFont(VRPFont(20, Fonts.Digital)):setCaption("Model")
	self.m_AcceptButton = GUIButton:new(350/2 - 120, 200-35, 90, 30, FontAwesomeSymbols.Close, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(140, 0, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_AcceptButton.onLeftClick = bind(self.closeForm, self)
	self.m_DeclineButton = GUIButton:new(350/2+30, 200-35, 90, 30, FontAwesomeSymbols.Accept, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(0, 140, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_DeclineButton.onLeftClick = bind(self.submitForm, self)
	self:setIdLabel( id ) 
end


function ItemDoor:setIdLabel( id ) 
	if self.m_Window then 
		self.m_Window:setTitleBarText ( "Gehört zu Keypad #"..id )
	end
end

function ItemDoor:setPosLabel( pos ) 
	if self.m_Window then 
		instance.m_CoordLabel:setText ("Koordinate: "..pos[1].." , "..pos[2].." , "..pos[3])
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
	local posX = self.m_DoorPosX:getText()
	local posY = self.m_DoorPosY:getText()
	local posZ = self.m_DoorPosZ:getText()
	local keyPad = self.m_EditKeyPadLink:getText()
	local model = self.m_EditModel:getText()
	triggerServerEvent("onDoorDataChange", localPlayer, posX, posY, posZ, keyPad, model)
	delete(self)
end