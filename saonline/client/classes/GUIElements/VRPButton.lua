-- Button with blue bar on top
VRPButton = inherit(GUIRectangle)

function VRPButton:constructor(posX, posY, width, height, text, parent)
	checkArgs("VRPButton:constructor", "number", "number", "number", "number", "string")
	
	GUIRectangle.constructor(self, posX, posY, width, height, tocolor(255, 255, 255), parent)
	
	self.m_Bar = GUIRectangle:new(0, 0, width, height*0.1, tocolor(19, 64, 121), self)
	local fontsize = 1
	local font = dxCreateFont("files/fonts/gtafont.ttf", math.floor(height/1.65))
	self.m_Label = GUILabel:new(0, height*0.05, width, height*0.9, text, fontsize, self)
		:setAlign("center", "center")
		:setFont(font)
		:setColor(tocolor(0, 0, 0, 255))
end

function VRPButton:setText(text)
	self.m_Label:setText(text)
	return self
end

function VRPButton:dark()
	self.m_Color = tocolor(0, 0, 0, 0)
	self.m_Bar:hide()
	self.m_Label:setColor(tocolor(255, 255, 255, 255))
	return self
end

function VRPButton:light()
	self.m_Color = tocolor(255, 255, 255, 255)
	self.m_Bar:show()
	self.m_Label:setColor(tocolor(0, 0, 0, 255))
	return self
end