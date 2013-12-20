-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Version.lua
-- *  PURPOSE:     Version information class
-- *
-- ****************************************************************************
Version = inherit(Singleton)

function Version:constructor()
	self.m_VersionString = VERSION_LABEL

	self.m_VersionLabel = guiCreateLabel(screenWidth - 255, screenHeight - 30, 250, 18, self.m_VersionString, false)
	guiSetAlpha(self.m_VersionLabel, 0.8)
	guiLabelSetHorizontalAlign(self.m_VersionLabel, "right")
	
	-- Wait till svnupdate has been started
	setTimer(
		function()
			local resource = getResourceFromName("svnupdate")
			if resource then
				self:setRevision(call(resource, "getRevision"))
			end
		end, 2000, 1
	)
end

function Version:getVersion()
	return self.m_VersionString
end

function Version:setVersion(versionString)
	self.m_VersionString = versionString
	guiSetText(self.m_VersionLabel, self.m_VersionString)
end

function Version:setRevision(rev)
	REVISION = rev

	if BUILD == "development" then
		VERSION_LABEL = ("%s %sdev r%d"):format(PROJECT_NAME, VERSION, REVISION)
	elseif BUILD == "unstable" then
		VERSION_LABEL = ("%s %s unstable"):format(PROJECT_NAME, VERSION)
	else
		VERSION_LABEL = ("%s %s"):format(PROJECT_NAME, VERSION)
	end
	
	self:setVersion(VERSION_LABEL)
end
