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
local DOWNLOAD_SIZE = 90 * 1024 * 1024 -- 100MB, Max size per latent client event

function Provider:constructor()
	addEventHandler("onClientRequestFile", resourceRoot, bind(Provider.onClientRequestFile, self))

	self.m_Files = {}
	self.m_ActiveDL = {}

	self.m_RefreshProgress = setTimer(bind(Provider.refreshProgress, self), 50, 1)
end

function Provider:destructor()
	killTimer(self.m_RefreshProgress)
end

function Provider:refreshProgress()
	for k, download in pairs(self.m_ActiveDL) do
		local player = download.player
		if isElement(player) then
			local handle, complete = self:getActiveDownloadHandle(player, download.handles)
			if handle then
				local status = getLatentEventStatus(player, handle)
				local percentComplete = (status.percentComplete + (complete*100)) / download.downloads

				triggerClientEvent(player, "onDownloadProgressUpdate", resourceRoot, percentComplete, download.downloadSize, download.fileCount)
			else
				triggerClientEvent(player, "onDownloadProgressUpdate", resourceRoot, 100, download.downloadSize, download.fileCount)
				self.m_ActiveDL[k] = nil
			end
		end
	end
	self.m_RefreshProgress = setTimer(bind(Provider.refreshProgress, self), 50, 1)
end

function Provider:offerFile(path)
	assert(fileExists(path), path.." does not exist")
	local fh = fileOpen(path)

	self.m_Files[path] = {
		path = path,
		data = fileRead(fh, fileGetSize(fh));
		size = fileGetSize(fh);
	}

	fileClose(fh)
	self.m_Files[path].md5 = md5(self.m_Files[path].data)
end

function Provider:onClientRequestFile(files)
	local clientFiles = { [1] = {} }
	local filesNotToDownload = {}
	local downloadPartSize = 0
	local downloadSize = 0
	local fileCount = 0

	for file, md5 in pairs(files) do
		if not self.m_Files[file] then
			-- Client requests something which it shouldn't be able to get
			return
		end

		if self.m_Files[file].md5 == md5 then
			table.insert(filesNotToDownload, file)
		else
			downloadPartSize = downloadPartSize + self.m_Files[file].size
			downloadSize = downloadSize + self.m_Files[file].size
			fileCount = fileCount + 1

			if downloadPartSize > DOWNLOAD_SIZE then
				downloadPartSize = self.m_Files[file].size
				clientFiles[#clientFiles + 1] = {}
			end

			table.insert(clientFiles[#clientFiles], self.m_Files[file])
		end
	end

	for _, downloadFiles in pairs(clientFiles) do
		triggerLatentClientEvent(client, "onDownloadStop", DOWNLOAD_SPEED, resourceRoot, downloadFiles, filesNotToDownload)
	end

	local id = #self.m_ActiveDL+1
	local evhandles = getLatentEventHandles(client)
	self.m_ActiveDL[id] = {player = client, handles = evhandles, downloads = #evhandles, downloadSize = downloadSize, fileCount = fileCount}
end

function Provider:getActiveDownloadHandle(player, handles)
	local complete = 0
	local active = false
	for k, v in pairs(handles) do
		local status = getLatentEventStatus(player, v)
		if not status then 
			complete = complete + 1
		else
			active = v
			break
		end
	end

	return active, complete
end
