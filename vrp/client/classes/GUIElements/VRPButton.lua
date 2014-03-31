-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIElements/VRPButton.lua
-- *  PURPOSE:     Special button class
-- *
-- ****************************************************************************

-- Button with blue bar
VRPButton = inherit(GUIRectangle)

function VRPButton:constructor(posX, posY, width, height, text, barOnTop, parent)
	checkArgs("VRPButton:constructor", "number", "number", "number", "number", "string")
	
	GUIRectangle.constructor(self, posX, posY, width, height, tocolor(0x23, 0x23, 0x23, 230), parent)
	
	if barOnTop then
		self.m_Bar = GUIRectangle:new(0, 0, width, height*0.075, tocolor(0x3F, 0x7F, 0xBF, 255), self)
	else
		self.m_Bar = GUIRectangle:new(0, height-height*0.075, width, height*0.075, tocolor(0x3F, 0x7F, 0xBF, 255), self)
	end
	self.m_Label = GUILabel:new(0, height*0.05, width, height*0.9, text, 1, self)
		:setAlign("center", "center")
		:setFont(VRPFont(height))
		
	self.m_Animation = false
	self.m_BarAnimation = false
	self.m_TextAnimation = false
	self.m_IsDark = false;
end

function VRPButton:setText(text)
	self.m_Label:setText(text)
	return self
end

function VRPButton:dark(quick)
	if quick then
		self.m_Bar:setColor(tocolor(0, 0, 0, 0))
	else
		if not self.m_IsDark then
			if self.m_BarAnimation then
				self.m_BarAnimation:delete()
			end
			self.m_BarAnimation = Animation.FadeColor:new(self.m_Bar, 150, { 0x3F, 0x7F, 0xBF, 255 }, { 0, 0, 0, 0 })
		end
	end
	self.m_IsDark = true
	return self
end

function VRPButton:light(quick)
	if quick then
		self.m_Bar:setColor(tocolor(0x3F, 0x7F, 0xBF, 255))
	else
		if self.m_IsDark then
			if self.m_BarAnimation then
				self.m_BarAnimation:delete()
			end
			self.m_BarAnimation = Animation.FadeColor:new(self.m_Bar, 150, { 0, 0, 0, 0 }, { 0x3F, 0x7F, 0xBF, 255 })
		end
	end
	self.m_IsDark = false
	return self
end

function VRPButton:fadeIn(time, quick)
	if quick then
		self:setColor(tocolor(0x23, 0x23, 0x23, 230))
		self.m_Bar:setColor(tocolor(0x3F, 0x7F, 0xBF, 255))
		self.m_Label:setColor(tocolor(255, 255, 255, 255))
	else
		Animation.FadeColor:new(self, time, { 0x23, 0x23, 0x23, 0 }, {0x23, 0x23, 0x23, 230})
		if not self.m_IsDark then
			Animation.FadeColor:new(self.m_Bar, time, { 0x3F, 0x7F, 0xBF, 0 }, {0x3F, 0x7F, 0xBF, 255})
		end
		Animation.FadeColor:new(self.m_Label, time, { 255, 255, 255, 0 }, {255, 255, 255, 255})
	end
end

function VRPButton:fadeOut(time, quick)
	if quick then
		self:setColor(tocolor(0x23, 0x23, 0x23, 0))
		self.m_Bar:setColor(tocolor(0x3F, 0x7F, 0xBF, 0))
		self.m_Label:setColor(tocolor(255, 255, 255, 0))
	else
		Animation.FadeColor:new(self, time, { 0x23, 0x23, 0x23, 230 }, {0x23, 0x23, 0x23, 0})
		if not self.m_IsDark then
			Animation.FadeColor:new(self.m_Bar, time, { 0x3F, 0x7F, 0xBF, 255 }, {0x3F, 0x7F, 0xBF, 0})
		end
		Animation.FadeColor:new(self.m_Label, time, { 255, 255, 255, 255 }, {255, 255, 255, 0})
	end
end

function VRPButton:anyChange()
	if self.m_Label then
		self.m_Label.m_Width = self.m_Width
		self.m_Bar.m_Width = self.m_Width
		self.m_Label.m_Height = self.m_Height
		self.m_Bar.m_Height = self.m_Height * 0.075
	end
	
	-- Propagate
	DxElement.anyChange(self)
end