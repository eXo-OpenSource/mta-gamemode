-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Version.lua
-- *  PURPOSE:     Version information class
-- *
-- ****************************************************************************
Version = inherit(Singleton)

function Version:constructor()
	self.m_VersionString = ("%s [%s]"):format(PROJECT_NAME, (GIT_VERSION or ""):sub(0, 7))

	-- Project name + git commit hash
	self.m_VersionLabel1 = guiCreateLabel(screenWidth - 255, screenHeight - 44, 250, 18, self.m_VersionString, false)
	guiSetAlpha(self.m_VersionLabel1, 0.53)
	guiLabelSetHorizontalAlign(self.m_VersionLabel1, "right")

	-- Git branch
	self.m_VersionLabel2 = guiCreateLabel(screenWidth - 255, screenHeight - 30, 250, 18, GIT_BRANCH or "master", false)
	guiSetAlpha(self.m_VersionLabel2, 0.53)
	guiLabelSetHorizontalAlign(self.m_VersionLabel2, "right")
end

function Version:getVersion()
	return self.m_VersionString
end
