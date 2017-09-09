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

    --use a GUI element as a handle (this got implemented later on to prevent an ongoing onClientCursorMove just to handle hover events)
    self.m_Handle = GUIRectangle:new(self:getInternalRelativeValue()*(self.m_Width-HANDLE_WIDTH), 0, HANDLE_WIDTH, self.m_Height, Color.Accent, self)
    self.m_Handle.onHover = function()
        self.m_Handle:setColor(Color.White)
    end
    self.m_Handle.onUnhover = function()
        if not self.m_Scrolling then
          self.m_Handle:setColor(Color.Accent)
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

function GUISlider:internalCheckForNewValue(cx, cy, updateFinished)
    local newVal = self:internalCursorPositionToSliderValue(cx, cy)
    if newVal ~= self.m_Value then 
        self.m_Value = newVal
        self:anyChange()
        if self.onUpdate then
            self.onUpdate(self.m_Value)
        end
    end
    if updateFinished then
        if self.onUpdated then
            self.onUpdated(self.m_Value)
        end
    end
end

function GUISlider:getInternalRelativeValue()
    return (self.m_Value - self.m_RangeMin)/(self.m_RangeMax - self.m_RangeMin)
end

function GUISlider:internalIsCursorOnRail(cx, cy)
    local x, y = self:getPosition(true)
    local railX, railY = x, y + self.m_Height/2 - RAIL_HEIGHT/2
    if cx > railX and cx < railX + self.m_Width and cy > railY  and cy < railY + RAIL_HEIGHT then
        return true
    end
end

function GUISlider:internalIsCursorOnHandle(cx, cy)
    local x, y = self:getPosition(true)
    local offsetByValue = self:getInternalRelativeValue()*(self.m_Width-HANDLE_WIDTH)
    local handleX, handleY = x + offsetByValue, y
    if cx > handleX and cx < handleX + HANDLE_WIDTH and cy > handleY  and cy < handleY + self.m_Height then
        return cx - handleX - HANDLE_WIDTH/2
    end
end

function GUISlider:internalCursorPositionToSliderValue(cx, cy)
    local x, y = self:getPosition(true)
    local valueByOffset = (math.clamp(x + HANDLE_WIDTH/2, cx, x + self.m_Width - HANDLE_WIDTH/2) - (x + HANDLE_WIDTH/2)) / (self.m_Width - HANDLE_WIDTH)
    return math.round(valueByOffset * (self.m_RangeMax - self.m_RangeMin) + self.m_RangeMin, self.m_RoundOffset)
end

function GUISlider:getValue()
    return self.m_Value
end

function GUISlider:onInternalLeftClickDown(cx, cy)
    local offsetOfCursorToHandle = self:internalIsCursorOnHandle(cx, cy) -- returns offset if cursor is on handle, otherwise nil
    if offsetOfCursorToHandle and not self.m_Scrolling then
        addEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
		self.m_Scrolling = true
		self.m_ScrollOffset = offsetOfCursorToHandle
    end

end

function GUISlider:onInternalLeftClick(cx, cy)
    if self.m_Scrolling then
        removeEventHandler("onClientCursorMove", root, self.m_CursorMoveHandler)
        self.m_Scrolling = false
        self:internalCheckForNewValue(cx, cy, true)
    elseif self:internalIsCursorOnRail(cx, cy) then
        self:internalCheckForNewValue(cx, cy, true)
    end
end

function GUISlider:Event_onClientCursorMove(_, _, cursorX, cursorY)
	if isCursorShowing() then
        if getKeyState("mouse1") then 
            self:internalCheckForNewValue(cursorX - self.m_ScrollOffset, cursorY)
        else -- mouse is no longer pressed (this happens if it gets released outside of the gui elements)
            self:onInternalLeftClick(cursorX, cursorY)
            self.m_Handle:setColor(Color.Accent)
        end
	end
end

function GUISlider:drawThis()
    --draw rail (rectangle)
	dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY + self.m_Height/2 - RAIL_HEIGHT/2, self.m_Width, RAIL_HEIGHT, Color.PrimaryNoClick)

	-- draw handle

    local offsetByValue = self:getInternalRelativeValue()*(self.m_Width-HANDLE_WIDTH)
    self.m_Handle:setPosition(offsetByValue, 0) -- update the handle gui element
end
