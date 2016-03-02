-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Phone/AppActivity.lua
-- *  PURPOSE:     Phone app activity class (similar to Android's activities)
-- *
-- ****************************************************************************
AppActivity = inherit(GUIElement)

function AppActivity:constructor(app)
	GUIElement.constructor(self, 0, 0, 260, 460, app:getForm())

	-- Close all current activities
	app:closeActivities()

	-- Add the new activity
	app:addActivity(self)

	self.m_App = app
end

function AppActivity:isOpen()
	return self:isVisible()
end

function AppActivity:getApp()
	return self.m_App
end
