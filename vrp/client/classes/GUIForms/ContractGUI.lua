-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ContractGUI.lua
-- *  PURPOSE:     Contract class
-- *
-- ****************************************************************************
ContractGUI = inherit(GUIForm)
inherit(Singleton, ContractGUI)

function ContractGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
    self.m_Height = grid("y", 12)
    self.m_PreListenState = false

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Vertrag", true, true, self)

	self.m_ChangerLabel = GUIGridLabel:new(1, 1, 2, 1, _"Art", self.m_Window)
	self.m_Changer = GUIGridChanger:new(3, 1, 13, 1, self.m_Window)
	self.m_Changer.onChange = function(text, index)
		self:changeType(text)
	end

	self.m_ChoosenUI = {}
	self.m_ChoosenUISub = {}

	self.m_itemTable = {}
	for index, v in pairs({_"Kaufvertrag", _"Mietvertrag", _"Kreditvertrag"}) do
		local item = self.m_Changer:addItem(v)
		self.m_itemTable[v] = index
	end

	self:changeType(_"Kaufvertrag")
	-- self.m_WebView = GUIWebView:new(self.m_Width*0.28, self.m_Height*0.08, self.m_Width*0.7, self.m_Height*0.9, "http://mta/local/files/html/help.htm", true, self.m_Window)
end

function ContractGUI:changeType(text)
	for k, v in pairs(self.m_ChoosenUI) do
		delete(v)
	end

	for k, v in pairs(self.m_ChoosenUISub) do
		delete(v)
	end

	self.m_ChoosenUI = {}
	self.m_ChoosenUISub = {}

	if text == _"Kaufvertrag" then
		self.m_ChoosenUI.m_ObjectLabel = GUIGridLabel:new(1, 2, 2, 1, _"Objekt", self.m_Window)
		self.m_ChoosenUI.m_ObjectChanger = GUIGridChanger:new(3, 2, 10, 1, self.m_Window)

		for index, v in pairs({_"Gegenstand", _"Fahrzeug", _"Haus", _"Shop", _"Property", _"Dienstleistung"}) do
			local item = self.m_ChoosenUI.m_ObjectChanger:addItem(v)
		end
		self.m_ChoosenUI.m_ObjectSelect = GUIGridButton:new(13, 2, 3, 1, _"Auswählen", self.m_Window)

		self.m_ChoosenUI.m_ObjectChanger.onChange = function(text)
			self:changeObjectType(text)
		end

		self.m_ChoosenUI.m_MoneyLabel = GUIGridLabel:new(1, 6, 2, 1, _"Betrag", self.m_Window)
		self.m_ChoosenUI.m_MoneyEdit = GUIGridEdit:new(3, 6, 5, 1, self.m_Window):setCaption(_"Betrag")
		self.m_ChoosenUI.m_MoneyEdit:setNumeric(true, true)
	elseif text == _"Mietvertrag" then
	else

	end

	self:changeObjectType(_"Gegenstand")
end

function ContractGUI:changeObjectType(text)
	for k, v in pairs(self.m_ChoosenUISub) do
		delete(v)
	end

	self.m_ChoosenUISub = {}

	if self.m_ChoosenUI.m_ObjectSelect then
		self.m_ChoosenUI.m_ObjectSelect:setEnabled(true)
	end

	if text == _"Gegenstand" then
	elseif text == _"Fahrzeug" then
	elseif text == _"Haus" then
	elseif text == _"Shop" then
	elseif text == _"Property" then
	elseif text == _"Dienstleistung" then
		if self.m_ChoosenUI.m_ObjectSelect then
			self.m_ChoosenUI.m_ObjectSelect:setEnabled(false)
		end

		self.m_ChoosenUISub.m_VirtualServiceText = GUIGridMemo:new(1, 3, 15, 3, self.m_Window)
	end
end

function ContractGUI:destructor()
	GUIForm.destructor(self)
end

ContractGUISelect = inherit(GUIForm)
inherit(Singleton, ContractGUISelect)

function ContractGUISelect:constructor(type)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 16)
    self.m_Height = grid("y", 12)
	self.m_PreListenState = false

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Vertrag", true, true, self)


	--[[
		type
			- vehicle
			- item
			- shop
			- property
	]]

	self.m_SelectGrid = GUIGridGridList:new(1, 1, 15, 10, self.m_Window)
	self.m_SelectGrid:addColumn("Name", 1)

	self.m_SelectGrid:addItem("Infernus")
	self.m_SelectGrid:addItem("Dönner")
	self.m_SelectGrid:addItem("Kebab")
end

function ContractGUISelect:destructor()
	GUIForm.destructor(self)
end
