-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ColorPicker.lua
-- *  PURPOSE:     ColorPicker
-- *
-- ****************************************************************************
ColorPicker = inherit(GUIForm)
inherit(Singleton, ColorPicker)

function ColorPicker:constructor(acceptCallback, changeCallback)
    local width, height = 390, 330
    GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"ColorPicker", true, true, self)

	self.m_AcceptCallback = acceptCallback
	self.m_ChangeCallback = changeCallback

	-- Border
	GUIRectangle:new(4, 34, 258, 258, Color.Black, self.m_Window) -- Gradient
	GUIRectangle:new(269, 34, 32, 258, Color.Black, self.m_Window) -- HueBar
	GUIRectangle:new(309, 34, 77, 62, Color.Black, self.m_Window) -- Preview

	self.m_BorderM1 = GUIRectangle:new(4, 294, 32, 32, Color.Black, self.m_Window) -- M1
	self.m_BorderM2 = GUIRectangle:new(39, 294, 32, 32, Color.Black, self.m_Window) -- M2
	self.m_BorderM3 = GUIRectangle:new(74, 294, 32, 32, Color.Black, self.m_Window) -- M3
	self.m_BorderM4 = GUIRectangle:new(109, 294, 32, 32, Color.Black, self.m_Window) -- M4
	self.m_BorderM5 = GUIRectangle:new(144, 294, 32, 32, Color.Black, self.m_Window) -- M5

	-- Gradient/Hue Bar
	self.m_BackgroundColor = GUIRectangle:new(5, 35, 256, 256, Color.White, self.m_Window)
	self.m_Gradient = GUIImage:new(5, 35, 256, 256, "files/images/Colorpicker/Gradient.png", self.m_Window)
	self.m_GradientCursor = GUIImage:new(5, 35, 11, 11, "files/images/Colorpicker/Cursor.png", self.m_Window)

	self.m_HueBar = GUIImage:new(270, 35, 30, 256, "files/images/Colorpicker/hueBar.png", self.m_Window)
	self.m_HueCursor = GUIRectangle:new(268, 35, 34, 2, Color.Black, self.m_Window)

	-- Preview
	self.m_Preview = GUIRectangle:new(310, 35, 75, 60, Color.Black, self.m_Window)

	-- Labels/Inputbox
	GUILabel:new(310, 100, 10, 20, "H:", self.m_Window)
	GUILabel:new(310, 125, 10, 20, "S:", self.m_Window)
	GUILabel:new(310, 150, 10, 20, "B:", self.m_Window)
	GUILabel:new(310, 185, 10, 20, "R:", self.m_Window)
	GUILabel:new(310, 210, 10, 20, "G:", self.m_Window)
	GUILabel:new(310, 235, 10, 20, "B:", self.m_Window)
	GUILabel:new(310, 270, 10, 20, "#", self.m_Window)

	self.m_HueEdit = GUIEdit:new(325, 100, 60, 20, self.m_Window):setNumeric(true, true):setMaxValue(360):setMaxLength(3)
	self.m_SaturationEdit = GUIEdit:new(325, 125, 60, 20, self.m_Window):setNumeric(true, true):setMaxValue(100):setMaxLength(3)
	self.m_BrightnessEdit = GUIEdit:new(325, 150, 60, 20, self.m_Window):setNumeric(true, true):setMaxValue(100):setMaxLength(3)
	self.m_RedEdit = GUIEdit:new(325, 185, 60, 20, self.m_Window):setNumeric(true, true):setMaxValue(255):setMaxLength(3)
	self.m_GreenEdit = GUIEdit:new(325, 210, 60, 20, self.m_Window):setNumeric(true, true):setMaxValue(255):setMaxLength(3)
	self.m_BlueEdit = GUIEdit:new(325, 235, 60, 20, self.m_Window):setNumeric(true, true):setMaxValue(255):setMaxLength(3)
	self.m_HexEdit = GUIEdit:new(325, 270, 60, 20, self.m_Window):setMaxLength(6)


	-- Memory
	self.m_M1 = GUIRectangle:new(5, 295, 30, 30, core:get("ColorPicker", "M1", Color.White), self.m_Window)
	self.m_M2 = GUIRectangle:new(40, 295, 30, 30, core:get("ColorPicker", "M2", Color.White), self.m_Window)
	self.m_M3 = GUIRectangle:new(75, 295, 30, 30, core:get("ColorPicker", "M3", Color.White), self.m_Window)
	self.m_M4 = GUIRectangle:new(110, 295, 30, 30, core:get("ColorPicker", "M4", Color.White), self.m_Window)
	self.m_M5 = GUIRectangle:new(145, 295, 30, 30, core:get("ColorPicker", "M5", Color.White), self.m_Window)
	self.m_M1.Option = "M1"
	self.m_M2.Option = "M2"
	self.m_M3.Option = "M3"
	self.m_M4.Option = "M4"
	self.m_M5.Option = "M5"

	-- Accept Button
	self.m_SaveToMemory = GUIButton:new(180, 295, 30, 30, "✚", self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Grey):setBackgroundHoverColor(Color.LightGrey)
	self.m_AcceptButton = GUIButton:new(270, 295, 115, 30, "✔", self.m_Window):setBarEnabled(false):setBackgroundColor(Color.Green)
	self.m_AcceptButton.onLeftClick = bind(ColorPicker.accept, self)

	-- Default values
	self.m_WindowInteraction = true
	self.m_Hue = 1
	self.m_Saturation = 1
	self.m_Brightness = 1

	self:updateColor()
	self:updatePosition()

	-- Events
	self.m_OnCursorClick = bind(ColorPicker.onCursorClick, self)
	self.m_OnCursorMove = bind(ColorPicker.onCursorMove, self)
	self.m_OnHSBEdit = bind(ColorPicker.onHSBEdit, self)
	self.m_OnRGBEdit = bind(ColorPicker.onRGBEdit, self)
	self.m_OnHexEdit = bind(ColorPicker.onHexEdit, self)
	self.m_OnMemorySelect = bind(ColorPicker.onMemorySelect, self)
	self.m_OnColorSaveLoad = bind(ColorPicker.onColorSaveLoad, self)

	self.m_HueEdit.onChange = self.m_OnHSBEdit
	self.m_SaturationEdit.onChange = self.m_OnHSBEdit
	self.m_BrightnessEdit.onChange = self.m_OnHSBEdit
	self.m_RedEdit.onChange = self.m_OnRGBEdit
	self.m_GreenEdit.onChange = self.m_OnRGBEdit
	self.m_BlueEdit.onChange = self.m_OnRGBEdit
	self.m_HexEdit.onChange = self.m_OnHexEdit

	self.m_Gradient.onLeftClickDown = self.m_OnCursorMove
	self.m_HueBar.onLeftClickDown = self.m_OnCursorMove

	self.m_M1.onLeftClick = self.m_OnMemorySelect
	self.m_M2.onLeftClick = self.m_OnMemorySelect
	self.m_M3.onLeftClick = self.m_OnMemorySelect
	self.m_M4.onLeftClick = self.m_OnMemorySelect
	self.m_M5.onLeftClick = self.m_OnMemorySelect
	self.m_M1.onLeftDoubleClick = self.m_OnColorSaveLoad
	self.m_M2.onLeftDoubleClick = self.m_OnColorSaveLoad
	self.m_M3.onLeftDoubleClick = self.m_OnColorSaveLoad
	self.m_M4.onLeftDoubleClick = self.m_OnColorSaveLoad
	self.m_M5.onLeftDoubleClick = self.m_OnColorSaveLoad
	self.m_SaveToMemory.onLeftClick = self.m_OnColorSaveLoad

	addEventHandler("onClientClick", root, self.m_OnCursorClick)
	addEventHandler("onClientCursorMove", root, self.m_OnCursorMove)
