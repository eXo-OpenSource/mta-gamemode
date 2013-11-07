-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIForm.lua
-- *  PURPOSE:     GUI form class (base class)
-- *
-- ****************************************************************************

GUIForm = inherit(CacheArea)

function GUIForm:constructor(posX, posY, width, height)
	checkArgs("GUIForm:constructor", "number", "number", "number", "number")
	
	CacheArea.constructor(self, posX or 0, posY or 0, width or screenWidth, height or screenHeight, true, true)
end

function GUIForm:destructor()
	-- Todo: Replace this by derived_destructor
	CacheArea.destructor(self)
end

function GUIForm:close()
	return self:setVisible(false)
end
