-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/PhoneApp.lua
-- *  PURPOSE:     PhoneApp class
-- *
-- ****************************************************************************
PhoneApp = inherit(Object)

function PhoneApp:constructor(appName, icon)
	self.m_Name = appName
	self.m_Icon = icon
	self.m_IsOpen = false
	self.m_Activities = {}
	self.m_DestroyOnClose = false
end

function PhoneApp:destructor()
end

function PhoneApp:isOpen()
	return self.m_IsOpen
end

function PhoneApp:getName()
	return self.m_Name
end

function PhoneApp:getIcon()
	return self.m_Icon
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

	self.m_Form = GUIRectangle:new(0, 0, 260, 460, tocolor(255, 255, 255, 150), Phone:getSingleton():getSurface())
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
	self:closeActivities()
	table.insert(self.m_Activities, activity)
end

function PhoneApp:closeActivities()
	for k, activity in pairs(self.m_Activities) do
		delete(activity)
	end
	self.m_Activities = {}
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
function PhoneApp.makeWebApp(caption, icon, url, destroyOnClose)
	local appClass = inherit(AppCEF)
	appClass.constructor = function(self) AppCEF.constructor(self, caption, icon, url, destroyOnClose) end
	return appClass
end
