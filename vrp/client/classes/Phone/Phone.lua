-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/Phone.lua
-- *  PURPOSE:     Phone class
-- *
-- ****************************************************************************
Phone = inherit(GUIForm)
inherit(Singleton, Phone)

function Phone:constructor()
	GUIForm.constructor(self, screenWidth-310, screenHeight-620, 295, 600)

	local phone = "iPhone"
	if core:get("Phone", "Phone") then
		phone = core:get("Phone", "Phone")
	end

	if core:get("Phone", "On") then
		self.m_PhoneOn = core:get("Phone", "On")
	else
		core:getConfig():set("Phone", "On", 1)
		self.m_PhoneOn = true
	end

	self.m_Phone = phone

	self.m_Apps = {}
	self.m_CurrentApp = false

	-- Register apps
	self:registerApp(AppCall)
	self:registerApp(AppSettings)
	--self:registerApp(AppDashboard)
	--self:registerApp(AppNametag)

	-- Register web apps
	self:registerApp(PhoneApp.makeWebApp("YouTube", "IconYouTube.png", "https://youtube.com/tv", false))
	self:registerApp(AppOnOff)
	self:registerApp(PhoneApp.makeWebApp("Nachrichten",  "IconMessage.png", ("http://exo-reallife.de/ingame/vRPphone/phone.php?page=sms&player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), true, self))



	-- Add GUI elements
	self.m_Background = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Phone/"..phone:gsub("-", "")..".png", self)

	-- Create app icons
	self.m_IconSurface = GUIElement:new(17, 71, 260, 460, self)
	self:loadHomeScreen()

	-- Create elements at the bottom
	self.m_HomeButton = GUIRectangle:new(117, 530, 60, 60, Color.Clear, self)
	self.m_HomeButton.onLeftClick =
	function()
		if self.m_PhoneOn == 1 then
			self:closeAllApps()
			self.m_IconSurface:setVisible(true)
		end
	end
end

function Phone:switchOff()
	core:getConfig():set("Phone", "On", 0)
	self.m_PhoneOn = 0
	self:loadHomeScreen()
end

function Phone:switchOn()
	core:getConfig():set("Phone", "On", 1)
	self.m_PhoneOn = 1
	self:closeAllApps()
	self:loadHomeScreen()
end

function Phone:loadHomeScreen()
	if self.m_PhoneOn == 1 then
		local iconPath = "files/images/Phone/Apps_"..self.m_Phone:gsub("-", "").."/"


		self.m_AppIcons = {}
		self.m_AppLabels = {}
		for k, app in ipairs(self.m_Apps) do
			local column, row = (k-1)%4, math.floor((k-1)/4)

			-- Create app icon
			self.m_AppIcons[k] = GUIImage:new(5+65*column, 9+75*row, 50, 50,  iconPath..app:getIcon(), self.m_IconSurface)

			-- Create app label
			self.m_AppLabels[k] = GUILabel:new(65*column-7, 62+75*row, 74, 16, app:getName(), self.m_IconSurface)
			self.m_AppLabels[k]:setAlignX("center")

			self.m_AppIcons[k].onLeftClick = function() self.m_IconSurface:setVisible(false) self:openApp(app) end
		end
	else
		self:closeAllApps()
		self:openAppByClass(AppOnOff)
	end
end

function Phone:refreshAppIcons()
	local iconPath = "files/images/Phone/Apps_"..self.m_Phone:gsub("-", "").."/"
	for k, app in ipairs(self.m_Apps) do
		self.m_AppIcons[k]:setImage(iconPath..app:getIcon())
	end
end

function Phone:setPhone(phone)
	self.m_Background:setImage("files/images/Phone/"..phone:gsub("-", "")..".png")
	self.m_Phone = phone
	self:refreshAppIcons()
end

function Phone:registerApp(appClasst)
	local app = appClasst:new()
	table.insert(self.m_Apps, app)
	return app
end

function Phone:onShow()
	if self.m_PhoneOn == 1 then
		if self.m_CurrentApp then
			self.m_IconSurface:setVisible(false)
		end
	else
		self:openAppByClass(AppOnOff)
	end
end

function Phone:onHide()
	for k, app in ipairs(self.m_Apps) do
		if app:isOpen() and app:isDestroyOnCloseEnabled() then
			app:close()
		end
	end
	self.m_IconSurface:setVisible(true)

	if self.m_CurrentApp and self.m_CurrentApp:isDestroyOnCloseEnabled() then
		self.m_CurrentApp = false
	end
end

function Phone:closeAllApps()
	for k, app in ipairs(self.m_Apps) do
		if app:isOpen() then
			app:close()
		end
	end
	self.m_IconSurface:setVisible(true)
end

function Phone:getAppByClass(classt)
	for k, app in ipairs(self.m_Apps) do
		if instanceof(app, classt, true) then
			return app
		end
	end
	return false
end

function Phone:isOpen()
	return self:isVisible()
end

function Phone:openApp(app)
	-- Show phone if not shown already
	if not self:isVisible() then
		self:open()
	end
	self.m_CurrentApp = app

	-- Hide app icon surface/activity
	self.m_IconSurface:setVisible(false)
	app:open()

	return true
end

function Phone:openAppByClass(appClass)
	local app = self:getAppByClass(appClass)
	if not app then
		error("Attempt to open a non-existing app")
		return false
	end

	return self:openApp(app)
end
