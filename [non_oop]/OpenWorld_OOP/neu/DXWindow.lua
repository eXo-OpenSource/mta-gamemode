DXWindow = inherit(DXElement)

screenW, screenH = guiGetScreenSize()

function DXWindow:constructor(x, y, width, height)
	DXElement.constructor(self, x, y, width, height)
	
	self.m_Color = tocolor(0,0,0,255)
	
	addEventHandler("onClientRender", root, bind(self.render, self))
end

function DXWindow:render()
	dxDrawRectangle(self.m_X, self.m_Y, self.m_Width, self.m_Height, self.m_Color, false)
end

function DXWindow:setColor(r, g, b, a)
	self.m_Color = tocolor(r, g, b, a)
end