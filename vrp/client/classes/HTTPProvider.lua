HTTPProvider = inherit(Object)

function HTTPProvider:constructor(url, dgi)
	self.ms_URL = url
	self.ms_GUIInstance = dgi
	self.m_FileList = Queue:new()
	self.m_Archives = Queue:new()
end

function HTTPProvider:addFile(fileNode)
	self.m_FileList:push({path = xmlNodeGetAttribute(fileNode, "path"), target_path = xmlNodeGetAttribute(fileNode, "target_path")})
end

function HTTPProvider:collectFiles()
	if self:requestAccessAsync() then
		local responseData, responseInfo = self:fetchAsync("index.xml")
		if not responseInfo["success"] == true then
			self.ms_GUIInstance:setStatus("failed", ("Error #%d"):format(responseInfo["statusCode"]))
			return false
		end

		if responseData ~= "" then
			local tempFile = fileCreate("index.tmp")
			tempFile:write(responseData)
			tempFile:close()

			local xml = xmlLoadFile("index.tmp")
			for _, archive in pairs(xmlNodeGetChildren(xml)) do
				if xmlNodeGetName(archive) == "archive" then
					if not self.checkFile(xmlNodeGetAttribute(archive, "target_path"), xmlNodeGetAttribute(archive, "hash")) then
						self:addFile(archive)
					else
						for _, file in pairs(xmlNodeGetChildren(archive)) do
							if xmlNodeGetName(file) == "file" then
								if not self.checkFile(xmlNodeGetAttribute(file, "target_path"), xmlNodeGetAttribute(file, "hash")) then
									self:addFile(file)
								end
							end
						end
					end
				end
			end
		end

		self.ms_GUIInstance:setStatus("file count", self.m_FileList:size())
		fileDelete("index.tmp")
	else
		self.ms_GUIInstance:setStatus("failed", "Cannot access download-server! (User-Access denied)")
		return false
	end
	return true
end

function HTTPProvider:downloadFiles()
	if self:requestAccessAsync() then
		while(not self.m_FileList:empty()) do
			local element = self.m_FileList:pop()
			self.ms_GUIInstance:setStatus("current file", element.path)
			outputDebug(element.path)
			local responseData, responseInfo = self:fetchAsync(element.path)
			if not responseInfo["success"] == true then
				outputDebug("HttpProvider Error: "..responseInfo["statusCode"])
				self.ms_GUIInstance:setStatus("failed", ("Error #%d"):format(responseInfo["statusCode"]))
				return false
			end

			if responseData ~= "" then
				local filePath = element.target_path
				if filePath:sub(-4, #filePath) == ".tar" then
					self.m_Archives:push(filePath)
				end
				if fileExists(filePath) then
					fileDelete(filePath)
				end
				local file = fileCreate(filePath)
				if file then
					file:write(responseData)
					file:close()
				end
			end
		end
	else
		self.ms_GUIInstance:setStatus("failed", "Cannot access download-server! (User-Access denied)")
		return false
	end
	return true
end

function HTTPProvider:processArchives()
	local size = self.m_Archives:size()
	while(not self.m_Archives:empty()) do
		self.ms_GUIInstance:setStatus("unpacking", ("all files have been downloaded. unpacking now the archives... (%d / %d archives)"):format(self.m_Archives:size(), size))
		local archive = self.m_Archives:pop()
		local status, err = untar(archive, "/")
		outputDebug(archive)
		if not status then
			self.ms_GUIInstance:setStatus("failed", ("Failed to unpack archive %s! (Error: %s)"):format(archive, err))
			return false
		end
	end
	return true
end

function HTTPProvider.checkFile(filePath, expectedHash)
	if fileExists(filePath) then
		local file = fileOpen(filePath)
		if file then
			if hash("md5", file:read(file:getSize())) == expectedHash then
				file:close()
				return true
			end
			file:close()
		end
	end
	return false
end

function HTTPProvider:start()
	local status = true
	self.ms_GUIInstance:setStatus("current file", self.ms_URL.."index.xml")
	status = self:collectFiles()
	if not status then
		return status
	end

	status = self:downloadFiles()
	if not status then
		return status
	end
	status = self:processArchives()
	if not status then
		return status
	end
	return status
end

function HTTPProvider:startCustom(fileName, targetPath, encrypt, raw)
	-- request url access for download
	if self:requestAccessAsync() then
		self.ms_GUIInstance:setStatus("file count", 1)
		self.ms_GUIInstance:setStatus("current file", fileName)
		outputDebug(fileName)
		local responseData, responseInfo = self:fetchAsync(fileName)
		if not responseInfo["success"] == true then
			outputDebug("HttpProvider Error: "..responseInfo["statusCode"])
			self.ms_GUIInstance:setStatus("failed", ("Error #%d"):format(responseInfo["statusCode"]))
			return false
		end

		if responseData ~= "" then
			local filePath = ("%s/%s%s"):format(targetPath, fileName, encrypt and ".texture" or "")
			if fileExists(filePath) then
				fileDelete(filePath)
			end
			local file = fileCreate(filePath)
			if file then
				if encrypt then
					file:write(base64Encode(responseData))
				else
					file:write(responseData)
				end
				file:setPos(file:getSize())
				file:close()
			end

			if raw then
				local pixelFile = fileCreate(("%s.pixels"):format(filePath))
				if pixelFile then
					local texture = DxTexture(filePath)
					pixelFile:write(texture:getPixels())
					texture:destroy()
					pixelFile:close()
				end
				fileDelete(filePath)
			end

			-- success
			return true
		else
			self.ms_GUIInstance:setStatus("ignored", ("Empty file %s"):format(fileName))
		end
	else
		self.ms_GUIInstance:setStatus("failed", "Kann den Download-Server nicht erreichen! (User-Access denied)")
		return false
	end
end

function HTTPProvider:fetch(callback, file)
    local options = {
		["connectionAttempts"] = HTTP_CONNECT_ATTEMPTS
	}
	return fetchRemote(("%s/%s"):format(self.ms_URL, file), options,
        function(responseData, responseInfo)
            callback(responseData, responseInfo)
        end
    )
end

function HTTPProvider:fetchAsync(...)
	self:fetch(Async.waitFor(), ...)
	return Async.wait()
end

function HTTPProvider:requestAccess(callback)
	self.ms_GUIInstance:setStatus("waiting", "Lädt...")

	if Browser.isDomainBlocked(self.ms_URL, true) then
		-- hack fix, requestDomains callback isnt working (so we cant detect a deny)
		addEventHandler("onClientBrowserWhitelistChange", root,
			function(domains)
				removeEventHandler( "onClientBrowserWhitelistChange", root, getThisFunction())
				callback(not Browser.isDomainBlocked(self.ms_URL, true))
			end
		)
		Browser.requestDomains({ self.ms_URL }, true)
	else
		nextframe(function () callback(true) end)
	end
end

function HTTPProvider:requestAccessAsync()
	self:requestAccess(Async.waitFor())
	return Async.wait()
end
