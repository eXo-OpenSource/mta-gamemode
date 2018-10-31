AdminVehicleEditGUI = inherit(GUIForm)
--inherit(Singleton, AdminVehicleEditGUI)

function AdminVehicleEditGUI:constructor(vehicle)
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 11) 	-- width of the window
	self.m_Height = grid("y", 8) 	-- height of the window

	self.m_Cache = {
		OwnerType = getElementData(vehicle, "OwnerType"),
		OwnerID = getElementData(vehicle, "OwnerID"),
	}

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrzeug editieren", true, true, self)

	GUIGridLabel:new(1, 1, 10, 1, "Eigenschaften", self.m_Window):setHeader("sub")

    GUIGridLabel:new(1, 2, 2, 1, "Klasse", self.m_Window)
	if not self.m_Cache.OwnerType then
		GUIGridLabel:new(3, 2, 4, 1, "nicht verfügbar", self.m_Window)
	else
		self.m_OwnerTypeCombo = GUIGridCombobox:new(3, 2, 4, 1, "Fahrzeug-Typ...", self.m_Window):setVisible(false)
		for i,v in ipairs(VehicleTypeName) do
			local item  = self.m_OwnerTypeCombo:addItem(i.." - "..v)
			item.m_OwnerTypeIndex = i
			item.m_OwnerTypeName = v
			if self.m_Cache.OwnerType == v then
				self.m_OwnerTypeCombo:setSelectedItem(i)
			end
		end
		self.m_OwnerTypeCombo.onSelectItem = function(...) self:loadOwnerSettings(...) end
	end

	GUIGridLabel:new(1, 3, 2, 1, "Besitzer", self.m_Window)
	if not self.m_Cache.OwnerID then
		GUIGridLabel:new(3, 3, 4, 1, "nicht verfügbar", self.m_Window)
	else
		self.m_OwnerEdit = GUIGridEdit:new(3, 3, 4, 1, self.m_Window)
			:setText(self.m_Cache.OwnerID or 0):setVisible(false)
		self.m_OwnerCombo = GUIGridCombobox:new(3, 3, 4, 1, "Besitzer...", self.m_Window):setVisible(false)
		self.m_TransferToSelfBtn = GUIGridButton:new(7, 3, 4, 1, "Auf mich übertragen", self.m_Window):setVisible(false)
		self.m_TransferToSelfBtn.onLeftClick = function()
			if self:getSelectedOwnerType() == "player" then
				self.m_OwnerEdit:setText(localPlayer:getPrivateSync("Id"))
			elseif self:getSelectedOwnerType() == "group" then
				self.m_OwnerEdit:setText(localPlayer:getPublicSync("GroupId"))
			end
		end
		--self:loadOwnerSettings(self.m_OwnerTypeCombo:getSelectedItem())
	end

	self.m_SaveButton = GUIGridButton:new(6, 5, 5, 1, "Speichern", self.m_Window):setBarEnabled(false)
	self.m_SaveButton.onLeftClick = function()
		local newModel = self:parseModelInput()
		if newModel then --don't bother with other things if it is not a valid model
			local changes = {}
			if newModel ~= vehicle:getModel() then -- model has been changed
				changes.Model = newModel
			end
			local newOwnerID = tonumber(self.m_OwnerEdit:getText())
			if self:getSelectedOwnerType() == "faction" or self:getSelectedOwnerType() == "company" then
				--newOwnerID = self.m_OwnerCombo:getSelectedItem().m_OwnerId
			end
			if not newOwnerID then
				ErrorBox:new(_"Der Besitzer konnte nicht gefunden werden! Die Eingabe muss entweder eine Fraktion / ein Unternehmen aus der Combo Box oder die ID (Zahl) des Spielers / der Gruppe sein.")
				return false
			end
			if self.m_Cache.OwnerID ~= newOwnerID then
				changes.OwnerID = newOwnerID
			end
			if self.m_Cache.OwnerType ~= self:getSelectedOwnerType() then
				changes.OwnerType = self:getSelectedOwnerType()
			end
			triggerServerEvent("adminVehicleEdit", localPlayer, vehicle, changes)
		end
	end

	GUIGridLabel:new(1, 4, 5, 1, "Modell", self.m_Window)
	self.m_ModelEdit = GUIGridEdit:new(3, 4, 4, 1, self.m_Window)
		:setText(vehicle:getModel())
	GUIGridButton:new(7, 4, 4, 1, "Modell suchen", self.m_Window):setVisible(false)

	GUIGridLabel:new(1, 6, 10, 1, "Optionen", self.m_Window):setHeader("sub")
	self.m_TextureChangeButton = GUIGridButton:new(1, 7, 5, 1, "Textur verwalten", self.m_Window)
	self.m_TextureChangeButton.onLeftClick = function()
		if core:get("Other", "TextureMode", TEXTURE_LOADING_MODE.DEFAULT) == TEXTURE_LOADING_MODE.NONE then
			ErrorBox:new("Du musst die Fahrzeugtexturen aktivieren, um sie zu editieren (lol).")
			return
		end
		triggerServerEvent("adminVehicleGetTextureList", localPlayer, vehicle)
	end
	self.m_ELSChangeButton = GUIGridButton:new(6, 7, 5, 1, "ELS ändern", self.m_Window)
	self.m_ELSChangeButton.onLeftClick = function() --func-ception, or should I call it... funk-ception???? OMG why am I writing this - MasterM
		AdminVehicleELSEditGUI:new(function(name)
			triggerServerEvent("adminVehicleEdit", localPlayer, vehicle, {["ELS"] = name})
		end)
	end

