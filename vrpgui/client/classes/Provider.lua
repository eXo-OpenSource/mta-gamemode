Provider = inherit(Singleton)
addEvent("onDownloadStart", true)
addEvent("onDownloadStop", true)
addEvent("onDownloadProgressUpdate", true)


function Provider:constructor()
	addEventHandler("onDownloadStart", resourceRoot, bind(Provider.onDownloadStart, self))
	addEventHandler("onDownloadStop", resourceRoot, bind(Provider.onDownloadFinish, self))
	addEventHandler("onDownloadProgressUpdate", resourceRoot, bind(Provider.onDownloadProgressUpdate, self))
	
	self.m_Files = {}
	self.m_RequestedFiles = {}
end

function Provider:requestFile(filename, onComplete, onProgress)
	self.m_RequestedFiles[filename] = { onComplete = onComplete; onProgress = onProgress } or true
	local hash = ""
	if fileExists(filename) then
		local fh = fileOpen(filename)
		hash = md5(fileRead(fh, fileGetSize(fh)))
		fileClose(fh)
	end
	
	triggerServerEvent("onClientRequestFile", resourceRoot, filename, hash)
end

function Provider:onDownloadStart(id, path, md5, size)
	self.m_Files[id] = { path = path, md5 = md5, size = size }
end

function Provider:onDownloadFinish(id, data)
	if type(id) == "string" then
		if data == true then
			-- md5 was already correct
			self.m_RequestedFiles[id].onProgress(100)
			self.m_RequestedFiles[id].onComplete(id)
			self.m_RequestedFiles[id] = nil
			return
		end
	end
		
	local file = self.m_Files[id]
	if not file then 
		return 
	end
	
	if md5(data) ~= file.md5 then
		outputDebugString("bad md5")
		-- do something here
		return
	end
	
	if fileExists(file.path) then
		fileDelete(file.path)
	end
	local fh = fileCreate(file.path)
	fileWrite(fh, data)
	fileClose(fh)
	
	if type(self.m_RequestedFiles[file.path]) == "table" and self.m_RequestedFiles[file.path].onComplete then 
		self.m_RequestedFiles[file.path].onComplete(file.path)
		self.m_RequestedFiles[file.path] = nil
	end
	
	self.m_Files[id] = nil
end

function Provider:onDownloadProgressUpdate(id, progress)
	local file = self.m_Files[id]
	if not file then 
		return 
	end
	
	if type(self.m_RequestedFiles[file.path]) == "table" and self.m_RequestedFiles[file.path].onProgress then 
		self.m_RequestedFiles[file.path].onProgress(progress)
	end
end







