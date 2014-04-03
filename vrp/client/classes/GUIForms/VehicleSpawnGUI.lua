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
		self.m_VehicleGrid:addItem(getVehicleNameFromModel(k))
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