end

function ColorPicker:virtual_destructor()
	removeEventHandler("onClientClick", root, self.m_OnCursorClick)
	removeEventHandler("onClientCursorMove", root, self.m_OnCursorMove)
end

function ColorPicker:onCursorClick(_, state)
	if state == "up" then
		self.m_HueMouseDown = false
		self.m_BrightnessSaturationMouseDown = false
		self.m_Window:toggleMoving(true)

		nextframe(function() self.m_WindowInteraction = true end)
		return
	end

	if self.m_Gradient:isCursorWithinBox(0, 0, 256, 256) then
		self.m_WindowInteraction = false
		self.m_Window:toggleMoving(false)
		self.m_BrightnessSaturationMouseDown = true
		return
	end

	if self.m_HueBar:isCursorWithinBox(0, 0, 30, 256) then
		self.m_WindowInteraction = false
		self.m_Window:toggleMoving(false)
		self.m_HueMouseDown = true
		return
	end
end

function ColorPicker:onCursorMove()
	local relCursorX, relCursorY = getCursorPosition()
	if not relCursorX then return end

	local cursorX, cursorY = screenWidth*relCursorX, screenHeight*relCursorY
	local windowX, windowY = self.m_Window:getPosition(true)

	if self.m_HueMouseDown then
		local _, hueBarPosY = self.m_HueBar:getPosition()
		local _, hueBarSize = self.m_HueBar:getSize()

		local positionY = cursorY - windowY

		if positionY < hueBarPosY then positionY = hueBarPosY end
		if positionY > hueBarPosY + hueBarSize then positionY = hueBarPosY + hueBarSize end

		self.m_HueCursor:setAbsolutePosition(nil, positionY - 1)
		self.m_Hue = 1-(360/hueBarSize*(positionY-hueBarPosY)/360)
		self:updateColor()
		return
	end

	if self.m_BrightnessSaturationMouseDown then
		local gradientPosX, gradientPosY = self.m_Gradient:getPosition()
		local gradientSizeW, gradientSizeH = self.m_Gradient:getSize()

		local positionX, positionY = cursorX - windowX, cursorY - windowY

		if positionY < gradientPosY then positionY = gradientPosY end
		if positionY > gradientPosY + gradientSizeH then positionY = gradientPosY + gradientSizeH end

		if positionX < gradientPosX then positionX = gradientPosX end
		if positionX > gradientPosX + gradientSizeW then positionX = gradientPosX + gradientSizeW end

		self.m_GradientCursor:setAbsolutePosition(positionX - 11/2, positionY - 11/2)
		self.m_Brightness = 1-(100/gradientSizeH*(positionY-gradientPosY)/100)
		self.m_Saturation = 100/gradientSizeW*(positionX-gradientPosX)/100
		self:updateColor()
		return
	end
