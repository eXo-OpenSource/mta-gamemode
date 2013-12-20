-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/VRPButton.lua
-- *  PURPOSE:     Special button class
-- *
-- ****************************************************************************

-- Button with blue bar on top
VRPButton = inherit(GUIRectangle)

function VRPButton:constructor(posX, posY, width, height, text, parent)
	checkArgs("VRPButton:constructor", "number", "number", "number", "number", "string")
	
	GUIRectangle.constructor(self, posX, posY, width, height, tocolor(255, 255, 255), parent)
	
	self.m_Bar = GUIRectangle:new(0, 0, width, height*0.1, tocolor(19, 64, 121), self)
	self.m_Label = GUILabel:new(0, height*0.05, width, height*0.9, text, 1, self)
		:setAlign("center", "center")
		:setFont(VRPFont(height))
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

function VRPButton:anyChange()
	if self.m_Label then
		self.m_Label.m_Width = self.m_Width
		self.m_Bar.m_Width = self.m_Width
		self.m_Label.m_Height = self.m_Height
		self.m_Bar.m_Height = self.m_Height * 0.1
	end
	
	-- Propagate
	DxElement.anyChange(self)
end