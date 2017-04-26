HTTPMinimalDownloadGUI = inherit(GUIForm)
inherit(Singleton, HTTPMinimalDownloadGUI)

function HTTPMinimalDownloadGUI:constructor()
	self.m_Failed = false
	self.m_FileCount = 0
	self.m_CurrentFile = 0

	GUIForm.constructor(self, 20, screenHeight-30*screenHeight/900, 340*screenWidth/1600+6, 25*screenHeight/900)
	self.m_DownloadBar = GUIRectangle:new(0, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 150), self)
	self.m_CurrentState = GUILabel:new(self.m_Width*0.1, 0, self.m_Width*0.9, self.m_Height*0.7, "Textur wird geladen ()", self)
	self.m_RefreshCircle = GUILabel:new(0, 0, self.m_Width*0.1, self.m_Height, FontAwesomeSymbols.Refresh, self):setFont(FontAwesome(15))
	self.m_RefreshCircle:setAlignX("center")
	self.m_RefreshCircle:setAlignY("center")
	self.m_CurrentState:setFont(FontAwesome(20))

	self.m_Rotate = bind(self.rotateCircle, self)
	addEventHandler("onClientPreRender", root, self.m_Rotate)
end

function HTTPMinimalDownloadGUI:destructor()
	GUIForm.destructor(self)
	removeEventHandler("onClientPreRender", root, self.m_Rotate)
end

function HTTPMinimalDownloadGUI:rotateCircle()
	self.m_RefreshCircle:setRotation(self.m_RefreshCircle:getRotation()+1)
end

function HTTPMinimalDownloadGUI:setStateText(text)
	self.m_CurrentState:setText(text)
end

function HTTPMinimalDownloadGUI:setCurrentFile(file)
	if file:sub(-9, #file) == "index.xml" then
		self:setStateText("downloading file-index")
	else
		self:setStateText(("Textur wird geladen (%s)"):format(file))
		self.m_CurrentFile = self.m_CurrentFile + 1
	end
end

function HTTPMinimalDownloadGUI:markAsFailed(reason)
	self.m_Failed = true
	self:setStateText(("Error: %s"):format(reason))
	self.m_DownloadBar:setColor(tocolor(125, 0, 0, 255))
end

function HTTPMinimalDownloadGUI:setStatus(status, arg)
	if status == "failed" then
		self:markAsFailed(arg)
	elseif status == "file count" then
		self.m_FileCount = arg
	elseif status == "current file" then
		self:setCurrentFile(arg)
	elseif status == "unpacking" then
		self:setStateText(arg)
		self.m_DownloadBar:setColor(tocolor(0, 125, 0, 255))
	elseif status == "waiting" then
		self.m_DownloadBar:setColor(tocolor(0, 125, 0, 255))
		self:setStateText(arg)
	end
end
