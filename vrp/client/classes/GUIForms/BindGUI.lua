BindGUI = inherit(GUIForm)

BindGUI.Modifiers = {
	[0] = "Ohne";
	["lalt"] = "Alt links",
	["ralt"] = "Alt rechts",
	["lctrl"] = "Strg links",
	["rctrl"] = "Strg rechts",
	["lshift"] = "Shift links",
	["rshift"] = "Shift rechts"
}

BindGUI.Headers = {
	["faction"] = "Fraktion",
	["company"] = "Unternehmen",
	["group"] = "Firma/Gang"
}

BindGUI.Functions = {
	["say"] = "Chat (/say)",
	["s"] = "schreien (/s)",
	["f"] = "flüstern (/l)",
	["t"] = "Fraktion (/t)",
	["me"] = "me (/me)",
	["u"] = "Unternehmen",
	["f"] = "Firma/Gang (/f)",
	["b"] = "Bündnis (/b)",
	["g"] = "Beamten (/g)",
}

addRemoteEvents{"bindReceive"}

function BindGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Binds", true, true, self)
	self.m_Window:deleteOnClose(true)

	self.m_Grid = GUIGridList:new(self.m_Width*0.02, 40+self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.595, self)
	self.m_Grid:addColumn("Funktion", 0.2)
	self.m_Grid:addColumn("Text", 0.6)
	self.m_Grid:addColumn("Tasten", 0.2)

	self.m_Footer = {}

	self.m_AddBindButton = GUIButton:new(self.m_Width*0.63, 40, self.m_Width*0.35, self.m_Height*0.07, "neuen Bind hinzufügen", self.m_Window):setBackgroundColor(Color.Green)
  	self.m_AddBindButton.onLeftClick = function()
		self:changeFooter("new")
		self.m_NewText:setText("")
		self.m_AddNewBindButton:setVisible(true)
		self.m_EditBindButton:setVisible(false)
		self.m_DeleteBindButton:setVisible(false)
	end

	--default Bind
	self.m_Footer["default"] = GUIElement:new(0, 40+self.m_Height*0.66, self.m_Width, self.m_Height*0.4-40, self.m_Window)

	--Local Bind
	self.m_Footer["local"] = GUIElement:new(0, 40+self.m_Height*0.66, self.m_Width, self.m_Height*0.4-40, self.m_Window)

	GUILabel:new(self.m_Width*0.02, self.m_Height*0.01, self.m_Width*0.25, self.m_Height*0.06, "Taste 1:", self.m_Footer["local"])
	GUILabel:new(self.m_Width*0.30, self.m_Height*0.01, self.m_Width*0.2, self.m_Height*0.06, "Taste 2:", self.m_Footer["local"])
	self.m_HelpChanger = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.07, self.m_Width*0.25, self.m_Height*0.07, self.m_Footer["local"]):setBackgroundColor(Color.LightBlue)
	for index, name in pairs(BindGUI.Modifiers) do
		self.m_HelpChanger:addItem(name)
	end
	GUILabel:new(self.m_Width*0.27, self.m_Height*0.07, self.m_Width*0.07, self.m_Height*0.07, " + ", self.m_Footer["local"])
	self.m_SelectedButton = GUIButton:new(self.m_Width*0.3, self.m_Height*0.07, self.m_Width*0.18, self.m_Height*0.07, " ", self.m_Footer["local"]):setBackgroundColor(Color.LightBlue):setFontSize(1.2)
  	self.m_SelectedButton.onLeftClick = function () self:waitForKey() end
	self.m_SaveBindButton = GUIButton:new(self.m_Width*0.5, self.m_Height*0.07, self.m_Width*0.2, self.m_Height*0.07, "Speichern", self.m_Footer["local"]):setBackgroundColor(Color.Green)
  	self.m_SaveBindButton.onLeftClick = function () self:saveBind() end
	self.m_DeleteBindButton = GUIButton:new(self.m_Width*0.73, self.m_Height*0.07, self.m_Width*0.25, self.m_Height*0.07, "Bind Löschen", self.m_Footer["local"]):setBackgroundColor(Color.Red)
  	self.m_DeleteBindButton.onLeftClick = function () self:deleteBind() end
	self.m_ChangeBindButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.16, self.m_Width*0.25, self.m_Height*0.07, "Bind ändern", self.m_Footer["local"]):setBackgroundColor(Color.Orange)
  	self.m_ChangeBindButton.onLeftClick = function () self:editBind() end

	--Remote Bind
	self.m_Footer["remote"] = GUIEleement:new(0, 40+self.m_Height*0.66, self.m_Width, self.m_Height*0.4-40, self.m_Window)
	self.m_CopyButton = GUIButton:new(self.m_Width*0.02, self.m_Height*0.07, self.m_Width*0.35, self.m_Height*0.07, "Diesen Bind verwenden", self.m_Footer["remote"]):setBackgroundColor(Color.Green)
  	self.m_CopyButton.onLeftClick = function () self:copyBind() end


	--New Bind
	self.m_Footer["new"] = GUIElement:new(0, 40+self.m_Height*0.66, self.m_Width, self.m_Height*0.4-40, self.m_Window)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.16, self.m_Width*0.25, self.m_Height*0.07, "Funktion:", self.m_Footer["new"])
	self.m_FunctionChanger = GUIChanger:new(self.m_Width*0.18, self.m_Height*0.16, self.m_Width*0.3, self.m_Height*0.07, self.m_Footer["new"]):setBackgroundColor(Color.LightBlue)
	for index, name in pairs(BindGUI.Functions) do
		self.m_FunctionChanger:addItem(name)
	end
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.01, self.m_Width*0.25, self.m_Height*0.07, "Nachricht:", self.m_Footer["new"])
	self.m_NewText = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.07, self.m_Width*0.96, self.m_Height*0.07, self.m_Footer["new"])
	self.m_AddNewBindButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.16, self.m_Width*0.25, self.m_Height*0.07, "Hinzufügen", self.m_Footer["new"]):setBackgroundColor(Color.Green):setVisible(false)
  	self.m_AddNewBindButton.onLeftClick = function () self:editAddBind() end
	self.m_EditBindButton = GUIButton:new(self.m_Width*0.74, self.m_Height*0.16, self.m_Width*0.25, self.m_Height*0.07, "Ändern", self.m_Footer["new"]):setBackgroundColor(Color.Orange):setVisible(false)
  	self.m_EditBindButton.onLeftClick = function () self:editAddBind(self.m_SelectedBind) end

	for index, footer in pairs(self.m_Footer) do
		if index ~= "default" then
			footer:setVisible(false)
		end
	end

	self.m_onKeyBind = bind(self.onKeyPressed, self)
	self:loadBinds()

    addEventHandler("bindReceive", root, bind(self.Event_onReceive, self))
