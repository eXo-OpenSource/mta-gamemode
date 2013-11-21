-- ****************************************************************************
-- *
-- *  PROJECT:     Open MTA:DayZ
-- *  FILE:        client/classes/GUI/GUIElement.lua
-- *  PURPOSE:     Base class for all GUI elements
-- *
-- ****************************************************************************

GUIElement = inherit(DxElement)

function GUIElement:constructor(posX, posY, width, height, parent)
	checkArgs("CGUIElement:constructor", "number", "number", "number", "number")
	assert(type(parent) == "table" or parent == nil, "Bad argument #5 @ GUIElement.constructor")

	DxElement.constructor(self, posX, posY, width, height, parent)
	
	-- Hover / Click Events
	self.m_LActive = false
	self.m_RActive = false
	self.m_Hover  = false
end

function GUIElement:performChecks(mouse1, mouse2, cx, cy)
	if not self.m_Visible then
		return
	end

	local absoluteX, absoluteY = self.m_AbsoluteX, self.m_AbsoluteY
	if self.m_CacheArea then
		absoluteX = absoluteX + self.m_CacheArea.m_AbsoluteX
		absoluteY = absoluteY + self.m_CacheArea.m_AbsoluteY
	end
	
	local inside = (absoluteX <= cx and absoluteY <= cy and absoluteX + self.m_Width > cx and absoluteY + self.m_Height > cy)
	
	if self.m_LActive and not mouse1 then
		if self.onLeftClick			then self:onLeftClick(cx, cy)			end
		if self.onInternalLeftClick	then self:onInternalLeftClick(cx, cy)	end
		self.m_LActive = false
	end
	if self.m_RActive and not mouse2 then
		if self.onRightClick			then self:onRightClick(cx, cy)			end
		if self.onInternalRightClick	then self:onInternalRightClick(cx, cy)	end
		self.m_RActive = false
	end
	
	if not inside then
		-- Call on*Events (disabling)
		if self.m_Hover then
			if self.onUnhover		  then self:onUnhover()         end
			if self.onInternalUnhover then self:onInternalUnhover() end
			self.m_Hover = false
		end
		
		return 
	end

	-- Call on*Events (enabling)
	if not self.m_Hover then
		if self.onHover			then self:onHover()			end
		if self.onInternalHover then self:onInternalHover() end
		self.m_Hover = true
		GUIElement.HoveredElement = self
	end
	if mouse1 and not self.m_LActive then
		if self.onLeftClickDown			then self:onLeftClickDown()			end
		if self.onInternalLeftClickDown then self:onInternalLeftClickDown() end
		self.m_LActive = true

		-- Check whether the focus changed
		GUIInputControl.checkFocus(self)
	end
	if mouse2 and not self.m_RActive then
		if self.onRightClickDown			then self:onRightClickDown()			end
		if self.onInternalRightClickDown	then self:onInternalRightClickDown()	end
		self.m_RActive = true
	end


	if self.m_LActive and not mouse1 then
		self.m_LActive = false
	end

	if self.m_RActive and not mouse2 then
		self.m_RActive = false
	end
	
	-- Check on children
	for k, v in pairs(self.m_Children) do
		v:performChecks(mouse1, mouse2, cx, cy)
	end
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
	return GUIElement.HoveredElement
end

function GUIElement:isHovered()
	return self.m_Hover
end

-- Static mouse wheel event checking
addEventHandler("onClientResourceStart", resourceRoot,
	function()
		bindKey("mouse_wheel_up", "down",
			function()
				local hoveredElement = GUIElement.getHoveredElement()
				if hoveredElement then
					if hoveredElement.onInternalMouseWheelUp then hoveredElement:onInternalMouseWheelUp() end
					if hoveredElement.onMouseWheelUp then hoveredElement:onMouseWheelUp() end
				end
			end
		)
		bindKey("mouse_wheel_down", "down",
			function()
				local hoveredElement = GUIElement.getHoveredElement()
				if hoveredElement then
					if hoveredElement.onInternalMouseWheelDown then hoveredElement:onInternalMouseWheelDown() end
					if hoveredElement.onMouseWheelDown then hoveredElement:onMouseWheelDown() end
				end
			end
		)
	end
)

addEventHandler("onClientDoubleClick", root,
	function(button, absoluteX, absoluteY)
		--local guiElement = self:getElementAt(absoluteX, absoluteY)
		local guiElement = GUIElement.getHoveredElement()
		if guiElement then
			if button == "left" and guiElement.onLeftDoubleClick then
				guiElement:onLeftDoubleClick(absoluteX, absoluteY)
			end
			if button == "right" and guiElement.onRightDoubleClick then
				guiElement:onRightDoubleClick(absoluteX, absoluteY)
			end
		end
	end
)
