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

	self.m_Apps = {}
	self.m_CurrentApp = false

	-- Register apps
	self:registerApp(AppCall)
	self:registerApp(AppSettings)
	self:registerApp(AppDashboard)
	--self:registerApp(AppNametag)

	-- Register web apps
	self:registerApp(PhoneApp.makeWebApp("YouTube", "files/images/Phone/Apps/IconYouTube.png", "https://youtube.com/tv", false))
	self:registerApp(PhoneApp.makeWebApp("Nachrichten", "files/images/Phone/Apps/IconMessage.png", "http://exo-reallife.de/ingame/vRPphone/phone.php?page=sms&player="..localPlayer:getName(), false))

	local phone = "Android-Phone"
	if core:get("Phone", "Phone") then
		phone = core:get("Phone", "Phone")
	end

	-- Add GUI elements
	self.m_Background = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Phone/"..phone:gsub("-", "")..".png", self)

	-- Create app icons
	self.m_IconSurface = GUIElement:new(17, 71, 260, 460, self)
	for k, app in ipairs(self.m_Apps) do
		local column, row = (k-1)%4, math.floor((k-1)/4)

		-- Create app icon
		local appIcon = GUIImage:new(5+65*column, 9+75*row, 52, 52, app:getIconPath(), self.m_IconSurface)

		-- Create app label
		local appLabel = GUILabel:new(65*column, 62+75*row, 69, 18, app:getName(), self.m_IconSurface)
		appLabel:setAlignX("center")

		appIcon.onLeftClick = function() self.m_IconSurface:setVisible(false) self:openApp(app) end
	end

	-- Create elements at the bottom
	self.m_HomeButton = GUIRectangle:new(117, 530, 60, 60, Color.Clear, self)
	self.m_HomeButton.onLeftClick = function() self:closeAllApps() self.m_IconSurface:setVisible(true) end
end

function Phone:setPhone(phone)
	self.m_Background:setImage("files/images/Phone/"..phone:gsub("-", "")..".png")
end

function Phone:registerApp(appClasst)
	local app = appClasst:new()
	table.insert(self.m_Apps, app)
	return app
end

function Phone:onShow()
	if self.m_CurrentApp then
		self.m_IconSurface:setVisible(false)
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
