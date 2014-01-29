DownloadGUI = inherit(Singleton)
inherit(GUIForm, DownloadGUI)

function DownloadGUI:constructor()
	local sw, sh = guiGetScreenSize()
	GUIForm.constructor(self, 0, 0, sw, sh)
	
	outputDebug("show some loading bar pls")
end

function DownloadGUI:onProgress(p)
	outputDebug("Progress is now "..tostring(p))
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
end