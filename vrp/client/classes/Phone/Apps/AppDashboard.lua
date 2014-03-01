-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppDashboard.lua
-- *  PURPOSE:     Hello world phone app class
-- *
-- ****************************************************************************
AppDashboard = inherit(PhoneApp)

function AppDashboard:constructor()
	PhoneApp.constructor(self, "Dashboard", "files/images/Phone/Apps/IconHelloWorld.png")
end

function AppDashboard:onOpen(form)
	self.m_Label = GUILabel:new(10, 3, 200, 20, "Dashboard", 2, form)
	self.m_Label:setColor(Color.Black)
	
	self.m_DashArea = GUIScrollableArea:new(0, 40, 222, 400, 222, 1, true, false, form)
end

function AppDashboard:onClose()
end

function AppDashboard:addNotification(text, acceptHandler, declineHandler)
	self.m_DashArea:resize(222, 70 + i * 72)
	local dashItem = DashboardItem:new(0, i * 72 - 70, 222, 70, "Möchtest du die Gruppe 'Die_Hustler betreten?'", self.m_DashArea)
	dashItem:setOnAcceptHandler(acceptHandler)
	dashItem:setOnDeclineHandler(declineHandler)
end

DashboardItem = inherit(GUIRectangle)
function DashboardItem:constructor(x, y, width, height, text, parent)
	GUIRectangle.constructor(self, x, y, width, height, Color.DarkBlue, parent)
	
	self.m_Label = GUILabel:new(5, 5, width-10, 30, text, 1, self)
	self.m_ButtonAccept = GUIButton:new(width-135, 40, 60, 20, "✓", self):setBackgroundColor(Color.Green)
	self.m_ButtonDecline = GUIButton:new(width-70, 40, 60, 20, "✕", self):setBackgroundColor(Color.Red)
end

function DashboardItem:setOnAcceptHandler(handler)
	self.m_ButtonAccept.onLeftClick = handler
	delete(self)
end

function DashboardItem:setOnDeclineHandler(handler)
	self.m_ButtonDecline.onLeftClick = handler
	delete(self)
end
