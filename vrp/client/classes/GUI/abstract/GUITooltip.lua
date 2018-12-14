GUITooltip = inherit(Object)

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
	if hovered ~= self.m_TooltipActive then
		if hovered then --create tooltip
			self.m_TooltipTimer = setTimer(self.m_CreateTooltip, 2000, 1)
		else --destroy tooltip
			if self.m_Tooltip then
				self.m_Tooltip:delete()
				self.m_TooltipArrow:delete()
				self.m_Tooltip = nil
			end
		end
		
		self.m_TooltipActive = hovered
	end
	
	if not hovered and isTimer(self.m_TooltipTimer) then
		killTimer(self.m_TooltipTimer)
	end
end

function GUITooltip:createTooltip()
	if GUIElement.getHoveredElement() ~= self then
		return
	end

	local f = VRPFont(20)
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
	
	Animation.FadeAlpha:new(self.m_Tooltip, 1000, 0, 255)
	Animation.FadeAlpha:new(self.m_TooltipArrow, 1000, 0, 255)
end