-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ColorPickerGUI.lua
-- *  PURPOSE:     Color picker GUI
-- *
-- ****************************************************************************
ColorPickerGUI = inherit(GUIForm)

function ColorPickerGUI:constructor(acceptCallback, changeCallback)
    local width, height = 330, 250
    GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height)

    self.m_AcceptCallback = acceptCallback
    self.m_ChangeCallback = changeCallback
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Farbwähler", true, true, self)

    local scrollFunc = bind(self.Color_Change, self)
    self.m_ScrollbarRed = GUIHorizontalScrollbar:new(5, 35, 320, 30, self.m_Window):setColor(Color.Red)
    self.m_ScrollbarRed.onScroll = scrollFunc
    self.m_ScrollbarGreen = GUIHorizontalScrollbar:new(5, 75, 320, 30, self.m_Window):setColor(Color.Green)
    self.m_ScrollbarGreen.onScroll = scrollFunc
    self.m_ScrollbarBlue = GUIHorizontalScrollbar:new(5, 115, 320, 30, self.m_Window):setColor(Color.Blue)
    self.m_ScrollbarBlue.onScroll = scrollFunc

    GUILabel:new(5, 155, 90, 30, _"Vorschau:", self.m_Window)
    self.m_PreviewRect = GUIRectangle:new(5, 185, 90, 60, Color.Black, self.m_Window)

    self.m_AcceptButton = GUIButton:new(230, 185+30, 90, 30, "✔", self.m_Window):setBackgroundColor(Color.Green)
    self.m_AcceptButton.onLeftClick = bind(self.AcceptButton_Click, self)

end

function ColorPickerGUI:setColor(r, g, b)
	r = r >= 255 and 254 or r
	g = g >= 255 and 254 or g
	b = b >= 255 and 254 or b

	self.m_ScrollbarRed:setScrollPosition(0.8)
	self.m_ScrollbarGreen:setScrollPosition((g/255)*0.75)
	self.m_ScrollbarBlue:setScrollPosition((b/255)*0.75)
	self.m_PreviewRect:setColorRGB(r, g, b)
end

function ColorPickerGUI:Color_Change()	
	local max = 0.834375	--// quick workaround -> on long-term: edit scrollbar-class in order to not get fucked up scrollPosition-max values!!!
	local scale = 1.198501872659176 --// you see?
    local r = (self.m_ScrollbarRed:getScrollPosition()*scale) * 255
    local g = (self.m_ScrollbarGreen:getScrollPosition()*scale) * 255
    local b = (self.m_ScrollbarBlue:getScrollPosition()*scale) * 255

    self.m_PreviewRect:setColorRGB(r, g, b)

    if self.m_ChangeCallback then
        self.m_ChangeCallback(r, g, b)
    end
end

function ColorPickerGUI:AcceptButton_Click()
    if self.m_AcceptCallback then
        local r, g, b = self.m_PreviewRect:getColorRGB()
        self.m_AcceptCallback(r, g, b)
    end
    delete(self)
end


--[[
function ColorPickerGUI:constructor(acceptCallback)
    local width, height = 460, 390
    GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height)

    self.m_AcceptCallback = acceptCallback
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Farbwähler", true, true, self)
    self.m_ColorPicker = GUIImage:new(5, 35, 350, 350, "files/images/ColorPicker.png", self.m_Window)
    self.m_ColorPicker.onLeftClick = bind(self.ColorPicker_Click, self)

    GUILabel:new(360, 35, 90, 30, _"Vorschau:", self.m_Window)
    self.m_PreviewRect = GUIRectangle:new(360, 65, 90, 60, Color.White, self.m_Window)

    self.m_AcceptButton = GUIButton:new(360, 350, 90, 30, "✔", self.m_Window):setBackgroundColor(Color.Green)
end

function ColorPickerGUI:ColorPicker_Click(image, cx, cy)
    -- Calculate mouse position within image
    local x, y = image:getPosition(true)
    x, y = cx - x, cy - y

    -- Calculate offset to center (of the circle)
    local width, height = image:getSize()
    local offX, offY = x - width/2, (y - height/2)

    -- Check if the click was within the circle
    if math.sqrt(offX, offY) > width/2 then -- width/2 = radius
        return
    end

    -- Calculate angle
    local angle = math.deg(math.atan2(offY, offX)) + 90

    local calcColor = function(angle)
            if angle >= 180 then
                angle = angle - 360
            end

            if angle >= 0 then
                angle = angle % 360
            else
                angle = -(-angle % 360)
            end

            if angle > 120 or angle < -120 then
                return 0
            end

            local color = -1/120 * math.abs(angle) + 1
            --local color = (-1/120^2) * angle^2 + 1
            if color < 0 then
                return 0
            end
            return color * 255
        end

    local r = calcColor(angle)
    local g = calcColor(angle - 120)
    local b = calcColor(angle - 240)

    -- Set color preview
    self.m_PreviewRect:setColor(tocolor(r, g, b))
end

function ColorPickerGUI:AcceptButton_Click()
    if self.m_AcceptCallback then
        self.m_AcceptCallback(self.m_PreviewRect:getColor())
    end
end
]]