end

function BindGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
end

function BindGUI:loadBinds()
	self.m_Grid:clear()

	self.m_Grid:addItemNoClick("Deine Binds", "", "")
	self:loadLocalBinds()

	triggerServerEvent("bindRequestPerOwner", localPlayer, "faction")
	triggerServerEvent("bindRequestPerOwner", localPlayer, "company")
	triggerServerEvent("bindRequestPerOwner", localPlayer, "group")
end

function BindGUI:loadLocalBinds()
	local keys, item
	local binds = BindManager:getSingleton():getBinds()

	for index, data in pairs(binds) do
		if not data.keys or #data.keys == 0 then
			keys = "-keine-"
		elseif #data.keys == 1 then
			keys = BindGUI.Modifiers[data.keys[1]] and BindGUI.Modifiers[data.keys[1]] or data.keys[1]:upper()
		else
			keys = table.concat({BindGUI.Modifiers[data.keys[1]] and BindGUI.Modifiers[data.keys[1]] or data.keys[1]:upper(), BindGUI.Modifiers[data.keys[2]] and BindGUI.Modifiers[data.keys[2]] or data.keys[2]:upper()}, " + ")
		end
		item = self.m_Grid:addItem(data.action.name, data.action.parameters, keys)
		item.index = index
		item.type = "local"
		item.action =  data.action.name
		item.parameter =  data.action.parameters
		item.onLeftClick = bind(self.onBindSelect, self, item, index)
	end
end

function BindGUI:addBackButton(callBack)
	if self.m_Window then
		self.m_Window:addBackButton(function () callBack() delete(self) end)
	end
end

function BindGUI:waitForKey ()
    self.m_SelectedButton:setText("...")
    addEventHandler("onClientKey", root, self.m_onKeyBind)
end

function BindGUI:copyBind()
	local item = self.m_SelectedBind
	if item and item.type and item.type == "server" then
		BindManager:getSingleton():addBind(item.action, item.parameter)
		self:loadBinds()
	else
		ErrorBox:new(_"Keine Bind ausgewählt!")
	end
end

function BindGUI:Event_onReceive(type, id, binds)
	local item
	self.m_Grid:addItemNoClick(BindGUI.Headers[type], "", "")
	for id, data in pairs(binds) do
		item = self.m_Grid:addItem(data["Func"], data["Message"], "-keine-")
		item.type = "server"
		item.action =  data["Func"]
		item.parameter =  data["Message"]
		item.onLeftClick = bind(self.onBindSelect, self, item)
	end
end

