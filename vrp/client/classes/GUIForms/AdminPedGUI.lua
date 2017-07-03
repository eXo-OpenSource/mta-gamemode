-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminPedGUI.lua
-- *  PURPOSE:     Admin Ped GUI class
-- *
-- ****************************************************************************

AdminPedGUI = inherit(GUIForm)
inherit(Singleton, AdminPedGUI)

addRemoteEvents{"adminPedReceiveData"}

function AdminPedGUI:constructor(money)
	GUIForm.constructor(self, screenWidth/2-400, screenHeight/2-540/2, 800, 540)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Admin-Ped Menü", true, true, self)

	self.m_CloseButton = GUIButton:new(self.m_Width-30, 0, 30, 30, FontAwesomeSymbols.Close, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.Red):setHoverColor(Color.White):setFontSize(1)
	self.m_CloseButton.onLeftClick = function() self:delete() end

	self.m_BackButton = GUIButton:new(self.m_Width-60, 0, 30, 30, FontAwesomeSymbols.Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.Clear):setBackgroundHoverColor(Color.LightBlue):setHoverColor(Color.White):setFontSize(1)
	self.m_BackButton.onLeftClick = function() self:close() AdminGUI:getSingleton():show() Cursor:show() end

	self.m_PedGrid = GUIGridList:new(10, 50, self.m_Width-20, 300, self.m_Window)
	self.m_PedGrid:addColumn(_"ID", 0.1)
	self.m_PedGrid:addColumn(_"Name", 0.3)
	self.m_PedGrid:addColumn(_"Zone", 0.2)
	self.m_PedGrid:addColumn(_"Rollen", 0.3)
	self.m_PedGrid:addColumn(_"gespawnt", 0.1)

	self.m_EventToggleButton = GUIButton:new(10, 370, 250, 30, "asdf",  self):setFontSize(1):setBackgroundColor(Color.Blue)

	addEventHandler("adminPedReceiveData", root, bind(self.onReceiveData, self))
end

function AdminPedGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	triggerServerEvent("adminPedRequestData", localPlayer)
end

function AdminPedGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

function AdminPedGUI:onReceiveData(peds)
	self.m_PedGrid:clear()
	for id, pedData in pairs(peds) do
		self.m_PedGrid:addItem(id, pedData["Name"], getZoneName(normaliseVector(pedData["Pos"])), table.concat(pedData["Roles"], ", "), pedData["Spawned"] and "Ja" or "Nein")
	end
end
