HTTPDownloadGUI = inherit(GUIForm)
inherit(Singleton, HTTPDownloadGUI)

function HTTPDownloadGUI:constructor()
	self.m_Failed = false
	self.m_FileCount = 0
	self.m_CurrentFile = 0

	GUIForm.constructor(self, 0, 0, screenWidth, screenHeight)
	self.m_Logo = GUIImage:new(screenWidth/2 - 350/2, screenHeight/2 - 200/2 - 120, 350, 167, "files/images/Logo.png", self)
	self.m_Text = GUILabel:new(0, screenHeight/2 - 150/2 + 50, screenWidth, 50, "Bitte warte, bis die erforderlichen Spielinhalte bereit sind...", self):setAlignX("center"):setFont(VRPFont(40))
	if screenWidth < 1024 then
		self.m_ResolutionWarning = GUILabel:new(0, screenHeight - 200, screenWidth, 20, "Bitte erhöhe deine Auflösung, um Darstellungsfehler zu vermeiden!", self):setAlignX("center"):setFont(VRPFont(30)):setColor(Color.Red)
	end
	self.m_CurrentState = GUILabel:new(0, screenHeight/2 - 150/2 + 150, screenWidth, 50, "", self):setAlignX("center"):setFont(VRPFont(30))
	self.m_MusicText = GUILabel:new(0, screenHeight - 30, screenWidth, 30, "Drücke 'm', um die Musik zu stoppen!", self):setAlignX("center")
	self.m_ProgressBar = GUIProgressBar:new(screenWidth/2 - 500/2, screenHeight/2 - 150/2 + 110, 500, 30, self)
end

function HTTPDownloadGUI:destructor()

end

function DownloadGUI:setStateText(text)
	self.m_CurrentState:setText(text)
end

function HTTPDownloadGUI:setCurrentFile(file)
	if file == "index.xml" then
		self:setStatus("Lade Datei-Index: index.xml...")
	else
		self.m_CurrentFile = self.m_CurrentFile + 1
		self:setStatus(("Lade Datei: %s... (%d/%d)"):format(file, self.m_CurrentFile, self.m_FileCount))
		self.m_ProgressBar:setProgress((self.m_CurrentFile/self.m_FileCount)*100)
	end
end

function HTTPDownloadGUI:markAsFailed(reason)
	self.m_Failed = true
	self:setStateText(("A error occured while download: %s"):format(reason))
end

function HTTPDownloadGUI:setStatus(status, arg)
	if status == "failed" then
		self:markAsFailed(arg)
	elseif status == "file count" then
		self.m_FileCount = arg
	elseif status == "current file" then
		self:setCurrentFile(arg)
	end
end