function BindGUI:changeFooter(target)
	for index, footer in pairs(self.m_Footer) do
		if index == target then
			footer:setVisible(true)
		else
			footer:setVisible(false)
		end
	end
end

function BindGUI:onBindSelect(item, index)
    self.m_SelectedBind = item
	if item.type == "local" then
		self:changeFooter("local")
		if BindManager:getSingleton().m_Binds[index] and BindManager:getSingleton().m_Binds[index].keys then
			if BindManager:getSingleton().m_Binds[index].keys[1] then
				local key1 = BindManager:getSingleton().m_Binds[index].keys[1]
				if BindGUI.Modifiers[key1] then
					self.m_HelpChanger:setSelectedItem(BindGUI.Modifiers[key1])
				else
					self.m_SelectedButton:setText(key1:upper())
				end
			end
			if BindManager:getSingleton().m_Binds[index].keys[2] then
				local key2 = BindManager:getSingleton().m_Binds[index].keys[2]
				self.m_SelectedButton:setText(key2:upper())
			end
		end

	else
		self:changeFooter("remote")
	end
end

function BindGUI:onKeyPressed(key, press)
    if press == false then
		if not table.find(KeyBindings.DisallowedKeys, key:lower()) then
			if self.m_SelectedBind and self.m_SelectedBind.index then
				self.m_SelectedButton:setText(key:upper())
			else
				ErrorBox:new(_"Keine Belegung in der Liste ausgewählt!")
			end
			removeEventHandler("onClientKey", root, self.m_onKeyBind)
		end
    end
end

function BindGUI:saveBind()
	if self.m_SelectedButton:getText() == "" or self.m_SelectedButton:getText() == " " then return end
	if self.m_SelectedBind and self.m_SelectedBind.index and self.m_SelectedBind.type == "local" then
		local index = self.m_SelectedBind.index
		local helper = table.find(BindGUI.Modifiers, self.m_HelpChanger:getSelectedItem())
		local key = self.m_SelectedButton:getText():lower()
		local result = false
		if helper == 0 then
			result = BindManager:getSingleton():changeKey(index, key)
		else
			result = BindManager:getSingleton():changeKey(index, key, helper)
		end

		if result then
			self:loadBinds()
			SuccessBox:new("Bind erfolgreich geändert!")
		else
			ErrorBox:new("Bind konnte nicht gespeichert werden!")
		end
	else
		ErrorBox:new(_"Keine Belegung in der Liste ausgewählt!")
	end
end

function BindGUI:editBind()
	self.m_AddNewBindButton:setVisible(false)
	self.m_EditBindButton:setVisible(true)
	self:changeFooter("new")
	local item = self.m_SelectedBind
	self.m_FunctionChanger:setSelectedItem(BindGUI.Functions[item.action])
	self.m_NewText:setText(item.parameter)
	self.m_AddNewBindButton:setText("Ändern")
end

function BindGUI:deleteBind()
	if self.m_SelectedBind and self.m_SelectedBind.index and self.m_SelectedBind.type == "local" then
		local index = self.m_SelectedBind.index
		if BindManager:getSingleton():removeBind(index) then
			self:loadBinds()
			SuccessBox:new("Bind gelöscht!")
		else
			ErrorBox:new("Bind konnte nicht gelöscht werden!")
		end
	else
		ErrorBox:new(_"Keine Belegung in der Liste ausgewählt!")
	end
end

function BindGUI:editAddBind(item)
	local parameters = self.m_NewText:getText()
	local name = table.find(BindGUI.Functions, self.m_FunctionChanger:getSelectedItem())
	if parameters:len() >= 1 and name then
		if item then
			if BindManager:getSingleton():editBind(item.index, name, parameters) then
				SuccessBox:new("Bind geändert!")
			else
				ErrorBox:new("Bind konnte nicht geändert werden!")
			end
		else
			BindManager:getSingleton():addBind(name, parameters)
			SuccessBox:new("Bind hinzugefügt! Du kannst nun die Tasten belegen!")
		end
		self:loadBinds()

		self:changeFooter("default")
	end
end

BindManageGUI = inherit(GUIForm)

