-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIWebForm.lua
-- *  PURPOSE:     GUI web form class (base class)
-- *
-- ****************************************************************************
GUIWebForm = inherit(GUIForm)

function GUIWebForm:constructor(posX, posY, width, height) -- Override but don't call GUIForm:constructor
    -- Create a cache area, but disable caching
    CacheArea.constructor(self, posX or 0, posY or 0, width or screenWidth, height or screenHeight, true, false)
	self.m_KeyBinds = {}

	Cursor:show()
end

--[[
function GUIWebForm:destructor()
	Cursor:hide()
end

function GUIWebForm:open(hiddenCursor)
    -- Hacky way to implement traits
    return GUIForm.open(hiddenCursor)
end

function GUIWebForm:close(decrementedCursorCounter)
    -- Hacky way to implement traits
    return GUIForm.close(decrementedCursorCounter)
end
]]
