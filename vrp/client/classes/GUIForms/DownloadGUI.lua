DownloadGUI = inherit(GUIForm)
inherit(Singleton, DownloadGUI)

function DownloadGUI:constructor()
	GUIForm.constructor(self, 0, 0, screenWidth, screenHeight)

	self.m_Logo = GUIImage:new(screenWidth/2 - 350/2, screenHeight/2 - 200/2 - 120, 350, 200, "files/images/Logo.png", self)
	self.m_Text = GUILabel:new(0, screenHeight/2 - 150/2 + 50, screenWidth, 50, "Bitte warte, bis die erforderlichen Spielinhalte bereit sind...", self):setAlignX("center"):setFont(VRPFont(40))
	if screenWidth < 1024 then
		self.m_ResolutionWarning = GUILabel:new(0, screenHeight - 200, screenWidth, 20, "Bitte erhöhe deine Auflösung, um Darstellungsfehler zu vermeiden!", self):setAlignX("center"):setFont(VRPFont(30)):setColor(Color.Red)
	end
	self.m_CurrentState = GUILabel:new(0, screenHeight/2 - 150/2 + 150, screenWidth, 50, "", self):setAlignX("center"):setFont(VRPFont(30))
	self.m_MusicText = GUILabel:new(0, screenHeight - 30, screenWidth, 30, "Drücke 'm', um die Musik zu stoppen!", self):setAlignX("center")
	self.m_ProgressBar = GUIProgressBar:new(screenWidth/2 - 500/2, screenHeight/2 - 150/2 + 110, 500, 30, self)

	fadeCamera(false) -- freeroam hack | todo: Remove when freeroam is no longer required
	self:setStateText("Lade Datenarchiv: exo.data...")

	setTimer(bind(DownloadGUI.launchMusic, self), 150, 1)
end

function DownloadGUI:launchMusic()
	if not self:isVisible() then return end
	self.m_Music = playSound("http://www.jusonex.net/public/saonline/downloadmusic.mp3", true)
	self.m_StopMusicFunc = function()
		if self.m_Music then
			destroyElement(self.m_Music)
			self.m_Music = nil
			self:bind("m", self.m_StartMusicFunc)
		end
	end
	self.m_StartMusicFunc = function()
		if not self.m_Music then
			self.m_Music = playSound("http://www.jusonex.net/public/saonline/downloadmusic.mp3", true)
			self:bind("m", self.m_StopMusicFunc)
		end
	end

	self:bind("m", self.m_StopMusicFunc)
end

function DownloadGUI:destructor()
	if self.m_Music and isElement(self.m_Music) then
		stopSound(self.m_Music)
	end

	GUIForm.destructor(self)
end

function DownloadGUI:onProgress(p, fullSize)
	self.m_ProgressBar:setProgress(tonumber(p) or 0)
	outputConsole("Progress: "..tostring(p))
	outputConsole("FullSize: "..tostring(fullSize))

	local downloadedSize = (tonumber(p) or 0)*(fullSize/100)
	self:setStateText(("Lade Datenarchiv: exo.data... (%.2fMB/%.2fMB)"):format(downloadedSize/1024/1024, fullSize/1024/1024))

	fadeCamera(false) -- freeroam hack | todo: Remove when freeroam is no longer required
end

function DownloadGUI:setStateText(text)
	self.m_CurrentState:setText(text)
end

function DownloadGUI:onComplete()
	Package.load("vrp.data")
	core:ready()
	fadeCamera(true)
	self:fadeOut(750)
	setTimer(
	function()
		delete(self)
		lgi = LoginGUI:new()
		lgi:setVisible(false)
		lgi:fadeIn(750)

		local pwhash = core:get("Login", "password", "")
		local username = core:get("Login", "username", "")
		lgi.m_LoginEditUser:setText(username)
		lgi.m_LoginEditPass:setText(pwhash)
		lgi.usePasswordHash = pwhash
		lgi.m_LoginCheckbox:setChecked(pwhash ~= "")
		lgi:anyChange()
	end, 800, 1)
end