function BindManageGUI:constructor(ownerType)
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_OwnerType = ownerType

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Binds verwalten", true, true, self)
	self.m_Window:deleteOnClose(true)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, 40+self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.595, self)
	self.m_Grid:addColumn("Funktion", 0.2)
	self.m_Grid:addColumn("Text", 0.8)

	self.m_AddBindButton = GUIButton:new(self.m_Width*0.63, 40, self.m_Width*0.35, self.m_Height*0.07, "neuen Bind hinzufügen", self.m_Window):setBackgroundColor(Color.Green)
  	self.m_AddBindButton.onLeftClick = function()
		self:changeFooter("new")
		self.m_NewText:setText("")
		self.m_AddNewBindButton:setVisible(true)
		self.m_EditBindButton:setVisible(false)
		self.m_DeleteBindButton:setVisible(false)
	end

	self.m_Footer = {}

	--default Bind
	self.m_Footer["default"] = GUIElement:new(0, 40+self.m_Height*0.66, self.m_Width, self.m_Height*0.4-40, self.m_Window)

	--New/Edit Bind
	self.m_Footer["new"] = GUIElement:new(0, 40+self.m_Height*0.66, self.m_Width, self.m_Height*0.4-40, self.m_Window)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.01, self.m_Width*0.25, self.m_Height*0.07, "Nachricht:", self.m_Footer["new"])
	self.m_NewText = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.07, self.m_Width*0.96, self.m_Height*0.07, self.m_Footer["new"])
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.16, self.m_Width*0.25, self.m_Height*0.07, "Funktion:", self.m_Footer["new"])
	self.m_FunctionChanger = GUIChanger:new(self.m_Width*0.18, self.m_Height*0.16, self.m_Width*0.3, self.m_Height*0.07, self.m_Footer["new"]):setBackgroundColor(Color.LightBlue)
	for index, name in pairs(BindGUI.Functions) do
		self.m_FunctionChanger:addItem(name)
	end
	self.m_AddNewBindButton = GUIButton:new(self.m_Width*0.50, self.m_Height*0.16, self.m_Width*0.23, self.m_Height*0.07, "Speichern", self.m_Footer["new"]):setBackgroundColor(Color.Green):setVisible(false)
  	self.m_AddNewBindButton.onLeftClick = function () self:editAddBind() end
	self.m_EditBindButton = GUIButton:new(self.m_Width*0.50, self.m_Height*0.16, self.m_Width*0.23, self.m_Height*0.07, "Ändern", self.m_Footer["new"]):setBackgroundColor(Color.Orange):setVisible(false)
  	self.m_EditBindButton.onLeftClick = function () self:editAddBind(self.m_SelectedBind) end
	self.m_DeleteBindButton = GUIButton:new(self.m_Width*0.75, self.m_Height*0.16, self.m_Width*0.23, self.m_Height*0.07, "Löschen", self.m_Footer["new"]):setBackgroundColor(Color.Red):setVisible(false)
  	self.m_DeleteBindButton.onLeftClick = function () self:deleteBind() end

	for index, footer in pairs(self.m_Footer) do
		if index ~= "default" then
			footer:setVisible(false)
		end
	end

    addEventHandler("bindReceive", root, bind(self.Event_onReceive, self))
	triggerServerEvent("bindRequestPerOwner", localPlayer, self.m_OwnerType)
end

function BindManageGUI:addBackButton(callBack)
	if self.m_Window then
		self.m_Window:addBackButton(function () callBack() delete(self) end)
	end
end

function BindManageGUI:changeFooter(target)
	for index, footer in pairs(self.m_Footer) do
		if index == target then
			footer:setVisible(true)
		else
			footer:setVisible(false)
		end
	end
end

function BindManageGUI:Event_onReceive(type, id, binds)
	self.m_Grid:clear()
	self.m_Grid:addItemNoClick(BindGUI.Headers[type], "")
	for id, data in pairs(binds) do
		item = self.m_Grid:addItem(data["Func"], data["Message"])
		item.action =  data["Func"]
		item.parameter =  data["Message"]
		item.id = id
		item.onLeftClick = bind(self.onBindSelect, self, item)
	end
end

function BindManageGUI:editAddBind(item)
	local parameters = self.m_NewText:getText()
	local name = table.find(BindGUI.Functions, self.m_FunctionChanger:getSelectedItem())
	if parameters:len() >= 1 and name then
		if item and item.id then
			triggerServerEvent("bindEditServerBind", localPlayer, self.m_OwnerType, item.id, name, parameters)
		else
			triggerServerEvent("bindAddServerBind", localPlayer, self.m_OwnerType, name, parameters)
		end
		self:changeFooter("default")
	end
end

function BindManageGUI:deleteBind()
	if self.m_SelectedBind and self.m_SelectedBind.id then
		triggerServerEvent("bindDeleteServerBind", localPlayer, self.m_OwnerType, self.m_SelectedBind.id)
	end
	self:changeFooter("default")
end

function BindManageGUI:onBindSelect(item)
    self.m_SelectedBind = item
	self:changeFooter("new")
	self.m_FunctionChanger:setSelectedItem(BindGUI.Functions[item.action])
	self.m_NewText:setText(item.parameter)
	self.m_EditBindButton:setVisible(true)
	self.m_DeleteBindButton:setVisible(true)
	self.m_AddNewBindButton:setVisible(false)
end