end

function AdminVehicleEditGUI:parseModelInput()
	local input = self.m_ModelEdit:getText()
	if tonumber(input) then
		input = tonumber(input)
		if input >= 400 and input <= 611 then
			return input
		else
			ErrorBox:new(_"Das Fahrzeugmodell muss zwischen ID 400 und 611 liegen.")
			return false
		end
	else
		local id = getVehicleModelFromName(input)
		if id then
			return id
		else
			ErrorBox:new(_("Das Fahrzeugmodell %s konnte nicht gefunden werden. Bitte benutze die Fahrzeug-ID (zwischen 400 und 611) oder nutze die Suchfunktion.", input))
		end
	end
end

function AdminVehicleEditGUI:getSelectedOwnerType()
	return self.m_OwnerTypeCombo:getSelectedItem().m_OwnerTypeName
end

function AdminVehicleEditGUI:loadOwnerSettings(item)
	if not self.m_OwnerEdit then return false end -- settings are not available
	if item.m_OwnerTypeName == "faction" or item.m_OwnerTypeName == "company" then -- show a combo of options
		self.m_OwnerEdit:setVisible(false)
		self.m_OwnerCombo:setVisible(true)
		self.m_TransferToSelfBtn:setVisible(false)
		self.m_OwnerCombo:clear()
		if item.m_OwnerTypeName == "faction" then
			for i, v in pairs(FactionManager.Map) do
				local item = self.m_OwnerCombo:addItem(v:getShortName())
				item.m_OwnerId = i
			end
		else
			for i, v in pairs(CompanyManager.Map) do
				local item = self.m_OwnerCombo:addItem(v:getShortName())
				item.m_OwnerId = i
			end
		end
	else -- show an edit box for the ids
		self.m_OwnerEdit:setVisible(true)
		self.m_OwnerCombo:setVisible(false)
		self.m_TransferToSelfBtn:setVisible(true)

	end
end

function AdminVehicleEditGUI:destructor()
	GUIForm.destructor(self)
end



AdminVehicleELSEditGUI = inherit(GUIForm)
inherit(Singleton, AdminVehicleELSEditGUI)

function AdminVehicleELSEditGUI:constructor(callback)
	local callback = callback
	GUIWindow.updateGrid()			-- initialise the grid function to use a window
	self.m_Width = grid("x", 6) 	-- width of the window
	self.m_Height = grid("y", 8) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"ELS", true, true, self)
	self.m_Grid = GUIGridGridList:new(1, 1, 5, 6, self.m_Window)
	self.m_Grid:addColumn("ELS Name", 1)
	self.m_Grid:addItem("(KEINS)").name = "__REMOVE"
	for name in pairs(ELS_PRESET) do
		self.m_Grid:addItem(tonumber(name) and getVehicleNameFromModel(name) or name).name = name
	end
	self.m_Button = GUIGridButton:new(1, 7, 5, 1, _"Auswählen", self.m_Window)
	self.m_Button:setBarEnabled(false):setBackgroundColor(Color.Green)
	self.m_Button.onLeftClick = function()
		if self.m_Grid:getSelectedItem() then
			callback(self.m_Grid:getSelectedItem().name)
		end
	end
end

function AdminVehicleELSEditGUI:destructor()
	GUIForm.destructor(self)
end
