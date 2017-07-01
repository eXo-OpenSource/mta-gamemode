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
		--self.m_Bar = GUIRectangle:new(0, 0, width, height*0.075, Color.LightBlue, self)
	else
		self.m_Bar = GUIRectangle:new(0, height-height*0.075, width, height*0.075, tocolor(0x3F, 0x7F, 0xBF, 255), self)
	end
	self.m_Label = GUILabel:new(0, height*0.05, width, height*0.9, text, self)
		:setAlign("center", "center")
		
	self.m_Animation = false
	self.m_BarAnimation = false
	self.m_TextAnimation = false
	self.m_IsDark = false
	self.m_BarColor = tocolor(0x3F, 0x7F, 0xBF, 255)
	self.m_Enabled = true
	
	self.onInternalHover = function() self.m_Bar:setColor(Color.White) end
	self.onInternalUnhover = function() self.m_Bar:setColor(self.m_BarColor) end
end

function VRPButton:setText(text)
	self.m_Label:setText(text)
	return self
end

function VRPButton:dark(quick)
	if quick then
		self.m_Bar:hide()
	else
		if not self.m_IsDark then
			if self.m_BarAnimation then
				self.m_BarAnimation:delete()
			end
			self.m_BarAnimation = Animation.FadeColor:new(self.m_Bar, 150, { 0x3F, 0x7F, 0xBF, 255 }, { 0, 0, 0, 0 })
			self.m_BarAnimation.onFinish = function() self.m_Bar:hide() end
		end
	end
	self.m_IsDark = true
	return self
end

function VRPButton:light(quick)
	self.m_Bar:show()
	if quick then
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

function VRPButton:setBarColor(color)
	self.m_BarColor = color
	self.m_Bar:setColor(color)
	self:anyChange()
	return self
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


function VRPButton:setEnabled(state)
	self.m_Enabled = state
	if state then
		self.m_Label:setColor(Color.White)
	else
		self.m_Label:setColor(tocolor(100, 100, 100))
	end
	
	--self:anyChange()
end

function VRPButton:isEnabled()
	return self.m_Enabled
end

function VRPButton:performChecks(...)
	-- Only perform checks if enabled
	if self.m_Enabled then
		GUIElement.performChecks(self, ...)
	end
end
