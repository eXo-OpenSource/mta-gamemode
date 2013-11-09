-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/Phone/AppActivity.lua
-- *  PURPOSE:     Phone app activity class (similar to Android's activities)
-- *
-- ****************************************************************************
AppActivity = inherit(GUIElement)

function AppActivity:constructor(app)
	GUIElement.constructor(self, 0, 0, 222, 365, app:getForm())
	
	-- Close all current activities
	app:closeActivities()
	
	-- Add the new activity
	app:addActivity(self)
	
	
end

function AppActivity:isOpen()
	return self:isVisible()
end
