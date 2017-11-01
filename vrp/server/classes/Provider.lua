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
	for k, v in pairs(self.m_ActiveDL) do
		local player = v.player
		if isElement(player) then
			local handle = v.handle
			local status = getLatentEventStatus(player, handle)
			if status and status.percentComplete < 100 then
				triggerClientEvent(player, "onDownloadProgressUpdate", resourceRoot, status.percentComplete, status.totalSize)
			elseif status then
				triggerClientEvent(player, "onDownloadProgressUpdate", resourceRoot, 100, status.totalSize)
			else
				self.m_ActiveDL[k] = nil
			end
		end
	end
	self.m_RefreshProgress = setTimer(bind(Provider.refreshProgress, self), 50, 1)
end

function Provider:offerFile(path)
	assert(fileExists(path))
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
	local clientFiles = {}

	for _, file in pairs(files) do
		if not self.m_Files[file.path] then
			-- Client requests something which it shouldn't be able to get
			return
		end

		if self.m_Files[file.path].md5 ~= file.md5 then
			table.insert(clientFiles, self.m_Files[file.path])
		end
	end

	triggerLatentClientEvent(client, "onDownloadStop", DOWNLOAD_SPEED, resourceRoot, clientFiles)

	local id = #self.m_ActiveDL+1
	local evhandles = getLatentEventHandles(client)
	self.m_ActiveDL[id] = { player = client, handle = evhandles[#evhandles]}
end
