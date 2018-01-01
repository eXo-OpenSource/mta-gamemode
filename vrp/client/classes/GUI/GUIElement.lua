-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIElement.lua
-- *  PURPOSE:     Base class for all GUI elements
-- *
-- ****************************************************************************

GUIElement = inherit(DxElement)

function GUIElement:constructor(posX, posY, width, height, parent)
	DxElement.constructor(self, posX, posY, width, height, parent)

	-- Hover / Click Events
	self.m_LActive = false
	self.m_RActive = false
	self.m_Hover  = false
end

function GUIElement:destructor()
--	outputDebug("destructed element", DxHelper:getSingleton():getElementClassName(self), self.getText and self:getText(), self.m_TooltipText)
	self:updateTooltip(false) 
	DxElement.destructor(self)
end

function GUIElement:performChecks(mouse1, mouse2, cx, cy)
	if not self.m_Visible then
		return
	end

	local isDirectlyHovered = (not GUIElement.ms_HoveredElement or self.m_Parent == GUIElement.ms_HoveredElement or self.m_Parent.m_ChildrenByObject[GUIElement.ms_HoveredElement])
	local absoluteX, absoluteY = self.m_AbsoluteX, self.m_AbsoluteY
	if self.m_CacheArea then
		absoluteX = absoluteX + self.m_CacheArea.m_AbsoluteX
		absoluteY = absoluteY + self.m_CacheArea.m_AbsoluteY
	end

	local inside = (absoluteX <= cx and absoluteY <= cy and absoluteX + self.m_Width > cx and absoluteY + self.m_Height > cy) and isDirectlyHovered

	if self.m_LActive and not mouse1 and (not self.ms_ClickProcessed or GUIElement.ms_CacheAreaRetrievedClick == self.m_CacheArea) then
		if self.onLeftClick			then self:onLeftClick(cx, cy)			end
		if self.onInternalLeftClick	then self:onInternalLeftClick(cx, cy)	end
		self.m_LActive = false

		if self ~= GUIRenderer.cacheroot then
			GUIElement.ms_ClickProcessed = true
			GUIElement.ms_CacheAreaRetrievedClick = self.m_CacheArea
		end
		--return true
	end
	if self.m_RActive and not mouse2 and (not self.ms_ClickProcessed or GUIElement.ms_CacheAreaRetrievedClick == self.m_CacheArea) then
		if self.onRightClick			then self:onRightClick(cx, cy)			end
		if self.onInternalRightClick	then self:onInternalRightClick(cx, cy)	end
		self.m_RActive = false

		if self ~= GUIRenderer.cacheroot then
			GUIElement.ms_ClickProcessed = true
			GUIElement.ms_CacheAreaRetrievedClick = self.m_CacheArea
		end
		--return true
	end

	if not inside then
		-- Call on*Events (disabling)
		if self.m_Hover then
			if self.onUnhover		  then self:onUnhover(cx, cy)         end
			if self.onInternalUnhover then self:onInternalUnhover(cx, cy) end
			self.m_Hover = false
			self:updateTooltip(self.m_Hover)
			self.m_LActive = false
			self.m_RActive = false

			-- Unhover down the tree (otherwise the unhover routine won't be executed)
			for k, child in ipairs(self.m_Children) do
				if child.performChecks then --only update if it it a GUI element (because DxElements don't have checks)
					if child.onUnhover		  then child:onUnhover(cx, cy)         end
					if child.onInternalUnhover then child:onInternalUnhover(cx, cy) end
					child.m_Hover = false
					child:updateTooltip(child.m_Hover)
				end
			end
		end

		return
	end

	-- Set hovered element (do it every time because it gets reset before each processing iteration)
	--only when element is directly, via parent or via neighbour hovered
	if isDirectlyHovered then
		GUIElement.ms_HoveredElement = self

		-- Call on*Events (enabling)
		if not self.m_Hover then
			if self.onHover			then self:onHover(cx, cy)			end
			if self.onInternalHover then self:onInternalHover(cx, cy) end
			self.m_Hover = true
			self:updateTooltip(self.m_Hover)
		end
		if mouse1 and not self.m_LActive and (not GUIElement.ms_ClickDownProcessed or GUIElement.ms_CacheAreaRetrievedClick == self.m_CacheArea) then
			if self.onLeftClickDown			then self:onLeftClickDown(cx, cy)			end
			if self.onInternalLeftClickDown then self:onInternalLeftClickDown(cx, cy) 	end
			self.m_LActive = true

			if self ~= GUIRenderer.cacheroot then
				GUIElement.ms_ClickDownProcessed = true
				GUIElement.ms_CacheAreaRetrievedClick = self.m_CacheArea
			end

			if EVENT_HALLOWEEN and self.m_Blood then
				Cursor:drawClickBlood()
			end

			-- Check whether the focus changed

			if not GUIInputControl.SelectionInProgress then
				GUIInputControl.checkFocus(self)
				--return
			end
		end
		if mouse2 and not self.m_RActive and (not GUIElement.ms_ClickDownProcessed or GUIElement.ms_CacheAreaRetrievedClick == self.m_CacheArea) then
			if self.onRightClickDown			then self:onRightClickDown(cx, cy)			end
			if self.onInternalRightClickDown	then self:onInternalRightClickDown(cx, cy)	end
			self.m_RActive = true

			if self ~= GUIRenderer.cacheroot then
				GUIElement.ms_ClickDownProcessed = true
				GUIElement.ms_CacheAreaRetrievedClick = self.m_CacheArea
			end
		end


		if self.m_LActive and not mouse1 then
			self.m_LActive = false
		end

		if self.m_RActive and not mouse2 then
			self.m_RActive = false
		end

		-- Check on children
		for k, v in ipairs(self.m_Children) do
			if v.performChecks and v:performChecks(mouse1, mouse2, cx, cy) then
				--break
			end
		end
	end
end

function GUIElement:setTooltip(text, pos, multiline)
	self.m_TooltipText = text
	self.m_TooltipPos = pos
	self.m_TooltipMultiline = multiline or false
	return self
end

function GUIElement:updateTooltip(hovered)
	if not self.m_TooltipText then return false end
	if hovered ~= self.m_TooltipActive then
		if hovered then --create tooltip
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
		else --destroy tooltip
			if self.m_Tooltip then
				self.m_Tooltip:delete()
				self.m_TooltipArrow:delete()
				self.m_Tooltip = nil
			end
		end
		self.m_TooltipActive = hovered
	end
end

function GUIElement.unhoverAll()
	local self = GUIElement.ms_HoveredElement
	while self do
		if self.m_Hover then
			local relCursorX, relCursorY = getCursorPosition()
			local cursorX, cursorY = relCursorX * screenWidth, relCursorY * screenHeight

			if self.onUnhover		  then self:onUnhover(cursorX, cursorY)         end
			if self.onInternalUnhover then self:onInternalUnhover(cursorX, cursorY) end
			self.m_Hover = false
		end
		self = self.m_Parent
	end
	GUIElement.ms_HoveredElement = false
end

function GUIElement:updateInput()
	-- Check for hovers, clicks, ...
	local relCursorX, relCursorY = getCursorPosition()
	if relCursorX then
		local cursorX, cursorY = relCursorX * screenWidth, relCursorY * screenHeight

		self:performChecks(getKeyState("mouse1"), getKeyState("mouse2"), cursorX, cursorY)
	end
end

function GUIElement.getHoveredElement()
	return GUIElement.ms_HoveredElement
end

function GUIElement:isHovered()
	return self.m_Hover
end
