-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleSpawnGUI.lua
-- *  PURPOSE:     VehicleSpawnGUI class
-- *
-- ****************************************************************************
VehicleSpawnGUI = inherit(GUIForm)

function VehicleSpawnGUI:constructor(spawnerId, vehicleList)
	GUIForm.constructor(self, screenWidth/2 - screenWidth/4/2, screenHeight/2 - screenHeight/2.5/2, screenWidth/4, screenHeight/2.5)
	self.m_SpawnerId = spawnerId

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug erstellen", true, true, self)
	self.m_VehicleGrid = GUIGridList:new(5, 35, self.m_Width - 10, self.m_Height - 85, self.m_Window)
	self.m_VehicleGrid:addColumn(_"Fahrzeug", 1.0)
	for k, v in pairs(vehicleList) do
		self.m_VehicleGrid:addItem(getVehicleNameFromModel(k)).onLeftDoubleClick = bind(self.SpawnButton_Click, self)
	end
	self.m_SpawnButton = VRPButton:new(5, self.m_Height - 45, self.m_Width - 10, 40, _"Spawn", true, self.m_Window)

	self.m_SpawnButton.onLeftClick = bind(self.SpawnButton_Click, self)
end
addEvent("vehicleSpawnGUI", true)
addEventHandler("vehicleSpawnGUI", root, function(spawnerId, vehicleList) VehicleSpawnGUI:new(spawnerId, vehicleList) end)

function VehicleSpawnGUI:SpawnButton_Click()
	if self.m_VehicleGrid:getSelectedItem() then
		local vehicleId = getVehicleModelFromName(self.m_VehicleGrid:getSelectedItem():getColumnText(1))
		triggerServerEvent("vehicleSpawn", root, self.m_SpawnerId, vehicleId)

		self:close()
	end
end


VehicleTuningItemGrid = inherit(GUIForm)

function VehicleTuningItemGrid:constructor(title, itemList, acceptCallback, changeCallback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth/4/2, screenHeight/2 - screenHeight/2.5/2, screenWidth/4, screenHeight/2.5)
	self.m_AcceptCallback = acceptCallback
	self.m_ChangeCallback = changeCallback

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, title, true, true, self)
	self.m_ItemGrid = GUIGridList:new(5, 35, self.m_Width - 10, self.m_Height - 85, self.m_Window)
	self.m_ItemGrid:addColumn("Item", 1.0)
	for k, v in pairs(itemList) do
		local item = self.m_ItemGrid:addItem(v)
		item.m_TextureId = k
		item.onLeftDoubleClick = function ()
			if self.m_AcceptCallback then
				self.m_AcceptCallback(k)
			end
		end
		item.onLeftClick = function ()
			if self.m_ChangeCallback then
				self.m_ChangeCallback(k)
			end
		end
	end

	self.m_SpawnButton = VRPButton:new(5, self.m_Height - 45, self.m_Width - 10, 40, _"Auswählen", true, self.m_Window)
	self.m_SpawnButton.onLeftClick = bind(self.AcceptButton_Click, self)
end

function VehicleTuningItemGrid:AcceptButton_Click()
	if self.m_ItemGrid:getSelectedItem() then
		if self.m_AcceptCallback then
			self.m_AcceptCallback(self.m_ItemGrid:getSelectedItem().m_TextureId)
		end
		self:close()
	end
end
