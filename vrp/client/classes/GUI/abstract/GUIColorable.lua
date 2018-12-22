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

function GUIColorable:setColor(color, backgroundColor)
	assert(type(color) == "number", "Bad argument @ GUIColorable.setColor")

	self.m_Color = color
	
	if backgroundColor then
		self.m_BackgroundColor = backgroundColor
	end

	self:anyChange()
	return self
end

function GUIColorable:setColorRGB(r, g, b, a)
	assert(type(r) == "number" and type(g) == "number" and type(b) == "number", "Bad argument @ GUIColorable.setColorRGB")

	self:setColor(tocolor(r, g, b, a or 255))
	return self
end

function GUIColorable:getColorRGB()
	return fromcolor(self.m_Color)
end

function GUIColorable:setAlpha(alpha)
	self.m_Alpha = alpha
	self:setColor(bitReplace(self.m_Color, alpha, 24, 8), self.m_BackgroundColor and bitReplace(self.m_BackgroundColor, alpha, 24, 8) or nil)
	return self
end

function GUIColorable:getAlpha()
	local r,g,b,a = fromcolor(self.m_Color)
	return a
end
