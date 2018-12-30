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

	self.m_Phone = core:get("Phone", "Phone", "iPhone")
	self.m_Background = core:get("Phone", "Background", "iOS_7")
	self.m_PhoneOn = core:get("Phone", "On", true)

	self.m_Apps = {}
	self.m_CurrentApp = false

	-- Register apps
	self:registerApp(AppCall)
	self:registerApp(AppSettings)
	self:registerApp(AppContacts)
	self:registerApp(PhoneApp.makeWebApp("Nachrichten",  "IconMessage.png", (INGAME_WEB_PATH .. "/ingame/vRPphone/apps/messages/index.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), false, self))
	--self:registerApp(AppNametag)
	self.m_AppDashboard = self:registerApp(AppDashboard)
	self:registerApp(PhoneApp.makeWebApp("YouTube", "IconYouTube.png", "https://youtube.com/tv", false))
	self:registerApp(AppOnOff)
	self:registerApp(AppAmmunation)
	self:registerApp(AppBank)
	self:registerApp(PhoneApp.makeWebApp("Snake",  "IconSnake.png", (INGAME_WEB_PATH .. "/ingame/vRPphone/webApps/snake/index.php?player=%s&sessionID=%s"):format(localPlayer:getName(), localPlayer:getSessionId()), false, self))
	self:registerApp(AppNavigator)
	self:registerApp(AppEPT)
	self:registerApp(AppSanNews)
	self:registerApp(AppNotes)
	self:registerApp(AppSkribble)


	-- Add GUI elements
	self.m_PhoneImage = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Phone/"..self.m_Phone:gsub("-", "")..".png", self)
	self.m_BackgroundImage = GUIImage:new(17, 71, 260, 460, ("files/images/Phone/Backgrounds/%s.png"):format(self.m_Background), self)

	-- Create app icons
	self.m_IconSurface = GUIElement:new(0, 0, 260, 460, self.m_BackgroundImage)
	self:loadHomeScreen()

	-- Create elements at the bottom
	self.m_HomeButton = GUIRectangle:new(117, 530, 60, 60, Color.Clear, self.m_PhoneImage)
	self.m_HomeButton.onLeftClick =
	function()
		if self.m_PhoneOn then
			if self.m_CurrentApp and (self.m_CurrentApp.m_InCall or self.m_CurrentApp.m_Caller) then return end
			self:closeAllApps()
			self.m_IconSurface:setVisible(true)
		end
	end

	triggerServerEvent("setPhoneStatus", root, self.m_PhoneOn)
end

function Phone:switchOff()
	self.m_PhoneOn = false
	core:getConfig():set("Phone", "On", self.m_PhoneOn)

	self:closeAllApps()
	self:openAppByClass(AppOnOff)
	triggerServerEvent("setPhoneStatus", localPlayer, self.m_PhoneOn)
end

function Phone:switchOn()
	self.m_PhoneOn = true
	core:getConfig():set("Phone", "On", self.m_PhoneOn)

	self:closeAllApps()
	self:loadHomeScreen()
	triggerServerEvent("setPhoneStatus", localPlayer, self.m_PhoneOn)
end

function Phone:isOn()
	return self.m_PhoneOn
end

function Phone:loadHomeScreen()
	local iconPath = "files/images/Phone/Apps_"..self.m_Phone:gsub("-", "").."/"

	self.m_AppIcons = {}
	self.m_AppLabels = {}
	for k, app in ipairs(self.m_Apps) do
		local column, row = (k-1)%4, math.floor((k-1)/4)

		-- Create app icon
		self.m_AppIcons[k] = GUIImage:new(5+65*column, 9+80*row, 50, 50,  iconPath..app:getIcon(), self.m_IconSurface)

		-- Create app label
		self.m_AppLabels[k] = GUILabel:new(65*column-7, 62+80*row, 74, 16, app:getName(), self.m_IconSurface)
		self.m_AppLabels[k]:setAlignX("center")

		self.m_AppIcons[k].onLeftClick = function() self.m_IconSurface:setVisible(false) self:openApp(app) end
	end
end

function Phone:refreshAppIcons()
	local iconPath = "files/images/Phone/Apps_"..self.m_Phone:gsub("-", "").."/"
	for k, app in ipairs(self.m_Apps) do
		self.m_AppIcons[k]:setImage(iconPath..app:getIcon())
	end
end

function Phone:setPhone(phone)
	self.m_PhoneImage:setImage("files/images/Phone/"..phone:gsub("-", "")..".png")
	self.m_Phone = phone
	self:refreshAppIcons()
end

function Phone:setBackground(background)
	self.m_BackgroundImage:setImage(("files/images/Phone/Backgrounds/%s.png"):format(background))
	--self.m_Background = background
	--self:refreshAppIcons()
end

function Phone:registerApp(appClasst)
	local app = appClasst:new()
	table.insert(self.m_Apps, app)
	return app
end

function Phone:onShow()
	if localPlayer:getHealth() == 0 then
		self:close()
		return
	end

	if self.m_PhoneOn then
		if self.m_CurrentApp then
			self.m_IconSurface:setVisible(false)
		end
	else
		self:closeAllApps()
		self:openAppByClass(AppOnOff)
	end
end

function Phone:onHide()
	for k, app in ipairs(self.m_Apps) do
		if app:isOpen() and app:isDestroyOnCloseEnabled() then
			app:close()
		end
	end

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
	self.m_CurrentApp = false
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
		showCursor(false)
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

function Phone:getSurface()
	return self.m_BackgroundImage
end

function Phone:getDashboard()
	return self.m_AppDashboard
end
