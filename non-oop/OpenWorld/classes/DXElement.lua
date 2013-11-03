DXElement = {}


function DXElement:constructor(x, y, width, height)
	self.m_X = screenW*(x/1600)
	self.m_Y = screenH*(y/900)
	self.m_Width = screenW*(width/1600)
	self.m_Height = screenH*(height/900)
end