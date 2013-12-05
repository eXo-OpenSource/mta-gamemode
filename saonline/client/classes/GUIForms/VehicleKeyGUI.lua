-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleKeyGUI.lua
-- *  PURPOSE:     Vehicle key management GUI
-- *
-- ****************************************************************************
VehicleKeyGUI = inherit(GUIForm)

function VehicleKeyGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3/ASPECT_RATIO_MULTIPLIER/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.3/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Key management", true, true, self)
	self.m_Keyname = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.12, self.m_Width*0.65, self.m_Height*0.1, self)
	self.m_Keyname:setCaption(_"Enter a player name")
	self.m_Keyname:setFont(VRPFont(self.m_Height*0.08))
	self.m_AddButton = GUIButton:new(self.m_Width*0.67, self.m_Height*0.12, self.m_Width*0.32, self.m_Height*0.1, _"Add key", self):setBackgroundColor(Color.Green)
	
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.25, self.m_Width*0.5, self.m_Height*0.08, _"Current keys: ", 1, self):setFont(VRPFont(self.m_Height*0.07))
	self.m_KeysGrid = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.33, self.m_Width*0.65, self.m_Height*0.65, self)
	self.m_KeysGrid:addColumn("Name", 0.9)
	for i=1, 5 do
		self.m_KeysGrid:addItem("Item "..i)
	end
	self.m_RemoveButton = GUIButton:new(self.m_Width*0.67, self.m_Height*0.33, self.m_Width*0.32, self.m_Height*0.1, _"Remove key", self):setBackgroundColor(Color.Red)
end

addCommandHandler("key", function() VehicleKeyGUI:new() end)
