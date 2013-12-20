-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/Phone.lua
-- *  PURPOSE:     Phone class
-- *
-- ****************************************************************************
Phone = inherit(Singleton)
inherit(GUIForm, Phone)

function Phone:constructor()
	GUIForm.constructor(self, screenWidth-270, screenHeight-500, 250, 490)
	
	self.m_Apps = {}
	
	-- Register apps
	self:registerApp(AppHelloWorld)
	self:registerApp(AppCall)
	self:registerApp(AppSettings)
	
	-- Add GUI elements
	self.m_Background = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/Phone/Phone.png", self)
	
	-- Create app icons
	self.m_IconSurface = GUIElement:new(14, 41, 222, 391, self)
	for k, app in ipairs(self.m_Apps) do
		local column, row = (k-1)%4, math.floor((k-1)/4)
		
		-- Create app icon
		local appIcon = GUIImage:new(5+54*column, 9+75*row, 52, 52, app:getIconPath(), self.m_IconSurface)
		
		-- Create app label
		local appLabel = GUILabel:new(5+54*column, 62+75*row, 52, 20, app:getName(), 1, self.m_IconSurface)
		appLabel:setAlignX("center")
		
		appIcon.onLeftClick = function() self.m_IconSurface:setVisible(false) app:open() end
	end
	
	-- Create elements at the bottom
	self.m_BackButton = GUIRectangle:new(14, 410, 80, 25, Color.Clear, self)
	self.m_BackButton.onLeftClick = function() self:closeAllApps() self.m_IconSurface:setVisible(true) end -- Todo: In-App back
	self.m_HomeButton = GUIRectangle:new(95, 410, 60, 25, Color.Clear, self)
	self.m_HomeButton.onLeftClick = function() self:closeAllApps() self.m_IconSurface:setVisible(true) end
	self.m_RecentButton = GUIRectangle:new(156, 410, 80, 25, Color.Clear, self)
	self.m_RecentButton.onLeftClick = function() outputChatBox("Not implemented") end
end

function Phone:registerApp(appClasst)
	local app = appClasst:new()
	table.insert(self.m_Apps, app)
	return app
end

function Phone:open()
	self:setVisible(true)
end

function Phone:close()
	self:closeAllApps()
	self:setVisible(false)
end

function Phone:closeAllApps()
	for k, app in ipairs(self.m_Apps) do
		if app:isOpen() then
			app:close()
		end
	end
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
