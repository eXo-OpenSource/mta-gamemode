HTTPMinimalDownloadGUI = inherit(GUIElement)
inherit(GUIFontContainer, HTTPMinimalDownloadGUI)
inherit(GUIColorable, HTTPMinimalDownloadGUI)

function HTTPMinimalDownloadGUI:constructor()
	self.m_Failed = false

	local x, y, w
	if MessageBoxManager.Mode then
		x, y, w = 20, screenHeight - screenHeight*0.265, 340*screenWidth/1600+6
		if HUDRadar:getSingleton().m_DesignSet == RadarDesign.Default then
			y = screenHeight - screenHeight*0.365
		end
	else
		x, y, w = 20, screenHeight - 5, 340*screenWidth/1600+6
	end
	GUIFontContainer.constructor(self, "Custom Textur wird geladen...\nTextur: -", 1, VRPFont(24))
	GUIColorable.constructor(self, tocolor(0, 0, 0, 0))
	local h = textHeight(self.m_Text, w - 8, self.m_Font, self.m_FontSize) + 4
	GUIElement.constructor(self, x, y - 20 - h, w, h)

	table.insert(MessageBoxManager.Map, self)
	MessageBoxManager.resortPositions()
end

function HTTPMinimalDownloadGUI:destructor()
	table.removevalue(MessageBoxManager.Map, self)
	MessageBoxManager.resortPositions()

	GUIElement.destructor(self)
end

function HTTPMinimalDownloadGUI:drawThis()
	local x, y, w, h = self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height
	dxDrawRectangle(x, y, w, h, self.m_Color)

	-- Center the text
	x = x + 4
	w = w - 8
	dxDrawText(self.m_Text, x, y, x + w, y + h, tocolor(255, 255, 255, self.m_Alpha), self.m_FontSize, self.m_Font, "left", "top", false, true)
end

function HTTPMinimalDownloadGUI:updateText(...)
	self:setText(...)

	local w, h = self:getSize()
	self:setSize(w, textHeight(self.m_Text, w - 8, self.m_Font, self.m_FontSize) + 4)
	MessageBoxManager.resortPositions()
end

function HTTPMinimalDownloadGUI:setCurrentFile(file)
	if file:sub(-9, #file) == "index.xml" then
		return
	else
		self:updateText(("Custom Textur wird geladen...\nTextur: %s"):format(file))
	end
end

function HTTPMinimalDownloadGUI:markAsFailed(reason)
	self.m_Failed = true
	self:updateText(("Download-Error: %s"):format(reason))
	self:setColorRGB(125, 0, 0, 200)
end

function HTTPMinimalDownloadGUI:setStatus(status, arg)
	if status == "failed" then
		self:markAsFailed(arg)
	elseif status == "current file" then
		self:setCurrentFile(arg)
	elseif status == "waiting" then
		self:setColorRGB(0, 125, 0, 200)
		self:updateText(arg)
	end
end
