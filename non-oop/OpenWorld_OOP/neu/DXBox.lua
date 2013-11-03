DXBox = inherit(DXElement)


function DXBox:constructor(x, y, width, height)
	DXElement.constructor(self, x, y, width, height)
	
	self.m_Color = tocolor(0,0,0,255)
	
	self.m_X = screenW*(self.m_X/1600)
	self.m_Y = screenH*(self.m_Y/900)
	self.m_Width = screenW*(self.m_Width/1600)
	self.m_Height = screenH*(self.m_Height/900)
	
	addEventHandler("onClientRender", root, bind(self.render, self))
end

function DXBox:render()
	dxDrawRectangle(self.m_X, self.m_Y, self.m_Width, self.m_Height, self.m_Color, false)
end

function DXBox:setColor(r, g, b, a)
	self.m_Color = tocolor(r, g, b, a)
end