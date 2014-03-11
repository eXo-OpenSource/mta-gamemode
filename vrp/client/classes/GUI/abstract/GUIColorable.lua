-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/abstract/GUIColorable.lua
-- *  PURPOSE:     GUI colorable abstract super class
-- *
-- ****************************************************************************
GUIColorable = inherit(Object)

function GUIColorable:constructor(color)
	self.m_Color = color or Color.White
end

function GUIColorable:getColor()
	return self.m_Color
end

function GUIColorable:setColor(color)
	assert(type(color) == "number", "Bad argument @ GUIColorable.setColor")

	self.m_Color = color
	self:anyChange()	
	return self
end

function GUIColorable:setColorRGB(r, g, b, a)
	assert(type(r) == "number" and type(g) == "number" and type(b) == "number", "Bad argument @ GUIColorable.setColorRGB")

	self:setColor(tocolor(r, g, b, a or 255))
	return self
end

function GUIColorable:setAlpha(alpha)
	-- This is wrong
	outputDebug("setalpha")
	self:setColor(tocolor(255, 255, 255, alpha))
	return self
end
