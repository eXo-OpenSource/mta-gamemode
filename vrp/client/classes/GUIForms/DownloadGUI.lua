DownloadGUI = inherit(GUIForm)
inherit(Singleton, DownloadGUI)

function DownloadGUI:constructor()
	GUIForm.constructor(self, 0, 0, screenWidth, screenHeight)

	self.m_Logo = GUIImage:new(screenWidth/2 - 350/2, screenHeight/2 - 200/2 - 120, 350, 167, "files/images/Logo.png", self)
	self.m_Text = GUILabel:new(0, screenHeight/2 - 150/2 + 50, screenWidth, 50, "Bitte warte, bis die erforderlichen Spielinhalte bereit sind...", self):setAlignX("center"):setFont(VRPFont(40))
	if screenWidth < 1024 then
		self.m_ResolutionWarning = GUILabel:new(0, screenHeight - 200, screenWidth, 20, "Bitte erhöhe deine Auflösung, um Darstellungsfehler zu vermeiden!", self):setAlignX("center"):setFont(VRPFont(30)):setColor(Color.Red)
	end
	self.m_MusicText = GUILabel:new(0, screenHeight - 30, screenWidth, 30, "Drücke 'm', um die Musik zu stoppen!", self):setAlignX("center")
	self.m_ProgressBar = GUIProgressBar:new(screenWidth/2 - 500/2, screenHeight/2 - 150/2 + 110, 500, 30, self)

	fadeCamera(false)
end

function DownloadGUI:destructor()
	GUIForm.destructor(self)
end

function DownloadGUI:onProgress(p, fullSize)
	self.m_ProgressBar:setProgress(tonumber(p) or 0)

	local downloadedSize = (tonumber(p) or 0)*(fullSize/100)
	self:setStateText(("%.2fMB / %.2fMB"):format(downloadedSize/1024/1024, fullSize/1024/1024))
end

function DownloadGUI:setStateText(text)
	self.m_ProgressBar:setText(text)
end

function DownloadGUI:onComplete()
	core:ready()
	fadeCamera(true)
	self:fadeOut(750)
	setTimer(
		function()
			self:setVisible(false)
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
		end,
	200, 1)
end
