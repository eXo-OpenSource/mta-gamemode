-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIForm.lua
-- *  PURPOSE:     GUI form class (base class)
-- *
-- ****************************************************************************

GUIForm = inherit(CacheArea)

function GUIForm:constructor(posX, posY, width, height)
	CacheArea.constructor(self, posX or 0, posY or 0, width or screenWidth, height or screenHeight, true, true)
	self.m_KeyBinds = {}
	
	Cursor:show()
end

function GUIForm:destructor()
	for k, v in pairs(self.m_KeyBinds) do
		unbindKey(k, "down", v)
	end
	self.m_KeyBinds = {}
	self:setVisible(false)
	Cursor:hide()
	
	-- Todo: Replace this by virtual_destructor
	CacheArea.destructor(self)
end

function GUIForm:open(hiddenCursor)
	if not hiddenCursor then
		Cursor:show()
	end
	return self:setVisible(true)
end

function GUIForm:close(decrementedCursorCounter)
	if not decrementedCursorCounter then
		Cursor:hide()
	end
	return self:setVisible(false)
end

function GUIForm:toggle(cursor)
	if self:isVisible() then
		self:close(cursor)
	else
		self:open(cursor)
	end
end

function GUIForm:fadeIn(time)
	if not time then time = 1000 end
	self:setVisible(true)
	for k, v in pairs(self:getChildrenRecursive()) do
		if v:isVisible() then
			if instanceof(v, GUIColorable) then
				Animation.FadeAlpha:new(v, 750, 0, v:getAlpha() or 255)
			end
		end
	end
end

function GUIForm:fadeOut(time)
	if not time then time = 1000 end
	for k, v in pairs(self:getChildrenRecursive()) do
		if v:isVisible() then
			if instanceof(v, GUIColorable) then
				Animation.FadeAlpha:new(v, 750, v:getAlpha() or 255, 0)
			end
		end
	end
	setTimer(function() self:setVisible(false) end, time, 1)
end

function GUIForm:bind(key, fn)
	if self.m_KeyBinds[key] then
		unbindKey(key, "down", self.m_KeyBinds[key])
	end
	
	local handler = bind(fn, self)
	self.m_KeyBinds[key] = handler
	bindKey(key, "down", handler)
end

function GUIForm:unbind(key, fn)
	if not self.m_KeyBinds[key] then
		return
	end
	
	unbindKey(key, "down", self.m_KeyBinds[key])
end

