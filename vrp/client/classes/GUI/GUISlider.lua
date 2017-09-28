-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUISlider.lua
-- *  PURPOSE:     provide a range slider which has more events than a simple scroll bar
-- *
-- ****************************************************************************
GUISlider = inherit(GUIElement)
local RAIL_HEIGHT = 4
local HANDLE_WIDTH = 8

function GUISlider:constructor(posX, posY, width, height, parent)
    GUIElement.constructor(self, posX, posY, width, height, parent)
	self.m_CursorMoveHandler = bind(GUISlider.Event_onClientCursorMove, self)
    self.m_RangeMin = 0 -- minimum value
    self.m_RangeMax = 1 --max value
    self.m_Value = 0.5 --current value
    self.m_RoundOffset = 3 --value for math.round on actual value to prevent event spam
	self.m_AnimationDuration = 150

	-- Clickdummy
	self.m_RailClickDummy = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, Color.Clear, self)
	self.m_RailClickDummy.onLeftClickDown =
		function(_, cx, cy)
			self:internalCheckForNewValue(cx, cy)

			if not self.m_Scrolling then
				addEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
				self.m_Scrolling = true
                self.m_Animation = Animation.Size:new(self.m_Handle, self.m_AnimationDuration, HANDLE_WIDTH, self.m_Height, "OutQuad")
			end
		end

    --use a GUI element as a handle (this got implemented later on to prevent an ongoing onClientCursorMove just to handle hover events)
    self.m_Handle = GUIRectangle:new(self:getInternalRelativeValue()*(self.m_Width-HANDLE_WIDTH), 0, HANDLE_WIDTH, HANDLE_WIDTH, Color.Accent, self)
    self.m_Handle.onHover = function() 
        self.m_Handle:setColor(Color.White)
        self.m_Animation = Animation.Size:new(self.m_Handle, self.m_AnimationDuration, HANDLE_WIDTH, self.m_Height, "OutQuad")
    end

    self.m_Handle.onUnhover = function() 
        if not self.m_Scrolling then 
            self.m_Handle:setColor(Color.Accent)
            self.m_Animation = Animation.Size:new(self.m_Handle, self.m_AnimationDuration, HANDLE_WIDTH, HANDLE_WIDTH, "OutQuad") 
        end 
    end
end

function GUISlider:setRange(rangeMin, rangeMax)
    self.m_RangeMin = tonumber(rangeMin) or self.m_RangeMin
    self.m_RangeMax = tonumber(rangeMax) or self.m_RangeMax
    self:setValue(self.m_Value) -- recall value to clamp it to new range
end

function GUISlider:setValue(value)
    self.m_Value = math.clamp(self.m_RangeMin, tonumber(value) or 0, self.m_RangeMax)
end

function GUISlider:internalCheckForNewValue(cx, cy)
    local newVal = self:internalCursorPositionToSliderValue(cx, cy)
    if newVal ~= self.m_Value then
        self.m_Value = newVal
        self:anyChange()
        if self.onUpdate then
            self.onUpdate(self.m_Value)
        end
    end
end

function GUISlider:getInternalRelativeValue()
    return (self.m_Value - self.m_RangeMin)/(self.m_RangeMax - self.m_RangeMin)
end

function GUISlider:internalCursorPositionToSliderValue(cx, cy)
    local x, y = self:getPosition(true)
    local valueByOffset = (math.clamp(x + HANDLE_WIDTH/2, cx, x + self.m_Width - HANDLE_WIDTH/2) - (x + HANDLE_WIDTH/2)) / (self.m_Width - HANDLE_WIDTH)
    return math.round(valueByOffset * (self.m_RangeMax - self.m_RangeMin) + self.m_RangeMin, self.m_RoundOffset)
end

function GUISlider:getValue()
    return self.m_Value
end

function GUISlider:Event_onClientCursorMove(_, _, cursorX, cursorY)
	if isCursorShowing() then
		self:internalCheckForNewValue(cursorX, cursorY)

        if not getKeyState("mouse1") then
			removeEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
			self.m_Scrolling = false
			self.m_Animation = Animation.Size:new(self.m_Handle, self.m_AnimationDuration, HANDLE_WIDTH, HANDLE_WIDTH, "OutQuad")
            self.m_Handle:setColor(Color.Accent)
		end
	end
end

function GUISlider:drawThis()
    --draw rail (rectangle)
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height/2 - RAIL_HEIGHT/2, self.m_Width, RAIL_HEIGHT, Color.PrimaryNoClick)

	-- draw handle
	local _, hY = self.m_Handle:getSize()
    local offsetByValue = self:getInternalRelativeValue()*(self.m_Width-HANDLE_WIDTH)
    self.m_Handle:setPosition(offsetByValue, self.m_Height/2 - hY/2) -- update the handle gui element
end
