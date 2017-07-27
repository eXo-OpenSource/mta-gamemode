-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Version.lua
-- *  PURPOSE:     Version information class
-- *
-- ****************************************************************************
Version = inherit(Singleton)

function Version:constructor()
	self.m_VersionString = ("%s %s"):format(PROJECT_NAME, PROJECT_VERSION)
	self.m_GitString = ("%s [%s]"):format(GIT_BRANCH or "master", (GIT_VERSION or ""):sub(0, 8))



	-- Project name + version
	self.m_VersionLabel2 = guiCreateLabel(screenWidth - 255, screenHeight - 30, 250, 18, self.m_VersionString, false)
	guiSetAlpha(self.m_VersionLabel2, 0.53)
	guiLabelSetHorizontalAlign(self.m_VersionLabel2, "right")

	-- Git branch + git commit hash
	if DEBUG then
		self.m_VersionLabel1 = guiCreateLabel(screenWidth - 255, screenHeight - 44, 250, 18, self.m_GitString, false)
		guiSetAlpha(self.m_VersionLabel1, 0.53)
		guiLabelSetHorizontalAlign(self.m_VersionLabel1, "right")
	end

	addCommandHandler("gitver", function()
		outputConsole(self.m_GitString)
	end)
end

function Version:getVersion()
	return self.m_VersionString
end