-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Admin/AdminSerialAccountsGUI.lua
-- *  PURPOSE:     SerialAccountsGUI class
-- *
-- ****************************************************************************

SerialAccountsGUI = inherit(GUIForm)
inherit(Singleton, SerialAccountsGUI)
addRemoteEvents{"adminSendSerialAccountsToClient", "adminDeleteAccountFromSerialList"}

function SerialAccountsGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 8)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Mit Serial verknüpfte Accounts", true, true, self)
	self.m_GridList = GUIGridGridList:new(1, 1, 11, 5, self.m_Window)
	self.m_GridList:addColumn("", 0.2)
	self.m_GridList:addColumn("", 0.8)
	self.m_DeleteButton = GUIGridButton:new(1, 6, 11, 1, "Trennen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_Edit = GUIGridEdit:new(1, 7, 8, 1, self.m_Window):setCaption("Serial")
	self.m_SearchButton = GUIGridButton:new(9, 7, 3, 1, "Suchen", self.m_Window)
	
	self.m_Bind = bind(self.receiveData, self)
	addEventHandler("adminSendSerialAccountsToClient", root, self.m_Bind)
	self.m_DeleteBind = bind(self.deleteFromList, self)
	addEventHandler("adminDeleteAccountFromSerialList", root, self.m_DeleteBind)

	self.m_SearchButton.onLeftClick = function()
		if self.m_Edit:getText() ~= "" then
			triggerServerEvent("adminRequestSerialAccounts", localPlayer, self.m_Edit:getText())
		end
	end

	self.m_DeleteButton.onLeftClick = function()
		if self.m_GridList:getSelectedItem() then
			QuestionBox:new(("Möchtest Du den Account %s von der Serial trennen?"):format(self.m_GridList:getSelectedItem():getColumnText(2)),
				function()
					triggerServerEvent("adminDeleteAccountFromSerial", localPlayer, self.m_GridList:getSelectedItem():getColumnText(1), self.m_Serial)
				end
			)
		end
	end

end

function SerialAccountsGUI:destructor()
	GUIForm.destructor(self)
	removeEventHandler("adminSendSerialAccountsToClient", root, self.m_Bind)
	removeEventHandler("adminDeleteAccountFromSerialList", root, self.m_DeleteBind)
end

function SerialAccountsGUI:receiveData(serial, dataTable)
	self.m_GridList:clear()
	self.m_Serial = serial
	self.m_GridList:setColumnText(1, ("Accounts auf PC %s"):format(self.m_Serial))
	self.m_GridList:addItemNoClick("Account ID", "Name")
	for key, nTable in pairs(dataTable) do
		self.m_GridList:addItem(nTable[1], nTable[2])
	end
end

function SerialAccountsGUI:deleteFromList(userId)
	for key, item in pairs(self.m_GridList:getItems()) do
		if item:getColumnText(1) == userId then
			self.m_GridList:removeItem(key)
		end
	end
end