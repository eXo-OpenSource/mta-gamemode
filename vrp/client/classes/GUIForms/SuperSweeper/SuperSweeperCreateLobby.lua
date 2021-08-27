-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/SuperSweeperCreateLobby.lua
-- *  PURPOSE:     Super Sweeper Create Lobby GUI
-- *
-- ****************************************************************************
SuperSweeperCreateLobby = inherit(GUIForm)
inherit(Singleton, SuperSweeperCreateLobby)

addRemoteEvents{"superSweeperReceiveCreateData"}


function SuperSweeperCreateLobby:constructor()
	GUIWindow.updateGrid()			
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 16)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Super Sweeper Lobby", true, true, self)
	self.m_Window:addBackButton(function () SuperSweeperLobbyGUI:getSingleton():show() end)
	GUIGridLabel:new(1, 1, 19, 1, _"Warnung: Die Lobby wird gelöscht sobald kein Spieler mehr darin spielt!", self.m_Window):setColor(Color.Red)

	GUIGridLabel:new(1, 2, 3, 1, _"Name:", self.m_Window)
	self.m_Name = GUIGridEdit:new(4, 2, 6, 1, self.m_Window):setMaxLength(32)
	
	GUIGridLabel:new(1, 3, 3, 1, _"Passwort:", self.m_Window)
	self.m_Password = GUIGridEdit:new(4, 3, 6, 1, self.m_Window):setMasked():setMaxLength(32)

	GUIGridLabel:new(1, 4, 3, 1, _"Lobby Größe:", self.m_Window)
	self.m_LobbySize = GUIGridEdit:new(4, 4, 6, 1, self.m_Window):setNumeric(true, true)

	GUIGridLabel:new(1, 5, 3, 1, _"Map:", self.m_Window)
	self.m_MapChanger = GUIGridChanger:new(4, 5, 6, 1, self.m_Window)

	GUIGridLabel:new(1, 6, 3, 1, _"Modus:", self.m_Window)
	self.m_ModeChanger = GUIGridChanger:new(4, 6, 6, 1, self.m_Window)
	self.m_ModeChanger.onChange = bind(self.onChangeMode, self)

	GUIGridLabel:new(11, 2, 3, 1, _"Nachjoinen:", self.m_Window)
	self.m_AllowLateJoin = GUIGridChanger:new(14, 2, 6, 1, self.m_Window)
	self.m_AllowLateJoin:addItem(_"Ja")
	self.m_AllowLateJoin:addItem(_"Nein")
	self.m_AllowLateJoin:setIndex(2)

	GUIGridLabel:new(11, 3, 3, 1, _"Preistyp:", self.m_Window)
	self.m_PriceType = GUIGridChanger:new(14, 3, 6, 1, self.m_Window)

	GUIGridLabel:new(11, 4, 3, 1, _"Eintrittspreis:", self.m_Window)
	self.m_EntryPrice = GUIGridEdit:new(14, 4, 6, 1, self.m_Window):setNumeric(true, true)

	GUIGridLabel:new(1, 7, 3, 1, _"Einstellungen:", self.m_Window)
	self.m_Settings = GUIGridGridList:new(4, 7, 16, 8, self.m_Window)
	self.m_Settings:addColumn(_"Name", 0.5)
	self.m_Settings:addColumn(_"Wert", 0.5)

	GUIGridLabel:new(1, 9, 3, 1, _"Presets:", self.m_Window)
	self.m_LoadPreset = GUIGridButton:new(1, 10, 3, 1, _"Laden", self.m_Window):setBackgroundColor(Color.Accent):setBarEnabled(true)
	self.m_SavePreset = GUIGridButton:new(1, 11, 3, 1, _"Speichern", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)

	self.m_Create = GUIGridButton:new(15, 15, 5, 1, _"Erstellen (500$)", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_Create.onLeftClick = bind(self.createLobby, self)

	addEventHandler("superSweeperReceiveCreateData", root, bind(self.receiveData, self))
end

function SuperSweeperCreateLobby:destructor()
	GUIForm.destructor(self)
end

function SuperSweeperCreateLobby:onShow()
	triggerServerEvent("superSweeperRequestCreateData", root)
end

function SuperSweeperCreateLobby:onHide()
end

function SuperSweeperCreateLobby:onChangeMode(mode)
	if self.m_ModeNames[mode] then
		self.m_SettingValues = {}

		for	key, value in pairs(self.m_ModeSettings[mode]) do
			if value.type == "number" then
				self.m_SettingValues[value.name] = value.default or 0
			elseif value.type == "bool" then
				self.m_SettingValues[value.name] = value.default or true
			elseif value.type == "list/number" then
				self.m_SettingValues[value.name] = {}

				for k, value2 in pairs(value.values) do
					self.m_SettingValues[value.name][value2.name] = value2.default
				end
			elseif value.type == "select" then
				self.m_SettingValues[value.name] = value.default
			end
		end
		
		self.m_PriceType:clear()
		self.m_PriceType:addItem(_"Deaktiviert")
		if self.m_ModeSupportedPriceTypes[mode] then
			for key2, value2 in pairs(self.m_ModeSupportedPriceTypes[mode]) do
				self.m_PriceType:addItem(value2.label)
			end
		end
		self.m_PriceType:setIndex(1)

		self:updateSettingsGrid(mode)
	end
end

function SuperSweeperCreateLobby:updateSettingsGrid(mode)
	if self.m_ModeNames[mode] then
		self.m_Settings:clear()
		for	key, value in pairs(self.m_ModeSettings[mode]) do
			local name = value.label
			local default = _"(...)"

			if value.type == "number" then
				default = tostring(self.m_SettingValues[value.name])
				if value.unit and value.unit ~= "" then
					default = default .. " " .. value.unit
				end
			elseif value.type == "bool" then
				default = self.m_SettingValues[value.name] and _"Ja" or _"Nein"
			elseif value.type == "select" then
				for k, value2 in pairs(value.values) do
					if self.m_SettingValues[value.name] == value2.name then
						default = value2.label
						break
					end
				end
			end

			local item = self.m_Settings:addItem(name, default)
			item.onLeftDoubleClick = bind(self.onSettingClick, self, value.name)
		end
	end
end

function SuperSweeperCreateLobby:onSettingClick(name)
	setTimer(bind(self.handleOnSettingClick, self, name), 100, 1)
end

function SuperSweeperCreateLobby:handleOnSettingClick(name)
	for	key, value in pairs(self.m_ModeSettings[self.m_ModeChanger:getSelectedItem()]) do
		if value.name == name then
			if value.type == "select" then
				local items = {}
				local index = 1
				for k, value2 in pairs(value.values) do
					table.insert(items, value2.label)
					if value2.name == self.m_SettingValues[value.name] then
						index = #items
					end
				end

				ChangerBox:new(value.label, value.description or "", items, bind(self.onSettingChangerSelect, self, name, items), index)
			elseif value.type == "bool" then
				local items = {_"Ja", _"Nein"}
				local index = self.m_SettingValues[value.name] and 1 or 2
				ChangerBox:new(value.label, value.description or "", items, bind(self.onSettingBoolSelect, self, name), index)
			elseif value.type == "number" then
				local val = self.m_SettingValues[value.name]
				InputBox:new(value.label, value.description or "", bind(self.onSettingNumber, self, name), true, 0, val)
			elseif value.type == "list/number" then
				local items = {}

				for key2, value2 in pairs(self.m_SettingValues[value.name]) do
					items[key2] = {label = "", value = value2}
				end

				if self.m_ModeSettings[self.m_ModeChanger:getSelectedItem()][value.name] and
				self.m_ModeSettings[self.m_ModeChanger:getSelectedItem()][value.name].values then
					for key2, value2 in pairs(self.m_ModeSettings[self.m_ModeChanger:getSelectedItem()][value.name].values) do
						items[key2].label = value2.label
					end
				end				

				ListEditBox:new(value.label, value.description or "", items, true, 0, bind(self.onListEditSelect, self, value.name))
			end
		end
	end
end

function SuperSweeperCreateLobby:onListEditSelect(name, values)
	self.m_SettingValues[name] = values
end

function SuperSweeperCreateLobby:onSettingChangerSelect(name, items, index)
	for	key, value in pairs(self.m_ModeSettings[self.m_ModeChanger:getSelectedItem()]) do
		if value.name == name and value.type == "select" then
			local selectedItem = items[index]
			local selectedKey = nil

			for k, value2 in pairs(value.values) do
				if value2.label == selectedItem then
					selectedKey = value2.name
					break
				end
			end

			if not selectedKey then return end
			self.m_SettingValues[value.name] = selectedKey

			self:updateSettingsGrid(self.m_ModeChanger:getSelectedItem())
			break
		end
	end
end

function SuperSweeperCreateLobby:onSettingBoolSelect(name, index)
	for	key, value in pairs(self.m_ModeSettings[self.m_ModeChanger:getSelectedItem()]) do
		if value.name == name and value.type == "bool" then
			self.m_SettingValues[value.name] = index == 1

			self:updateSettingsGrid(self.m_ModeChanger:getSelectedItem())
			break
		end
	end
end

function SuperSweeperCreateLobby:onSettingNumber(name, inputValue)
	for	key, value in pairs(self.m_ModeSettings[self.m_ModeChanger:getSelectedItem()]) do
		if value.name == name and value.type == "number" then
			local inputValue = tonumber(inputValue)
			if not inputValue then return end

			if value.range then
				if value.range.min and inputValue < value.range.min then
					if value.range.max ~= 0 or inputValue ~= 0 then
						ErrorBox:new(_("Der Wert %d unterschreitet den Mindestwert %d!", inputValue, value.range.min))
						return
					end
				end
				if value.range.max and value.range.max ~= 0 and inputValue > value.range.max then
					ErrorBox:new(_("Der Wert %d überschreitet den Maximalwert %d!", inputValue, value.range.max))
					return
				end
			end

			self.m_SettingValues[value.name] = inputValue
			self:updateSettingsGrid(self.m_ModeChanger:getSelectedItem())
			break
		end
	end
end

function SuperSweeperCreateLobby:createLobby()
	local map = self.m_MapNames[self.m_MapChanger:getSelectedItem()]
	local password = self.m_Password:getText() or ""
	triggerServerEvent("superSweeperCreateLobby", localPlayer, map, password, self.m_SettingValues)
	delete(self)
end

function SuperSweeperCreateLobby:receiveData(maps, modes)
	self.m_Name:setText(_("%s's Lobby", localPlayer.name))
	self.m_LobbySize:setText(32)

	self.m_MapNames = {}
	self.m_ModeNames = {}
	self.m_ModeSettings = {}
	self.m_ModeSupportedPriceTypes = {}
	
	for index, mapData in pairs(maps) do
		self.m_MapNames[mapData.name] = index
		self.m_MapChanger:addItem(mapData.name)
	end

	for index, mode in pairs(modes) do
		self.m_ModeNames[mode.name] = index
		self.m_ModeSettings[mode.name] = mode.settings
		self.m_ModeSupportedPriceTypes[mode.name] = mode.supportedPriceTypes
		self.m_ModeChanger:addItem(mode.name)
	end
	self:onChangeMode(self.m_ModeChanger:getSelectedItem())
end
