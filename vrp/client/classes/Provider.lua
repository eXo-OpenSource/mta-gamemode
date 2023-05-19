Provider = inherit(Singleton)
addEvent("onDownloadStart", true)
addEvent("onDownloadStop", true)
addEvent("onDownloadProgressUpdate", true)


function Provider:constructor()
	addEventHandler("onDownloadStop", resourceRoot, bind(Provider.onDownloadFinish, self))
	addEventHandler("onDownloadProgressUpdate", resourceRoot, bind(Provider.onDownloadProgressUpdate, self))

	self.m_RequestedFiles = {}
end

function Provider:addFileToRequest(filename)
	local hash = ""
	if fileExists(filename) then
		local fh = fileOpen(filename)
		hash = md5(fileRead(fh, fileGetSize(fh)))
		fileClose(fh)
	end

	self.m_RequestedFiles[filename] = hash
end

function Provider:requestFiles(onComplete, onUpdate, onWrite)
	self.m_OnComplete = onComplete
	self.m_OnUpdate = onUpdate
	self.m_OnWrite = onWrite
	triggerServerEvent("onClientRequestFile", resourceRoot, self.m_RequestedFiles)
end

function Provider:onDownloadFinish(files, filesNotToDownload)
	local st = getTickCount()

	for _, file in pairs(filesNotToDownload) do
		if self.m_RequestedFiles[file] then
			self.m_RequestedFiles[file] = nil
		end
	end

	for _, file in pairs(files) do
		if fileExists(file.path) then
			fileDelete(file.path)
		end

		local fh = fileCreate(file.path)
		fileWrite(fh, file.data)
		fileClose(fh)

		self.m_RequestedFiles[file.path] = nil

		if self.m_OnWrite then self.m_OnWrite(table.size(self.m_RequestedFiles)) end
	end

	outputDebug(("Create %s files in %.1dms"):format(#files, getTickCount() - st))

	if table.size(self.m_RequestedFiles) == 0 then
		if self.m_OnComplete then self.m_OnComplete() end
	end
end

function Provider:onDownloadProgressUpdate(progress, totalSize, fileCount)
	if self.m_OnUpdate then
		self.m_OnUpdate(progress, totalSize)
	end

	if progress == 100 and fileCount > 0 then
		if self.m_OnWrite then
			self.m_OnWrite(fileCount)
		end
	end
end
