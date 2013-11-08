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
		if self.onLeftClickUp			then self:onLeftClickUp()			end
		if self.onInternalLeftClickUp	then self:onInternalLeftClickUp()	end
		self.m_LActive = false
	end
	if self.m_RActive and not mouse2 then
		if self.onRightClickUp			then self:onRightClickUp()			end
		if self.onInternalRightClickUp	then self:onInternalRightClickUp()	end
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
		if self.onLeftClick			then self:onLeftClick()			end
		if self.onInternalLeftClick then self:onInternalLeftClick() end
		self.m_LActive = true

		-- Check whether the focus changed
		GUIInputControl.checkFocus(self)
	end
	if mouse2 and not self.m_RActive then
		if self.onRightClick			then self:onRightClick()			end
		if self.onInternalRightClick	then self:onInternalRightClick()	end
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

function GUIElement:update()
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
