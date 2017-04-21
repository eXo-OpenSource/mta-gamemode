HTTPProvider = inherit(Object)

function HTTPProvider:constructor(url, dgi)
	self.ms_URL = url
	self.ms_GUIInstance = dgi
end

--[[
	index.xml structure
	<files>
		<file
			name="Texture1"
			path="files/folder1/Texture1.png" (Path on the http server to the file)
			target_path = "textures/texture1.png" (Path on the client where the file should get saved)
		/>
	</files>
]]

function HTTPProvider:start(force)
	-- request url access for download
	if self:requestAccessAsync() then
		self.ms_GUIInstance:setStatus("current file", self.ms_URL.."index.xml")
		outputDebug(self.ms_URL.."index.xml")
		local responseData, errno = self:fetchAsync("index.xml")
		if errno ~= 0 then
			outputDebug(errno)
			self.ms_GUIInstance:setStatus("failed", ("Error #%d"):format(errno))
			return false
		end

		outputDebug(responseData)
		if responseData ~= "" then
			local tempFile = fileCreate("files.tmp")
			tempFile:write(responseData)
			tempFile:close()

			local xml = xmlLoadFile("files.tmp")
			local files = {}
			for k, v in pairs(xmlNodeGetChildren(xml)) do
				if xmlNodeGetName(v) == "file" then
					--files[#files+1] = {name = xmlNodeGetAttribute(v, "name"), path = xmlNodeGetAttribute(v, "path"), target_path = xmlNodeGetAttribute(v, "target_path")}
					--outputTable(files[#files])
					local filePath = xmlNodeGetAttribute(v, "target_path")
					local expectedHash = xmlNodeGetAttribute(v, "hash")
					local forceFileDownload = false
					if fileExists(filePath) and expectedHash ~= nil then
						outputDebug("checking file hash")
						local file = fileOpen(filePath, true)
						if file then
							if force then
								forceFileDownload = true
							else
								if hash("md5", file:read(file:getSize())) ~= expectedHash then
									forceFileDownload = true
								end
								fileClose(file)
							end
						else
							forceFileDownload = true
						end
					else
						forceFileDownload = true
					end

					if forceFileDownload then
						files[#files+1] = {name = xmlNodeGetAttribute(v, "name"), path = xmlNodeGetAttribute(v, "path"), target_path = xmlNodeGetAttribute(v, "target_path")}
					end
				end
			end
			xmlUnloadFile(xml)

			self.ms_GUIInstance:setStatus("file count", table.getn(files))

			local archives = {}
			for i, v in ipairs(files) do
				self.ms_GUIInstance:setStatus("current file", v.path)
				outputDebug(v.path)
				local responseData, errno = self:fetchAsync(v.path)
				if errno ~= 0 then
					outputDebug(errno)
					self.ms_GUIInstance:setStatus("failed", ("Error #%d"):format(errno))
					return false
				end

				if responseData ~= "" then
					local filePath = v.target_path
					if v.target_path:sub(-4, #v.target_path) == ".tar" then
						archives[#archives+1] = filePath
					end
					if fileExists(filePath) then
						fileDelete(filePath)
					end
					local file = fileCreate(filePath)
					if file then
						file:write(responseData)
						file:close()
					end
					-- continue
				else
					self.ms_GUIInstance:setStatus("ignored", ("Empty file %s"):format(v.path))
					-- continue
				end
			end

			for i, path in ipairs(archives) do
				outputConsole("unpacking: "..path)
				self.ms_GUIInstance:setStatus("unpacking", ("all files have been downloaded. unpacking now the archives... (%d / %d archives)"):format(i, table.getn(files)))
				local status, err = untar(path, "/")
				if not status then
					self.ms_GUIInstance:setStatus("failed", ("Failed to unpack archive %s! (Error: %s)"):format(path, err))

					for i, path in ipairs(archives) do
						fileDelete(path)
					end
					return false
				end
			end

			-- remove temp file
			fileDelete("files.tmp")

			-- success
			return true
		else
			self.ms_GUIInstance:setStatus("failed", "Got empty index file!")
			return false
		end
	else
		self.ms_GUIInstance:setStatus("failed", "Cannot access download-server! (User-Access denied)")
		return false
	end
end

function HTTPProvider:startCustom(fileName, targetPath, encryptKey)
	-- request url access for download
	if self:requestAccessAsync() then
		self.ms_GUIInstance:setStatus("file count", 1)
		self.ms_GUIInstance:setStatus("current file", fileName)
		outputDebug(fileName)
		local responseData, errno = self:fetchAsync(fileName)
		if errno ~= 0 then
			outputDebug(errno)
			self.ms_GUIInstance:setStatus("failed", ("Error #%d"):format(errno))
			return false
		end

		if responseData ~= "" then
			local filePath = ("%s/%s.texture"):format(targetPath, fileName)
			if fileExists(filePath) then
				fileDelete(filePath)
			end
			local file = fileCreate(filePath)
			if file then
				if encryptKey then
					file:write(teaEncode(responseData, encryptKey))
				else
					file:write(responseData)
				end
				file:setPos(file:getSize())
				file:close()
			end

			-- success
			return true
		else
			self.ms_GUIInstance:setStatus("ignored", ("Empty file %s"):format(fileName))
		end
	else
		self.ms_GUIInstance:setStatus("failed", "Cannot access download-server! (User-Access denied)")
		return false
	end
end

function HTTPProvider:fetch(callback, file)
    return fetchRemote(("%s/%s"):format(self.ms_URL, file), HTTP_CONNECT_ATTEMPTS,
        function(responseData, errno)
            callback(responseData, errno)
        end
    )
end

function HTTPProvider:fetchAsync(...)
	self:fetch(Async.waitFor(), ...)
	return Async.wait()
end

function HTTPProvider:requestAccess(callback)
	self.ms_GUIInstance:setStatus("waiting", "Please accept the prompt, to download the required files!")

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
