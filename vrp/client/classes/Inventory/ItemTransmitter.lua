ItemTransmitter = inherit(GUIForm)
inherit(Singleton, ItemTransmitter)

local instance = nil
addEvent("promptTransmitter", true)
addEventHandler("promptTransmitter", localPlayer,
	function(id)
		if not instance then
			instance = ItemTransmitter:new(id)
		else 
			instance:setIdLabel( id )
		end
	end
)

function ItemTransmitter:constructor( id )
	GUIWindow.updateGrid()        
	self.m_Width = grid("x", 9) 
	self.m_Height = grid("y", 4) 

	GUIForm.constructor(self, screenWidth/2-(350/2)/2, 300, self.m_Width, self.m_Height, true)	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Transmitter", true, false, self)
	--GUIGridRectangle:new(0, 0, 9, 4, tocolor(10, 0, 0, 150), self.m_Window)	
	self.m_FreqNameLabel = GUIGridLabel:new(1, 1, 3, 1, "Frequenz-Name:", self.m_Window):setFont(VRPFont(22, Fonts.EkMukta))
	self.m_FrequencyName = GUIGridEdit:new(4,1,5,1, self.m_Window):setColorRGB(0, 60, 0, 255):setFont(VRPFont(24, Fonts.Digital)):setMaxLength(4)
	self.m_FreqCodeLabel = GUIGridLabel:new(1, 2, 3, 1, "Frequenz:", self.m_Window):setFont(VRPFont(22, Fonts.EkMukta))
	self.m_FrequencyCode = GUIGridEdit:new(4,2,5,1, self.m_Window):setColorRGB(0, 60, 0, 255):setFont(VRPFont(24, Fonts.Digital)):setMaxLength(6)
	self.m_AcceptButton = GUIGridButton:new(1, 3, 4, 1, FontAwesomeSymbols.Close, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(140, 0, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_AcceptButton.onLeftClick = bind(self.closeForm, self)
	self.m_DeclineButton = GUIGridButton:new(5, 3, 4, 1,  FontAwesomeSymbols.Accept, self.m_Window):setFont(FontAwesome(20)):setColor(tocolor(0, 140, 0, 255)):setBarEnabled(false):setBackgroundColor(tocolor(90, 90, 90, 255))
	self.m_DeclineButton.onLeftClick = bind(self.submitForm, self)
	self:setIdLabel( id ) 
end

function ItemTransmitter:setIdLabel( id ) 
	if self.m_Window then 
		self.m_Window:setTitleBarText ( "Transmitter #"..id )
	end
end

function ItemTransmitter:destructor()
	GUIForm.destructor(self)
	instance = nil
end

function ItemTransmitter:closeForm() 
	delete(self)
end

function ItemTransmitter:submitForm() 
	local freqCode = self.m_FrequencyCode:getText()
	local freqName = self.m_FrequencyName:getText()
	if (freqCode and #freqCode > 0) and (freqName and #freqName > 0) then 
		triggerServerEvent("onTransmitterDataChange", localPlayer, freqCode, freqName)
		delete(self)
	end
end