end

function ColorPicker:updateColor(skipHex)
	local r, g, b = hsvToRgb(self.m_Hue, 1, 1, 1)
	self.m_BackgroundColor:setColorRGB(r, g, b)

	local r, g, b = hsvToRgb(self.m_Hue, self.m_Saturation, self.m_Brightness, 1)
	self.m_Preview:setColorRGB(r, g, b)

	self.m_HueEdit:setText(math.round(self.m_Hue*360))
	self.m_SaturationEdit:setText(math.round(self.m_Saturation*100))
	self.m_BrightnessEdit:setText(math.round(self.m_Brightness*100))

	self.m_RedEdit:setText(math.round(r))
	self.m_GreenEdit:setText(math.round(g))
	self.m_BlueEdit:setText(math.round(b))

	if not skipHex then
		self.m_HexEdit:setText(RGBToHex(r, g, b))
	end

	if self.m_ChangeCallback then
		self.m_ChangeCallback(r, g, b)
	end
end

function ColorPicker:updatePosition()
	local _, hueBarPosY = self.m_HueBar:getPosition()
	local _, hueBarSize = self.m_HueBar:getSize()

	local positionY = hueBarPosY + (1-self.m_Hue)*hueBarSize
	self.m_HueCursor:setAbsolutePosition(nil, positionY)

	local gradientPosX, gradientPosY = self.m_Gradient:getPosition()
	local gradientSizeW, gradientSizeH = self.m_Gradient:getSize()

	local positionX = gradientPosX + self.m_Saturation*gradientSizeW
	local positionY = gradientPosY + (1-self.m_Brightness)*gradientSizeH

	self.m_GradientCursor:setAbsolutePosition(positionX - 11/2, positionY - 11/2)
