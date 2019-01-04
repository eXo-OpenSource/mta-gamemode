GUITooltip = inherit(Object)
GUITooltip.ms_CurrentTooltip = nil

function GUITooltip:virtual_constructor()
	self.m_CreateTooltip = bind(GUITooltip.createTooltip, self)
end

function GUITooltip:setTooltip(text, pos, multiline)
	self.m_TooltipText = text
	self.m_TooltipPos = pos
	self.m_TooltipMultiline = multiline or false
	return self
end

function GUITooltip:updateTooltip(hovered)
	if not self.m_TooltipText then return false end

	if hovered and not self.m_TooltipActive then
		if isTimer(self.m_TooltipCreateTimer) then killTimer(self.m_TooltipCreateTimer) end
		self.m_TooltipCreateTimer = setTimer(self.m_CreateTooltip, 300, 1)
	else
		if self.m_TooltipActive then
			self:fadeOut()
			self.m_TooltipResetTimer = setTimer(
				function()
					self.m_Tooltip:delete()
					self.m_TooltipArrow:delete()
					self.m_TooltipActive = false
				end, 210, 1
			)
		end
	end

	if not hovered and isTimer(self.m_TooltipCreateTimer) then
		killTimer(self.m_TooltipCreateTimer)
	end

	if hovered and isTimer(self.m_TooltipResetTimer) then
		killTimer(self.m_TooltipResetTimer)
	end
end

function GUITooltip:createTooltip()
	if GUIElement.getHoveredElement() ~= self then
		return
	end

	GUITooltip.ms_CurrentTooltip = self
	self.m_TooltipActive = true

	local f = getVRPFont(VRPFont(20))
	local x, y = self:getPosition(true)
	local w, h = self:getSize()
	local textW = fontWidth(self.m_TooltipText, f, 1) + 10 -- 30 is the margin
	local textH = self.m_TooltipMultiline and (string.count(self.m_TooltipText, "\n")+1)*dxGetFontHeight(1, VRPFont(20)) or 20

	if self.m_TooltipPos == "left" then
		self.m_Tooltip = GUILabel:new(x - textH/2 - textW, y + h/2 - 10, textW, textH, self.m_TooltipText)
		self.m_TooltipArrow = GUIImage:new(x - 14, y + h/2 - 4, 16, 8, "files/images/GUI/Triangle.png"):setRotation(90)
	elseif self.m_TooltipPos == "right" then
		self.m_Tooltip = GUILabel:new(x + w + textH/2, y + h/2 - 10, textW, textH, self.m_TooltipText)
		self.m_TooltipArrow = GUIImage:new(x + w - 2, y + h/2 - 4, 16, 8, "files/images/GUI/Triangle.png"):setRotation(270)
	elseif self.m_TooltipPos == "bottom" then
		self.m_Tooltip = GUILabel:new(x + w/2 - textW/2, y + h + 10, textW, textH, self.m_TooltipText)
		self.m_TooltipArrow = GUIImage:new(x + w/2 - 8, y + h + 2, 16, 8, "files/images/GUI/Triangle.png"):setRotation(0)
	else -- top is default
		self.m_Tooltip = GUILabel:new(x + w/2 - textW/2, y - textH-10, textW, textH, self.m_TooltipText)
		self.m_TooltipArrow = GUIImage:new(x + w/2 - 8, y - 10, 16, 8, "files/images/GUI/Triangle.png"):setRotation(180)
	end

	if self.m_TooltipMultiline then
		self.m_Tooltip:setMultiline(true)
		self.m_Tooltip:setFont(f)
	end

	self.m_Tooltip:setColor(Color.PrimaryNoClick):setBackgroundColor(Color.White)
	self.m_Tooltip:setAlignX(self.m_TooltipMultiline and "left" or "center")
	self.m_Tooltip.m_CacheArea:bringToFront()

	self:fadeIn()
end

function GUITooltip:fadeIn()
	Animation.FadeAlpha:new(self.m_Tooltip, 500, 0, 255)
	Animation.FadeAlpha:new(self.m_TooltipArrow, 500, 0, 255)
end

function GUITooltip:fadeOut()
	Animation.FadeAlpha:new(self.m_Tooltip, 200, 255, 0)
	Animation.FadeAlpha:new(self.m_TooltipArrow, 200, 255, 0)
end

function GUITooltip.checkTooltip()
	if  GUITooltip.ms_CurrentTooltip and GUIElement.getHoveredElement() and GUIElement.getHoveredElement() ~= GUITooltip.ms_CurrentTooltip then
		GUITooltip.ms_CurrentTooltip:updateTooltip(false)
		GUITooltip.ms_CurrentTooltip = nil
		return
	end
end
