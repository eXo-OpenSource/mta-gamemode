-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Provider.lua
-- *  PURPOSE:     Custom resource files provider class
-- *
-- ****************************************************************************
Provider = inherit(Singleton)
addEvent("onClientRequestFile", true)
local DOWNLOAD_SPEED = 8 * 1024 * 1024 -- 8MiB/s

-- Unlimited speed if in debug mode
--if DEBUG then
	DOWNLOAD_SPEED = 1000000000000
--end

function Provider:constructor()
	addEventHandler("onClientRequestFile", resourceRoot, bind(Provider.onClientRequestFile, self))

	self.m_Files = {}
	self.m_ActiveDL = {}

	self.m_RefreshProgress = setTimer(bind(Provider.refreshProgress, self), 500, 1)
end

function Provider:destructor()
	killTimer(self.m_RefreshProgress)
end

function Provider:refreshProgress()
	for k, v in pairs(self.m_ActiveDL) do
		local player = v.player
		if isElement(player) then
			local handle = v.handle
			local status = getLatentEventStatus(player, handle)

			if status and status.percentComplete < 100 then
				triggerClientEvent(player, "onDownloadProgressUpdate", resourceRoot, k, status.percentComplete)
			else
				self.m_ActiveDL[k] = nil
				triggerClientEvent(player, "onDownloadStop", resourceRoot, v.filename, true)
			end
		end
	end

	self.m_RefreshProgress = setTimer(bind(Provider.refreshProgress, self), 500, 1)
end

function Provider:offerFile(path)
	assert(fileExists(path))

	local fh = fileOpen(path)

	self.m_Files[path] = {
		data = fileRead(fh, fileGetSize(fh));
		size = fileGetSize(fh);
	}
	fileClose(fh)
	self.m_Files[path].md5 = md5(self.m_Files[path].data)
end

function Provider:onClientRequestFile(filename, hash)
	if not self.m_Files[filename] then
		-- Client requests something which it shouldn't be able to get
		return
	end

	if hash == self.m_Files[filename].md5 then
		triggerClientEvent(client, "onDownloadStop", resourceRoot, filename, true)
		return
	end

	local id = #self.m_ActiveDL+1
	triggerLatentClientEvent(client, "onDownloadStop", DOWNLOAD_SPEED, resourceRoot, id, self.m_Files[filename].data)
	local evhandles = getLatentEventHandles(client)
	self.m_ActiveDL[id] = { player = client, handle = evhandles[#evhandles], filename = filename}
	triggerClientEvent(client, "onDownloadStart", resourceRoot, id, filename, self.m_Files[filename].md5, self.m_Files[filename].size)
end
