DXImage = inherit(DXElement)


function DXImage:constructor(image, x, y, width, height)
	DXElement.constructor(self, x, y, width, height)
	
	self.m_Image = image
	self.m_X = screenW*(self.m_X/1600)
	self.m_Y = screenH*(self.m_Y/900)
	self.m_Width = screenW*(self.m_Width/1600)
	self.m_Height = screenH*(self.m_Height/900)
	
	addEventHandler("onClientRender", root, bind(self.render, self))
end

function DXImage:render()
	dxDrawImage(self.m_X, self.m_Y, self.m_Width, self.m_Height, self.m_Image, 0, 0, 0, tocolor(255, 255, 255, 255), true)
end

function DXImage:setImage(imagepath)
	self.m_Image = imagepath
end