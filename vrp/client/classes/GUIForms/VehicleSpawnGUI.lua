-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/VehicleSpawnGUI.lua
-- *  PURPOSE:     VehicleSpawnGUI class
-- *
-- ****************************************************************************
VehicleSpawnGUI = inherit(GUIForm)
inherit(Singleton, VehicleSpawnGUI)

function VehicleSpawnGUI:constructor(spawnerId, vehicleList, showEPTAdvertisement)
	GUIForm.constructor(self, screenWidth/2 - screenWidth/4/2, screenHeight/2 - screenHeight/2.5/2, screenWidth/4, screenHeight/2.5)
	self.m_SpawnerId = spawnerId

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug erstellen", true, true, self)
	self.m_VehicleGrid = GUIGridList:new(5, 35, self.m_Width - 10, self.m_Height - (showEPTAdvertisement and 85*2 or 85), self.m_Window)
	self.m_VehicleGrid:addColumn(_"Fahrzeug", 1.0)
	for k, v in pairs(vehicleList) do
		self.m_VehicleGrid:addItem(VehicleCategory:getSingleton():getModelName(k)).onLeftDoubleClick = bind(self.SpawnButton_Click, self)
	end

	self.m_SpawnButton = GUIButton:new(5, self.m_Height - (showEPTAdvertisement and 85 + 45 or 45), self.m_Width - 10, 40, _"Spawn", self.m_Window):setBarEnabled(true)
	self.m_SpawnButton.onLeftClick = bind(self.SpawnButton_Click, self)

	if showEPTAdvertisement then
		GUIRectangle:new(5, self.m_Height - 84, self.m_Width - 10, 1, Color.Grey, self.m_Window)
		GUIRectangle:new(5, self.m_Height - 86, self.m_Width - 10, 1, Color.Grey, self.m_Window)
		--GUIImage:new(5, self.m_Height - 85, 80, 80, "...", self.m_Window) -- EPT Logo
		GUILabel:new(5, self.m_Height - 85, self.m_Width - 10, 30, "Oder doch lieber ein Taxi?", self.m_Window)
		GUILabel:new(5, self.m_Height - 85 + 25, self.m_Width - 10, 23, "Sicher, schnell und günstig in LS unterwegs; Rufe gleich das eXo Public Transport (EPT) an!", self.m_Window)
		self.m_CallButton = GUIButton:new(self.m_Width - 130, self.m_Height - 30, 125, 25, "Verbinden", self.m_Window):setBackgroundColor(Color.Orange):setBarEnabled(true)
		self.m_CallButton.onLeftClick = bind(self.CallEPT_Click, self)
	end
end
addEvent("vehicleSpawnGUI", true)
addEventHandler("vehicleSpawnGUI", root, function(...) VehicleSpawnGUI:new(...) end)

function VehicleSpawnGUI:SpawnButton_Click()
	if self.m_VehicleGrid:getSelectedItem() then
		local vehicleId = getVehicleModelFromName(self.m_VehicleGrid:getSelectedItem():getColumnText(1))
		triggerServerEvent("vehicleSpawn", root, self.m_SpawnerId, vehicleId)

		delete(self)
	end
end

function VehicleSpawnGUI:CallEPT_Click()
	if Phone:getSingleton():isOn()then
		Phone:getSingleton():onShow()
		Phone:getSingleton():closeAllApps()
		Phone:getSingleton():openAppByClass(AppCall)


		Phone:getSingleton():getAppByClass(AppCall):openInCall("company", "EPT", CALL_RESULT_CALLING, false)
		triggerServerEvent("callStartSpecial", root, 389)
		delete(self)
	else
		WarningBox:new("Dein Handy ist ausgeschaltet!")
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
		item.m_ItemId = k
		item.onLeftDoubleClick = function ()
			self:AcceptButton_Click()
		end
		item.onLeftClick = function ()
			if self.m_ChangeCallback then
				self.m_ChangeCallback(k)
			end
		end
	end

	self.m_SpawnButton = GUIButton:new(5, self.m_Height - 45, self.m_Width - 10, 40, _"Auswählen", self.m_Window):setBarEnabled(true)
	self.m_SpawnButton.onLeftClick = bind(self.AcceptButton_Click, self)
end

function VehicleTuningItemGrid:AcceptButton_Click()
	if self.m_ItemGrid:getSelectedItem() then
		if self.m_AcceptCallback then
			self.m_AcceptCallback(self.m_ItemGrid:getSelectedItem().m_ItemId)
		end
		self:close()
	end
end
