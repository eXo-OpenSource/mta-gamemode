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
end

function GUIColorable:setColorRGB(r, g, b, a)
	assert(type(r) == "number" and type(g) == "number" and type(b) == "number", "Bad argument @ GUIColorable.setColorRGB")

	self:setColor(tocolor(r, g, b, a or 255))
end
