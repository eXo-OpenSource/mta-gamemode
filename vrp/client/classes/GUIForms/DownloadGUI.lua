﻿DownloadGUI = inherit(Singleton)
inherit(GUIForm, DownloadGUI)

function DownloadGUI:constructor()
	GUIForm.constructor(self, 0, 0, screenWidth, screenHeight)
	
	GUIImage:new(screenWidth/2 - 150/2, screenHeight/2 - 150/2 - 120, 150, 150, "files/images/Logo.png", self)
	GUILabel:new(0, screenHeight/2 - 150/2 + 50, screenWidth, 50, "Bitte warten, bis das Spielerlebnis geladen wurde...", 1, self):setAlignX("center"):setFont(VRPFont(40))
	if screenWidth < 1024 then
		GUILabel:new(0, screenHeight - 200, screenWidth, 20, "Bitte erhöhe deine Auflösung, um Darstellungsfehler zu vermeiden!", 1, self):setAlignX("center"):setFont(VRPFont(30)):setColor(Color.Red)
	end
	GUILabel:new(0, screenHeight - 30, screenWidth, 50, "Drücke 'm', um die Musik bei einer langsamen Internetverbindung zu stoppen!", 1, self):setAlignX("center"):setFont(VRPFont(20))
	self.m_ProgressBar = GUIProgressBar:new(screenWidth/2 - 500/2, screenHeight/2 - 150/2 + 110, 500, 30, self)
		
	fadeCamera(false) -- freeroam hack | todo: Remove when freeroam is no longer required
	
	setTimer(bind(DownloadGUI.launchMusic, self), 150, 1)
end

function DownloadGUI:launchMusic()
	if self ~= DownloadGUI:getSingleton() then return end
	self.m_Music = playSound("http://www.jusonex.net/public/saonline/downloadmusic.mp3", true)
	self.m_StopMusicFunc = function() if self.m_Music then destroyElement(self.m_Music) self.m_Music = nil end end
	self.m_StartMusicFunc = function() if not self.m_Music then self.m_Music = playSound("http://www.jusonex.net/public/saonline/downloadmusic.mp3", true) end end
	bindKey("m", "down", self.m_StopMusicFunc)
	bindKey("m", "down", self.m_StartMusicFunc)
end

function DownloadGUI:destructor()
	if self.m_Music and isElement(self.m_Music) then
		stopSound(self.m_Music)
	end
	unbindKey("m", "down", self.m_StopMusicFunc)
	unbindKey("m", "down", self.m_StartMusicFunc)
	
	GUIForm.destructor(self)
end

function DownloadGUI:onProgress(p)
	outputDebug("Progress is now "..tostring(p))
	self.m_ProgressBar:setProgress(tonumber(p) or 50)
	
	fadeCamera(false) -- freeroam hack | todo: Remove when freeroam is no longer required
end

function DownloadGUI:onComplete()
	Package.load("vrp.data")
	core:ready()

	lgi = LoginGUI:new()
	lgi:showHome(true)
	local pwhash = core:get("login", "password") or ""
	local username = core:get("login", "username") or ""
	lgi.m_LoginEditUsername:setText(username)
	lgi.m_LoginEditPassword:setText(pwhash)
	lgi.usePasswordHash = pwhash
	lgi.m_SaveLoginCheckbox:setChecked(pwhash ~= "")
	lgi:anyChange()
	
	delete(self)
end