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
	
	self.m_Notifications = {}
end

function AppDashboard:onOpen(form)
	self.m_Label = GUILabel:new(10, 3, 200, 50, "Dashboard", form)
	self.m_Label:setColor(Color.Black)
	
	self.m_DashArea = GUIScrollableArea:new(0, 40, 222, 400, 222, 1, true, false, form)
	self:refreshItems()
end

function AppDashboard:onClose()
end

function AppDashboard:refreshItems()
	if self.m_DashArea then
		self.m_DashArea:clearChildren()
	end
	
	for i, v in pairs(self.m_Notifications) do
		self.m_DashArea:resize(222, 70 + i * 72)
		local dashItem = DashboardItem:new(0, i * 72 - 70, 222, 70, v.text, self.m_DashArea)
		dashItem:setOnAcceptHandler(v.acceptHandler)
		dashItem:setOnDeclineHandler(v.declineHandler)
	end
end

function AppDashboard:addNotification(text, acceptHandler, declineHandler)
	table.insert(self.m_Notifications, {text = text, acceptHandler = acceptHandler, declineHandler = declineHandler})
	
	if self:isOpen() then
		self:refreshItems()
	end
end

DashboardItem = inherit(GUIRectangle)
function DashboardItem:constructor(x, y, width, height, text, parent)
	GUIRectangle.constructor(self, x, y, width, height, Color.DarkBlue, parent)
	
	self.m_Label = GUILabel:new(5, 5, width-10, 30, text, self)
	self.m_ButtonAccept = GUIButton:new(width-135, 40, 60, 20, "✓", self):setBackgroundColor(Color.Green)
	self.m_ButtonDecline = GUIButton:new(width-70, 40, 60, 20, "✕", self):setBackgroundColor(Color.Red)
end

function DashboardItem:setOnAcceptHandler(handler)
	self.m_ButtonAccept.onLeftClick = function() handler() delete(self) end
end

function DashboardItem:setOnDeclineHandler(handler)
	self.m_ButtonDecline.onLeftClick = function() handler() delete(self) end
end
