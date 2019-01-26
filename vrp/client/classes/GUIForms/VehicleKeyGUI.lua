-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleKeyGUI.lua
-- *  PURPOSE:     Vehicle key management GUI
-- *
-- ****************************************************************************
VehicleKeyGUI = inherit(GUIForm)

addRemoteEvents{"vehicleKeysRetrieve"}

function VehicleKeyGUI:constructor(vehicleElement)
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.3/ASPECT_RATIO_MULTIPLIER/2, screenHeight/2-screenHeight*0.4/2, screenWidth*0.3/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4)
	self.m_Element = vehicleElement

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Schlüsselverwaltung", true, true, self)
	self.m_Keyname = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.12, self.m_Width*0.65, self.m_Height*0.1, self)
	self.m_Keyname:setCaption(_"Gib einen Spielernamen ein")
	self.m_Keyname:setFont(VRPFont(self.m_Height*0.08))
	self.m_AddButton = GUIButton:new(self.m_Width*0.67, self.m_Height*0.12, self.m_Width*0.32, self.m_Height*0.1, _"Hinzufügen", self):setBackgroundColor(Color.Green)
	self.m_AddButton.onLeftClick = bind(self.AddButton_Click, self)

	GUILabel:new(self.m_Width*0.01, self.m_Height*0.25, self.m_Width*0.5, self.m_Height*0.08, _"Schlüssel:", self):setFont(VRPFont(self.m_Height*0.07))
	self.m_KeysGrid = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.33, self.m_Width*0.65, self.m_Height*0.65, self)
	self.m_KeysGrid:addColumn("Name", 0.9)
	self.m_KeysGrid:addItem("Loading...").CharacterId = false
	self.m_RemoveButton = GUIButton:new(self.m_Width*0.67, self.m_Height*0.33, self.m_Width*0.32, self.m_Height*0.1, _"Entfernen", self):setBackgroundColor(Color.Red)
	self.m_RemoveButton.onLeftClick = bind(self.RemoveButton_Click, self)

	-- Request the key list
	triggerServerEvent("vehicleRequestKeys", vehicleElement)
	addEventHandler("vehicleKeysRetrieve", vehicleElement,
		function(keyList)
			-- Clear old stuff
			self.m_KeysGrid:clear()

			if type(keyList) == "table" then
				-- Insert new items
				for id, name in pairs(keyList) do
					self.m_KeysGrid:addItem(name).CharacterId = id
				end
			else
				self.m_KeysGrid:addItem(_"Ein Fehler ist aufgetreten!").CharacterId = false
			end
		end
	)
end

function VehicleKeyGUI:AddButton_Click()
	if self.m_Keyname:getText() == "" then
		ErrorBox:new(_"Bitte gib einen Spielernamen ein!")
		return
	end

	local player = getPlayerFromName(self.m_Keyname:getText())
	if not player then
		ErrorBox:new(_"Dieser Spieler ist nicht online!")
		return
	end

	triggerServerEvent("vehicleAddKey", self.m_Element, player)
end

function VehicleKeyGUI:RemoveButton_Click()
	local selectedItem = self.m_KeysGrid:getSelectedItem()
	if not selectedItem then
		ErrorBox:new(_"Bitte wähle ein Item aus!")
		return
	end

	local characterId = selectedItem.CharacterId
	if characterId then
		triggerServerEvent("vehicleRemoveKey", self.m_Element, characterId)
	end
end
