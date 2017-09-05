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

function BindGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Binds", true, true, self)
	self.m_Window:deleteOnClose(true)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, 40, self.m_Width*0.96, self.m_Height*0.6, self)
	--self.m_Grid:setFont(VRPFont(20))
	--self.m_Grid:setItemHeight(20)
	self.m_Grid:addColumn("Funktion", 0.2)
	self.m_Grid:addColumn("Text", 0.6)
	self.m_Grid:addColumn("Tasten", 0.2)


	self.m_HelpButton = GUIChanger:new(self.m_Width*0.02, 40+self.m_Height*0.7, self.m_Width*0.25, self.m_Height*0.07, self.m_Window):setBackgroundColor(Color.LightBlue):setVisible(false)
	for index, name in pairs(BindGUI.Modifiers) do
		self.m_HelpButton:addItem(name)

	end

	self.m_CopyButton = GUIButton:new(self.m_Width*0.02, 40+self.m_Height*0.7, self.m_Width*0.25, self.m_Height*0.07, "Bind verwenden", self.m_Window):setFontSize(1.2):setBackgroundColor(Color.Green):setVisible(false)
  	self.m_CopyButton.onLeftClick = function () self:copyBind() end
	self.m_Plus = GUILabel:new(self.m_Width*0.27, 40+self.m_Height*0.7, self.m_Width*0.07, self.m_Height*0.07, " + ", self.m_Window)
	self.m_SelectedButton = GUIButton:new(self.m_Width*0.3, 40+self.m_Height*0.7, self.m_Width*0.2, self.m_Height*0.07, " ", self.m_Window):setBackgroundColor(Color.LightBlue):setFontSize(1.2):setVisible(false)
  	self.m_SelectedButton.onLeftClick = function () self:waitForKey() end

	self.m_onKeyBind = bind(self.onKeyPressed, self)

	self:loadBinds()

	addRemoteEvents{"bindReceive"}
    addEventHandler("bindReceive", root, bind(self.Event_onReceive, self))
end

function BindGUI:loadBinds()
	self.m_Grid:clear()

	self.m_Grid:addItemNoClick("Deine Binds", "", "")
	self:loadLocalBinds()

	triggerServerEvent("bindRequestPerOwner", localPlayer, "faction", localPlayer:getFaction():getId())
	triggerServerEvent("bindRequestPerOwner", localPlayer, "company", localPlayer:getCompany():getId())
	triggerServerEvent("bindRequestPerOwner", localPlayer, "group", localPlayer:getGroupId())
end

function BindGUI:loadLocalBinds()
	local keys
	local binds = BindManager:getSingleton():getBinds()

	for index, data in pairs(binds) do
		if not data.keys or #data.keys == 0 then
			keys = "-keine-"
		elseif #data.keys == 1 then
			keys = BindGUI.Modifiers[data.keys[1]] and BindGUI.Modifiers[data.keys[1]] or data.keys[1]
		else
			keys = table.concat({BindGUI.Modifiers[data.keys[1]] and BindGUI.Modifiers[data.keys[1]] or data.keys[1], BindGUI.Modifiers[data.keys[2]] and BindGUI.Modifiers[data.keys[2]] or data.keys[2]}, " + ")
		end
		item = self.m_Grid:addItem(data.action.name, data.action.parameters, keys)
		item.index = index
		item.type = "local"
		item.onLeftClick = function() self:onBindSelect(item, index) end
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
	local item = self.m_Grid:getSelectedItem()
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
		--item:setFont(VRPFont(20))

		item.type = "server"
		item.action =  data["Func"]
		item.parameter =  data["Message"]
		item.onLeftClick = function() self:onBindSelect(item) end
	end
end

function BindGUI:onBindSelect(item, index)
    if item.type == "local" then
		self.m_HelpButton:setVisible(true)
		self.m_SelectedButton:setVisible(true)
		self.m_CopyButton:setVisible(false)
		if BindManager:getSingleton().m_Binds[index] and BindManager:getSingleton().m_Binds[index].keys then
			if BindManager:getSingleton().m_Binds[index].keys[1] then
				local key1 = BindManager:getSingleton().m_Binds[index].keys[1]
				if BindGUI.Modifiers[key1] then
					self.m_HelpButton:setSelectedItem(BindGUI.Modifiers[key1])
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
		self.m_CopyButton:setVisible(true)
		self.m_HelpButton:setVisible(false)
		self.m_SelectedButton:setVisible(false)
	end
end

function BindGUI:onKeyPressed(key, press)
    if press == false then
		if not table.find(KeyBindings.DisallowedKeys, key:lower()) then
			local item = self.m_Grid:getSelectedItem()
			if item and item.index then
				self:changeKey(item.index, key)
			else
				ErrorBox:new(_"Keine Belegung in der Liste ausgewählt!")
			end
			removeEventHandler("onClientKey", root, self.m_onKeyBind)
		end
    end
end

function BindGUI:changeKey(index, newKey)
	if newKey == "" or newKey == " " then return end
	self.m_SelectedButton:setText(newKey:upper())

	local helper = table.find(BindGUI.Modifiers, self.m_HelpButton:getSelectedItem())
	helper = helper == 0 and nil or helper
  	BindManager:getSingleton():changeKey(index, newKey, helper)
	self:loadBinds()
end
