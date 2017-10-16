-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppDashboard.lua
-- *  PURPOSE:     Hello world phone app class
-- *
-- ****************************************************************************
AppDashboard = inherit(PhoneApp)
local ITEM_HEIGHT = 115
addRemoteEvents{"onAppDashboardGameInvitation"}

function AppDashboard:constructor()
	PhoneApp.constructor(self, "Dashboard", "IconDashboard.png")

	self.m_Notifications = {
		[NOTIFICATION_TYPE_INVATION] = {};
		[NOTIFICATION_TYPE_GAME] = {};
	}
end

function AppDashboard:onOpen(form)
	self.m_TabPanel = GUIPhoneTabPanel:new(0, 0, form.m_Width, form.m_Height, form)

	local tabInfo = self.m_TabPanel:addTab(_"Information", FontAwesomeSymbols.Info)
	GUILabel:new(10, 3, 200, 50, "Dashboard", tabInfo):setColor(Color.White)
	self.m_TabInfo = tabInfo
	GUILabel:new(10, 65, form.m_Width-20, 22, _[[
		Verschiedene Anfragen wie Fraktions,
		Unternehmens, Firmen und Gang
		Einladungen aber auch Spiele-Anfragen
		von anderen usern werden dir hier
		zentral angezeigt.

		Du kannst diese hier akzeptieren oder ablehnen!
	]], self.m_TabInfo):setMultiline(true)

	local tabInvitation = self.m_TabPanel:addTab(_"Einladungen", FontAwesomeSymbols.Mail)
	GUILabel:new(10, 3, 200, 50, "Einladungen", tabInvitation):setColor(Color.White)
	tabInvitation.m_DashArea = GUIScrollableArea:new(1, 53, 258, 355, 258, 1, true, false, tabInvitation, 53)
	self.m_TabInvitation = tabInvitation

	local tabGameInvitation = self.m_TabPanel:addTab(_"Anfragen", FontAwesomeSymbols.Gamepad)
	GUILabel:new(10, 3, 200, 50, "Spielanfragen", tabGameInvitation):setColor(Color.White)
	tabGameInvitation.m_DashArea = GUIScrollableArea:new(1, 53, 258, 355, 258, 1, true, false, tabGameInvitation, 53)
	self.m_TabGameInvitation = tabGameInvitation


	self:refreshNotifications()
end

function AppDashboard:onClose()
end

function AppDashboard:refreshNotifications()
	self.m_TabInvitation.m_DashArea:clearChildren()

	for type, notifications in pairs(self.m_Notifications) do
		local parent = false
		if type == NOTIFICATION_TYPE_INVATION then
			parent = self.m_TabInvitation.m_DashArea
		elseif type == NOTIFICATION_TYPE_GAME then
			parent = self.m_TabGameInvitation.m_DashArea
		end

		if parent then
			for i, data in pairs(notifications) do
				parent:resize(258, 0 + i * (ITEM_HEIGHT + (i > 1 and 2 or 0)))
				local dashItem = DashboardNotification:new(i, 0, i * (ITEM_HEIGHT + (i > 1 and 2 or 0)) - ITEM_HEIGHT, 260, ITEM_HEIGHT, data.title, data.text, parent, self)
				dashItem:setType(data.type)
				dashItem:setOnAcceptHandler(data.acceptHandler)
				dashItem:setOnDeclineHandler(data.declineHandler)
			end
		end
	end
end

function AppDashboard:addNotification(title, text, type, acceptHandler, declineHandler)
	if not self.m_Notifications[type] then return false end
	table.insert(self.m_Notifications[type], {title = title, text = text, acceptHandler = acceptHandler, declineHandler = declineHandler, type = type})

	if self:isOpen() then
		self:refreshNotifications()
	end

	ShortMessage:new(_"Du hast eine Benachrichtigung erhalten!\n(Du kannst diese in der Dashboard App ansehen)", "Dashboard", Color.Grey)
end

DashboardNotification = inherit(GUIRectangle)
function DashboardNotification:constructor(id, x, y, width, height, title, text, parent, app)
	GUIRectangle.constructor(self, x, y, width, height, Color.DarkBlue, parent)
	self.m_Id = id
	self.m_App = app

	GUILabel:new(5, 5, width-10, 30, title, self)
	GUILabel:new(5, 35, width-10, 22, text, self)

	--self.m_Label = GUILabel:new(5, 5, width-10, 30, text, self)
	self.m_ButtonAccept = GUIButton:new(width-135, height-30, 60, 20, "✓", self):setBackgroundColor(Color.Green):setBarEnabled(false)
	self.m_ButtonDecline = GUIButton:new(width-70, height-30, 60, 20, "✕", self):setBackgroundColor(Color.Red):setBarEnabled(false)
end

function DashboardNotification:setOnAcceptHandler(handler)
	self.m_ButtonAccept.onLeftClick = function()
		-- call the handler
		if handler then
			handler()
		end

		-- remove from notifications list
		table.remove(self.m_App.m_Notifications[self.m_Type], self.m_Id)
		if self.m_App:isOpen() then
			self.m_App:refreshNotifications()
		end

		-- delete this element
		delete(self)
	end
end

function DashboardNotification:setOnDeclineHandler(handler)
	self.m_ButtonDecline.onLeftClick = function()
		-- call the handler
		if handler then
			handler()
		end

		-- remove from notifications list
		table.remove(self.m_App.m_Notifications[self.m_Type], self.m_Id)
		if self.m_App:isOpen() then
			self.m_App:refreshNotifications()
		end

		-- delete this element
		delete(self)
	end
end

function DashboardNotification:setType(type)
	self.m_Type = type
end

addEventHandler("onAppDashboardGameInvitation", root,
	function(player, game, acceptEvent, declineEvent, ...)
		local args = {...}
		local dashboard = Phone:getSingleton():getDashboard()
		dashboard:addNotification(game, _("Der Spieler \"%s\" möchte mit dir \"%s\" spielen!", player:getName(), game), NOTIFICATION_TYPE_GAME,
			function()
				triggerServerEvent(acceptEvent, localPlayer, unpack(args))
			end,
			function()
				triggerServerEvent(declineEvent, localPlayer, unpack(args))
			end
		)
	end
)
