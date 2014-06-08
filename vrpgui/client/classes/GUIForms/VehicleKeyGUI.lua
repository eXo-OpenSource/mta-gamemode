-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleKeyGUI.lua
-- *  PURPOSE:     Vehicle key management GUI
-- *
-- ****************************************************************************
VehicleKeyGUI = inherit(GUIForm)
addEvent("vehicleKeysRetrieve", true)

function VehicleKeyGUI:constructor(vehicleElement)
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3/ASPECT_RATIO_MULTIPLIER/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.3/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4)
	self.m_Element = vehicleElement
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Key management", true, true, self)
	self.m_Keyname = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.12, self.m_Width*0.65, self.m_Height*0.1, self)
	self.m_Keyname:setCaption(_"Enter a player name")
	self.m_Keyname:setFont(VRPFont(self.m_Height*0.08))
	self.m_AddButton = GUIButton:new(self.m_Width*0.67, self.m_Height*0.12, self.m_Width*0.32, self.m_Height*0.1, _"Add key", self):setBackgroundColor(Color.Green)
	self.m_AddButton.onLeftClick = bind(self.AddButton_Click, self)
	
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.25, self.m_Width*0.5, self.m_Height*0.08, _"Current keys: ", self):setFont(VRPFont(self.m_Height*0.07))
	self.m_KeysGrid = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.33, self.m_Width*0.65, self.m_Height*0.65, self)
	self.m_KeysGrid:addColumn("Name", 0.9)
	self.m_KeysGrid:addItem("Loading...")
	self.m_RemoveButton = GUIButton:new(self.m_Width*0.67, self.m_Height*0.33, self.m_Width*0.32, self.m_Height*0.1, _"Remove key", self):setBackgroundColor(Color.Red)
	self.m_RemoveButton.onLeftClick = bind(self.RemoveButton_Click, self)
	
	-- Request the key list
	triggerServerEvent("vehicleRequestKeys", vehicleElement)
	addEventHandler("vehicleKeysRetrieve", vehicleElement,
		function(keyList)
			-- Clear old stuff
			self.m_KeysGrid:clear()
			
			-- Insert new items
			for id, name in pairs(keyList) do
				self.m_KeysGrid:addItem(name).CharacterId = id
			end
		end
	)
end

function VehicleKeyGUI:AddButton_Click()
	if self.m_Keyname:getText() == "" then
		WarningBox:new(_"Please insert a player name")
		return
	end
	
	local player = getPlayerFromName(self.m_Keyname:getText())
	if not player then
		WarningBox:new(_"Please insert a valid player name")
		return
	end
	
	triggerServerEvent("vehicleAddKey", self.m_Element, player)
end

function VehicleKeyGUI:RemoveButton_Click()
	local selectedItem = self.m_KeysGrid:getSelectedItem()
	if not selectedItem then
		WarningBox:new(_"Please select an item")
		return
	end
	
	local characterId = selectedItem.CharacterId
	if characterId then
		triggerServerEvent("vehicleRemoveKey", self.m_Element, characterId)
	end
end
