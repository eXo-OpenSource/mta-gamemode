Provider = inherit(Singleton)
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

	table.insert(self.m_RequestedFiles, {path = filename, md5 = hash})
end

function Provider:requestFiles(onComplete, onUpdate)
	self.m_OnComplete = onComplete
	self.m_OnUpdate = onUpdate
	triggerServerEvent("onClientRequestFile", resourceRoot, self.m_RequestedFiles)
end

function Provider:onDownloadFinish(files)
	local st = getTickCount()
	
	for _, file in pairs(files) do
		if fileExists(file.path) then
			fileDelete(file.path)
		end

		local fh = fileCreate(file.path)
		fileWrite(fh, file.data)
		fileClose(fh)
	end

	outputDebug(("Create %s files in %.1dms"):format(#files, getTickCount() - st))

	self.m_RequestedFiles = {}
	if self.m_OnComplete then self.m_OnComplete() end
end

function Provider:onDownloadProgressUpdate(progress, totalSize)
	if self.m_OnUpdate then
		self.m_OnUpdate(progress, totalSize)
	end
end
