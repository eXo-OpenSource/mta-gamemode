ColorPicker = inherit(GUIForm)
inherit(Singleton, ColorPicker)

function ColorPicker:constructor(acceptCallback, changeCallback)
    local width, height = 400, 300
    GUIForm.constructor(self, screenWidth/2-width/2, screenHeight/2-height/2, width, height)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Colorpicker", true, true, self)

	self.m_AcceptCallback = acceptCallback
	self.m_ChangeCallback = changeCallback

	-- Border
	GUIRectangle:new(4, 34, 258, 258, Color.Black, self.m_Window)
	GUIRectangle:new(269, 34, 32, 258, Color.Black, self.m_Window)

	-- Gradient/Hue Bar
	self.m_BackgroundColor = GUIRectangle:new(5, 35, 256, 256, Color.White, self.m_Window)
	self.m_Gradient = GUIImage:new(5, 35, 256, 256, "files/images/Colorpicker/Gradient.png", self.m_Window)
	self.m_GradientCursor = GUIImage:new(5, 35, 11, 11, "files/images/Colorpicker/Cursor.png", self.m_Window)

	self.m_HueBar = GUIImage:new(270, 35, 30, 256, "files/images/Colorpicker/hueBar.png", self.m_Window)
	self.m_HueCursor = GUIRectangle:new(268, 35, 34, 2, Color.Black, self.m_Window)

	-- Preview
	self.m_Preview = GUIRectangle:new(310, 35, 70, 70, Color.Black, self.m_Window)

	self:updateColor()

	-- Accept Button
	self.m_AcceptButton = GUIButton:new(310, 260, 80, 30, "✔", self.m_Window):setBackgroundColor(Color.Green)
	self.m_AcceptButton.onLeftClick = bind(self.accept, self)

	self.m_OnCursorClick = bind(ColorPicker.onCursorClick, self)
	self.m_OnCursorMove = bind(ColorPicker.onCursorMove, self)

	self.m_Gradient.onLeftClickDown = self.m_OnCursorMove
	self.m_HueBar.onLeftClickDown = self.m_OnCursorMove
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
		return
	end

	if self.m_Gradient:isCursorWithinBox(0, 0, 256, 256) then
		self.m_Window:toggleMoving(false)
		self.m_BrightnessSaturationMouseDown = true
		return
	end

	if self.m_HueBar:isCursorWithinBox(0, 0, 30, 256) then
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

		self.m_HueCursor:setAbsolutePosition(nil, positionY)
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

function ColorPicker:updateColor()
	local r, g, b = hsvToRgb(self.m_Hue or 1, 1, 1, 1)
	self.m_BackgroundColor:setColorRGB(r, g, b)

	local r, g, b = hsvToRgb(self.m_Hue or 1, self.m_Saturation or 1, self.m_Brightness or 1, 1)
	self.m_Preview:setColorRGB(r, g, b)
end

function ColorPicker:accept()

end
