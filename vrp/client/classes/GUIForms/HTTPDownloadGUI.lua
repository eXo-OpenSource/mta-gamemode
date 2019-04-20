HTTPDownloadGUI = inherit(GUIForm)
inherit(Singleton, HTTPDownloadGUI)

function HTTPDownloadGUI:constructor()
	self.m_Failed = false
	self.m_FileCount = 0
	self.m_CurrentFile = 0

	GUIForm.constructor(self, 0, 0, screenWidth, screenHeight)
	self.m_Logo = GUIImage:new(screenWidth/2 - 350/2, screenHeight/2 - 200/2 - 120, 350, 167, "files/images/Logo.png", self)
	self.m_Text = GUILabel:new(0, screenHeight - 150 - 60/2, screenWidth, 60, "Lade Dateien herunter...", self):setAlignX("center")
	self.m_DownloadBar = GUIProgressBar:new(screenWidth/6, screenHeight - 75 - 25/2, screenWidth - screenWidth/3, 25, self)
	if core:get("Login", "LoginMusic", true) then
		self.m_MusicText = GUILabel:new(0, screenHeight - 30, screenWidth, 30, "Drücke 'm', um die Musik zu stoppen!", self):setAlignX("center")
	else
		self.m_MusicText = GUILabel:new(0, screenHeight - 30, screenWidth, 30, "Drücke 'm', um die Musik zu starten!", self):setAlignX("center")
	end

	fadeCamera(false, 0.1)
	self:launchMusic()
end

function HTTPDownloadGUI:virtual_destructor()
	if self.m_Music and isElement(self.m_Music) then
		stopSound(self.m_Music)
	end

	fadeCamera(true)
end

function HTTPDownloadGUI:launchMusic()
	if not self:isVisible() then return end
	if core:get("Login", "LoginMusic", true) then
		self.m_Music = playSound(INGAME_WEB_PATH .. "/ingame/DownloadMusic.mp3", true)
		self.m_Music:setVolume(0.3)
	end
	self.m_StopMusicFunc = function()
		if self.m_Music then
			destroyElement(self.m_Music)
			self.m_Music = nil
			self.m_MusicText:setText("Drücke 'm', um die Musik zu starten!")
			core:set("Login", "LoginMusic", false)
			self:bind("m", self.m_StartMusicFunc)
		end
	end
	self.m_StartMusicFunc = function()
		if not self.m_Music then
			self.m_Music = playSound(INGAME_WEB_PATH .. "/ingame/DownloadMusic.mp3", true)
			self.m_Music:setVolume(0.3)
			self.m_MusicText:setText("Drücke 'm', um die Musik zu stoppen!")
			core:set("Login", "LoginMusic", true)
			self:bind("m", self.m_StopMusicFunc)
		end
	end
	if core:get("Login", "LoginMusic", true) then
		self:bind("m", self.m_StopMusicFunc)
	else
		self:bind("m", self.m_StartMusicFunc)
	end
end

function HTTPDownloadGUI:setStateText(text)
	self.m_DownloadBar:setText(text)
end

function HTTPDownloadGUI:setCurrentFile(file)
	if file:sub(-9, #file) == "index.xml" then
		self:setStateText("Lade Dateiliste herunter")
	else
		self:setStateText(("%d von %d Dateien heruntergeladen. Aktuelle Datei: %s"):format(self.m_CurrentFile, self.m_FileCount, file))
		self.m_DownloadBar:setProgress(100/self.m_FileCount*self.m_CurrentFile)
		self.m_CurrentFile = self.m_CurrentFile + 1
	end
end

function HTTPDownloadGUI:markAsFailed(reason)
	self.m_Failed = true
	self:setStateText(("Beim Herunterladen ist ein Fehler aufgetreten: %s (Bitte versuche es später erneut oder kontaktiere einen Admin)"):format(reason))
	self.m_DownloadBar:setBackgroundColor(tocolor(125, 0, 0, 255))
end

function HTTPDownloadGUI:setStatus(status, arg)
	if status == "failed" then
		self:markAsFailed(arg)
	elseif status == "file count" then
		self.m_FileCount = arg
	elseif status == "current file" then
		self:setCurrentFile(arg)
	elseif status == "unpacking" then
		self:setStateText(arg)
		--self.m_DownloadBar:setBackgroundColor(tocolor(0, 125, 0, 255))
		self.m_Text:setText("Entpacke Archive...")
	elseif status == "waiting" then
		--self.m_DownloadBar:setBackgroundColor(tocolor(0, 125, 0, 255))
		self:setStateText(arg)
		--self.m_Text:setText("")
	end
end
