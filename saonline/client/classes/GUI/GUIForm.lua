-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIForm.lua
-- *  PURPOSE:     GUI form class (base class)
-- *
-- ****************************************************************************

GUIForm = inherit(CacheArea)

function GUIForm:constructor(posX, posY, width, height)
	checkArgs("GUIForm:constructor", "number", "number", "number", "number")
	
	CacheArea.constructor(self, posX or 0, posY or 0, width or screenWidth, height or screenHeight, true, true)
	self.m_KeyBinds = {}
end

function GUIForm:destructor()
	for k, v in pairs(self.m_KeyBinds) do
		unbindKey(k, "down", v)
	end
	
	-- Todo: Replace this by derived_destructor
	CacheArea.destructor(self)
end

function GUIForm:open(showTheCursor)
	if showTheCursor then
		showCursor(true)
	end
	return self:setVisible(true)
end

function GUIForm:close(hideCursor)
	if hideCursor then
		showCursor(false)
	end
	return self:setVisible(false)
end

function GUIForm:bind(key, fn)
	if self.m_KeyBinds[key] then
		unbindKey(key, "down", self.m_KeyBinds[key])
	end
	
	local handler = bind(fn, self)
	self.m_KeyBinds[key] = handler
	bindKey(key, "down", handler)
end

