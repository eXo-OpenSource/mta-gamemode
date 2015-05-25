-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/PhoneApp.lua
-- *  PURPOSE:     PhoneApp class
-- *
-- ****************************************************************************
PhoneApp = inherit(Object)

function PhoneApp:constructor(appName, iconPath)
	self.m_Name = appName
	self.m_IconPath = iconPath
	self.m_IsOpen = false
	self.m_Activities = {}
	self.m_DestroyOnClose = true
end

function PhoneApp:destructor()
end

function PhoneApp:isOpen()
	return self.m_IsOpen
end

function PhoneApp:getName()
	return self.m_Name
end

function PhoneApp:getIconPath()
	return self.m_IconPath
end

function PhoneApp:getForm()
	return self.m_Form
end

function PhoneApp:open()
	if self.m_IsOpen then
		-- App is already open
		return
	end
	self.m_IsOpen = true

	self.m_Form = GUIRectangle:new(14, 41, 222, 365, tocolor(255, 255, 255, 150), Phone:getSingleton())
	self:onOpen(self.m_Form)
end

function PhoneApp:close()
	if self.onClose then
		self:onClose(self.m_Form)
	end
	self:closeActivities()
	delete(self.m_Form)
	self.m_Form = nil
	self.m_IsOpen = false
end

function PhoneApp:addActivity(activity)
	table.insert(self.m_Activities, activity)
end

function PhoneApp:closeActivities()
	for k, activity in ipairs(self.m_Activities) do
		delete(activity)
	end
end

function PhoneApp:getActivities()
	return self.m_Activities
end

function PhoneApp:isDestroyOnCloseEnabled()
	return self.m_DestroyOnClose
end

function PhoneApp:setDestroyOnCloseEnabled(state)
	self.m_DestroyOnClose = state
end

PhoneApp.onOpen = pure_virtual


-- Utilities
function PhoneApp.makeWebApp(caption, iconPath, url, destroyOnClose)
	local appClass = inherit(AppCEF)
	appClass.constructor = function(self) AppCEF.constructor(self, caption, iconPath, url, destroyOnClose) end
	return appClass
end