end

function ColorPicker:onHSBEdit()
	self.m_Hue = (self.m_HueEdit:getText(true) or 0)/360
	self.m_Saturation = (self.m_SaturationEdit:getText(true) or 0)/100
	self.m_Brightness = (self.m_BrightnessEdit:getText(true) or 0)/100

	if self.m_Hue < 0 then self.m_Hue = 0 end
	if self.m_Hue > 1 then self.m_Hue = 1 end
	if self.m_Saturation < 0 then self.m_Saturation = 0 end
	if self.m_Saturation > 1 then self.m_Saturation = 1 end
	if self.m_Brightness < 0 then self.m_Brightness = 0 end
	if self.m_Brightness > 1 then self.m_Brightness = 1 end

	self:updateColor()
	self:updatePosition()
end

function ColorPicker:onRGBEdit()
	local r = self.m_RedEdit:getText(true)
	local g = self.m_GreenEdit:getText(true)
	local b = self.m_BlueEdit:getText(true)

	if not r or not g or not b then return end
	if r < 0 then r = 0 end
	if r > 255 then r = 255 end
	if g < 0 then g = 0 end
	if g > 255 then g = 255 end
	if b < 0 then b = 0 end
	if b > 255 then b = 255 end

	self.m_Hue, self.m_Saturation, self.m_Brightness = rgbToHsv(r, g, b, 1)

	self:updateColor()
	self:updatePosition()
end

function ColorPicker:onHexEdit()
	local hex = self.m_HexEdit:getText()
	local r, g, b = getColorFromString("#" .. hex)

	if not r or not g or not b then return end
	self.m_Hue, self.m_Saturation, self.m_Brightness = rgbToHsv(r, g, b, 1)

	self:updateColor(true)
	self:updatePosition()
end

function ColorPicker:setColor(r, g, b)
	self.m_Hue, self.m_Saturation, self.m_Brightness = rgbToHsv(r, g, b, 1)
	self:updateColor()
	self:updatePosition()
end

function ColorPicker:onMemorySelect(button)
	if self.m_LastSelected then
		self[("m_Border%s"):format(self.m_LastSelected.Option)]:setColor(Color.Black)
		self.m_LastSelected = false
	end

	if button and button.Option then
		self.m_LastSelected = button
		self[("m_Border%s"):format(self.m_LastSelected.Option)]:setColor(Color.White)
	end
end

function ColorPicker:onColorSaveLoad(button)
	if not self.m_WindowInteraction then return end

	if button == self.m_SaveToMemory then
		local currentColor = self.m_Preview:getColor()
		self.m_LastSelected:setColor(currentColor)
		core:set("ColorPicker", self.m_LastSelected.Option, currentColor)
		return
	end

	if self.m_LastSelected then
		self:setColor(self.m_LastSelected:getColorRGB())
		self:onMemorySelect(false)
	end
end

function ColorPicker:accept()
	if self.m_WindowInteraction then
		if self.m_AcceptCallback then
			local r, g, b = self.m_Preview:getColorRGB()
			self.m_AcceptCallback(r, g, b)
		end

		delete(self)
	end
end
