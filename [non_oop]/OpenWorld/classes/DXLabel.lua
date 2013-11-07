DXLabel = inherit(DXElement)


function DXLabel:constructor(text, x, y, width, height)
	DXElement.constructor(self, x, y, width, height)

	self.m_Text = text
	self.m_Color = tocolor(255, 255, 255, 255)
	self.m_Font = "arial"
	self.m_AlignX = "left"
	self.m_AlignY = "top"
	
	
	addEventHandler("onClientRendern", root, bind(self.render, self))
end

function DXLabel:render()
	dxDrawText(self.m_Text, self.m_X, self.m_Y, self.m_Width, self.m_Height, self.m_Color, 1, self.m_Font, self.m_AlignX, self.m_AlignY, false, false, true, false, false)
end

function DXLabel:setText(text)
	self.m_Text = text
end

function DXLabel:setColor(r, g, b, a)
	self.m_Color = tocolor(r, g, b, a)
end

function DXLabel:setFont(font)
	self.m_Font = font
end

function DXLabel:setAlignX(alignx)
	self.m_AlignX = alignx
end

function DXLabel:setAlignY(aligny)
	self.m_AlignY = aligny
end